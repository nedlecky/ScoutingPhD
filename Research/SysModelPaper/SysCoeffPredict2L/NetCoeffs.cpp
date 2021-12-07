// NetCoeffs.cpp : Defines the entry point for the console application.
//
#include "stdafx.h"

#include "LEmatrix.h"
#include "LEneuralnet.h"
#include "LEsimulate.h"
#include <conio.h>
#include <math.h>

// Desired Trajectory
LEmatrix& ComputeXd(double t)
{
	static LEmatrix Xd("Xd",4,1);
	double slope = 0.2;

	// copy t into Xd[0]
	Xd[0][0]=t;

	if(t<1)
	{
		Xd[1][0]=0;
		Xd[2][0]=0;
		Xd[3][0]=0;
		return Xd;
	}
	if(t<10)
	{
		Xd[1][0]=1*sin(2*(t-1));
		Xd[2][0]=2*cos(2*(t-1));
		Xd[3][0]=-4*sin(2*(t-1));
		return Xd;
	}
	if(t<20)
	{
		Xd[1][0]=1*sin(2*(10-1)) + slope*(t-10);
		Xd[2][0]=slope;
		Xd[3][0]=0;
		return Xd;

	Xd[1][0]=1*sin(2*(10-1)) + slope*(20-10);
	}
	Xd[2][0]=0;
	Xd[3][0]=0;

	return Xd;
}

// 2nd Order System
double m=1;
double b=1;
double k=1;
double f=0;
void System(double x[],double xdot[])
{
	xdot[1] = x[2];
	xdot[2] = (f - b*x[2] - k*x[1])/m;
}

// 2 Layer NN, tanh layer1 linear layer2, V&Wtranspose
// Leaves output of layer 1 around in global z for training purposes
LEmatrix z("z");
LEmatrix& NN(LEmatrix& VT,LEmatrix& WT,LEmatrix& x)
{
	static LEmatrix y("y");
	z = leSigma(VT*x,LEAtanh);
	y = WT*z;
	return y;
}


int main(int argc, char* argv[])
{
	// number of NN training passes
	int nTrainingLoops=10;

	// Initial Plant Parameters
	b=5;
	k=5;
	m=10;

	// Simulation Parameters
	double t0=0;			// start time
	double tf=25;			// final time
	double dt=.01;			// integration timestep
	double updateFreq=100;	// control loop update frequency Hz
	
	// Computed Constants
	double updateDt=1/updateFreq;	// control loop update frequency Hz
	double critical_b=sqrt(4*m*k);

	// initial conditions; assume we start out on the desired trajectory
	LEmatrix Xd;
	Xd=ComputeXd(t0);
	LEmatrix x0("x0",2,1);
	x0[0][0]=Xd[1][0];	
	x0[1][0]=Xd[2][0];

	// Compute control coefficents to achieve critical damping
	// desired spring coeff of resulting controlled system
	double Kp=100;	// desired spring coeff of controlled system

	// compute necessary resulting bPrime to get critical damping
	double Kd=2*sqrt(Kp);
	printf("  Kp=%.3lf Kd=%.3lf\n",Kp,Kd);

	int n=3;	// number of inputs
	int m=2;	// number of outputs
	int L=2;	// neurons in hidden layer

	// layer 1 weights
	LEmatrix V("V",n+1,L);
	V.Randomize(-0.2,0.2);
	
	// layer 2 weights
	LEmatrix W("W",L+1,m);
	W.Randomize(-0.2,0.2);

	LEmatrix x("x",2,1);
	LEmatrix xnn("xnn",4,1);
	xnn[0][0]=1;
	LEmatrix yReal("yReal");
	LEmatrix yNN("yNN");

	double eta=0.01;
	int eMemoryLength=20;
	int eIndex=0;
	LEmatrix eMemory("eMemory",2,1);

	double t=t0;
	x=x0;

	LEmatrix result("result",1,3);
	result[0][0]=t;
	result[0][1]=x0[0][0];
	result[0][2]=x0[1][0];

	// define transpose matrices for speed
	LEmatrix VT("VT");
	VT=leTranspose(V);
	LEmatrix WT("WT");
	WT=leTranspose(W);

	// setup for training
	LEmatrix y("y");
	LEmatrix e("e");
	LEmatrix oldX("oldX");
	LEmatrix del1("del1");
	LEmatrix del2("del2");
	LEmatrix tmpmat("tmpmat");

	LEmatrix Iy("Iy");
	LEmatrix Iz("Iz");
	Iy=leIdentMat(m);
	Iz=leIdentMat(L+1);

	for(int train=0; train<nTrainingLoops; train++)
	{
	printf("Train %3d: ",train+1);
	t=t0;
	x=x0;
	result.SetSize(1,3);
	result[0][0]=t;
	result[0][1]=x0[0][0];
	result[0][2]=x0[1][0];
	int compE=0;
	while(t<tf)
	{
		// Controller Computations
		Xd=ComputeXd(t);

		// desired situation
		double x1d=Xd[1][0];  // pos
		double x2d=Xd[2][0];  // vel
		double x3d=Xd[3][0];  // acc

		// present situation
		double x1=x[0][0];
		double x2=x[1][0];
	
		// servo equation
		double fPrime = x3d + Kp*(x1d-x1) + Kd*(x2d-x2);

		// model equation
		f = fPrime*m + b*x2 + k*x1;

		// integrate us forward one update step
		oldX=x;
		LEmatrix stepResult;
		stepResult=leODErk4(System,t,t+updateDt,dt,x);
		
		// just keep the last row
		stepResult=leRow(stepResult,stepResult.Nrows()-1);
	
		// copy down new t,x (last row of integration results)
		t=stepResult[0][0];
		x[0][0]=stepResult[0][1];
		x[1][0]=stepResult[0][2];

		// append step integration results to entire result
		result.AppendRows(stepResult);

		// try doing the same with the nn
		xnn[1][0]=x1;
		xnn[2][0]=x2;
		xnn[3][0]=f;
		yNN=NN(VT,WT,xnn);

		e = x-oldX - yNN;

		// appropriate for linear output
		del2=e;

		// appropriate for tanh output
		//tmpmat=leDiag(y);
		//del2=(Iy-tmpmat*tmpmat)*e;

		// appropriate for tanh layer 1
		tmpmat=leDiag(z);
		del1=(Iz-tmpmat*tmpmat)*W*del2;

		// now, del1 has an extra 1 at the front.  Get rid of it
		for(int i=1; i<del1.Nrows(); i++) del1[i-1][0]=del1[i][0];
		del1.SetSize(del1.Nrows()-1,del1.Ncols());

		W = W + (z*leTranspose(del2)*eta);
		V = V + (xnn*leTranspose(del1)*eta);
		VT=leTranspose(V);
		WT=leTranspose(W);

		if(eIndex==eMemoryLength)
			eIndex=0;
		else
			if(eIndex>=eMemory.Ncols())
			{
				eMemory.SetSize(2,eIndex+1);
			}

		eMemory[0][eIndex]=e[0][0];
		eMemory[1][eIndex++]=e[1][0];

		if(++compE%50 == 0)
		{
			double E=leEcalc(eMemory);
			printf("%.3lf ",E);
		}
	}
	printf("\n");
	}

	result.Save("sim.csv");
	V.Print();

	// now run just from the NN
	t=t0;
	x=x0;

	result.SetSize(1,3);
	result[0][0]=t;
	result[0][1]=x0[0][0];
	result[0][2]=x0[1][0];

	while(t<tf)
	{
		// Controller Computations
		Xd=ComputeXd(t);

		// desired situation
		double x1d=Xd[1][0];  // pos
		double x2d=Xd[2][0];  // vel
		double x3d=Xd[3][0];  // acc

		// present situation
		double x1=x[0][0];
		double x2=x[1][0];
	
		// servo equation
		double fPrime = x3d + Kp*(x1d-x1) + Kd*(x2d-x2);

		// model equation
		f = fPrime*m + b*x2 + k*x1;

		// move us forward one update step
		xnn[1][0]=x1;
		xnn[2][0]=x2;
		xnn[3][0]=f;
		yNN=NN(VT,WT,xnn);

		// copy down new t,x (last row of integration results)
		t=t+updateDt;
		x[0][0] = x[0][0] + yNN[0][0];
		x[1][0] = x[1][0] + yNN[1][0];

		// append step integration results to entire result
		int r=result.Nrows();
		result.SetSize(r+1,3);
		result[r][0]=t;
		result[r][1]=yNN[0][0];
		result[r][2]=yNN[1][0];
	}
	result.Save("nnsim.csv");

	return 0;
}


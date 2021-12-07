// Simulation 3.15a Two Layer NN Controller 2-axis Robot
// Prof. J.E. (Ned) Lecky
// EE295A Spring 00: Introduction to Neural Control of Robotic Manipulators

#include "stdafx.h"
#include "..\util\LEsimulate.h"
#include "..\util\LEneuralnet.h"
#include <math.h>
#include <conio.h>
double pi=3.14159;

// 2 Layer NN, sigmoid layer1 linear layer2, V&Wtranspose
// Leaves output of layer 1 around in global z for training purposes
LEmatrix z("z");
LEmatrix& TwoLayerNN(LEmatrix& VT,LEmatrix& WT,LEmatrix& x)
{
	static LEmatrix y("y");
	z = leSigma(VT*x,LEAsigmoid);
	y = WT*z;
	return y;
}

//must modify
// Desired Trajectory
double amp1;
double amp2;
double fact;
LEmatrix& ComputeXd(double t)
{
	static LEmatrix Xd("Xd",6,1);

	t=fmod(t,20);

	if(t<5)
	{
		double sinf=sin(fact*5);
		double cosf=cos(fact*5);
		double v1 = amp1*sinf/5.;
		double v2 = amp2*cosf/5.;
		Xd[0][0] = v1*t;	Xd[1][0] = v2*t;
		Xd[2][0] = v1;		Xd[3][0] = v2;
		Xd[4][0] = 0;		Xd[5][0] = 0;
		return Xd;
	}

	if(t<14.75)
	{
		double sinf=sin(fact*t);
		double cosf=cos(fact*t);
		Xd[0][0] = amp1*sinf;
		Xd[1][0] = amp2*cosf;
		Xd[2][0] = fact*amp1*cosf;
		Xd[3][0] = -fact*amp2*sinf;
		Xd[4][0] = -fact*fact*Xd[0][0];
		Xd[5][0] = -fact*fact*Xd[1][0];
		return Xd;
	}

	if(1)
	{
		double sinf=sin(fact*14.75);
		double cosf=cos(fact*14.75);
		double v1 = -amp1*sinf/5.25;
		double v2 = -amp2*cosf/5.25;
		Xd[0][0] = amp1*sinf+v1*(t-14.75);
		Xd[1][0] = amp2*cosf+v2*(t-14.75);
		Xd[2][0] = v1;		Xd[3][0] = v2;
		Xd[4][0] = 0;		Xd[5][0] = 0;
		return Xd;
	}
}

//don't need
// 2-Link Planar Robot System
double m1,m2;
double a1,a2;
double g;
LEmatrix M("M",2,2);
LEmatrix Minv("Minv",2,2);
LEmatrix N("N",2,1);
LEmatrix T1("T1",2,1);
LEmatrix tau("tau",2,1);
void System(double x[],double xdot[])
{
	// x, xdot definitions
	//0  time
	//1  pos1 2  pos2
	//3  vel1 4  vel2

	// variable m2
	double m2_actual=m2;

	// Compute and invert current inertia matrix
	M[0][0]=(m1+m2_actual)*a1*a1 + m2_actual*a2*a2 + 2*m2_actual*a1*a2*cos(x[2]);
	M[0][1]=m2_actual*a2*a2 + m2_actual*a1*a2*cos(x[2]);
	M[1][0]=M[0][1];
	M[1][1]=m2_actual*a2*a2;
	Minv=leInvert(M);

	// Compute current nonlinear vector
	N[0][0]=-m2_actual*a1*a2*(2*x[3]*x[4] + x[4]*x[4])*sin(x[2]) +
		(m1+m2_actual)*g*a1*cos(x[1]) + m2_actual*g*a2*cos(x[1]+x[2]);
	N[1][0]=m2_actual*a1*a2*x[3]*x[3]*sin(x[2]) + m2_actual*g*a2*cos(x[1]+x[2]);

	// True acceleration
	T1=Minv*(tau-N);

	// System Equations
	xdot[1] = x[3];
	xdot[2] = x[4];
	xdot[3] = T1[0][0];
	xdot[4] = T1[1][0];
}

// Build real NN input composite
LEmatrix& MakeNNx(LEmatrix& e,LEmatrix& edot,LEmatrix& qd)
{
	static LEmatrix NNx("NNx");

	NNx.SetSize(1,1);
	NNx=1;
	NNx.AppendRows(e);
	NNx.AppendRows(edot);
	NNx.AppendRows(qd);

	return NNx;
}

int main(int argc, char* argv[])
{
	printf("Simulation 3.15a Two Layer NN Controller 2-axis\n");

//don't need
	// Robot Parameters
	m1=0.8;
	m2=2.3;
	a1=1;
	a2=1;
	g=9.8;

	// Desired Trajectory Parameters
	double period=2;
	amp1=0.1;
	amp2=0.1;
	fact=2*pi/period;

	// Simulation Parameters
	double t0=0;			// start time
	double tf=80;			// final time
	double dt=.01;			// integration timestep

	// Initial Conditions
	LEmatrix x0("x0",4,1);
	x0=0;

	// Desired Control Coefficients
	double updateFreq=100;
	LEmatrix Kv("Kv");
	LEmatrix lam("lam");
	Kv=20*leIdentMat(2);
	lam=5*leIdentMat(2);
	
	// Computed Constants
	double updateDt=1/updateFreq;	// control loop update frequency Hz

	LEmatrix stepResult;
	LEmatrix x("x");
	LEmatrix Xd("Xd");
	LEmatrix NNx("NNx");
	
	// error integration
	LEmatrix e("e",2,1);
	LEmatrix edot("edot",2,1);
	LEmatrix r("r",2,1); //r = edot + lam*e;

	// Initial result matrix with row of initial conditions
	LEmatrix result("result",(int)(tf/updateDt+1),x0.Nrows()+1);
	result.SetSize(1,x0.Nrows()+1);
	result[0][0]=t0;
	for(int i=0; i<x0.Nrows(); i++)
		result[0][i+1]=x0[i][0];

	// Setup V and W
	Xd=ComputeXd(0);
	NNx=MakeNNx(e,edot,Xd);
	int n=NNx.Nrows()-1;
	int L=10;
	int m=tau.Nrows();
	LEmatrix V("V",n+1,L);
	LEmatrix W("W",L+1,m);
	printf("n=%d L=%d m=%d\n",n,L,m);
	
	// Lewis Way
	V=0;
	W=0;
	
	// Alternative
	//V.Randomize(-1,1);
	//W.Randomize(-1,1);

	LEmatrix VT("VT");
	LEmatrix WT("WT");
	VT=leTranspose(V);
	WT=leTranspose(W);

	// NN Learning Rates
	double eta1=50*updateDt;
	double eta2=50*updateDt;

	tau=TwoLayerNN(VT,WT,NNx);
	LEmatrix Iz("Iz");
	Iz=leIdentMat(z.Nrows());

	LEmatrix del1("del1");
	LEmatrix del2("del2");
	LEmatrix tmpmat("tmpmat");
	
	double t=t0;
	x=x0;
	while(t<tf)
	{
		Xd=ComputeXd(t); // pos1 pos2 vel1 vel2 acc1 acc2

		double x1=x[0][0];		double x2=x[1][0];  // pos1 pos2
		double x3=x[2][0];		double x4=x[3][0];  // vel1 vel2

		// state errors
		e[0][0]=Xd[0][0]-x1;	e[1][0]=Xd[1][0]-x2;
		edot[0][0]=Xd[2][0]-x3;	edot[1][0]=Xd[3][0]-x4;

		// Filtered error
		r = edot + lam*e;

		NNx=MakeNNx(e,edot,Xd);

		tau = TwoLayerNN(VT,WT,NNx) + Kv*r;

		// don't start training until the second rehearsal
		if(t>20)
		{
			del2=r;

			tmpmat=leDiag(z);
			del1=tmpmat*(Iz-tmpmat)*W*r;
		
			// del1 has a leading 1 that isn't necessary
			for(int i=1; i<del1.Nrows(); i++) del1[i-1][0]=del1[i][0];
			del1.SetSize(del1.Nrows()-1,del1.Ncols());

			W = W + eta2*z*leTranspose(del2);
			V = V + eta1*NNx*leTranspose(del1);

			VT=leTranspose(V);
			WT=leTranspose(W);
		}

		// Integrate us forward one update step
		stepResult=leODErk4(System,t,t+updateDt,dt,x);

		// Make stepResult into just its last row (final result)
		stepResult=leRow(stepResult,stepResult.Nrows()-1);
		
		// Copy down new t,x (last row of integration results)
		t=stepResult[0][0];
		x[0][0]=stepResult[0][1];		x[1][0]=stepResult[0][2];
		x[2][0]=stepResult[0][3];		x[3][0]=stepResult[0][4];

		// append step integration results to entire result
		result.AppendRows(stepResult);
	}

	V.Save("V.csv");
	W.Save("W.csv");

	char filename[128];
	sprintf(filename,"sim_%s.csv",result.Name());
	result.Save(filename);

	// Build the error position trajectories
	// time e1 e2
	LEmatrix error("error",result.Nrows(),3);
	for(i=0; i<result.Nrows(); i++)
	{
		double t=result[i][0];

		Xd=ComputeXd(t);
		error[i][0]=t;
		error[i][1]=Xd[0][0]-result[i][1];  // this is e1
		error[i][2]=Xd[1][0]-result[i][2];  // this is e2
	}
	error.Save("error.csv");

	return 0;
}



// Simulation 3.9c Linear Controller, Model/Servo
// J.E. (Ned) Lecky
// EE295A

#include "stdafx.h"
#include "LEneuralnet.h"
#include "LEsimulate.h"
#include <math.h>

// Desired Trajectory
LEmatrix& Trajectory(double t)
{
	static LEmatrix xd("xd",4,1);

	// copy t into xd[0]
	xd[0][0]=t;

	xd[1][0]=1*sin(2*t);
	xd[2][0]=2*cos(2*t);
	xd[3][0]=-4*sin(2*t);

	return xd;
}

// 2nd Order System
	// INPUT:   t=x[0], x1=x[1], x2=x[2], etc.
	// OUTPUT:	xdot[1] xdot[2]
// system constants
double m=1;
double b=1;
double k=1;
double Kp=0;
double Kd=0;
int L=5;

LEmatrix V("V",4,L);
LEmatrix W("W",L+1,1);
LEmatrix xnn("x",4,1);
LEmatrix y("y",1,1);

double lastE=0;

void ControlledModelServoSystem2(double x[],double xdot[])
{
	double t=x[0];
	LEmatrix xd;
	xd=Trajectory(t);

	double x1d=xd[1][0];  // pos
	double x2d=xd[2][0];  // vel
	double x3d=xd[3][0];  // acc
	
	// controller operation
	double fPrime = x3d + Kp*(x1d-x1) + Kd*(x2d-x2);

	double E=0.5*(pow(x1d-x1,2)+pow(x2d-x2,2));
	if(lastE!=0 && E>lastE)
	{
		// NN needs an improvement
		LEmatrix X("X");
		X=xnn;
		LEmatrix Y("Y");
		Y=y*scale;
	}
	lastE=E;

	xnn[0][1]=1;
	xnn[1][1]=fPrime;
	xnn[2][1]=x[1];
	xnn[3][1]=x[2];
	y=leTranspose(W)*leSigma(leTranspose(V)*xnn,LEAtanh);
	double f=fPrime+y[0][0];

	//double f = fPrime*m + b*x2 + k*x1;

	// real system equations
	xdot[1] = x[2];
	xdot[2] = (f - b*x[2] - k*x[1])/m;
	lastAcc=xdot[2];
}

int main(int argc, char* argv[])
{
	printf("2nd order model/servo with regulator\n");
	double t0;
	double tf;
	double dt;

	LEmatrix x0("x0",2,1);
	LEmatrix result("result");

	t0=0;			// start time
	tf=10;			// final time
	dt=.01;			// timestep

	// System Setup
	b=5;
	k=5;
	m=10;

	double critical_b=sqrt(4*m*k);

	// Initialize NN
	V.Randomize(-.1,.1);
	W.Randomize(-.1,.1);

	// initial conditions
	x0[0][0]=1;	
	x0[1][0]=1;

	// Compute control coefficents to achieve critical damping
	// desired spring coeff of resulting controlled system
	Kp=100;	// desired spring coeff of controlled system

	// compute necessary resulting bPrime to get critical damping
	Kd=2*sqrt(Kp);
	printf("  kp=%.3lf kv=%.3lf\n",Kp,Kd);

	for(int i=0; i<3; i++)
	{
		switch(i)
		{
		case 0:
			// make the system overdamped
			result.SetName("overdamped");
			b=1.5*critical_b;
			break;
		case 1:
			// make the system underdamped
			result.SetName("underdamped");
			b=0.5*critical_b;
			break;
		case 2:
			// make the system critically damped
			result.SetName("critical");
			b=critical_b;
			break;
		}


		printf("m=%.3lf b=%.3lf k=%.3lf\n",m,b,k);

		// 4th order Runga Kutta Integration
		result=leODErk4(ControlledModelServoSystem2,t0,tf,dt,x0);

		// add target position and position errors to result
		int newNcols=result.Ncols()+2;
		result.SetSize(result.Nrows(),newNcols);
		for(int j=0; j<result.Nrows(); j++)
		{
			LEmatrix traj;
			traj=Trajectory(result[j][0]);
			result[j][newNcols-2]=traj[1][0];
			result[j][newNcols-1]=result[j][1]-traj[1][0];
		}

		char filename[128];
		sprintf(filename,"2nd_rk4_%s.csv",result.Name());
		result.Save(filename);
	}
	
	return 0;
}


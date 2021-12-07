#include "stdafx.h"
#include "Stockcar.h"
#include <math.h>
#include <conio.h>


// Desired Trajectory
double amp1;
double fact;
LEmatrixObj& ComputeXd(double t)
{
	static LEmatrixObj Xd("Xd",3,1);
	static bool fFirst=true;
	static double lastT;

	if(fFirst)
	{
		fFirst=false;
		lastT=t;
		Xd=0;
		return Xd;
	}

	double dt=t-lastT;
	lastT=t;
	double a=0;

	if(t<5)
		a=0;
	else if(t<=10)
		a=1;
	else if(t<=15)
		a=-1;
	else
		a=0;

	Xd[2][0] = a;
	Xd[1][0] += a*dt;
	Xd[0][0] += Xd[1][0] * dt;

	return Xd;
}

// 2nd Order System
	// INPUT:   t=x[0], x1=x[1], x2=x[2], etc.
	// OUTPUT:	xdot[1] xdot[2]
// system constants
double m=1;
double b=1;
double k=1;
LEmatrixObj tau("tau",1,1);
void STDCALL System(double x[],double xdot[])
{
	// system equations
	xdot[1] = x[2];
	xdot[2] = (tau[0][0] - b*x[2] - k*x[1])/m;
}

int main(int argc, char* argv[])
{
	printf("PID Controller\n");

	// System Parameters
	m=1;
	b=1;
	k=1;

	// Desired Trajectory Parameters
	double period=2;
	amp1=0.1;
	fact=2*LE_PI/period;

	// Simulation Parameters
	double t0=0;			// start time
	double tf=20;			// final time
	double dt=.005;			// integration timestep
	double updateFreq=100;	// control loop update frequency Hz
	
	// Computed Constants
	double updateDt=1/updateFreq;	// control loop update frequency Hz

	// Initial Conditions
	LEmatrixObj x0("x0",2,1);
	x0=0;
	
	// Initial result matrix with row of initial conditions
	LEmatrixObj result("result",(tf-t0)/updateDt,x0.mRows()+1);
	result.SetSize(1,x0.mRows()+1);
	result[0][0]=t0;
	for(UINT i=0; i<x0.mRows(); i++)
		result[0][i+1]=x0[i][0];

	// Desired Control Coefficients
	// 40,0,0 gives stable oscillation period 1.414 seconds
	double Kp=100;//100; // 40,0,0 is stable oscillation period 1.414 seconds
	double Kd=2*sqrt(Kp);
	double Ki=1000;  // try this at 0 and 1

	LEmatrixObj stepResult;
	LEmatrixObj x("x");
	LEmatrixObj Xd("Xd");
	LEmatrixObj s("s",1,1);
	
	// error integration
	LEmatrixObj e("e",1,1);
	LEmatrixObj eLast("e",1,1);
	LEmatrixObj edot("edot",1,1);
	LEmatrixObj eps("eps",1,1);
	eps=0;
	eLast=0;
	
	double t=t0;
	x=x0;
	LEmatrixObj error("error",(int)((tf-t0)/updateDt+0.5),3);
	int row=0;
	while(t<tf)
	{
		Xd=ComputeXd(t); // pos1 vel1

		double x1=x[0][0];		double x2=x[1][0];  // pos1 vel1

		// state errors
		e[0][0]=Xd[0][0]-x1;
		edot[0][0]=Xd[1][0]-x2;
		//edot=(e-eLast)/updateDt;
		//eLast=e;

		error[row][0]=t;
		error[row][1]=e[0][0];
		error[row++][2]=edot[0][0];

		// integration of position errors
		eps = eps + e*updateDt;

		tau = edot*Kd + e*Kp + eps*Ki;
		
		// Integrate us forward one update step
		stepResult=leodeRK4(System,t,t+updateDt,dt,x);

		// Copy down new t,x (last row of integration results)
		int r=stepResult.mRows()-1;
		t=stepResult[r][0];
		x[0][0]=stepResult[r][1];		x[1][0]=stepResult[r][2];

		// append last row of step integration results to entire result
		result.AppendRows(lemExtractRow(stepResult,r));
	}

	char filename[128];
	sprintf(filename,"sim_%s.csv",result.Name());
	result.Write(filename);
	error.Write("error.csv");

	return 0;
}



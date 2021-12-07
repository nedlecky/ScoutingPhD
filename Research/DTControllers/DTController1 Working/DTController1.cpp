// DTController1.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "LEsimulate.h"
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
	}

	Xd[1][0]=1*sin(2*(10-1)) + slope*(20-10);
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

int main(int argc, char* argv[])
{
	printf("DT Controller\n");

	LEmatrix x0("x0",2,1);
	LEmatrix result("result",1,1);
	LEmatrix control("control",1,1);

	// Initial Plant Parameters
	b=5;
	k=5;
	m=10;

	// Simulation Parameters
	double t0=0;			// start time
	double tf=25;			// final time
	double dt=.01;			// integration timestep
	double updateFreq=20;	// control loop update frequency Hz
	
	// Computed Constants
	double updateDt=1/updateFreq;	// control loop update frequency Hz
	double critical_b=sqrt(4*m*k);

	// initial conditions; assume we start out on the desired trajectory
	LEmatrix Xd;
	Xd=ComputeXd(t0);
	x0[0][0]=Xd[1][0];	
	x0[1][0]=Xd[2][0];

	// Compute control coefficents to achieve critical damping
	// desired spring coeff of resulting controlled system
	double Kp=100;	// desired spring coeff of controlled system

	// compute necessary resulting bPrime to get critical damping
	double Kd=2*sqrt(Kp);
	printf("  Kp=%.3lf Kd=%.3lf\n",Kp,Kd);

	// run complete simulation with various actual plants
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

		double t=t0;
		LEmatrix x("x");
		x=x0;
		result.SetSize(1,1);
		bool fFirstTime=true;
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

			// Save f,fprime
			if(fFirstTime)
				control.SetSize(1,3);
			else
				control.SetSize(control.Nrows()+1,3);
			int r=control.Nrows()-1;
			control[r][0]=t;
			control[r][1]=fPrime;
			control[r][2]=f;

			// integrate us forward one update step
			LEmatrix stepResult;
			stepResult=leODErk4(System,t,t+updateDt,dt,x);

			// copy down new t,x (last row of integration results)
			r=stepResult.Nrows()-1;
			t=stepResult[r][0];
			x[0][0]=stepResult[r][1];
			x[1][0]=stepResult[r][2];

			// append step integration results to entire result
			if(fFirstTime)
				result=stepResult;
			else
			{
				// knock of the last result row since the
				//   first stepResult row is a copy
				result.SetSize(result.Nrows()-1,result.Ncols());
				result.AppendRows(stepResult);
			}
			fFirstTime=false;
		}

		// add target position and position errors to result
		int newNcols=result.Ncols()+2;
		result.SetSize(result.Nrows(),newNcols);
		for(int j=0; j<result.Nrows(); j++)
		{
			LEmatrix traj;
			traj=ComputeXd(result[j][0]);
			result[j][newNcols-2]=traj[1][0];
			result[j][newNcols-1]=result[j][1]-traj[1][0];
		}

		char filename[128];
		sprintf(filename,"sim_%s.csv",result.Name());
		result.Save(filename);

		sprintf(filename,"control_%s.csv",result.Name());
		control.Save(filename);
	}
	
	return 0;
}



// DTController1.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "LEsimulate.h"
#include <math.h>
#include <stdlib.h>

LEmatrix& Destination(double t,double& tStarted)
{
	static LEmatrix dest("dest",3,1);

	double tGoOn=0.1;


	double t1=5;
	double t2=10;
	double t3=15;

	// first goal
	if(t<t1-tGoOn)
	{
		dest[0][0]=t1;
		dest[1][0]=50;
		dest[2][0]=0;//10;
		tStarted=0;

		return dest;
	}

	// second goal
	if(t<t2-tGoOn)
	{
		dest[0][0]=t2;
		dest[1][0]=70;
		dest[2][0]=0;//4;
		tStarted=t1;

		return dest;
	}

	// second goal
	if(t<t3-tGoOn)
	{
		dest[0][0]=t3;
		dest[1][0]=5;
		dest[2][0]=-.3;
		tStarted=t2;

		return dest;
	}

	// implement hold state
	double tHold=0.2;
	dest[0][0]=t+tHold;
	dest[1][0]=5-0.3*(t+tHold-t3);
	dest[2][0]=-0.3;
	tStarted=t;
	return dest;
}


// Desired Trajectory
//double tInitial=0.0;
LEmatrix retraj("retraj");
double ComputeAcc(double t,double y,double ydot)
{
	LEmatrix dest;
	double tStarted;
	dest=Destination(t,tStarted);
	double tf=dest[0][0];
	double yf=dest[1][0];
	double ydotf=dest[2][0];

	// time and distance remaining to goal
	double tr=tf-t;
	double yr=yf-y;

	// case 1: Fixed hard compliance
	// gets right on the linear decel plan
	//tc=0.05;

	// case 2: Give me as long as you've got
	// too lackadaisical
	//tc = tr;

	// case 3: Give me 1/n of the time you have left
	//tc = tr;
	//tc/=3;

	// case 4: sliding scale
	//double scaleInit=.5;
	//double scaleFinal=5;
	//double fracTimeToGo=tr/(tFinal-tInitial);
	//tc = tr / (scaleFinal-(scaleFinal-scaleInit)*fracTimeToGo);

	// case 5: decaying exponential
	//tc = 10*exp(-0.5*(t-tStarted));
	//if(tc<0.05) tc=0.05;

	// case 6: decaying linear
	//tc = 2*tr/(tf-tStarted);
	//if(tc<0.05) tc=0.05;

	// case 7: decaying exponential
	//tc = .1*exp(0.5*(tf-t));
	//if(tc<0.05) tc=0.05;

	// case 8: squared time
	//tc = (tr*tr)/pow((tf-tStarted),2);
	//if(tc<0.05) tc=0.05;

	// alternative expression not requiring constant jerk
	// ideal velocity to hit both
	double ydotCAP=2*yr/tr - ydotf;
	
	// linear decel we could use then
	double yddotCAP=2*(ydotf-yr/tr)/tr;

	double tc=tr/5; // for tc=tr/4, degenerates to constant jerk
	double yddot = yddotCAP + (ydotCAP-ydot)/tc;

//	double yddot = 2*(3*yr/tr - 2*ydot - ydotf)/tr;
	//if(4<t && t<6)
	//	yddot+=5;


	int r=retraj.Nrows()-1;
	retraj[r][0]=t;
	retraj[r][1]=0;//Kd;
	retraj[r][2]=ydot;
	retraj[r][3]=0;//ydotCAP;
	retraj[r][4]=yddot;
	return yddot;
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
	double tf=21;			// final time
	double dt=.01;			// integration timestep
	double updateFreq=20;	// control loop update frequency Hz
	
	// Computed Constants
	double updateDt=1/updateFreq;	// control loop update frequency Hz
	double critical_b=sqrt(4*m*k);

	// initial conditions; assume we start out on the desired trajectory
	x0[0][0]=0;
	x0[1][0]=0;

	// Compute control coefficents to achieve critical damping
	// desired spring coeff of resulting controlled system
	double Kp=100;	// desired spring coeff of controlled system

	// compute necessary resulting bPrime to get critical damping
	double Kd=2*sqrt(Kp);
	printf("  Kp=%.3lf Kd=%.3lf\n",Kp,Kd);

	// run complete simulation with various actual plants
	for(int i=2; i<3; i++)
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
			// present situation
			double x1=x[0][0];
			double x2=x[1][0];

			// servo equation
			if(fFirstTime)
				retraj.SetSize(1,5);
			else
				retraj.SetSize(retraj.Nrows()+1,5);
			double fPrime = ComputeAcc(t,x1,x2);

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
/*
		int newNcols=result.Ncols()+2;
		result.SetSize(result.Nrows(),newNcols);
		for(int j=0; j<result.Nrows(); j++)
		{
			LEmatrix traj;
			traj=ComputeXd(result[j][0]);
			result[j][newNcols-2]=traj[1][0];
			result[j][newNcols-1]=result[j][1]-traj[1][0];
		}
*/
		char filename[128];
		sprintf(filename,"sim_%s.csv",result.Name());
		result.Save(filename);

		sprintf(filename,"control_%s.csv",result.Name());
		control.Save(filename);

		sprintf(filename,"retraj_%s.csv",result.Name());
		retraj.Save(filename);
	}
	
	return 0;
}



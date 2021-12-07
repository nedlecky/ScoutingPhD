// DTController1.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "LEsimulate.h"
#include <math.h>
#include <conio.h>

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
	if(t<50)
	{
		Xd[1][0]=1*sin(2*(t-1));
		Xd[2][0]=2*cos(2*(t-1));
		Xd[3][0]=-4*sin(2*(t-1));
		return Xd;
	}
	if(t<98)
	{
		Xd[1][0]=1*sin(2*(50-1)) + 1.5*sin(2.5*(t-50));
		Xd[2][0]=2.5*1.5*cos(2.5*(t-50));
		Xd[3][0]=-2.5*2.5*1.5*sin(2.5*(t-50));
		return Xd;
	}

	Xd=ComputeXd(97.9999999);
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
	LEmatrix result("result",20000,5);
	LEmatrix control("control",5000,3);
	LEmatrix estimates("estimates",5000,5);

	// Initial Plant Parameters
	b=5;
	k=5;
	m=10;

	// Simulation Parameters
	double t0=0;			// start time
	double tf=100;			// final time
	double dt=.005;			// integration timestep
	double updateFreq=40;	// control loop update frequency Hz
	
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
		printf("%s: m=%.3lf b=%.3lf k=%.3lf\n",result.Name(),m,b,k);

		double t=t0;
		LEmatrix x("x");
		x=x0;
		result.SetSize(1,1);
		bool fFirstTime=true;

		double mEst=1;
		double bEst=1;
		double kEst=1;
		double mEstSum=0;
		double bEstSum=0;
		double kEstSum=0;
		double nEstSums=0;
		double pos[4];
		for(int i=0; i<4; i++) pos[i]=0;
mEst=m;
bEst=b;
kEst=k;
		while(t<tf)
		{
			// present state estimate
			// where are we?
			pos[3]=pos[2];
			pos[2]=pos[1];
			pos[1]=pos[0];
			pos[0]=x[0][0];
			double v0=(pos[0]-pos[1])/updateDt;
			double v1=(pos[1]-pos[2])/updateDt;
			double v2=(pos[2]-pos[3])/updateDt;
			double a0=(v0-v1)/updateDt;
			double a1=(v1-v2)/updateDt;
			double x1=pos[0];
			double x2=v0 + a0/2*updateDt;
			double x3=a0 +(a0-a1)*updateDt;

			// Controller Computations
			Xd=ComputeXd(t);

			// desired state
			double x1d=Xd[1][0];  // pos
			double x2d=Xd[2][0];  // vel
			double x3d=Xd[3][0];  // acc

//printf("%.03lf: %8.02lf %8.02lf %8.2lf %8.04lf %8.04lf %8.04lf\n",
//	   t,x[0][0],x[1][0],0.0,x1,x2,x3);
//printf("%.03lf: %8.02lf %8.02lf %8.2lf\n",
//	   t,x1d,x2d,x3d);

	
			double e;
			double edot;
			double eddot;
			double fPrime;

			// servo equation
			e=x1d-x1;
			edot=x2d-x2;
			eddot=x3d-x3;

			if(!fFirstTime)
			{
				// update system estimates
				double eta=.1;

				double mEst1 = mEst + eta*eddot/(mEst*mEst)*(bEst*x2 + kEst*x1 - f);
				double bEst1 = bEst + eta*edot/(bEst*bEst)*(mEst*x3 + kEst*x1 - f);
				double kEst1 = kEst + eta*e/(kEst*kEst)*(mEst*x3 + bEst*x2 - f);
//printf("FROM: m=%.3lf b=%.3lf k=%.3lf\n",mEst,bEst,kEst);
				if(mEst1<0.1) mEst1=0.1;
				if(bEst1<0.1) bEst1=0.1;
				if(kEst1<0.1) kEst1=0.1;

				mEstSum+=mEst1;
				bEstSum+=bEst1;
				kEstSum+=kEst1;
				nEstSums++;

				if(nEstSums>100)
				{
					mEst=mEstSum/nEstSums;
					bEst=bEstSum/nEstSums;
					kEst=kEstSum/nEstSums;
					nEstSums=1;
					mEstSum=mEst;
					bEstSum=bEst;
					kEstSum=kEst;
				}
				//printf("  TO: m=%.3lf b=%.3lf k=%.3lf\n",mEst,bEst,kEst);
			}

//printf("WITH: e=%.3lf edot=%.3lf eddot=%.3lf\n",e,edot,eddot);
//getch();
			// servo control equation
			fPrime = x3d + Kp*e + Kd*edot;

			// model equation
			f = fPrime*mEst + bEst*x2 + kEst*x1;

			// Save f,fprime
			if(fFirstTime)
				control.SetSize(1,3);
			else
				control.SetSize(control.Nrows()+1,3);
			int r=control.Nrows()-1;
			control[r][0]=t;
			control[r][1]=fPrime;
			control[r][2]=f;

			// Save system estimates
			if(fFirstTime)
				estimates.SetSize(1,4);
			else
				estimates.SetSize(estimates.Nrows()+1,4);
			r=estimates.Nrows()-1;
			estimates[r][0]=t;
			estimates[r][1]=mEstSum/nEstSums;//mEst;
			estimates[r][2]=bEstSum/nEstSums;//bEst;
			estimates[r][3]=kEstSum/nEstSums;//kEst;

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
		sprintf(filename,"%s.csv",result.Name());
		result.Save(filename);

		sprintf(filename,"control_%s.csv",result.Name());
		control.Save(filename);

		sprintf(filename,"estimates_%s.csv",result.Name());
		estimates.Save(filename);
	}
	
	return 0;
}



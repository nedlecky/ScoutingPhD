// TrajBuilder.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "LEmatrix.h"
#include <math.h>

double Acc(double t)
{
	return 0.4*cos(5*t);
}

int main(int argc, char* argv[])
{
	LEmatrix traj("traj",1000,4);

	double t0=0;
	double tf=10;
	double dt=0.01;

	double t=t0;
	traj.SetSize(1,4);
	// intitial conditions
	traj[0][0]=t0;
	traj[1][0]=0;
	traj[2][0]=0;
	traj[3][0]=Acc(t0);
	t+=dt;
	while(t<tf)
	{
		traj.SetSize(traj.Nrows()+1,4);
		
		int r=traj.Nrows()-1;
		traj[r][0]=t;

		double curAcc=Acc(t);
		traj[r][3]=curAcc;

		// assume readings at end of sample period
		/*
		double accMid=(curAcc+traj[r-1][3])/2;
		double curVel=traj[r-1][2]+accMid*dt;
		traj[r][2]=curVel;

		double velMid=(curVel+traj[r-1][2])/2;
		traj[r][1]=traj[r-1][1]+velMid*dt;
		double curAcc=Acc(t);
		traj[r][3]=curAcc;
		*/

		// assume readings at center of sample period
		double curVel=traj[r-1][2]+curAcc*dt;
		traj[r][2]=curVel;

		traj[r][1]=traj[r-1][1]+curVel*dt;

		t+=dt;
	}

	traj.Save("traj.csv");

	return 0;
}


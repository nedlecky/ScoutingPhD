#include <stdio.h>
#include <math.h>
#include <stdlib.h>
const int TRUE=1;
const int FALSE=0;


double M=1.;
double B=2.;
double K=4.;

// a simple SMD simulation given Fa
// ala Close and Frederick p.171
void Simple(void)
{
	double x=1.;
	double v=0.;
	double dt=0.03125;


	for(double t=0.; t<=17.5; t+=dt)
	{
		double f0=sin(0.5*t);
		if(fabs(fmod(t,0.25))<0.01)
			printf("%9.2lf %9.4lf %9.4lf %9.4lf\n",
				t,x,v,f0);
		double xdot=v;
		double vdot=1./M*(-K*x - B*v + f0);
		x=x+xdot*dt;
		v=v+vdot*dt;
	}
}

// Situation
//	x,v,t
#define x (s[0])
#define v (s[1])
#define t (s[2])

// Action
//	dir,F,dt  (dir -1,0,1 of last increment)
#define dir (a[0])
#define f (a[1])
#define dt (a[2])

// Recast in Scouting Genre
void NextSituation(double* s,double* a)
{
	double xdot=v;
	double vdot=1./M*(-K*x - B*v + f);
	x=x+xdot*dt;
	v=v+vdot*dt;
	t=t+dt;
}

void PickAction(double* a)
{
	int lastd=(int)dir;
	int d;
	do
	{
		d=rand()%3-1;
	}
	while((lastd==-1 && d==1) || (lastd==1 && d==-1));

	switch(d)
	{
	case -1:
		if(f>-2.) f=f-0.1; break;
	case 1:
		if(f<2.) f=f+0.1; break;
	default:
		break;
	}
	dir=(double)d;
	//dt=0.03125;
}

double targetX=0.5;
double targetV=0.3;
int GoalCheck(double* s)
{

	if(fabs(x-targetX)<0.05 && fabs(v-targetV)<0.05) return TRUE;

	return FALSE;
}

void ShowStatus(double* s,double* a)
{
	printf("%9.3lf %9.4lf %9.4lf %9.4lf %d\n",t,x,v,f,GoalCheck(s));
}

int Scout(int maxLen,int fPrint)
{
	double a[3];
	double s[3];
	x=1;
	v=0;
	t=0;
	dir=0;
	f=0;
	dt=0.03125;


	for(int i=0; i<maxLen; i++)
	{
		if(fPrint) ShowStatus(s,a);
		if(GoalCheck(s))
		{
			return i;
		}
		PickAction(a);
		NextSituation(s,a);
	}

	return -1;
}

main()
{
	int bestSolution=1000;
	int bestr0=-1;
	for(int i=0; i<10000; i++)
	{
		int r0=rand();
		srand(r0);
		int s=Scout(bestSolution,FALSE);
		if(s>0)
		{
			bestSolution=s;
			bestr0=r0;
			printf("Scout %d found solution in %d steps\n",
				i,s);
		}
	}

	if(bestr0>=0)
	{
		srand(bestr0);
		Scout(bestSolution+1,TRUE);
	}
	else printf("No solution found.\n");

	return 0;
}


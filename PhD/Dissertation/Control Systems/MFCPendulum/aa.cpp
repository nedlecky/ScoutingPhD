#include <stdio.h>
#include <math.h>
#include <stdlib.h>
const int TRUE=1;
const int FALSE=0;

const double PI=3.1415926535897932;

double M=.7;
//double B=.1;
double g=1;
double L=4.;
double maxTau=3;
int integrationsPerStep=2;

double B(double t)
{
	double b=10.-sqrt(t);
	if(b<0) b=0.;
	return b;
}

FILE* outFp=NULL;


// Situation
//	theta,omega,t
#define theta s[0]
#define omega s[1]
#define t s[2]

// Action
//	dir,T,dt  (dir -1,0,1 of last increment)
#define dir a[0]
#define Tau a[1]
#define dt a[2]

// Recast in Scouting Genre
void NextSituation(double* s,double* a,int fPrint)
{
	for(int i=0; i<integrationsPerStep; i++)
	{
		double thetadot=omega;
		double omegadot=1./(M*L*L) * (Tau - B(t)*omega - M*g*L*sin(theta));
		theta=theta+thetadot*dt;
		omega=omega+omegadot*dt;
		double delta=dt;
		t=t+delta;
	}
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

	double delta=fabs(Tau)*0.05;
	if(delta<0.1) delta=0.1;
	switch(d)
	{
	case -1:
		if(Tau>-maxTau) Tau = Tau - delta; break;
	case 1:
		if(Tau<maxTau) Tau = Tau + delta; break;
	default:
		break;
	}
	dir=(double)d;
	//dt=0.03125;
}

double targetTheta=PI*.999;
double targetOmega=0.0;
int GoalCheck(double* s)
{

	if(fabs(theta-targetTheta)<0.1 && fabs(omega-targetOmega)<.1)
		return TRUE;

	return FALSE;
}

void ShowStatus(double* s,double* a)
{
	printf("%9.3lf %9.4lf %9.4lf %9.4lf %d\n",t,theta,omega,Tau,GoalCheck(s));
	if(outFp!=NULL)
		fprintf(outFp,"%9.3lf,%9.4lf,%9.4lf,%9.4lf,%d\n",t,theta,omega,Tau,GoalCheck(s));
}

int Scout(int maxLen,int fPrint)
{
	double a[3];
	double s[3];
	theta=0;
	omega=0;
	t=0;
	dir=0;
	Tau=0;
	dt=0.03125;


	for(int i=0; i<maxLen; i++)
	{
		if(fPrint) ShowStatus(s,a);
		if(GoalCheck(s))
		{
			return i;
		}
		PickAction(a);
		NextSituation(s,a,fPrint);
	}

	return -1;
}

main()
{
	outFp=fopen("c:\\out.csv","w");

	int bestSolution=1500;
	int bestr0=-1;
	for(int i=0; i<5000; i++)
	{
		srand(i);
		int s=Scout(bestSolution,FALSE);
		if(s>0)
		{
			bestSolution=s;
			bestr0=i;
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

	if(outFp!=NULL) fclose(outFp);

	return 0;
}


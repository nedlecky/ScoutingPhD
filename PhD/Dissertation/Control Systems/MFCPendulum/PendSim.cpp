#include "stdafx.h"

#include <math.h>
#include <stdlib.h>
#include "PendSim.h"



/*
double Btv(double t)
{
	return 1.0;
	
	double bScale=5-t;
	if(bScale<0) bScale=0;
	return bScale;
}
*/
double PtoMotorTorque(double power,double velocity)
{
	double tau;
	
	if(fabs(velocity)<0.01)
		tau=power;
	else
		tau=power/velocity;

	return tau;
}

double VtoMotorTorque(double voltage,double velocity)
{
	double tau;
	
	if(fabs(velocity)<0.01)
		tau=voltage;
	else
		tau=voltage/velocity;

	return tau;
}

double ItoMotorTorque(double current,double velocity)
{
	double tau;
	
	if(fabs(velocity)<0.01)
		tau=current;
	else
		tau=current/velocity;

	return tau;
}

PendulumSimulator::PendulumSimulator()
{
	timeStep=0.03125;
	maxDepth=1000;
	initRand=1;
	nScouts=1000;
	M=0.5;
	B=1.;
	G=1.;
	L=2.;
	inputType=eForce;
	maxInput=5.;
	minInput=-5.;
	inputSlew=.05;
	integrationsPerStep=2;
	initialTheta=0;
	initialOmega=0;
	finalTheta=PI;
	finalOmega=0;
	finalThetaTol=0.2;
	finalOmegaTol=0.2;

	arraySize=0;
	trackT=NULL;
	trackTheta=NULL;
	trackOmega=NULL;
	trackInput=NULL;
	trackInputA1=NULL;
	trackInputA2=NULL;
}

PendulumSimulator::~PendulumSimulator()
{
	ClearData();
}

void PendulumSimulator::ClearData(void)
{
	if(trackT) delete trackT;
	if(trackTheta) delete trackTheta;
	if(trackOmega) delete trackOmega;
	if(trackInput) delete trackInput;
	if(trackInputA1) delete trackInputA1;
	if(trackInputA2) delete trackInputA2;
	trackT=NULL;
	trackTheta=NULL;
	trackOmega=NULL;
	trackInput=NULL;
	trackInputA1=NULL;
	trackInputA2=NULL;
	arraySize=0;
}

void PendulumSimulator::SetConst(void)
{
	MLLinv=1./M/L/L;
	MGL=M*G*L;
}

void PendulumSimulator::SetArraySize(int n)
{
	if(n<=arraySize) return;

	ClearData();

	trackT=new double[n];
	trackTheta=new double[n];
	trackOmega=new double[n];
	trackInput=new double[n];
	trackInputA1=new double[n];
	trackInputA2=new double[n];

	arraySize=n;
}


// Recast in Scouting Genre
void PendulumSimulator::NextSituation(Situation& s,Action& a)
{
	nNS++;

	// Euler differential equation simulation
	for(int i=0; i<integrationsPerStep; i++)
	{
		a.input += a.dinput;

		// compute tau
		double tau;
		if(a.inputType==eForce)
			tau=a.input;
		else if(a.inputType==ePower)
			tau=PtoMotorTorque(a.input,s.omega);
		else if(a.inputType==eVoltage)
			tau=VtoMotorTorque(a.input,s.omega);
		else if(a.inputType==eCurrent)
			tau=ItoMotorTorque(a.input,s.omega);

		double thetadot = s.omega;
		double omegadot = MLLinv * (tau - B*s.omega - MGL*sin(s.theta));
		
		s.theta = s.theta + thetadot * a.dt;
		s.omega = s.omega + omegadot * a.dt;

		s.t+=a.dt;
	}
}

void PendulumSimulator::PickAction(Action& a)
{
	nPA++;

	//int d;
	//if(dTau==0)
	//	d=rand()%3-1;
	//else if(dTau>0)
	//	d=rand()%2;
	//else
	//	d=rand()%2-1;

	int d;
	if(a.dir==-2)
	{
		d=rand()%2;
	}
	else if(a.dir==2)
	{
		d=rand()%2-1;
	}
	else
		d=rand()%3-1;

	a.dir+=d;

	a.dinput=(double)(a.dir)/2.*inputSlew;

	double inputDist=a.dinput*(double)integrationsPerStep;
	if(a.input+inputDist>maxInput)
		a.dinput=(maxInput-a.input)/integrationsPerStep;
	else
		if(a.input+inputDist<minInput)
			a.dinput=(minInput-a.input)/integrationsPerStep;
}

int nOK=0;
BOOL PendulumSimulator::GoalCheck(Situation& s)
{
	nGC++;

	//if(t<1) return FALSE;

	if(fabs(s.theta-finalTheta)<finalThetaTol && fabs(s.omega-finalOmega)<finalOmegaTol)
	{
		nOK++;
		if(nOK>0) return TRUE;
		else return FALSE;
	}
	else
	{
		nOK=0;
		return FALSE;
	}
}

void PendulumSimulator::SaveStatus(int slot,Situation& s,Action& a)
{
	trackT[slot]=s.t;
	trackTheta[slot]=s.theta;
	trackOmega[slot]=s.omega;
	trackInput[slot]=a.input;
}

int PendulumSimulator::Scout(int maxLen,int fSave)
{
	Action a;
	Situation s;
	s.theta=initialTheta;
	s.omega=initialOmega;
	s.t=0;
	a.dinput=0;
	a.dir=0;
	a.input=0;
	a.inputType=inputType;
	a.dt=timeStep;

	for(int i=0; i<maxLen; i++)
	{
		if(fSave) SaveStatus(i,s,a);
		if(GoalCheck(s))
		{
			return i;
		}
		PickAction(a);
		NextSituation(s,a);
	}

	return -1;
}


int PendulumSimulator::Solve(void)
{
	// profiling counters
	nGC=0;
	nPA=0;
	nNS=0;

	SetArraySize(maxDepth);

	// run the scouts
	int bestSolution=maxDepth;
	int bestr0=-1;
	fRun=TRUE;
	for(int i=0; i<nScouts && fRun; i++)
	{
		int rSeed=i+initRand;
		srand(rSeed);
		int s=Scout(bestSolution,FALSE);
		if(s>0)
		{
			bestSolution=s;
			bestr0=rSeed;
		}
	}

	// recreate the best solution, if one was found
	if(bestr0>=0)
	{
		srand(bestr0);
		Scout(bestSolution+1,TRUE);
		lastLen=bestSolution;

		// compute torque model coefficients
		for(int j=1; j<bestSolution; j++)
		{
			//double A2num = trackTheta[j]*trackInput[j-1];
			//double A2den = trackTheta[j]*trackOmega[j-1] - trackTheta[j-1]*trackOmega[j];
			double A2num = (trackTheta[j]+100)*(trackInput[j-1]+100);
			double A2den = (trackTheta[j]+100)*(trackOmega[j-1]+100) - (trackTheta[j-1]+100)*(trackOmega[j]+100);
			double A2=0;
			if(fabs(A2den>0.0000001)) A2=A2num/A2den;

			//double A1num = trackInput[j] - A2*trackOmega[j];
			//double A1den = trackTheta[j];
			double A1num = (trackInput[j]+100) - A2*(trackOmega[j]+100);
			double A1den = (trackTheta[j]+100);
			double A1=0;
			if(fabs(A1den>0.0000001)) A1=A1num/A1den;

			trackInputA1[j]=A1;
			trackInputA2[j]=A2;
		}
		trackInputA1[0]=trackInputA1[1];
		trackInputA2[0]=trackInputA2[1];
	}
	else
		lastLen=-1;
	
	return lastLen;
}


void PendulumSimulator::AbortScouting(void)
{
	fRun=FALSE;
}

#include "stdafx.h"
#include <stdlib.h>
#include <math.h>
#include "ffnn.h"

struct Situation
{
	double theta;
	double omega;
	double t;
};

struct Action
{
	double dinput;
	double input;
	double dt;
};

int integrationsPerStep=8;
double MLLinv=0.1;
double B=1.;
double MGL=10.;
void NextSituation(Situation& s,Action& a)
{
	// Euler differential equation simulation
	for(int i=0; i<integrationsPerStep; i++)
	{
		a.input += a.dinput;

		// compute tau
		double tau;
		tau=a.input;

		double thetadot = s.omega;
		double omegadot = MLLinv * (tau - B*s.omega - MGL*sin(s.theta));
		
		s.theta = s.theta + thetadot * a.dt;
		s.omega = s.omega + omegadot * a.dt;

		s.t+=a.dt;
	}
}

double drand(void)
{
	double r=rand();
	return r/(double)RAND_MAX;
}

#define PI 3.14159

int main(int argc, char* argv[])
{
	printf("FFNN Simulator\n");
	srand(1);

	int nSamp=500;
	int nIn=4;
	int nOut=2;
	TestData* in[2];
	TestData* out[2];
	for(int i=0; i<2; i++)
	{
		in[i]  = new TestData(nIn,nSamp);
		out[i] = new TestData(nOut,nSamp);
	}

/*
	for(int i=0; i<nSamp; i++)
	{
		double x=drand();
		double y=drand();
		in0[i][0]=x;
		in0[i][1]=y;
		out0[i][0]=sin(x);
		out0[i][1]=sin(x)*cos(y);
	}

*/
	Situation s;
	Action a;

	for(int set=0; set<2; set++)
	{
		for(int i=0; i<nSamp; i++)
		{
			// inputs theta, omega, tau, dtau
			s.theta=drand()*2.*PI - PI;
			s.omega=drand()*PI - PI/2.;
			a.input=drand()*4.-2.;
			a.dinput=drand() - 0.5;
			(*in[set])[i][0]=s.theta;
			(*in[set])[i][1]=s.omega;
			(*in[set])[i][2]=a.input;
			(*in[set])[i][3]=a.dinput;
			NextSituation(s,a);
			// outputs theta++, omega++
			(*out[set])[i][0]=s.theta;
			(*out[set])[i][1]=s.omega;
		}
	}
	for(set=0; set<2; set++)
	{
		in[set]->Show();
		out[set]->Show();
	}

	int layerSizes[]={nIn,7,7,7,7,nOut};
	FFNN ffnn(6,layerSizes);

	ffnn.InputAmps()->SetScaling(*in[0],1);
	ffnn.InputAmps()->ShowScaling();
	ffnn.OutputAmps()->SetScaling(*out[0],0);
	ffnn.OutputAmps()->ShowScaling();

	for(int nNet=0; nNet<3; nNet++)
	{
//		ffnn.RandomizeWeights();
		int nEpochs=5000;
		for(int epoch=0; epoch<nEpochs; epoch++)
		{
			for(i=0; i<nSamp; i++)
			{
				int ii=i;//rand()%nSamp;
				ffnn.ForwardProp((*in[0])[ii]);
				ffnn.BackwardProp((*out[0])[ii]);
				ffnn.UpdateWeights(0.6 - 0.5*(double)epoch/nEpochs);//0.5);
			}
			//if(epoch%1000==0) ffnn.Evaluate(in0,out0);
		}
		//ffnn.ShowAllOutputs();
		ffnn.Evaluate(*in[0],*out[0],0);
		ffnn.Evaluate(*in[1],*out[1],0);
	}

	for(set=0; set<2; set++)
	{
		delete in[set];
		delete out[set];
	}
	return 0;
}

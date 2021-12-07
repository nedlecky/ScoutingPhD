#include "stdafx.h"
#include "neuron.h"
#include <stdlib.h>

double randm1p1(void)
{
	return (double)rand()*2./(double)RAND_MAX-1.;
}

Neuron::Neuron()
{
	nInputs=0;
	weights=NULL;
}
Neuron::~Neuron()
{
	if(weights) delete weights;
}
void Neuron::InitializeWeights(void)
{
	for(int i=0; i<=nInputs; i++)
		weights[i]=randm1p1();
}
int Neuron::NumInputs(void)
{
	return nInputs;
}
void Neuron::NumInputs(int x)
{
	if(weights) delete weights;
	weights=new double[x+1];
	nInputs=x;
	InitializeWeights();
}
double Neuron::Sigma(double x)
{
	double emx=exp(-x);
	double x=

}
void Neuron::ShowWeights(void)
{
	for(int i=0; i<=nInputs; i++)
		printf("%2d %.3lf\n",i,weights[i]);
}
double Neuron::Execute(double* inputs)
{
	double sum=weights[0];
	for(int i=0; i<nInputs; i++)
		sum += inputs[i]*weights[i+1];
	return Sigma(sum);
}
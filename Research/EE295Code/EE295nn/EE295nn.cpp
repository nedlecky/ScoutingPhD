// EE295nn.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "neuron.h"

int main(int argc, char* argv[])
{
	printf("Artificial Neural Network Testing\n");

	const int nInputs=8;
	
	Neuron n1;
	n1.NumInputs(nInputs);

	double inputs[nInputs];
	for(int i=0; i<8; i++)
	{
		inputs[i]=i;
		printf("input %2d: %.3lf\n",i,inputs[i]);
	}

	n1.ShowWeights();
	double x=n1.Execute(inputs);
	printf("output=%.3lf\n",x);

	return 0;
}


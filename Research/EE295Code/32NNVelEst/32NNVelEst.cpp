// 32NNVelEst.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "LEneuralnet.h"
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <math.h>

int randint(int min,int max)
{
	int x=rand()%(max-min+1);
	return x+min;
}

int main(int argc, char* argv[])
{
	int size=100;
	
	LEmatrix pos("pos",1,size);
	LEmatrix vel("vel",1,size);
	LEmatrix estVel("estVel",1,size);

	for(int i=0; i<size; i++)
	{
		pos[0][i]=sin(.41*i);
		vel[0][i]=.41*cos(.41*i);
	}

	int nTrain=50;
	int nSamples=4;
	LEmatrix X("X",nSamples,nTrain);
	LEmatrix Y("Y",1,nTrain);
	for(i=0; i<nTrain; i++)
	{
		int startIndex=randint(nSamples-1,size-1);
		for(int x=0; x<nSamples; x++)
			X[x][i]=pos[0][startIndex-x];
		Y[0][i]=vel[0][startIndex];
	}

	LEmatrix VT("VT");
	LEmatrix WT("WT");
	double E=TrainApprox1(VT,WT,X,Y,
		10, // hidden neurons
		10000, // max Epochs
		0.1, // eta
		0.0001); // eLimit

	printf("Final Error: %.4lf\n",E);

	LEmatrix x("x",nSamples+1,size);
	x=1;

	LEmatrix y("y");
	for(i=nSamples-1; i<size; i++)
	{
		for(int j=0; j<nSamples; j++)
			x[j+1][0]=pos[0][i-j];
		y=NNApprox1(VT,WT,x);
		estVel[0][i]=y[0][0];
	}

	LEmatrix e1("e1");
	e1=estVel-vel;
	double E1=Trace(e1*Transpose(e1))/size;
	printf("NN Error=%.4lf\n",E1);

	return 0;
}


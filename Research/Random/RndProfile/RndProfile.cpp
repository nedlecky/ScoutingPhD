#include "stdafx.h"
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#define mPI 3.14159
#define m2PI (2.0*mPI)

// A better way to get longer sequences, due to Knuth and H.W. Lewis
// (see Press p. 284)
unsigned long qseed=1;
void sqrand(unsigned int seed)
{
	qseed=seed;
}
int qrand(int maxRand)
{
	qseed = qseed*1664525L + 1013904223L + rand();
	return qseed % maxRand;
}


int main(int argc, char* argv[])
{
	int nPts=500;
	int decisionSpacing=8;
	int sMin=-100;
	int sMax=100;
	int sInit=0;
	int sRange=sMax-sMin+1;
	sqrand(12345);

	double* rseq=new double[nPts];
	double* rudseq=new double[nPts];
	double* udseq=new double[nPts];
	double* dseq=new double[nPts];
	double* aseq=new double[nPts];
	double* sseq=new double[nPts];
	double* bseq=new double[nPts];
	printf("Sequence Tester\n");

	// Random Sequence State
	double rlast;
	
	// RUD Sequence state
	double rudlast=sInit;
	double rudstep=10;
	int ruddir;  // -1 0 1

	// UD Sequence state
	double udlast=sInit;
	double udstep=10;
	int uddir=0;  // -1 0 1

	// Derivative Sequence State
	double dlast=sInit;
	double dstep=2;
	int ddir=0; // -2 -1 0 1 2 (decision +1 -1 0)

	// Acceleration Sequence State
	double alast=sInit;
	double avlast=0;
	double astep=.05;
	int adecisionSpacing=1;
	int adir=0; // -2 -1 0 1 2

	// Sine Sum State
	int nHarmonics=4;
	int baseWavelength=20;
	double* amp=new double[nHarmonics];
	for(int j=0; j<nHarmonics; j++)
		amp[j]=qrand(sRange/2/nHarmonics);

	// Binary Sequence state
	double blast=sInit;
	double bstep=2;
	int bdir=0;  // -2 -1 0 1 2 (decision +1 -1)

	for(int i=0; i<nPts; i++)
	{
		// rseq
		if(i%decisionSpacing==0)
			rlast=(double)(qrand(sRange)+sMin);
		rseq[i]=rlast;
		
		// rudseq
		if(i%decisionSpacing==0)
			ruddir=qrand(3)-1;
		rudlast += ruddir*rudstep;
		if(rudlast<sMin) rudlast=sMin;
		if(rudlast>sMax) rudlast=sMax;
		rudseq[i]=rudlast;

		// udseq
		if(i%decisionSpacing==0)
		{
			uddir += qrand(3)-1;
			if(uddir<-1) uddir=-1;
			if(uddir>1) uddir=1;
		}
		udlast += uddir*udstep;
		if(udlast<sMin) udlast=sMin;
		if(udlast>sMax) udlast=sMax;
		udseq[i]=udlast;

		// dseq
		if(i%decisionSpacing==0)
		{
			ddir=ddir + qrand(3)-1;
			if(ddir<-2) ddir = -2;
			if(ddir> 2) ddir =  2;
		}
		dlast += ddir*dstep;
		if(dlast<sMin)
		{
			dlast=sMin;
			ddir=0;
		}
		if(dlast>sMax)
		{
			dlast=sMax;
			ddir=0;
		}
		dseq[i]=dlast;

		// aseq
		if(i%adecisionSpacing==0)
		{
			adir += qrand(2)*2-1;
			if(adir<-2) adir = -2;
			if(adir> 2) adir =  2;
		}
		avlast += adir*astep;
		alast += avlast;
		if(alast<sMin)
		{
			alast=sMin;
			avlast=0;
		}
		if(alast>sMax)
		{
			alast=sMax;
			avlast=0;
		}
		aseq[i]=alast;

		// Sine
		double val=0;
		for(j=0; j<nHarmonics; j++)
			val += amp[j]*sin(m2PI*i/(baseWavelength*(j+1)));
		if(val<sMin) val=sMin;
		if(val>sMax) val=sMax;
		sseq[i]=val;

		// bseq
		if(i%decisionSpacing==0)
		{
			bdir+=qrand(2)*2-1;
			if(bdir<-2) bdir = -2;
			if(bdir> 2) bdir =  2;
		}
		blast += bdir*bstep;
		if(blast<sMin)
		{
			blast=sMin;
			bdir=0;
		}
		if(blast>sMax)
		{
			blast=sMax;
			bdir=0;
		}
		bseq[i]=blast;
	}

	for(i=0; i<nPts; i++)
		printf("%d,%8.3lf,%8.3lf,%8.3lf,%8.3lf,%8.3lf,%8.3lf,%8.3lf\n",
		i,rseq[i],rudseq[i],udseq[i],dseq[i],aseq[i],sseq[i],bseq[i]);
	
	
	delete rseq;
	delete rudseq;
	delete udseq;
	delete dseq;
	delete aseq;
	delete sseq;
	delete bseq;
	return 0;
}

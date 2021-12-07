// J.E. (Ned) Lecky
// CoverTheory Verifier with Picks
// 1-10-99

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <math.h>

const int TARGET=1;
const int VISIT=2;



// VRan correctly generates random numbers 0-(maxRand-1) for maxRand up
//   to 2^31.  This routine is important since the library rand() function
//   only generates random integers up through 2^15
int VRand(int maxRand)
{
	int r=rand() | (rand()<<15) | ((rand()&1)<<30);

	return r%maxRand;
}


void StateCounter(int k1,int k2,int k3,int nTargetsAdded,double simMult)
{
	int k=k1*k2*k3;
	int D=k-nTargetsAdded;
	int simLength=(int)((double)k*simMult);
	int printmod=k/10;  // setup to print about 10 times along the way

	printf("Visit Counter k=%d t=%d simLength=%d\n",
		k,nTargetsAdded,simLength);

	// allocate visit tally vector
	unsigned char* state=new unsigned char[k];
	if(state==NULL)
	{
		printf("Can't allocate state array.\n");
		return;
	}

	// clear visit data
	memset(state,0,k*sizeof(char));

	// pick nSolutions random sites as "targets"
	int tSet=0;
	while(tSet<nTargetsAdded)
	{
		int r=VRand(k);
		if(state[r]==0)
		{
			state[r]=TARGET;
			tSet++;
		}
	}

	// run the simulation
	int nTarget=0;
	int nRepeat=0;
	int nVisit=0;
	for(int i=0; i<simLength; i++)
	{
		// here's our random pick
		int r1=VRand(k1);
		int r2=VRand(k2);
		int r3=VRand(k3);
		int r = r1 + r2*k1 + r3*k1*k2;

		// if we hit a target, nTarget++
		if(state[r]&TARGET) nTarget++;

		// if we have already visited here, nRepeat++
		if(state[r]&VISIT) nRepeat++;
		else
		{
			// first vist; sit the visit bit and nVisit++
			state[r]|=VISIT;
			nVisit++;
		}

		// pretty-print every so many lines, or on last line
		if(i%printmod==0 || i==k-1)
		{
			double N=i;
			double K=k;
			double c=nVisit/K;
			double cTheo=1.-exp(-N/K);
			double nTargetTheo=cTheo*2 * nTargetsAdded;

			printf("%d %d %.2lf %.2lf %d %.1lf %d\n",i,nVisit,c,cTheo,
				nTarget,nTargetTheo,nRepeat);
		}
	}
	delete state;
}


int main()
{
	srand(1);
	StateCounter(10,3,7,1,5.0);
	//srand(2);
	//StateCounter((int)pow(2,24),1,5.0);
	//srand(3);
	//StateCounter((int)pow(2,24),1,5.0);
	return 0;
}
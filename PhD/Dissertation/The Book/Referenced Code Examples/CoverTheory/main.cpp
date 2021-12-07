// Coverage Theory Verification
// Dissertation Coding Example
// J.E. (Ned) Lecky
// 1/19/99

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <math.h>

const int TARGET=1;
const int VISIT=2;

// Generate random number from 0 to max-1
int VRand(int max)
{
	return rand()%max;
}

// Simulate n tosses of a k-sided die
//   - insert nTargets desired targets
//   - store actual coverage and number of target hits
void StateCounter(int k,int n,int nTargets,double* cList,int* nTargetList)
{
	int sizeD=k-nTargets;

	// allocate visit tally vector
	unsigned char* state=new unsigned char[k];
	if(state==NULL)
	{
		printf("Can't allocate state array.\n");
		return;
	}

	// clear visit data
	memset(state,0,k*sizeof(char));

	// pick nTargets random sites as "targets"
	int tSet=0;
	while(tSet<nTargets)
	{
		int r=VRand(k);
		if(state[r]==0)
		{
			state[r]=TARGET;
			tSet++;
		}
	}

	// run the simulation
	int nHits=0;
	int nVisits=0;
	for(int i=0; i<n; i++)
	{
		// store away stats for later analysis
		double Cactual=(double)nVisits/(double)k;
		cList[i]=Cactual;
		nTargetList[i]=nHits;

		// now make the toss
		int r=VRand(k);

		// if we hit a target, increment count
		if(state[r]&TARGET) nHits++;

		// if we have not already hit this state, coverage is up
		if(!(state[r]&VISIT))
		{
			state[r]|=VISIT;
			nVisits++;
		}
	}

	delete state;
}

// Run the complete simulation
int main()
{
	srand(1);

	// all experimental data goes into this file
	FILE* fp=fopen("\\cover.dat","w");

	// Running tests at various k
	for(int test=0; test<6; test++)
	{
		// select k (number of sides on the die)
		int k;
		// select nTargets (number of target sides)
		int nTargets=1;
		switch(test)
		{
		case 0: k=2; break;
		case 1: k=3; break;
		case 2: k=6; nTargets=3; break;
		case 3: k=40; nTargets=2; break;
		case 4: k=1000; nTargets=4; break;
		case 5: k=4000; break;
		}

		// select a reasonable number of tosses known to generate
		//   high coverage
		int n=k*5;

		// number of simulation runs
		int iterCount=200;

		// number of individual tests to print
		int iterPrint=3;
		if(iterPrint>iterCount) iterPrint=iterCount;

		// allocate and clear coverage and target hit arrays
		double** cList=new double*[iterCount];
		int** nTargetList=new int*[iterCount];
		for(int i=0; i<iterCount; i++)
		{
			cList[i]=new double[n];
			nTargetList[i]=new int[n];
			for(int j=0; j<n; j++)
			{
				cList[i][j]=0.;
				nTargetList[i][j]=0;
			}
		}

		// print simulation column headers
		fprintf(fp,"Theory Testing  k=%d n=%d sims=%d m=%d\n",k,n,iterCount,nTargets);
		fprintf(fp,"    i,Ctheo,CtheoA, Cact,nTtheo, nTact,Pdtheo, Pdact");
		for(i=0; i<iterPrint; i++)
			fprintf(fp,",C%dact,T%dact",i,i);
		fprintf(fp,"\n");


		// run iterCount complete simulations
		for(i=0; i<iterCount; i++)
			StateCounter(k,n,nTargets,cList[i],nTargetList[i]);

		// print approximately 25 lines from the simulation data
		int printmod=n/25;
		if(printmod==0) printmod=1;
		
		// double precision versions
		double kd=k;
		double nTargetsd=nTargets;
		
		// analysis loop
		for(i=0; i<n; i++)
		{
			// print every so many lines, or on last line
			if(i%printmod==0 || i==n-1)
			{
				double nd=i;
				double cTheo = 1. - pow((1. - 1./kd),nd);
				double cTheoApprox = 1. - exp(-nd/kd);
				double PdTheo = 1. - pow((1. - nTargetsd/kd),nd);
				double nTargetTheo = nd/kd * nTargetsd;

				// average all tests
				double cSum=0.;
				double nTsum=0.;
				double nHit=0.;
				for(int j=0; j<iterCount; j++)
				{
					cSum+=cList[j][i];
					nTsum+=nTargetList[j][i];
					if(nTargetList[j][i]>0) nHit++;
				}
				double I=iterCount;

				// experimental averages
				double Cavg=cSum/I;
				double nTavg=nTsum/I;
				double Pd=nHit/I;

				fprintf(fp,"%5d, %4.02lf, %5.02lf, %4.02lf, %5.02lf, %5.02lf, %5.02lf, %5.02lf",
					i,cTheo,cTheoApprox,Cavg,nTargetTheo,nTavg,PdTheo,Pd);
				for(j=0; j<iterPrint; j++)
					fprintf(fp,", %4.02lf, %4d",cList[j][i],nTargetList[j][i]);
				fprintf(fp,"\n");
			}
		}

		// deallocate storage
		for(i=0; i<iterCount; i++)
		{
			delete cList[i];
			delete nTargetList[i];
		}	

		delete nTargetList;
		delete cList;
	}

	// close output file and exit
	fclose(fp);

	return 0;
}
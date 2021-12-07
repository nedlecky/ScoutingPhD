// Coverage Theory Verification
// J.E. (Ned) Lecky
// 1/19/99

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <math.h>

const int TARGET=1;
const int VISIT=2;
int k1,k2,k3;

int VRand(int maxRand)
{
	return rand()%maxRand;
}

void StateCounter(int k,int simLength,int nTargetsAdded,double* cList,int* nTargetList)
{
	int sizeD=k-nTargetsAdded;

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
//		int r1=VRand(k1);
//		int r2=VRand(k2);
//		int r3=VRand(k3);
//		int r = r1 + r2*k1 + r3*k1*k2;
		int r=VRand(k);

		// if we hit a target, nTarget++
		if(state[r]&TARGET) nTarget++;

		// if we have already visited here, nRepeat++
		if(state[r]&VISIT) nRepeat++;
		else
		{
			// first visit; set the visit bit and nVisit++
			state[r]|=VISIT;
			nVisit++;
		}

		// store away stats
		double c=(double)nVisit/(double)k;
		cList[i]=c;
		nTargetList[i]=nTarget;
	}
	delete state;
}

int main()
{
	srand(1);

	FILE* fp=fopen("\\cover.csv","w");

	for(int test=0; test<6; test++)
	{
		int k;
		switch(test)
		{
		case 0: k=2; break;
		case 1: k=3; break;
		case 2: k=6; break;
		case 3: k=40; break;
		case 4: k=1000; break;
		case 5: k=10000; break;
		}

		int iterCount=100;
		int simLen=k*5;
		int nTargets=1;
		int iterPrint=iterCount;
		if(iterPrint>10) iterPrint=10;

		double** cList=new double*[iterCount];
		int** nTargetList=new int*[iterCount];
		for(int i=0; i<iterCount; i++)
		{
			cList[i]=new double[simLen];
			nTargetList[i]=new int[simLen];
			for(int j=0; j<simLen; j++)
			{
				cList[i][j]=0.;
				nTargetList[i][j]=0;
			}
		}

		fprintf(fp,"Coverage k=%d nT=%d\n",k,nTargets);
		fprintf(fp,"i,Ctheo,CtheoA,Cavg,nTtheo,nTavg,Pdtheo,Pd");
		for(i=0; i<iterPrint; i++)
			fprintf(fp,",C%dexptl,nT%dexptl",i,i);
		fprintf(fp,"\n");


		for(i=0; i<iterCount; i++)
			StateCounter(k,simLen,nTargets,cList[i],nTargetList[i]);

		int printmod=simLen/50;
		if(printmod==0) printmod=1;
		for(i=0; i<simLen; i++)
		{
			// print every so many lines, or on last line
			if(i%printmod==0 || i==simLen-1)
			{
				double N=i+1;
				double K=k;
				double nt=nTargets;
				double cTheo = 1. - pow((1. - 1/K),N);
				double cTheoApprox = 1. - exp(-N/K);
				double Pdtheo=1.-exp(-N/(K/nt));
				double nTargetTheo=N/K * nt;

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
				double Cavg=cSum/I;
				double nTavg=nTsum/I;
				double Pd=nHit/I;

				fprintf(fp,"%d,%.02lf,%.02lf,%.02lf,%.02lf,%.02lf,%.02lf,%.02lf",
					i+1,cTheo,cTheoApprox,Cavg,nTargetTheo,nTavg,Pdtheo,Pd);
				for(j=0; j<iterPrint; j++)
					fprintf(fp,",%.02lf,%d",cList[j][i],nTargetList[j][i]);
				fprintf(fp,"\n");
			}
		}
		for(i=0; i<iterCount; i++)
		{
			delete cList[i];
			delete nTargetList[i];
		}	

		delete nTargetList;
		delete cList;
	}

	fclose(fp);
	

	return 0;
}
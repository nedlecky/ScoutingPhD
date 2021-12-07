// COMBINATIONAL WEIGHING STUDY FOR HAYSSEN
// 2/2/00
// Scouting Search Implementation
//
// Lecky Engineering, LLC
//   www.lecky.com
//   Dr. Ned Lecky
//   nlecky@lecky.com

#include "stdafx.h"
#include <memory.h>
#include <stdlib.h>
#include <windows.h>
#include <mmsystem.h>

// Slower but more evenhanded random integer generator
// returns integer mini <= x <= maxi
int RandInt(int mini,int maxi)
{
	double x=rand()/(double)RAND_MAX;

	return (int)(x*(double)(maxi-mini+1)) + mini;
}

// Faster but less well-behaved randint, used for scout decisions
int RandIntFast(int lo,int hi)
{
	return rand()%(hi-lo+1)+lo;
}

// Object implementation of the set of buckets
class Buckets
{
	int n;				// number of buckets
	int* weights;		// list of current bucket contents

	int targetWt;		// desired complete combo weight
	int typWt;			// typical weight per bucket
	int typVariation;	// typical variation in bucket weight
	int maxPicks;		// maximum bucket count in a combination

	int bestWeight;		// weight of best combo found
	int bestnPicks;		// count of buckets in best combo found
public:
	Buckets(int n,int targetWt0,int typWt0,int typVariation0,int maxPks);
	~Buckets();
	void Show(bool fAll=false);
	void FillBucket(int i);
	void FillAllEmptyBuckets(int seed=0);
	int MakeCombination(int nScouts,bool fEmpty=false);
	int BestWeight(void) {return bestWeight;}
	int BestCount(void) {return bestnPicks;}
};

Buckets::Buckets(int nBuckets,int targetWt0,int typWt0,int typVariation0,int maxPk0)
{
	n=nBuckets;
	weights=new int[n];
	memset(weights,0,n*sizeof(int));
	targetWt=targetWt0;
	typWt=typWt0;
	typVariation=typVariation0;
	maxPicks=maxPk0;
}

Buckets::~Buckets()
{
	delete weights;
}

void Buckets::Show(bool fAll)
{
	if(fAll)
	{
		printf("%d buckets\n",n);
		printf("typ=%d target=%d\n",typWt,targetWt);
	}
	for(int i=0; i<n; i++)
		printf("%02d: %5d\n",i,weights[i]);
}

// Statistical simulator for bucket filling
void Buckets::FillBucket(int i)
{
	switch(RandInt(1,10))
	{
	// COMMENT OUT empty buckets, since here we do selective refill
//	case 1: // make 10% empty
//		weights[i]=0; break;
	case 2: // make 10% extra heavy
		weights[i]=targetWt + RandInt(-typVariation,typVariation);
	default: // the rest are typical
		weights[i]=typWt + RandInt(-typVariation,typVariation);
	}
}

void Buckets::FillAllEmptyBuckets(int seed)
{
	if(seed) srand(seed);
	for(int i=0; i<n; i++)
		if(weights[i]==0)
			FillBucket(i);
}

// Scouting bucket combination search
int Buckets::MakeCombination(int nScouts,bool fEmpty)
{
	int* picks=new int[n];
	int* curPicks=new int[maxPicks];
	int* bestPicks=new int[maxPicks];

	bestWeight=9999999;
	bestnPicks=0;

	for(int scout=0; scout<nScouts; scout++)
	{
		memset(picks,0,n*sizeof(int));
		int wt=0;
		int nPicks=0;
		while(wt<targetWt && nPicks<maxPicks)
		{
			int p=RandIntFast(0,n-1);
			if(picks[p]==0)
			{
				picks[p]=1;
				curPicks[nPicks]=p;
				wt+=weights[p];
				nPicks++;
			}
		}
		if(wt>=targetWt)
			if(wt<bestWeight)
			{
				bestWeight=wt;
				bestnPicks=nPicks;
				memcpy(bestPicks,curPicks,nPicks*sizeof(int));
			}
	}

	if(fEmpty && bestnPicks)
	{
		printf("Empty bucket:");
		int wt=0;
		for(int i=0; i<bestnPicks; i++)
		{
			wt+=weights[bestPicks[i]];
			weights[bestPicks[i]]=0;
			printf(" %d",bestPicks[i]);
		}
		printf("=%d\n",wt);
	}

	delete picks;
	delete curPicks;
	delete bestPicks;

	return bestWeight;
}

int main(int argc, char* argv[])
{
	printf("ComboTest\n");
	srand(1234);

	int nBuckets=24;
	int targetWt=2000;
	int typCount=5;					// typical number of bins needed
	int typWt=targetWt/typCount;	// compute typical bin weight
	int typVariation=typWt/2;		// typical variation per bin
	int maxPicks=6;

	Buckets b(nBuckets,targetWt,typWt,typVariation,maxPicks);

	int minTime=99999;
	int maxTime=0;
	int minCount=99999;
	int maxCount=0;
	int minWeight=99999;
	int maxWeight=0;
	double timeSum=0;
	double countSum=0;
	double weightSum=0;
	int nScouts=10000;
	int nTrials=250;
	for(int i=0; i<nTrials; i++)
	{
		b.FillAllEmptyBuckets();
		
		DWORD t0=timeGetTime();
		int bestWeight=b.MakeCombination(nScouts,true);

		// found no combination?
		if(b.BestCount()==0)
		{
			printf("RETRY\n");
			b.Show(true);
			bestWeight=b.MakeCombination(nScouts,true);
		}
		DWORD t1=timeGetTime();

		// track execution time
		int eTime=t1-t0;
		timeSum+=eTime;
		if(eTime>maxTime) maxTime=eTime;
		if(eTime<minTime) minTime=eTime;

		// track bin count
		int bestCount=b.BestCount();
		if(bestCount>maxCount) maxCount=bestCount;
		if(bestCount<minCount) minCount=bestCount;
		countSum+=bestCount;

		// track weight
		if(bestWeight>maxWeight) maxWeight=bestWeight;
		if(bestWeight<minWeight) minWeight=bestWeight;
		weightSum+=bestWeight;

		// report best combination
		printf("Best Weight %d (%d bins) %d mS\n",bestWeight,bestCount,eTime);
	}
	
	// report min/max/avg time and count
	double avgTime=timeSum/nTrials;
	double avgCount=countSum/nTrials;
	double avgWeight=weightSum/nTrials;
	printf("avgTime = %.1lf mS  minTime = %d mS  maxTime = %d mS\n",avgTime,minTime,maxTime);
	printf("avgCount = %.1lf bins  minCount = %d bins  maxCount = %d bins\n",avgCount,minCount,maxCount);
	printf("avgWeight = %.1lf  minWeight = %d  maxWeight = %d\n",avgWeight,minWeight,maxWeight);

	return 0;
}


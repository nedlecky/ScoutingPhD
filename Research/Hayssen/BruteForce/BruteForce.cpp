// COMBINATIONAL WEIGHING STUDY FOR HAYSSEN
// 4/5/00
// Brute Force Search Implementation
//
// Lecky Engineering, LLC
//   www.lecky.com
//   Dr. Ned Lecky
//   nlecky@lecky.com

#include "stdafx.h"
#include <windows.h>
#include <mmsystem.h>
#include <stdlib.h>
#include <string.h>

// Globals set in main()
int maxk;	// maximum number of bins considered in a combination
int k;		// current number of bins considered
int count;	// statistical helper; count of combinations found

// Storage area for best combination found
int* bestCombination;
int bestWt;
int bestCount;
int gTargetWt;

// Storage area for bin readings
int* bins;


// Slower but more evenhanded random integer generator
// returns integer mini <= x <= maxi
int RandInt(int mini,int maxi)
{
	double x=rand()/(double)RAND_MAX;

	return (int)(x*(double)(maxi-mini+1)) + mini;
}

// Display a vector of integers n elements long
void ShowInt(int* v,int n,bool fIndex=false)
{
	char lbuf[512];
	char tbuf[128];
	lbuf[0]=0;
	for(int i=0; i<n; i++)
	{
		if(fIndex)
			sprintf(tbuf,"(%d)%d ",i,v[i]);
		else
			sprintf(tbuf,"%d ",v[i]);
		strcat(lbuf,tbuf);
	}
	printf("%s\n",lbuf);
}

// Load N bins trying to load targetWt total combination
void LoadBins(int* bins,int N,int targetWt)
{
	int typCount=5;					// typical number of bins needed
	int typWt=targetWt/typCount;	// compute typical bin weight
	int typVariation=typWt/2;		// typical variation per bin

	// load the bins
	for(int i=0; i<N; i++)
	{
		// variation handler
		switch(RandInt(1,10))
		{
		case 1: // make 10% empty
			bins[i]=0; break;
		case 2: // make 10% extra heavy
			bins[i]=targetWt + RandInt(-typVariation,typVariation);
		default: // the rest are typical
			bins[i]=typWt + RandInt(-typVariation,typVariation);
		}
	}
}

// Construct and evaluate all of the combinations
//  This is a recursive routine which constructs all combinations
//   down to k deep, keeping track of the total sum of all bins so far
//  When the last level is reached, the solution is checked to see
//   if it is the best so far.
void Choose(int N,int* choices,int level,int sum)
{
	// see if we've hit the end of the choosing process
	if(level==k)
	{
		// increment our count of combinations visited
		count++;

		// remember this combination if it is better than everything else
		if(sum>=gTargetWt && sum<bestWt)
		{
			bestWt=sum;
			bestCount=k;
			memcpy(bestCombination,choices,k*sizeof(int));
		}
	}
	else
	{
		// continue the search
		int start=0;
		if(level>0) start=choices[level-1]+1;

		for(int i=start; i<N; i++)
		{
			// record this level's choice
			choices[level]=i;
			
			// update the sum
			int mysum=sum+bins[i];
			
			// brute force all of them
			//Choose(N,choices,level+1,mysum);

			// more clever: only until you exceed bestWt
			if(mysum<bestWt) Choose(N,choices,level+1,mysum);
		}
	}
}

// Main routine
int main(int argc, char* argv[])
{
	printf("Brute Force Combo Simulator\n");
	
	// target combination weight
	int targetWt=2000;
	gTargetWt=targetWt;
	
	// number of bins
	int N=24;

	// maximum number of bins considered in a solution
	maxk=6;
	
	// allocate the bins
	bins=new int[N];

	// generate all combinations
	int* choices=new int[maxk];
	bestCombination=new int[maxk];

	// run some tests
	int minTime=99999;
	int maxTime=0;
	int minCount=999;
	int maxCount=0;
	int minWeight=99999;
	int maxWeight=0;
	double timeSum=0;
	double countSum=0;
	double weightSum=0;
	int nTrials=250;
	for(int test=1; test<=nTrials; test++)
	{
		printf("Test %d: ",test);

		// load bins them randomly
		LoadBins(bins,N,targetWt);

		// show bin contents
		//ShowInt(bins,N,true);

		// construct and evaluate all 1, 2, 3, ..., maxk bin combos
		DWORD t0=timeGetTime();
		bestWt=999999;
		for(k=1; k<=maxk; k++)
		{
			count=0;
			Choose(N,choices,0,0);
			//printf("%d %d-combinations evaluated (bestWt=%d)\n",count,k,bestWt);
		}	
		DWORD t1=timeGetTime();

		// track execution time
		int eTime=t1-t0;
		timeSum+=eTime;
		if(eTime>maxTime) maxTime=eTime;
		if(eTime<minTime) minTime=eTime;

		// track size
		if(bestCount>maxCount) maxCount=bestCount;
		if(bestCount<minCount) minCount=bestCount;
		countSum+=bestCount;

		// track weight
		int bestWeight=bestWt;
		if(bestWeight>maxWeight) maxWeight=bestWeight;
		if(bestWeight<minWeight) minWeight=bestWeight;
		weightSum+=bestWeight;

		// report best combination
		printf("Best Weight %d (%d bins) %d mS ",bestWt,bestCount,eTime);
		ShowInt(bestCombination,bestCount);
	}

	// report min/max/avg time and count
	double avgTime=timeSum/nTrials;
	double avgCount=countSum/nTrials;
	double avgWeight=weightSum/nTrials;
	printf("avgTime = %.1lf mS  minTime = %d mS  maxTime = %d mS\n",
		avgTime,minTime,maxTime);
	printf("avgCount = %.1lf bins  minCount = %d bins  maxCount = %d bins\n",
		avgCount,minCount,maxCount);
	printf("avgWeight = %.1lf  minWeight = %d  maxWeight = %d\n",
		avgWeight,minWeight,maxWeight);

	// cleanup
	delete bestCombination;
	delete choices;
	delete bins;
	return 0;
}


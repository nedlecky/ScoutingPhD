//
// Lecky Engineering, LLC
// Combinational Weighing Scout Code
// Dr. J.E. (Ned) Lecky
// 2/02/00
//

#include "stdafx.h"
#include <memory.h>
#include <stdlib.h>

int random(int lo, int hi)
{
	double p=(double)rand()/(double)RAND_MAX;
	double drange=hi-lo;

	int x = lo + (int)(p*drange);

	return x;
}

class Buckets
{
	int* weights;
	int n;

	int maxWeight;
	int minWeight;
	int avgWeight;
	int targetWeight;
public:
	Buckets(int n,int minWt,int maxWt,int avgWt,int targetWt);
	~Buckets();
	void LoadEmptyBuckets(void);
	void Show(bool fAll=false);
	void FillBucket(int i);
	void FillAllEmptyBuckets(void);
	int MakeCombinationExact(bool fEmpty=false);
	int MakeCombination(bool fEmpty=false);
};

Buckets::Buckets(int nBuckets,int minWt,int maxWt,int avgWt,int targetWt)
{
	n=nBuckets;
	weights=new int[n];
	memset(weights,0,n*sizeof(int));
	minWeight=minWt;
	maxWeight=maxWt;
	avgWeight=avgWt;
	targetWeight=targetWt;
}
Buckets::~Buckets()
{
	delete weights;
}
void Buckets::LoadEmptyBuckets(void)
{
}
void Buckets::Show(bool fAll)
{
	if(fAll)
	{
		printf("%d buckets\n",n);
		printf("min=%d max=%d avg=%d target=%d\n",minWeight,maxWeight,avgWeight,targetWeight);
	}
	for(int i=0; i<n; i++)
		printf("%02d: %5d\n",i,weights[i]);
}
void Buckets::FillBucket(int i)
{
	weights[i]=random(minWeight,maxWeight);
}
void Buckets::FillAllEmptyBuckets(void)
{
	for(int i=0; i<n; i++)
		if(weights[i]==0)
			FillBucket(i);
}
int Buckets::MakeCombinationExact(bool fEmpty)
{
	return 0;
}
int Buckets::MakeCombination(bool fEmpty)
{
	int* picks=new int[n];
	int* bestPicks=new int[n];

	int bestWeight=9999999;

	for(int scout=0; scout<1000000; scout++)
	{
		memset(picks,0,n*sizeof(int));
		int wt=0;
		int nPicks=0;
		while(wt<targetWeight && nPicks<n)
		{
			int p=random(0,n-1);
			if(picks[p]==0)
			{
				picks[p]=1;
				wt+=weights[p];
				nPicks++;
			}
		}
		if(wt>=targetWeight)
			if(wt<bestWeight)
			{
				bestWeight=wt;
				memcpy(bestPicks,picks,n*sizeof(int));
//				printf("new best %d at %d\n",bestWeight,scout);
			}
	}

	if(fEmpty)
	{
	}

	delete picks;
	delete bestPicks;

	return bestWeight;
}

int main(int argc, char* argv[])
{
	printf("ComboTest\n");
	srand(1234);

	int nBuckets=10;
	int minWeight=300;
	int maxWeight=500;
	int avgWeight=400;
	int targetWeight=2000;

	Buckets b(nBuckets,minWeight,maxWeight,avgWeight,targetWeight);

	b.Show(true);

	b.FillAllEmptyBuckets();
	for(int i=0; i<10; i++)
	{
		int wtExact=b.MakeCombinationExact(false);
		int wtApprox=b.MakeCombination(true);
		printf("%5d %5d %5d\n",wtExact,wtApprox,wtApprox-wtExact);
		b.FillAllEmptyBuckets();
	}
	return 0;
}


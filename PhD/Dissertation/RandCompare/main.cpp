#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <math.h>

const int psize=100;

unsigned char SR=1;
int LFSR8()
{
	unsigned char inbit=SR&1;
	if(SR&2) inbit++;
	if(SR&32) inbit++;
	if(SR&64) inbit++;
	inbit&=1;
	SR>>=1;
	SR|=inbit<<7;
	return SR;
}

int VRand(int m)
{
	//int a=rand()%m;
	int a;
rea:
	a=LFSR8()-1;
	if(a>=m) goto rea;
	return a;
}


void Simulate()
{
	int* bins=new int[psize];
	memset(bins,0,psize*sizeof(int));

	int covered=0;
	int repeated=0;
	int limit=psize*100;
	for(int i=1; i<limit; i++)
	{
		int c=VRand(psize);
		if(bins[c]) repeated++;
		else covered++;
		bins[c]++;
		if(!(i%(psize/5)) || i==limit-1)
		{
			double coveragePct=(double)covered*100./(double)psize;
			double repeatedPct=(double)repeated*100./(double)i;

			printf("%4d %5.1lf %5.1lf\n",i,coveragePct,repeatedPct);
		}
	}

	double sum=0;
	double sumsq=0;
	int imin=0;
	int min=999999;
	int imax=0;
	int max=0;
	for(i=0; i<psize; i++)
	{
		printf("%4d %4d\n",i,bins[i]);
		if(bins[i]<min)
		{
			min=bins[i];
			imin=i;
		}
		if(bins[i]>max)
		{
			max=bins[i];
			imax=i;
		}
		sum+=bins[i];
		sumsq+=bins[i]*bins[i];
	}

	double n=psize;
	double avg=sum/n;
	double var=(n*sumsq - sum*sum)/(n*(n-1.));
	double std=sqrt(var);

	printf("Max: %d at %d\n",max,imax);
	printf("Min: %d at %d\n",min,imin);
	printf("Avg: %.1lf\n",avg);
	printf("Std: %.1lf\n",std);

	delete bins;
}


int main()
{
	srand(1);

	printf("Random Comparison (%d)\n",psize);
	Simulate();

	return 0;
}
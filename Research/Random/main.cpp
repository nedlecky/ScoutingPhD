// J.E. (Ned) Lecky
// Qualification of Random number generator
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <math.h>

// vrand correctly generates random numbers 0-(maxRand-1) for maxRand up
//   to 2^31.  This routine is important since the library rand() function
//   only generates random integers up through 2^15
int vrand(int maxRand)
{
	int r=rand() | (rand()<<15) | ((rand()&1)<<30);

	return r%maxRand;
}

// A better way to get longer sequences, due to Knuth and H.W. Lewis
// (see Press p. 284)
unsigned long qseed=1;
void sqrand(unsigned int seed)
{
	qseed=seed;
}
int qrand(int maxRand)
{
	qseed = qseed*1664525L + 1013904223L;
	return qseed % maxRand;
}




int main()
{
	int N = 16000000;	// how many rand()s to generate
	int r = 200000;		// rands range from 0 to maxRand-1
	
	double d_r=r;
	double d_N=N;

	int* bins=new int[r];

	for(int test=0; test<2; test++)
	{
		srand(1);
		sqrand(1);
		memset(bins,0,r*sizeof(int));

		// generate nRands random number
		double sum=0;
		double sumsq=0;
		int minRand=r;
		int maxRand=0;
		for(int i=0; i<N; i++)
		{
			int rnd;
			switch(test)
			{
			case 0:
				rnd=vrand(r); break;
			case 1:
				rnd=qrand(r); break;
			}

			sum+=rnd;
			sumsq+=(double)rnd*(double)rnd;
			if(rnd<minRand) minRand=rnd;
			if(rnd>maxRand) maxRand=rnd;

			// increment corresponding histogram bin
			bins[rnd]++;
		}

		// display results
		double t=0;
		int minCount=r;
		int maxCount=0;
		for(i=0; i<r; i++)
		{
			t += bins[i]*bins[i];
			if(bins[i]>maxCount) maxCount=bins[i];
			if(bins[i]<minCount) minCount=bins[i];
		}


		double avg=sum/d_N;
		double var=(d_N*sumsq - sum*sum)/(d_N*d_N);
		if(var>0) var=sqrt(var);

		double chisq=(d_r*t/d_N) - d_N;
		double target=r;
		double quality=100*(1. - fabs(chisq-target)/target);
		printf("tech %2d: avg=%8.1lf stdev=%8.1lf chisq = %8.3lf q=%8.3lf\n",
			test,avg,var,chisq,quality);
		printf("   min=%d max=%d minCount=%d maxCount=%d\n",
			minRand,maxRand,minCount,maxCount);
	}

	delete bins;
	return 0;
}
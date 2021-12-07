// J.E. (Ned) Lecky
// Qualification of Random number generator
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <math.h>


// VRand correctly generates random numbers 0-(maxRand-1) for maxRand up
//   to 2^31.  This routine is importand since the library rand() function
//   only generates random integers up through 2^15
int VRand(int maxRand)
{
	int r=rand() | (rand()<<15) | ((rand()&1)<<30);

	return r%maxRand;
}

// BadRand illustrates how NOT to generate random numbers from several
//  random numbers
int BadRand(int maxRand)
{
	int nSums=maxRand/RAND_MAX+1;

	int r=0;
	for(int i=0; i<nSums; i++) r+=rand();

	return r%maxRand;
}

// UniRand synthesizes a 31-bit random number from 31 calls to rand()&1.
//   This is a test of our ability to generate large random numbers from
//   a single random bit generator
int UniRand(int maxRand)
{
	int nBits=31;
	int r=0;
	for(int b=0; b<nBits; b++)
		r |= (rand()&1) << b;

	return r%maxRand;
}


// 
const int nBins=40;			// number of histogram bins
const int nRands=2000000;	// how many rand()s to generate
const int maxRand=131072;	// rands range from 0 to maxRand-1
int main()
{
	int* bins=new int[nBins];

	for(int r=0; r<3; r++)
	{
		// reset random generator and clear hist bins
		srand(0);
		memset(bins,0,nBins*sizeof(int));
		int binSize=maxRand/nBins;

		// generate nRands random number
		for(int i=0; i<nRands; i++)
		{
			int rand=0;
			switch(r)
			{
			case 0:
				rand=BadRand(maxRand); break;
			case 1:
				rand=VRand(maxRand); break;
			case 2:
				rand=UniRand(maxRand); break;
			}

			// increment corresponding histogram bin
			int bin=rand/binSize;
			bins[bin]++;
		}

		// display results
		for(i=0; i<nBins; i++)
			printf("%d %d\n",i,bins[i]);
	}

	delete bins;
	return 0;
}
// J.E. (Ned) Lecky
// LFSR Comparison
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <math.h>
#include <conio.h>


// VRand correctly generates random numbers 0-(maxRand-1) for maxRand up
//   to 2^31.  This routine is importand since the library rand() function
//   only generates random integers up through 2^15
int VRand(int maxRand)
{
	int r=rand() | (rand()<<15) | ((rand()&1)<<30);

	return r%maxRand;
}

unsigned int LFSRstate=1;
unsigned int NextLFSR(void)
{
	unsigned bit=LFSRstate&1;
	//if(LFSRstate&2) bit++;
	if(LFSRstate&16) bit++;
	if(LFSRstate&32) bit++;
	if(LFSRstate&128) bit++;
	//if(LFSRstate&1) bit++;
	//if(LFSRstate&0x10000000) bit++;
	//if(LFSRstate&0x08000000) bit++;
	bit&=1;

	LFSRstate<<=1;
	LFSRstate&=255;
	LFSRstate|=bit;
	//printf("%d\n",LFSRstate);
	//getche();
	return LFSRstate;
}

int UniRand(int maxRand)
{
	return 0;
	int nBits=2;
	int r=0;
	for(int b=0; b<nBits; b++)
		r |= (NextLFSR()&1) << b;

	return r%maxRand;
}

int LFSRRand(int maxRand)
{
	return NextLFSR()%maxRand;
	//int n=NextLFSR()&3;
	//while(n==3) n=NextLFSR()&3;
	//return n;//(NextLFSR()&3)%maxRand;
}


// 
const int nBins=10;			// number of histogram bins
const int nRands=256000;	// how many rand()s to generate
const int maxRand=256;		// rands range from 0 to maxRand-1
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
				rand=VRand(maxRand); break;
			case 1:
				rand=LFSRRand(maxRand); break;
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
// Timer.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <windows.h>
#include <largeint.h>
#include <math.h>

// Timer interface
double msec_ticks=0;		/* Milliseconds per tick */
static double LItod(LARGE_INTEGER i)
{
	return(ldexp((double)(i.HighPart),32)+(double)(i.LowPart));
}

static int InitTimer(void)
{
	LARGE_INTEGER Frequency;

	if (!QueryPerformanceFrequency(&Frequency))
		return(-1);

	msec_ticks = 1000.0/LItod(Frequency);
	return(0);
}

// #func
double msec(void)
// Returns current time in milliseconds using Windows'
// QueryPerformanceCounter() call, which is quite accurate.
// #returns
// DOUBLE  time in mS
{
	LARGE_INTEGER li; 

	if (msec_ticks == 0.0)
		InitTimer();

	QueryPerformanceCounter(&li);
	
	return ((ldexp((double)(li.HighPart),32)+(double)(li.LowPart))*msec_ticks);
}

int main(int argc, char* argv[])
{
	printf("Hello World!\n");

	double t0=msec();

	for(int i=0; i<100; i++)
	{
		double t=msec()-t0;
		printf("Time is %lf\n",t);
	}

	return 0;
}


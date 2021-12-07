// Filter1.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdio.h>

const int maxSamples=10000;
double t[maxSamples];
double x[maxSamples];
double f0[maxSamples];
double f1[maxSamples];
double p0[maxSamples];
double p1[maxSamples];

double Vaverage(double* v,int n)
{
	double sum=0;
	for(int i=0; i<n; i++)
		sum+=v[i];
	return sum/(double)n;
}
void PeakTrough(double* x,int n,int window,double thresh,FILE* fp)
{
	if(window>=n) return;

	int dir=1;
	int peak0=0;
	int trough0=0;

	double avg=Vaverage(x,window);
	double maxAvg=avg;
	double minAvg=avg;
	int iMax=window;
	int iMin=window;
	double lastPeak[2];
	double lastTrough[2];
	
	for(int i=0; i<n; i++)
	{
		p0[i]=7;
		p1[i]=0;
	}
	lastPeak[0]=0;
	lastPeak[1]=0;
	lastTrough[0]=0;
	lastTrough[1]=0;

	double p1val=0;
	for(i=window+1; i<n; i++)
	{
		avg=Vaverage(x+i-window,window);
		if(dir==1)
		{
			if(avg>maxAvg)
			{
				maxAvg=avg;
				iMax=i;
			}
			else if(avg<maxAvg-thresh)
			{
				fprintf(fp,"  peak at %5d %.4lf (%d)\n",iMax,maxAvg,iMax-peak0);
				lastPeak[0]=lastPeak[1];
				lastPeak[1]=maxAvg;
				dir=0;
				minAvg=avg;
				peak0=iMax;
				p0[iMax]=12;

			}
		}
		else
		{
			if(avg<minAvg)
			{
				minAvg=avg;
				iMin=i;
			}
			else if(avg>minAvg+thresh)
			{
				fprintf(fp,"trough at %5d %.4lf (%d)\n",iMin,minAvg,iMin-trough0);
				lastTrough[0]=lastTrough[1];
				lastTrough[1]=minAvg;
				dir=1;
				p1val = 0.125 * (lastPeak[0]+lastTrough[1]) + 
					0.375 * (lastPeak[1]+lastTrough[0]);
				maxAvg=avg;
				trough0=iMin;
				p0[iMin]=2;
			}
		}
		p1[i]=p1val;
	}
}

void TriggeredAverage(double* t,double triggerTime,double* x,int n,double* out)
{
	double sum=0;
	bool fTrigger=false;
	int count=0;
	for(int i=0; i<n; i++)
	{
		if(fTrigger)
		{
			sum+=x[i];
			count++;
		}
		else
		{
			if(t[i]>=triggerTime)
			{
				fTrigger=true;
				printf("triggered at %d %lf\n",i,t[i]);
			}
		}

		if(fTrigger && count>0)
			out[i]=sum/(double)(count);
		else
			out[i]=x[i];
	}
}

void MovingAverage(double* x,int n,double* out,int window)
{
	double sum=0;
	for(int i=0; i<n; i++)
	{
		int lolim=i-window+1;
		if(lolim<0) lolim=0;

		double sum=0;
		for(int j=lolim; j<=i; j++)
			sum+=x[j];

		out[i]=sum/(double)(i-lolim+1);
	}
}

int main(int argc, char* argv[])
{
	printf("Load Cell Filtering\n");
	
	char* filename="..\\data\\200gA.txt";
	char* outFile="..\\out.txt";
	//FILE* out=stdout;
	FILE* out=fopen(outFile,"w");
	if(out==NULL)
	{
		printf("Can't open output file [%s]\n",outFile);
		return 1;
	}

	fprintf(out,"Load Cell Filtering\n");

	FILE* fp=fopen(filename,"r");
	if(fp==NULL)
	{
		printf("Can't open input file [%s]\n",filename);
		return 1;
	}

	char lbuf[1024];
	int nSamples=0;
	while(fgets(lbuf,1020,fp))
	{
		double t0,x0;
		if(2==sscanf(lbuf,"%lf %lf",&t0,&x0))
		{
			if(nSamples<maxSamples)
			{
				t[nSamples]=t0;
				x[nSamples]=x0;
				nSamples++;
			}
		}
	}
	fclose(fp);
	if(nSamples<1)
	{
		printf("File [%s] contained no samples.\n",filename);
		return 1;
	}

	fprintf(out,"%d samples read from [%s].\n",nSamples,filename);
	printf("%d samples read from [%s].\n",nSamples,filename);
	
	int finalCount=100;
	double lastAvg=Vaverage(x+nSamples-finalCount,finalCount);
	printf("Average of last %d samples = %.4lf\n",finalCount,lastAvg);
	
	PeakTrough(x,nSamples,10,0.1,out);
	MovingAverage(x,nSamples,f0,520);
	TriggeredAverage(t,0.7,f0,nSamples,f1);

	for(int i=0; i<nSamples; i++)
		fprintf(out,"%8.4lf %8.4lf %8.4lf %8.4lf\n",t[i],x[i],f0[i],f1[i]);

	if(out!=stdout) fclose(out);

	return 0;
}


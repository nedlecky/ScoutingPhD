// 8PAnalyze.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdio.h>
#include <string.h>


int main(int argc, char* argv[])
{
	if(argc!=2)
	{
		printf("Usage:\n\t8panalyze <file>\n");
		return 1;
	}

	FILE* fp=fopen(*++argv,"r");
	if(fp==NULL)
	{
		printf("Can't open data file [%s].\n",*argv);
		return 0;
	}

	int nLines=0;
	char lineBuf[1024];

	int maxD=100;
	int* h=new int[maxD];
	int* sum=new int[maxD];
	int* maxN=new int[maxD];
	int* minN=new int[maxD];
	for(int i=0; i<maxD; i++)
	{
		h[i]=0;
		sum[i]=0;
		minN[i]=99999999;
		maxN[i]=0;
	}

	int fHeader=1;
	while(1==fscanf(fp,"%s",lineBuf))
	{
		int t,d,n,p1;
		int chk=sscanf(lineBuf,"%d,%d,%d,%d",&t,&d,&n,&p1);
		if(chk!=4)
		{
			if(fHeader)
			{
				if(feof(fp))
				{
					printf("ERROR: Entire file is of wrong data type.\n");
					goto cleanup;
				}
				else continue;
			}
			else
			{
				printf("ERROR data [%s]\n",lineBuf);
				goto cleanup;
			}
		}

		fHeader=0;
		h[d]++;
		sum[d]+=n;
		if(n<minN[d]) minN[d]=n;
		if(n>maxN[d]) maxN[d]=n;

		nLines++;
		if(!(nLines%1000))
			printf(".");
	}

	printf("\nTotal Lines Read: %d\n",nLines);

	for(i=0; i<maxD; i++)
	{
		if(h[i]>0)
		{
			double avg=(double)sum[i]/(double)h[i];
			printf("%2d %5d %6.0lf %6d %6d\n",i,h[i],avg,minN[i],maxN[i]);
		}
	}

cleanup:
	delete h;
	delete sum;
	delete minN;
	delete maxN;
	fclose(fp);
	return 0;
}

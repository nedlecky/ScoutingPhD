// Combination Generator
// Lecky Engineering, LLC
//    for Hayssen

#include "stdafx.h"
#include "string.h"

int N=24;
int k=4;
int nChoices=0;

void Show(int* choices)
{
	char lbuf[128];
	char tbuf[32];
	lbuf[0]=0;
	for(int i=0; i<k; i++)
	{
		sprintf(tbuf,"%2d ",choices[i]);
		strcat(lbuf,tbuf);
	}
	nChoices++;
	printf("%3d: %s\n",nChoices,lbuf);
}

void Choose(int* choices,int level)
{
	if(level==k)
	{
		Show(choices);
	}
	else
	{
		int start=0;
		if(level>0) start=choices[level-1]+1;
		for(int i=start; i<N; i++)
		{
			choices[level]=i;
			Choose(choices,level+1);
		}
	}
}

int main(int argc, char* argv[])
{
	printf("%d Combination Generator\n",N);
	int* choices=new int[k];

	Choose(choices,0);

	delete choices;
	return 0;
}


// 15PuzzleHW.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "core.h"
#include <string.h>
#include <stdlib.h>
#include <math.h>


// A better way to get longer sequences, due to Knuth and H.W. Lewis
// (see Press p. 284)
unsigned long qseed=1;
void sqrand(unsigned int seed)
{
	qseed=seed;
}
int qrand(void)
{
	qseed = qseed*1664525L + 1013904223L;
	return qseed;
}
int rand4(void)
{
	return (qrand()&0xC0000000)>>30;
}

Square::Square(int i)
{
	cur=0;
	goal=0;
	index=i;
	udlr[0]=NULL;
	udlr[1]=NULL;
	udlr[2]=NULL;
	udlr[3]=NULL;
}
Square::~Square()
{
}
void Square::SetNeighbors(Square* u,Square* d,Square* l,Square* r)
{
	udlr[0]=u;
	udlr[1]=d;
	udlr[2]=l;
	udlr[3]=r;
}
int Square::Move(void)
{
	while(1)
	{
		int r=rand4();
		if(r==lastFrom) continue;
		if(udlr[r]!=NULL)
		{
			cur=udlr[r]->Cur();
			udlr[r]->SetCur(0,r^1);
			return udlr[r]->Index();
		}
	}
}


Game3x3::Game3x3()
{
	// create the cell objects
	for(int i=0; i<9; i++)
		square[i]=new Square(i);

	// Attach I/Os
	square[0]->SetNeighbors(NULL,square[3],NULL,square[1]);
	square[1]->SetNeighbors(NULL,square[4],square[0],square[2]);
	square[2]->SetNeighbors(NULL,square[5],square[1],NULL);
	square[3]->SetNeighbors(square[0],square[6],NULL,square[4]);
	square[4]->SetNeighbors(square[1],square[7],square[3],square[5]);
	square[5]->SetNeighbors(square[2],square[8],square[4],NULL);
	square[6]->SetNeighbors(square[3],NULL,NULL,square[7]);
	square[7]->SetNeighbors(square[4],NULL,square[6],square[8]);
	square[8]->SetNeighbors(square[5],NULL,square[7],NULL);
}
Game3x3::~Game3x3()
{
	// free the cell objects
	for(int i=0; i<9; i++)
		delete square[i];
}
void Game3x3::SetGoal(int* x)
{
	for(int i=0; i<9; i++)
		square[i]->SetGoal(*x++);
}
void Game3x3::SetState(int* x)
{
	for(int i=0; i<9; i++)
	{
		if(!*x) empty=i;
		square[i]->SetCur(*x++,-1);
	}

}
void Game3x3::UnloadState(int* x)
{
	for(int i=0; i<9; i++)
		*x++=square[i]->Cur();

}
void Game3x3::ShowState(void)
{
	for(int i=0; i<3; i++)
	{
		char lbuf[64];
		lbuf[0]=0;
		for(int j=0; j<3; j++)
		{
			char tbuf[16];
			sprintf(tbuf,"%1d ",square[i*3+j]->Cur());
			strcat(lbuf,tbuf);
		}
		printf("%s\n",lbuf);
	}
	printf(" empty=%d\n",empty);
}
void Game3x3::ShowState(FILE* fp)
{
	for(int i=0; i<9; i++)
		fprintf(fp,"%d%c",square[i]->Cur(),i==8?' ':',');
	fprintf(fp,"\n");
}
void Game3x3::Move(void)
{
	empty=square[empty]->Move();
}
int Game3x3::IsGoal(void)
{
	for(int i=0; i<9; i++)
		if(square[i]->Cur()!=square[i]->Goal()) return 0;
	return 1;
}

int main(int argc, char* argv[])
{
	printf("8-Puzzle Simulator\n");
	sqrand(1);

	FILE*fp=fopen("\\Research\\8P10KP=0.99.csv","w");

	int goal[]={
		1,2,3,
		8,0,4,
		7,6,5};
	int init[9];

	Game3x3 g;
	g.SetGoal(goal);

	int rSize=100000;
	int nTrials=10000;
	int maxN=100000000;
	double Plimit=0.99;
	fprintf(fp,"8-Puzzle\njumble,nPuzzles,maxN,Plimit\n");
	fprintf(fp,"%d,%d,%d,%.2lf\n\n",rSize,nTrials,maxN,Plimit);

	fprintf(fp,"trial,depth,nfinder,n,Popt,puzzle...\n");
	
	// clear stat monitors
	double* count=new double[rSize];
	double* sum=new double[rSize];
	for(int i=0; i<rSize; i++)
	{
		count[i]=0;
		sum[i]=0;
	}

	for(int trial=0; trial<nTrials; trial++)
	{
		printf("\nTrial %d:\n",trial+1);
		g.SetState(goal);
		int thisJumble=rSize+rand4();
		for(int i=0; i<thisJumble; i++)
			g.Move();
		g.ShowState();

		g.UnloadState(init);

		int d=40;
		int nSolve;
		double Popt=0.;
		for(i=1; i<=maxN && Popt<Plimit; i++)
		{
			g.SetState(init);
			for(int m=1; m<d; m++)
			{
				g.Move();
				if(g.IsGoal())
				{
					d=m;
					nSolve=i+1;
					Popt=1-exp(-i/pow(1.67,d));
					printf("(%d:%.2lf)",d,Popt);
					break;
				}
			}
			if(i%100000==0)
			{
				Popt=1-exp(-i/pow(1.67,d));
				printf(".");
			}
		}
		Popt=1-exp(-i/pow(1.67,d));
		printf("[%d:%.2lf]\n",d,Popt);
		count[d]++;
		sum[d]+=nSolve;
		fprintf(fp,"%d,%d,%d,%d,%.4lf",trial,d,i-1,nSolve,Popt);
		g.SetState(init);
		g.ShowState(fp);
		fflush(fp);
	}
	printf("\nDone.\n");

	fprintf(fp,"\ndepth,nPuzzle,avgN\n");
	for(i=0; i<rSize; i++)
	{
		if(count[i]==0) continue;
		double avg=sum[i]/count[i];
		fprintf(fp,"%d,%.0lf,%.0lf\n",
			i,count[i],avg);
	}

	fclose(fp);

	delete sum;
	delete count;

	return 0;
}


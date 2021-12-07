// 15PuzzleHW.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "core.h"
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <conio.h>

void Summarize(char* fname=NULL);
char movelist[1024];


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
char m[]="0";
int Square::Move(void)
{
	while(1)
	{
		int r=rand4();
		if(r==lastFrom) continue;
		if(udlr[r]!=NULL)
		{
			m[0]=r+'0';
			strcat(movelist,m);
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

int maxDepth=200;
int nTrials=1;
int maxN=10000000;
double* count=NULL;
double* sum=NULL;
int main(int argc, char* argv[])
{
	printf("8-Puzzle Simulator\n");
	sqrand(1);

	int r1=qrand();
	int r2=qrand();
	int r3=qrand();


	FILE*fp=fopen("\\Research\\solndepth.csv","w");

	int goal[]={
		1,2,3,+
		8,0,4,
		7,6,5};
	int p30[]={
		1,6,7,
		2,0,8,
		3,4,5};
	int init[9];

	Game3x3 g;
	g.SetGoal(goal);

	fprintf(fp,"8-Puzzle Repeater");

	fprintf(fp,"trial,seed,depth,nfinder,n,Popt,movelist,puzzle...\n");
	
	// clear stat monitors
	count=new double[maxDepth];
	sum=new double[maxDepth];
	for(int i=0; i<maxDepth; i++)
	{
		count[i]=0;
		sum[i]=0;
	}

	for(int trial=0; trial<nTrials; trial++)
	{
		printf("\nTrial %d:\n",trial+1);
		g.SetState(p30);
		g.ShowState();

		g.UnloadState(init);

		int d=maxDepth;
		double Popt=0.;
		unsigned long seed0=qseed;
		for(i=1; i<=maxN; i++)
		{
			g.SetState(init);
			seed0=qseed;
			movelist[0]=0;
			for(int m=1; m<d; m++)
			{
				g.Move();
				if(g.IsGoal())
				{
					count[m]++;
					sum[m]+=i;
					Popt=1-exp(-i/pow(1.67,m));
					printf("(%d:%.2lf)",m,Popt);
					fprintf(fp,"%d,'%lu,%d,%d,%.4lf,'%s\n",
						trial,seed0,m,i,Popt,movelist);
					fflush(fp);
					if(kbhit())
					{
						while(kbhit()) getch();
						Summarize();
						Summarize("\\Research\\intersum.csv");
					}
				continue;
				}
			}
			if(i%100000==0)
			{
				Popt=1-exp(-i/pow(1.67,d));
				printf(".");
			}
		}
	}
	printf("\nDone.\n");
	Summarize();
	Summarize("\\Research\\finalsum.csv");
	fclose(fp);

	delete sum;
	delete count;

	return 0;
}

void Summarize(char* fname)
{
	FILE* fp;
	if(fname==NULL)
		fp=stdout;
	else
		fp=fopen(fname,"w");
	if(fp==NULL)
	{
		printf("ERROR: Can't open [%s]\n",fname);
		return;
	}

	fprintf(fp,"\ndepth,nSolns,avgN\n");
	for(int i=0; i<maxDepth; i++)
	{
		if(count[i]==0) continue;
		double avg=sum[i]/count[i];
		fprintf(fp,"%d,%.0lf,%.0lf\n",
			i,count[i],avg);
	}

	if(fp!=NULL && fp!=stdout) fclose(fp);
}

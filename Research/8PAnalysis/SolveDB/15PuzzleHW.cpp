// 15PuzzleHW.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "core.h"
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <conio.h>


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
void Game3x3::SetState(int hash)
{
	for(int i=8; i>=0; i--)
	{
		int x=hash%10;
		hash/=10;
		if(!x) empty=i;
		square[i]->SetCur(x,-1);
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

void Summarize(int nSolved,int* count,int* sum,int maxDepth,char* fname=NULL);
void Summarize(int nSolved,int* count,int* sum,int maxDepth,char* fname)
{
	FILE*fp=stdout;
	
	if(fname) fp=fopen(fname,"w");
	if(fp==NULL) return;

	fprintf(fp,"%d puzzles analyzed.\n",nSolved);
	fprintf(fp,"depth,nPuzzle,avgN\n");
	int total=0;
	for(int i=0; i<maxDepth; i++)
	{
		if(count[i]==0) continue;
		double avg=(double)sum[i]/(double)count[i];
		fprintf(fp,"%d,%d,%.0lf\n",
			i,count[i],avg);
		total+=count[i];
	}
	fprintf(fp,"%d puzzles solved.\n",total);

	if(fp!=stdout) fclose(fp);
}

int main(int argc, char* argv[])
{
	printf("8-Puzzle Database Improver\n");
	sqrand(1);

	FILE* fp=fopen("\\Research\\8pdb2.csv","w");
	FILE* fpin=fopen("\\Research\\8pdb.dat","r");
	int nPuzzles;
	fscanf(fpin,"%d",&nPuzzles);
	printf("%d puzzles\n",nPuzzles);

	int goal[]={
		1,2,3,
		8,0,4,
		7,6,5
		};
	int init[9];

	Game3x3 g;
	g.SetGoal(goal);

	int maxDepth=40;
	int maxN=100000;
	double Plimit=0.90;

	fprintf(fp,"#,puzzle,d,nSolve,n,Popt,qseed\n");
	
	// clear stat monitors
	int* count=new int[maxDepth];
	int* sum=new int[maxDepth];
	for(int i=0; i<maxDepth; i++)
	{
		count[i]=0;
		sum[i]=0;
	}

	int nSolved=0;
	char lbuf[1024];
	int fPrint=1;
	while(nSolved<nPuzzles && 1==fscanf(fpin,"%s",lbuf))
	{
		nSolved++;
		int hash;
		sscanf(lbuf,"%d",&hash);

		g.SetState(hash);
		g.UnloadState(init);
		if(fPrint) g.ShowState();

		int d=maxDepth;
		int nSolve=-1;
		double Popt=0.;
		int nLimit=maxN;
		unsigned long qseedStart=0;
		for(i=1; i<=nLimit; i++)
		{
			g.SetState(init);
			qseedStart=qseed;
			for(int m=0; m<d; m++)
			{
				if(g.IsGoal())
				{
					d=m;
					nSolve=i;
					Popt=1-exp(-i/pow(1.67,d));
					if(fPrint) printf("(%d:%.2lf)",d,Popt);
					double dnLimit=-pow(1.67,d)*log(1-Plimit);
					if(dnLimit>maxN) nLimit=maxN; else nLimit=(int)(dnLimit+0.5);
					break;
				}
				g.Move();
			}
		}
		Popt=1-exp(-(i-1)/pow(1.67,d));
		if(fPrint) printf("[%d:%.2lf]\n",d,Popt);
		if(nSolve>0)
		{
			count[d]++;
			sum[d]+=nSolve;
		}
		fprintf(fp,"%d,%d,%d,%d,%d,%.4lf,%lu\n",nSolved,hash,d,nSolve,i-1,Popt,qseed);
		if(0==(nSolved%100)) fflush(fp);
		if(kbhit())
		{
			char c=getch();
			while(kbhit()) getch();
			switch(c)
			{
			case 'p':
				if(fPrint) fPrint=0; else fPrint=1;
				break;
			case 's':
				Summarize(nSolved,count,sum,maxDepth);
				Summarize(nSolved,count,sum,maxDepth,"\\Research\\dbsummInter.csv");
				break;
			case 'x':
				nPuzzles=nSolved;
			}
		}
	}
	printf("\nDone.\n");
	fclose(fpin);
	fclose(fp);

	Summarize(nSolved,count,sum,maxDepth,"\\Research\\dbsummFinal.csv");


	delete sum;
	delete count;

	return 0;
}


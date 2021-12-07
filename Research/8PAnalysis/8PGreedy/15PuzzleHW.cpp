// 15PuzzleHW.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "core.h"
#include <string.h>
#include <stdlib.h>
#include <math.h>

struct destdelta
{
	int x;
	int y;
};

int goal[]={
	1,2,3,
	8,0,4,
	7,6,5};
destdelta dest[]={
	{2,2},
	{0,0},
	{0,1},
	{0,2},
	{1,2},
	{2,2},
	{2,1},
	{2,0},
	{1,0}
	};


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
int rand32K(void)
{
	return (qrand()&0xEF000000)>>30;
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
	// Greedy
	int bestMove=0;
	int minD=100;
	int myX=index%3;
	int myY=index/3;
	int nEquiv=1;
	int choices[4];
	for(int r=0; r<4; r++)
	{
		if(udlr[r]!=NULL && r!=lastFrom)
		{
			int thatX=udlr[r]->Index()%3;
			int thatY=udlr[r]->Index()/3;
			int that=udlr[r]->Cur();
			//int x0a=dest[Cur()].x-myX;
			//int y0a=dest[Cur()].y-myY;
			//int x0b=dest[that].x-thatX;
			//int y0b=dest[that].y-thatY;
			int x1a=dest[that].x-myX;
			int y1a=dest[that].y-myY;
			int x1b=dest[Cur()].x-thatX;
			int y1b=dest[Cur()].y-thatY;
			//int dx=dest[Cur()].x-dest[that].x;
			//int dy=dest[Cur()].y-dest[that].y;
			int manh1=abs(x1a+x1b)+abs(y1a+y1b);
			if(manh1==minD)
			{
				choices[nEquiv++]=r;
			}
			else if(manh1<minD)
			{
				minD=manh1;
				bestMove=r;
				nEquiv=1;
				choices[0]=r;
			}
		}
	}

	if(nEquiv>1)
		r=choices[rand32K()%nEquiv];
	else
		r=bestMove;
	cur=udlr[r]->Cur();
	udlr[r]->SetCur(0,r^1);
	return udlr[r]->Index();
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
void Game3x3::SetState(int hash)
{
	for(int i=8; i>=0; i--)
	{
		int val=hash%10;
		hash/=10;
		if(!val) empty=i;
		square[i]->SetCur(val,-1);
	}
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
	printf("8-Puzzle Greedy Solver\n");
	sqrand(1);

	FILE* fp=fopen("\\Research\\8pGreedy.csv","w");
	FILE* fpin=fopen("\\Research\\8pdb.dat","r");

	Game3x3 g;
	g.SetGoal(goal);

	int nPuzzles;
	fscanf(fpin,"%d",&nPuzzles);
	printf("nPuzzles=%d\n",nPuzzles);

	fprintf(fp,"trial,puzzle,depth\n");
	int maxDepth=100;
	
	// clear stat monitors
	int* count=new int[maxDepth];
	for(int i=0; i<maxDepth; i++)
	{
		count[i]=0;
	}

	int nSolved=0;
	int hash;
	while(1==fscanf(fpin,"%d",&hash))
	{
		nSolved++;
		g.SetState(hash);
		//g.ShowState();

		int fGotIt=0;
		for(int trial=0; trial<5 && !fGotIt; trial++)
		{
			int d=maxDepth;
			for(int m=1; m<d; m++)
			{
				g.Move();
				if(g.IsGoal())
				{
					d=m;
					printf("Puzzle %d: [%d] %d\n",nSolved,hash,d);
					fprintf(fp,"%d,%d,%d\n",nSolved,hash,d);	
					count[d]++;
					fGotIt=1;
					break;
				}
			}
		}
	}
	fclose(fpin);
	printf("\nDone.\n");

	fprintf(fp,"\ndepth,nPuzzle\n");
	for(i=0; i<maxDepth; i++)
	{
		if(count[i]==0) continue;
		fprintf(fp,"%d,%d\n",
			i,count[i]);
	}

	fclose(fp);

	delete count;

	return 0;
}


// This finds all of the puzzles reachable from a given goal
//   by random iteration; it asymptotically approaches the real value
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
void Game3x3::UnloadState(int* x)
{
	for(int i=0; i<9; i++)
		*x++=square[i]->Cur();

}
int Game3x3::Hash(void)
{
	int hash=0;
	int mult=1;

	for(int i=8; i>=0; i--)
	{
		hash += square[i]->Cur()*mult;
		mult *= 10;
	}
	return hash;
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
void AddDB(int* db,int& nDB,int newval)
{
	if(nDB==0)
	{
		db[0]=newval;
		nDB++;
		return;
	}

	for(int i=0; i<nDB; i++)
	{
		if(newval==db[i])
		{
			//printf("skip %d\n",newval);
			return;
		}
		if(newval<db[i])
		{
			// insertion
			for(int k=nDB; k>i; k--)
				db[k]=db[k-1];
			db[i]=newval;
			nDB++;
			//printf("add %d (%d)\n",newval,nDB);
			return;
		}
	}

	db[nDB++]=newval;
}

void WriteDB(int* db,int nPuzzles)
{
	FILE* fp=fopen("\\Research\\8pdb.dat","w");
	fprintf(fp,"%d\n",nPuzzles);
	for(int i=0; i<nPuzzles; i++)
		fprintf(fp,"%09d\n",db[i]);
	fclose(fp);
}

int main(int argc, char* argv[])
{
	printf("8-Puzzle Database Generator\n");
	sqrand(1);

	int goal[]={
		1,2,3,
		8,0,4,
		7,6,5};

	Game3x3 g;
	g.SetGoal(goal);

	int* db=new int[400000];
	int nPuzzles=0;
	int count=0;

	g.SetState(goal);
	int fGo=1;
	while(fGo)
	{
		//g.ShowState();
		int pHash=g.Hash();
		AddDB(db,nPuzzles,pHash);
		count++;
		if((count%100)==0)
		{
			count=0;
			if(kbhit())
			{
				char c=getch();
				while(kbhit()) getch();
				switch(c)
				{
				case ' ':
					printf("nPuzzles=%d\n",nPuzzles);
					break;
				case 'w':
					WriteDB(db,nPuzzles);
					printf("db written\n");
					break;
				case 'x':
					fGo=0;
					break;
				}
			}
		}
		g.Move();
	}

	WriteDB(db,nPuzzles);
	delete db;

	return 0;
}



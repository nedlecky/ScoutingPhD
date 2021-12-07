// 8PHeur.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <memory.h>

int nPuzzles;
struct hopcount
{
	int hash;
	int hops;
	int repl;
} *hopcounts=NULL;

int Lookup(int hash)
{
	int guess=nPuzzles/2;
	int dist=guess/2;
	int nextTry=hopcounts[guess].hash;
	while(nextTry!=hash)
	{
		if(hash>nextTry) guess+=dist;
		else guess-=dist;
		nextTry=hopcounts[guess].hash;
		//if(dist==1) break;
		//printf("LOOKUP %09d hop to %09d\n",hash,nextTry);
		if (dist>1) dist/=2;
	}
	if(nextTry==hash) return guess;
	else
	{
		printf("missed lookup %09d\n",hash);
		return -1;
	}
}

int abs(int a)
{
	return a<0?-a:a;
}

int goal[]={
	1,2,3,
	8,0,4,
	7,6,5};
struct destdelta
{
	int x;
	int y;
};
// map of row,col for each tile in goal state
destdelta dest[]={
	{1,1},
	{0,0},
	{1,0},
	{2,0},
	{2,1},
	{2,2},
	{1,2},
	{0,2},
	{0,1}
	};
// map of row,col for tile index
destdelta map[]={
	{0,0},
	{1,0},
	{2,0},
	{0,1},
	{1,1},
	{2,1},
	{0,2},
	{1,2},
	{2,2}
	};

void UnloadHash(int hash,int* tiles)
{
	for(int i=8; i>=0; i--)
	{
		tiles[i]=hash%10;
		hash/=10;
	}
}
int Rehash(int* tiles)
{
	int hash=0;
	int mult=1;
	for(int i=8; i>=0; i--)
	{
		hash+=tiles[i]*mult;
		mult*=10;
	}
	return hash;
}
void TileSwap(int* tiles, int a, int b)
{
	int t=tiles[a];
	tiles[a]=tiles[b];
	tiles[b]=t;
}

int ManhattanDistance(int* tiles)
{
	int dist=0;
	for(int i=0; i<9; i++)
	{
		int xpos=map[i].x;
		int ypos=map[i].y;
		int dx=dest[tiles[i]].x;
		int dy=dest[tiles[i]].y;
		dist += abs(xpos-dx) + abs(ypos-dy);
	}
	return dist;
}

void MarkMoves(int hash,int d)
{
	int tiles[9];

	UnloadHash(hash,tiles);

	int pos=0;
	int xpos;
	int ypos;
	// find 0
	for(int i=0; i<9; i++)
		if(!tiles[i])
		{
			pos=i;
			xpos=i%3;//map[i].x;
			ypos=i/3;//map[i].y;
			break;
		}

		//printf("     xpos=%d ypos=%d  ",xpos,ypos);
	// N?
	if(ypos>0)
	{
		TileSwap(tiles,pos,pos-3);
		int newindex=Lookup(Rehash(tiles));
		if(hopcounts[newindex].hops==d) hopcounts[newindex].repl++;
		else
			if(hopcounts[newindex].hops>d)
				hopcounts[newindex].hops=d;
		TileSwap(tiles,pos,pos-3);
	}
	// S?
	if(ypos<2)
	{
		TileSwap(tiles,pos,pos+3);
		int newindex=Lookup(Rehash(tiles));
		if(hopcounts[newindex].hops==d) hopcounts[newindex].repl++;
		else
			if(hopcounts[newindex].hops>d)
				hopcounts[newindex].hops=d;
		TileSwap(tiles,pos,pos+3);
	}
	// E?
	if(xpos>0)
	{
		TileSwap(tiles,pos,pos-1);
		int newindex=Lookup(Rehash(tiles));
		if(hopcounts[newindex].hops==d) hopcounts[newindex].repl++;
		else
			if(hopcounts[newindex].hops>d)
				hopcounts[newindex].hops=d;
		TileSwap(tiles,pos,pos-1);
	}
	// W?
	if(xpos<2)
	{
		TileSwap(tiles,pos,pos+1);
		int newindex=Lookup(Rehash(tiles));
		if(hopcounts[newindex].hops==d) hopcounts[newindex].repl++;
		else
			if(hopcounts[newindex].hops>d)
				hopcounts[newindex].hops=d;
		TileSwap(tiles,pos,pos+1);
	}
}


int main(int argc, char* argv[])
{
	FILE* fpdb=fopen("\\Research\\8pdb.dat","r");
	fscanf(fpdb,"%d",&nPuzzles);

	printf("Heuristic 8-Puzzle Solver (%d puzzles)\n",nPuzzles);

	hopcounts=new hopcount[nPuzzles];

	int nProcessed=0;
	int hash;
	int tiles[9];
	int pInit=0;
	while(/*nProcessed<5 &&*/ 1==fscanf(fpdb,"%d",&hash))
	{
		UnloadHash(hash,tiles);
		int d=ManhattanDistance(tiles);
		hopcounts[nProcessed].hash=hash;
		hopcounts[nProcessed].hops = d==0?0:999;
		hopcounts[nProcessed].repl=1;
		if(d==0) pInit=hash;
		nProcessed++;
		if(!(nProcessed%10000)) printf("nProcessed=%d\n",nProcessed);
	}
	fclose(fpdb);
	printf("%d puzzles processed.\n",nProcessed);

	int nUnsolved=nPuzzles;
	int d=0;
	while(nUnsolved>0 && d<4)
	{
		printf("from d=%d\n",d);
		nUnsolved=0;
		int nSolved=0;
		for(int i=0; i<nPuzzles; i++)
		{
			if(hopcounts[i].hops==d)
			{
				nSolved++;
				MarkMoves(hopcounts[i].hash,d+1);
				//printf("%d %09d\n",i,hopcounts[i].hash);
			}
			else if(hopcounts[i].hops==999) nUnsolved++;
		}
		printf("  %d more added. (%d unsolved)\n",nSolved,nUnsolved);
		d++;
	}

	int maxD=d;
	int count[40];
	int replSum[40];
	for(d=0; d<maxD; d++)
	{
		count[d]=0;
		replSum[d]=0;
	}

	FILE* fp=fopen("\\Research\\8PexactSummary.csv","w");
	for(int i=0; i<nPuzzles; i++)
		{
		int d=hopcounts[i].hops;
		count[d]++;
		replSum[d]+=hopcounts[i].repl;
	}

	for(d=0; d<maxD; d++)
	{
		double avg=(double)replSum[d]/(double)count[d];
		fprintf(fp,"%d,%d,%.1lf\n",d,count[d],avg);
	}
	fclose(fp);

	fp=fopen("\\Research\\8Pexact.dat","w");
	for(i=0; i<nPuzzles; i++)
	{
		fprintf(fp,"%d,%09d,%d,%d\n",
			i+1,hopcounts[i].hash,hopcounts[i].hops,hopcounts[i].repl);
	}
	fclose(fp);


	delete hopcounts;
	return 0;
}


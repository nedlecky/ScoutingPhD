// 8PHeur.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <memory.h>

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
int GreedyMove(int* tiles)
{
	int tilecopy[4][9];

	int pos=0;
	int xpos;
	int ypos;
	// find 0
	for(int i=0; i<9; i++)
		if(!tiles[i])
		{
			pos=i;
			xpos=map[i].x;
			ypos=map[i].y;
			break;
		}

	int dBest=ManhattanDistance(tiles);
	int pick=-1;
	
	// N?
	if(ypos>0)
	{
		memcpy(tilecopy[0],tiles,9*sizeof(int));
		TileSwap(tilecopy[0],pos,pos-3);
		int d=ManhattanDistance(tilecopy[0]);
		if(d<dBest)
		{
			pick=0;
			dBest=d;
		}
	}
	// S?
	if(ypos<2)
	{
		memcpy(tilecopy[1],tiles,9*sizeof(int));
		TileSwap(tilecopy[1],pos,pos+3);
		int d=ManhattanDistance(tilecopy[1]);
		if(d<dBest)
		{
			pick=1;
			dBest=d;
		}
	}
	// E?
	if(xpos>0)
	{
		memcpy(tilecopy[2],tiles,9*sizeof(int));
		TileSwap(tilecopy[2],pos,pos-1);
		int d=ManhattanDistance(tilecopy[2]);
		if(d<dBest)
		{
			pick=2;
			dBest=d;
		}
	}
	// W?
	if(xpos<2)
	{
		memcpy(tilecopy[3],tiles,9*sizeof(int));
		TileSwap(tilecopy[3],pos,pos+1);
		int d=ManhattanDistance(tilecopy[3]);
		if(d<dBest)
		{
			pick=3;
			dBest=d;
		}
	}

	if(pick>=0)
	{
		memcpy(tiles,tilecopy[pick],9*sizeof(int));
		return dBest;
	}
	else return -1;
}
int main(int argc, char* argv[])
{
	FILE* fpdb=fopen("\\Research\\8pdb.dat","r");
	int nPuzzles;
	fscanf(fpdb,"%d",&nPuzzles);

	printf("Heuristic 8-Puzzle Solver (%d puzzles)\n",nPuzzles);

	FILE* fp=fopen("\\Research\\8Pheur.dat","w");

	int nProcessed=0;
	int nSolved=0;
	int hash;
	int tiles[9];
	while(/*nProcessed<5 &&*/ 1==fscanf(fpdb,"%d",&hash))
	{
		nProcessed++;
		if(!(nProcessed%1000)) printf("nProcessed=%d\n",nProcessed);
		UnloadHash(hash,tiles);
		int dManhattan0=ManhattanDistance(tiles);
		int dManhattan=dManhattan0;

		int nMoves=0;
		while(dManhattan>0)
		{
			dManhattan=GreedyMove(tiles);
			nMoves++;
		}
		if(dManhattan==0) nSolved++;
		fprintf(fp,"%d,%09d,%d,%d\n",nProcessed,hash,dManhattan,nMoves);
	}
	fclose(fpdb);
	fclose(fp);

	printf("%d puzzles processed.  %d solved.\n",nProcessed,nSolved);

	return 0;
}


#include "stdafx.h"

#include <memory.h>
#include <string.h>

class PuzzleList
{
	int allocSize;
	int count;
	int* puzzles;
public:
	PuzzleList();
	~PuzzleList();
	int Count(void) {return count;}
	void Show(char* filename=NULL);
	void Load(char* filename);
	void Add(int hash);
	int Hash(int i) {return puzzles[i];}
	int Lookup(int hash);
};
PuzzleList::PuzzleList()
{
	count=0;
	allocSize=10;
	puzzles=new int[allocSize];
}
PuzzleList::~PuzzleList()
{
	if(puzzles) delete puzzles;
}
void PuzzleList::Add(int hash)
{
	if(count>=allocSize)
	{
		allocSize+=10000;
		int* newPuzzles=new int[allocSize];
		memcpy(newPuzzles,puzzles,count*sizeof(int));
		delete puzzles;
		puzzles=newPuzzles;
	}

	// adding to the end of the list
	if(count==0 || hash>puzzles[count-1])
	{
		puzzles[count++]=hash;
		return;
	}

	// binary search to get close to where we should find it
	int* p=puzzles+count/2;
	int dist=count/2/2;
	if(dist<1) dist=1;
	while(*p!=hash)
	{
		if(hash>*p) p+=dist;
		else p-=dist;
		dist/=2;
		if(dist==0) break;
	}

	// fine tune
	while(hash<*p && p>puzzles) p--;
	while(hash>*p && p<puzzles+count-1) p++;

	if(hash==*p)
	{
		printf("Adding duplicate %d ignored\n",hash);
		return;
	}

	memmove(p+1,p,(puzzles+count-p)*sizeof(int));
	*p=hash;
	count++;
}
void PuzzleList::Show(char* filename)
{
	FILE* fp=stdout;

	if(filename!=NULL)
	{
		fp=fopen(filename,"w");
		if(fp==NULL)
		{
			printf("::Show() can't open [%s]\n",filename);
			return;
		}
	}

	for(int i=0; i<count; i++)
		fprintf(fp,"%09d\n",puzzles[i]);

	if(fp!=stdout) fclose(fp);
}
void PuzzleList::Load(char* filename)
{
	FILE* fp=fopen(filename,"r");
	if(fp==NULL)
	{
		printf("::Load() can't open [%s]\n",filename);
		return;
	}

	while(!feof(fp))
	{
		int hash;
		fscanf(fp,"%d",&hash);
		Add(hash);
	}

	fclose(fp);
}

int PuzzleList::Lookup(int hash)
{
	if(count<1) return -1;
	int* pGuess=puzzles+count/2;
	int dist=count/2/2;
	if(dist<1) dist=1;
	int nextTry=*pGuess;
	while(*pGuess!=hash)
	{
		if(hash>*pGuess) pGuess+=dist;
		else pGuess-=dist;
		dist/=2;
		if(dist==0) break;
	}
	
	// fine tune
	while(hash<*pGuess && pGuess>puzzles) pGuess--;
	while(hash>*pGuess && pGuess<puzzles+count-1) pGuess++;

	if(*pGuess==hash) return pGuess-puzzles;
	else
	{
		// miss by one?
		if(pGuess>puzzles)
			if(*(pGuess-1)==hash)
			{
				printf("m1\n");
				return pGuess-puzzles-1;
			}
		if(pGuess<puzzles+count-1)
			if(*(pGuess+1)==hash)
			{
				printf("p1\n");
				return pGuess-puzzles+1;
			}
		return -1;
	}
}

int abs(int a)
{
	return a<0?-a:a;
}

struct destdelta
{
	int x;
	int y;
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

void MakeMoves(int hash,PuzzleList* pList,PuzzleList* masterList)
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

	// N?
	if(ypos>0)
	{
		TileSwap(tiles,pos,pos-3);
		int h=Rehash(tiles);
		if(masterList->Lookup(h)<0)
		{
			pList->Add(h);
			masterList->Add(h);
		}
		TileSwap(tiles,pos,pos-3);
	}
	// S?
	if(ypos<2)
	{
		TileSwap(tiles,pos,pos+3);
		int h=Rehash(tiles);
		if(masterList->Lookup(h)<0)
		{
			pList->Add(h);
			masterList->Add(h);
		}
		TileSwap(tiles,pos,pos+3);
	}
	// E?
	if(xpos>0)
	{
		TileSwap(tiles,pos,pos-1);
		int h=Rehash(tiles);
		if(masterList->Lookup(h)<0)
		{
			pList->Add(h);
			masterList->Add(h);
		}
		TileSwap(tiles,pos,pos-1);
	}
	// W?
	if(xpos<2)
	{
		TileSwap(tiles,pos,pos+1);
		int h=Rehash(tiles);
		if(masterList->Lookup(h)<0)
		{
			pList->Add(h);
			masterList->Add(h);
		}
		//TileSwap(tiles,pos,pos+1);
	}
}

int goal[]={
	1,2,3,
	8,0,4,
	7,6,5};

int main(int argc, char* argv[])
{
	printf("Dynamic Programming 8-Puzzle Tabulator\n");

	PuzzleList* masterList=new PuzzleList();

	int goalHash=Rehash(goal);

	const int maxDepth=35;
	PuzzleList* pList[maxDepth+1];
	for(int i=0; i<maxDepth+1; i++)
		pList[i]=new PuzzleList();

	pList[0]->Add(goalHash);
	masterList->Add(goalHash);

	FILE* fp=fopen("report.dat","w");
	fprintf(fp,"depth,N,master\n");

	for(i=0; i<=maxDepth; i++)
	{
		if(i>0)
			for(int p=0; p<pList[i-1]->Count(); p++)
				MakeMoves(pList[i-1]->Hash(p),pList[i],masterList);
		fprintf(fp,"%d,%d,%d\n",i,pList[i]->Count(),masterList->Count());
		printf("d=%2d N=%8d Total=%8d\n",i,pList[i]->Count(),masterList->Count());
	}
	fclose(fp);

	for(i=0; i<=maxDepth; i++)
	{
		char filename[128];
		sprintf(filename,"pList[%02d].dat",i);
		pList[i]->Show(filename);
	}
	masterList->Show("masterList.dat");

	delete masterList;
	for(i=0; i<maxDepth+1; i++)
		delete pList[i];
	return 0;
}

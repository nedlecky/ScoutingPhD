#include "stdafx.h"
#include <memory.h>

void TileMove(int* dest,int* src,int zIndex,int zNew)
{
	memcpy(dest,src,9*sizeof(int));
	dest[zIndex]=dest[zNew];
	dest[zNew]=0;
}
int PExpand(int* tile,int puzzle)
{
	int index=0;
	for(int i=8; i>=0; i--)
	{
		tile[i]=puzzle%10;
		if(!tile[i]) index=i;
		puzzle/=10;
	}
	return index;
}
int PCompact(int* tile)
{
	int val=0;

	int* p=tile+8;
	int* pLimit=tile;
	int mult=1;
	while(pLimit<=p)
	{
		val += *p-- * mult;
		mult*=10;
	}
	return val;
}
char* PString(int puzzle)
{
	static char str[10];
	sprintf(str,"%09d",puzzle);
	return str;
}
char* PString(int* tile)
{
	return PString(PCompact(tile));
}


void TileShow(int* tiles)
{
	for(int i=0; i<9; i++)
		printf("%d",tiles[i]);
	printf("\n");
}

class PuzzleList
{
	int* puzzles;
	int* depths;
	int* dupDepths;
	int* counts;
	int allocSize;
	int size;
	int maxD;
	bool fBadParity;
public:
	PuzzleList();
	~PuzzleList();
	int Size(void) {return size;}
	void Add(int* tile);
	int Find(int* tile);
	int Find(int puzzle);
	void Show(void);
	void BackpropCosts(int* goal);
	void BackpropCosts(int puzzle);
	int MarkPuzzles(int puzzle,int d);
	void Stats(void);
	int FindExample(int depth);
	void DuplicateDepths(void);
	void AnalyzeSuboptimal(int d);
};
PuzzleList::PuzzleList()
{
	allocSize=1024;
	puzzles=new int[allocSize];
	depths=new int[allocSize];
	counts=new int[allocSize];
	dupDepths=NULL;
	size=0;
	maxD=0;
	fBadParity=true;
}
PuzzleList::~PuzzleList()
{
	if(puzzles) delete puzzles;
	if(depths) delete depths;
	if(dupDepths) delete dupDepths;
	if(counts) delete counts;
}
void PuzzleList::Add(int* tile)
{
	if(size>=allocSize)
	{
		allocSize+=1024*16;
		int* newPuzzles=new int[allocSize];
		int* newDepths=new int[allocSize];
		int* newCounts=new int[allocSize];
		memcpy(newPuzzles,puzzles,size*sizeof(int));
		memcpy(newDepths,depths,size*sizeof(int));
		memcpy(newCounts,counts,size*sizeof(int));
		delete puzzles;
		delete depths;
		delete counts;
		puzzles=newPuzzles;
		depths=newDepths;
		counts=newCounts;
	}
	depths[size]=999;
	counts[size]=0;
	puzzles[size]=PCompact(tile);
	size++;
}
int PuzzleList::Find(int* tile)
{
	return Find(PCompact(tile));
}
int PuzzleList::Find(int puzzle)
{
	int *p=puzzles+size/2;
	int delta=size/4;
	while(*p!=puzzle)
	{
		if(*p>puzzle) p-=delta;
		else p+=delta;
		delta/=2;
		if(delta==0) break;
	}

	// fine tune
	while(*p>puzzle && p>puzzles) p--;
	while(*p<puzzle && p<puzzles+size-1) p++;

	if(*p==puzzle) return p-puzzles;
	else return -1;
}

void PuzzleList::Show(void)
{
	for(int i=0; i<size; i++)
		printf("%s\n",PString(puzzles[i]));
}

int PuzzleList::MarkPuzzles(int puzzle,int d)
{
	int tiles[9];
	int tiledups[9];
	int zIndex=PExpand(tiles,puzzle);
	int zRow=zIndex/3;
	int zCol=zIndex%3;
	int nMarked=0;

	if(zRow>0) // N
	{
		TileMove(tiledups,tiles,zIndex,zIndex-3);
		int index=Find(tiledups);
		if(index>=0)
			if(depths[index]==d)
				counts[index]++;
			else if(depths[index]>d)
			{
				depths[index]=d;
				counts[index]=1;
				nMarked++;
			}
	}

	if(zRow<2) // S
	{
		TileMove(tiledups,tiles,zIndex,zIndex+3);
		int index=Find(tiledups);
		if(index>=0)
			if(depths[index]==d)
				counts[index]++;
			else if(depths[index]>d)
			{
				depths[index]=d;
				counts[index]=1;
				nMarked++;
			}
	}

	if(zCol<2) // E
	{
		TileMove(tiledups,tiles,zIndex,zIndex+1);
		int index=Find(tiledups);
		if(index>=0)
			if(depths[index]==d)
				counts[index]++;
			else if(depths[index]>d)
			{
				depths[index]=d;
				counts[index]=1;
				nMarked++;
			}
	}
	
	if(zCol>0) // W
	{
		TileMove(tiledups,tiles,zIndex,zIndex-1);
		int index=Find(tiledups);
		if(index>=0)
			if(depths[index]==d)
				counts[index]++;
			else if(depths[index]>d)
			{
				depths[index]=d;
				counts[index]=1;
				nMarked++;
			}
	}

	return nMarked;
}

void PuzzleList::BackpropCosts(int puzzle)
{
	int tile[9];
	PExpand(tile,puzzle);
	BackpropCosts(tile);
}
void PuzzleList::BackpropCosts(int* goal)
{
	// clear depths
	for(int i=0; i<size; i++)
		depths[i]=99999;

	// Mark the goal state as having depth=0
	int goalIndex=Find(goal);
	if(goalIndex<0)
	{
		printf("Critical Error: Goal state not found in state list.\n");
		printf("ABORTING.\n");
		return;
	}
	printf("goal state index = %d\n",goalIndex);
	depths[goalIndex]=0;

	// Dynamic Programming; set optimal solution depths for all
	//   initial states
	int d=0;
	int nUnsolved = fBadParity ? size/2-1 : size-1;;
	while(nUnsolved>0)
	{
		int nSolved=0;
		for(int i=0; i<size; i++)
			if(depths[i]==d)
			{
				nSolved+=MarkPuzzles(puzzles[i],d+1);
			}
		nUnsolved-=nSolved;
		printf("Solved %d at d=%d (%d to go)\n",
			nSolved,d+1,nUnsolved);
		d++;
	}
	maxD=d;

	// Compress out unvisited states
	int newsize=0;
	for(i=0; i<size; i++)
		if(depths[i]!=99999)
		{
			puzzles[newsize]=puzzles[i];
			depths[newsize]=depths[i];
			counts[newsize]=counts[i];
			newsize++;
		}
	size=newsize;
	printf("newsize=%d\n",size);
	fBadParity=false;
}

void PuzzleList::Stats(void)
{
	printf("STATS\n");
	printf("  nPuzzles=%d\n",size);
	printf("  d   nInstances   avgCount\n");
	int avgDsum=0;
	int nTotal=0;
	for(int d=0; d<=maxD; d++)
	{
		int n=0;
		int countSum=0;
		int minCount=99999;
		int maxCount=0;
		for(int i=0; i<size; i++)
			if(depths[i]==d)
			{
				n++;
				nTotal++;
				countSum+=counts[i];
				if(counts[i]<minCount) minCount=counts[i];
				if(counts[i]>maxCount) maxCount=counts[i];
			}
		avgDsum+=n*d;
		double avgCount=(double)countSum/(double)n;
		printf("%4d %5d %4.1lf %3d %3d\n",d,n,avgCount,minCount,maxCount);
	}
	double avgD=(double)avgDsum/(double)nTotal;
	printf("Avg solution length=%.1lf\n",avgD);
}

// Find the first example puzzle with a solution of length d
// For d=-1, finds the hardest puzzle (largest d)
int PuzzleList::FindExample(int depth)
{
	if(depth==-1)
	{
		int iWorst=0;
		int dWorst=0;

		for(int i=0; i<size; i++)
		{
			if(depths[i]>dWorst)
			{
				dWorst=depths[i];
				iWorst=i;
			}
		}
	printf("worst soln = %d\n",dWorst);
	return puzzles[iWorst];
	}
	else
	{
		for(int i=0; i<size; i++)
			if(depths[i]==depth) return puzzles[i];
		return -1;
	}
}
void PuzzleList::DuplicateDepths(void)
{
	if(dupDepths) delete dupDepths;
	dupDepths=new int[size];
	memcpy(dupDepths,depths,size*sizeof(int));
}
void PuzzleList::AnalyzeSuboptimal(int d)
{
	if(!dupDepths) return;

	int maxBins=100;
	int* hist=new int[maxBins];

	for(int i=0; i<maxBins; i++)
		hist[i]=0;

	for(i=0; i<size; i++)
	{
		int soln=depths[i]+dupDepths[i];
		hist[soln]++;
	}

	for(i=0; i<maxBins; i++)
		if(hist[i])
		{
			double norm=(double)hist[i];///(double)d;
			printf("%03d %.2lf\n",i,norm);
		}
}


int tile[9];
void GenAll(PuzzleList* puzzles,int level)
{
	for(int i=0; i<9; i++)
	{
		int skip=0;
		for(int j=0; j<level; j++)
		{
			if(tile[j]==i)
			{
				skip=1;
				break;
			}
		}
		if(skip) continue;
		tile[level]=i;
		if(level<8)
			GenAll(puzzles,level+1);
		else
		{
			puzzles->Add(tile);
		}
	}
}

int main(int argc, char* argv[])
{
	// Desired goal state
	int goal0[]={
		1,2,3,
		8,0,4,
		7,6,5};
	int goal1[]={
		0,1,2,
		3,4,5,
		6,7,8};
	int goal2[]={
		1,0,2,
		3,4,5,
		6,7,8};

	int* goal=goal0;


	// Generate the complete list of initial states
	PuzzleList initStates;
	GenAll(&initStates,0);
	int nStates=initStates.Size();
	printf("nInitStates=%d\n",nStates);

	// Backpropagate to all possible initial states
	initStates.BackpropCosts(goal);

	// Show stats
	initStates.Stats();

	// Solve some other puzzles
	for(int d=5; d<=30; d+=5)
	{
		int hard=initStates.FindExample(d);
		printf("Solving a d=%d puzzle (%s)\n",d,PString(hard));

		// Save the cost-to-optimal
		initStates.DuplicateDepths();
		initStates.BackpropCosts(hard);
		initStates.AnalyzeSuboptimal(d);
	}

	return 0;
}


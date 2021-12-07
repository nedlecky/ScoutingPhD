#include "stdafx.h"
#include <memory.h>
#include <math.h>
#include <conio.h>
#include "LEmatrix.h"
#include "LEneuralnet.h"

LEmatrix V("V");
LEmatrix W("W");
LEmatrix VT("VT");
LEmatrix WT("WT");

LEmatrix z("z");
LEmatrix y_("y_");
LEmatrix& NN2(LEmatrix& x)
{
	z = leSigma(VT*x,LEAtanh);
	y_ = WT*z;
	return y_;
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

// Manhattan Distance Heuristic
int manhTable[9][2];

// Load manhTable with goal state info.
// [t][0] is row tile t should be in
// [t][1] is col tile t should be in
void SetManhattan(int* goal)
{
	int i=0;
	for(int r=0; r<3; r++)
		for(int c=0; c<3; c++)
		{
			manhTable[goal[i]][0]=r;
			manhTable[goal[i]][1]=c;
			i++;
		}
}

// Compute manhattan distance; must call SetManhattan with goal first
int ManhDistance(int* tile)
{
	int dist=0;
	for(int i=0; i<9; i++)
		if(tile[i])
		{
			int r=i/3;
			int c=i%3;
			dist = dist + abs(r-manhTable[tile[i]][0]) + abs(c-manhTable[tile[i]][1]);
		}
	return dist;
}
int ManhDistance(int p)
{
	int tile[9];
	PExpand(tile,p);
	return ManhDistance(tile);
}

void TileMove(int* dest,int* src,int zIndex,int zNew)
{

	memcpy(dest,src,9*sizeof(int));
	dest[zIndex]=dest[zNew];
	dest[zNew]=0;
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
	void Show(char* filename=NULL);
	void BackpropCosts(int* goal);
	void BackpropCosts(int puzzle);
	int MarkIndex(int* tiledups,int d,int parentCounts);
	int MarkPuzzles(int index,int d);
	void Stats(char* filename=NULL);
	void NNStats(char* filename);
	void TrainingData(char* filename=NULL);
	int FindExample(int depth);
	void DuplicateDepths(void);
	void AnalyzeSuboptimal(char* filename=NULL);
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

void PuzzleList::Show(char* filename)
{
	FILE* fp=stdout;
	if(filename!=NULL)
	{
		fp=fopen(filename,"w");
		if(fp==NULL)
		{
			printf("::Show can't open [%s]\n",filename);
			return;
		}
		fprintf(fp,"%s\n",filename);
	}
	
	fprintf(fp,"%d puzzles\npuzzle,d,count\n",size);
	for(int i=0; i<size; i++)
		fprintf(fp,"%s,%d,%d\n",PString(puzzles[i]),depths[i],counts[i]);
	
	if(fp!=stdout) fclose(fp);
}

int PuzzleList::MarkIndex(int* tiledups,int d,int parentCounts)
{
	int index=Find(tiledups);

	// New version
	if(index>=0)
		if(depths[index]==d)
			counts[index]+=parentCounts;
		else if(depths[index]>d)
		{
			depths[index]=d;
			counts[index]=parentCounts;
			return 1;
		}
	/*
	// original
	if(index>=0)
		if(depths[index]==d)
			counts[index]++;
		else if(depths[index]>d)
		{
			depths[index]=d;
			counts[index]=1;
			return 1;
		}
	*/

	return 0;
}

int PuzzleList::MarkPuzzles(int index,int d)
{
	int puzzle=puzzles[index];
	int tiles[9];
	int tiledups[9];
	int zIndex=PExpand(tiles,puzzle);

	int parentCounts=counts[index];
	int zRow=zIndex/3;
	int zCol=zIndex%3;
	int nMarked=0;

	if(zRow>0) // N
	{
		TileMove(tiledups,tiles,zIndex,zIndex-3);
		nMarked+=MarkIndex(tiledups,d,parentCounts);
	}

	if(zRow<2) // S
	{
		TileMove(tiledups,tiles,zIndex,zIndex+3);
		nMarked+=MarkIndex(tiledups,d,parentCounts);
	}

	if(zCol<2) // E
	{
		TileMove(tiledups,tiles,zIndex,zIndex+1);
		nMarked+=MarkIndex(tiledups,d,parentCounts);
	}
	
	if(zCol>0) // W
	{
		TileMove(tiledups,tiles,zIndex,zIndex-1);
		nMarked+=MarkIndex(tiledups,d,parentCounts);
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
	counts[goalIndex]=1;

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
				nSolved+=MarkPuzzles(i,d+1);
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

void PuzzleList::Stats(char* filename)
{
	FILE* fp=stdout;
	if(filename!=NULL)
	{
		fp=fopen(filename,"w");
		if(fp==NULL)
		{
			printf("::Stats can't open [%s]\n",filename);
			return;
		}
		fprintf(fp,"%s ",filename);
	}

	fprintf(fp,"Statistics\n");
	fprintf(fp,"nPuzzles\n%d\n",size);
	fprintf(fp,"d,nInstances,maxCount,minCount,avgCount,maxManh,minManh,avgManh\n");
	int avgDsum=0;
	int nTotal=0;
	for(int d=0; d<=maxD; d++)
	{
		int n=0;
		int countSum=0;
		int minCount=99999;
		int maxCount=0;
		int manhSum=0;
		int minManh=99999;
		int maxManh=0;
		for(int i=0; i<size; i++)
			if(depths[i]==d)
			{
				n++;
				nTotal++;
				countSum+=counts[i];
				if(counts[i]<minCount) minCount=counts[i];
				if(counts[i]>maxCount) maxCount=counts[i];

				int manh=ManhDistance(puzzles[i]);
				manhSum+=manh;
				if(manh<minManh) minManh=manh;
				if(manh>maxManh) maxManh=manh;
			}
		avgDsum+=n*d;
		double avgCount=(double)countSum/(double)n;
		double avgManh=(double)manhSum/(double)n;
		fprintf(fp,"%d,%d,%d,%d,%.1lf,%d,%d,%.1lf\n",
			d,n,maxCount,minCount,avgCount,maxManh,minManh,avgManh);
	}
	double avgD=(double)avgDsum/(double)nTotal;
	fprintf(fp,"Avg d\n%.1lf\n",avgD);

	if(fp!=stdout) fclose(fp);
}

void PuzzleList::TrainingData(char* fileprefix)
{
	LEmatrix X("X",18,size);
	LEmatrix Y("Y",1,size);
	for(int i=0; i<size; i++)
	{
		int tiles[9];
		PExpand(tiles,puzzles[i]);
		for(int t=0; t<9; t++)
		{
			int r=tiles[t]/3;
			int c=tiles[t]%3;
			X[t*2][i]=r;
			X[t*2+1][i]=c;
		}
		Y[0][i]=depths[i]-ManhDistance(puzzles[i]);  // train on delta from Heuristic
	}

	char filename[128];
	sprintf(filename,"%s_X.csv",fileprefix);
	X.Save(filename);
	sprintf(filename,"%s_Y.csv",fileprefix);
	Y.Save(filename);
}

void PuzzleList::NNStats(char* filename)
{
	FILE* fp=stdout;
	if(filename!=NULL)
	{
		fp=fopen(filename,"w");
		if(fp==NULL)
		{
			printf("::NNStats can't open [%s]\n",filename);
			return;
		}
		fprintf(fp,"%s ",filename);
	}

	fprintf(fp,"Statistics\n");
	fprintf(fp,"nPuzzles\n%d\n",size);
	fprintf(fp,"d,nInstances,maxManh,minManh,avgManh,maxNN,minNN,avgNN\n");
	int avgDsum=0;
	int nTotal=0;
	LEmatrix x("x",19,1);
	x[0][0]=1;
	LEmatrix y;
	for(int d=0; d<=maxD; d++)
	{
		int n=0;
		double nnSum=0;
		double minNN=99999;
		double maxNN=0;
		int manhSum=0;
		int minManh=99999;
		int maxManh=0;
		for(int i=0; i<size; i++)
			if(depths[i]==d)
			{
				n++;
				nTotal++;

				int tiles[9];
				PExpand(tiles,puzzles[i]);
				for(int t=0; t<9; t++)
				{
					int r=tiles[t]/3;
					int c=tiles[t]%3;
					x[t*2+1][0]=r;
					x[t*2+2][0]=c;
				}

				y=NN2(x);

				double nn=(double)ManhDistance(tiles)+y[0][0];
				nnSum+=nn;
				if(nn<minNN) minNN=nn;
				if(nn>maxNN) maxNN=nn;

				int manh=ManhDistance(puzzles[i]);
				manhSum+=manh;
				if(manh<minManh) minManh=manh;
				if(manh>maxManh) maxManh=manh;
			}
		avgDsum+=n*d;
		double avgManh=(double)manhSum/(double)n;
		double avgNN=nnSum/(double)n;
		fprintf(fp,"%d,%d,%d,%d,%.1lf,%.1lf,%.1lf,%.1lf\n",
			d,n,maxManh,minManh,avgManh,maxNN,minNN,avgNN);
	}
	double avgD=(double)avgDsum/(double)nTotal;
	fprintf(fp,"Avg d\n%.1lf\n",avgD);

	if(fp!=stdout) fclose(fp);
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
void PuzzleList::AnalyzeSuboptimal(char* filename)
{
	if(!dupDepths) return;

	FILE* fp=stdout;
	if(filename!=NULL)
	{
		fp=fopen(filename,"w");
		if(fp==NULL)
		{
			printf("::AnalyzeSuboptimal can't open [%s]\n",filename);
			return;
		}
		fprintf(fp,"%s ",filename);
	}

	fprintf(fp,"Suboptimal\n");
	fprintf(fp,"d,count\n");

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
			double norm=(double)hist[i];
			fprintf(fp,"%d,%.2lf\n",i,norm);
		}

	if(fp!=stdout) fclose(fp);
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


void TrainNN(void)
{
	printf("NN Training\n");
	int L=30;			// number of hidden neurons
	double eta=.01;		// training rate (both layers)

	printf("Loading\n");
	// pull in Xbar data and create X
	LEmatrix Xbar;
	Xbar.Load("NN_X.csv");

	LEmatrix X("X",1,Xbar.Ncols());
	X=1;
	X.AppendRows(Xbar);

	LEmatrix Y;
	Y.Load("NN_Y.csv");

	int n=Xbar.Nrows();	// number of inputs
	int m=Y.Nrows();	// number of outputs

	// layer 1 weights
	V.SetSize(n+1,L);
	V.Randomize(-.01,.01);
	
	// layer 2 weights
	W.SetSize(L+1,m);
	W.Randomize(-.01,.01);
	
	// define transpose matrices for speed
	VT=leTranspose(V);
	WT=leTranspose(W);

	// setup for training
	LEmatrix y("y");
	LEmatrix e("e");
	LEmatrix del1("del1");
	LEmatrix del2("del2");
	LEmatrix tmpmat("tmpmat");
	double E;


	LEmatrix Iy("Iy");
	LEmatrix Iz("Iz");
	Iy=leIdentMat(m);
	Iz=leIdentMat(L+1);

	printf("Train\n");
	
	// training loop
	int epoch=0;
	int maxEpochs=30000;
	double lastE0=0.;
	double lastE1=0.;
	double maxSafeEta=0.1;
	double minSafeEta=0.0005;
	while(epoch<maxEpochs)
	{
		// sequential weight updater
		for(int c=0/*leRandInt(0,1000)*/; c<X.Ncols(); c+=100)
		{
			int doCol=c;
			LEmatrix x("x");
			x=leCol(X,doCol);
			y=NN2(x);

			e=leCol(Y,doCol)-y;

			// appropriate for linear output
			del2=e;

			// appropriate for tanh output
			//tmpmat=leDiag(y);
			//del2=(Iy-tmpmat*tmpmat)*e;

			// appropriate for tanh layer 1
			tmpmat=leDiag(z);
			del1=(Iz-tmpmat*tmpmat)*W*del2;

			// now, del1 has an extra 1 at the front.  Get rid of it
			for(int i=1; i<del1.Nrows(); i++) del1[i-1][0]=del1[i][0];
			del1.SetSize(del1.Nrows()-1,del1.Ncols());

			W = W + (z*leTranspose(del2)*eta);
			V = V + (x*leTranspose(del1)*eta);
			VT=leTranspose(V);
			WT=leTranspose(W);
		}

		// occasionally check whether we've converged
		if(epoch%30 == 0)
		{
			bool fFirstTime=true;
			LEmatrix ecol;
			for(int c=0/*leRandInt(0,1000)*/; c<X.Ncols(); c+=100)
			{
				int doCol=c;
				LEmatrix x("x");
				x=leCol(X,doCol);
				y=NN2(x);

				ecol=leCol(Y,doCol)-y;
				if(fFirstTime)
				{
					e=ecol;
					fFirstTime=false;
				}
				else
					e.AppendCols(ecol);
			}
			E=leEcalc(e);
			printf("epoch %d E=%.3lf eta=%.3lf\n",epoch,E,eta);

			// adaptive eta
			if(lastE0!=0)
			{
				if(E<lastE0 && lastE0<lastE1)
					eta*=1.2;
				if(E>lastE0 && lastE0>lastE1)
					eta*=.6;

				// safe eta
				if(eta>maxSafeEta)
					eta=maxSafeEta;
				if(eta<minSafeEta)
					eta=minSafeEta;
			}
			lastE1=lastE0;
			lastE0=E;
		}

		// if we've converged OR you hit the x key, stop training
		char cc=0;
		if(kbhit()) cc=getch();
		if(cc=='x' || E<=0.005)
		{
			break;
		}

		epoch++;
		//printf("epoch %d complete\n",epoch);
	}
	
	// simulation and evaluation
	printf("Final NN %d epochs, E=%.4lf\n",epoch,E);
	V.Print();
	W.Print();
	V.Save("V.csv");
	W.Save("W.csv");
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

	SetManhattan(goal);

	// Generate the complete list of initial states
	PuzzleList initStates;
	GenAll(&initStates,0);
	int nStates=initStates.Size();
	printf("nInitStates=%d\n",nStates);

	// Backpropagate to all possible initial states
	//   this also compresses out impossible initial states
	initStates.BackpropCosts(goal);
	initStates.Show("initstates.csv");

	// Show stats
	if(0)
		initStates.Stats("initstates_stats.csv");

	// Save NN Training Data
	if(0)
		initStates.TrainingData("NN");

	// Solve some other puzzles to count suboptimal solutions
	if(0)
	{
		for(int d=5; d<=30; d+=5)
		{
			int hard=initStates.FindExample(d);
			printf("Solving a d=%d puzzle (%s)\n",d,PString(hard));

			// Save the cost-to-optimal
			initStates.DuplicateDepths();
			initStates.BackpropCosts(hard);

			// Analysis
			char filename[128];
			sprintf(filename,"suboptimal_%02d.csv",d);
			initStates.AnalyzeSuboptimal(filename);
		}
	}

	// attempt NN training
	if(1)
		TrainNN();
	else
	{
		V.Load("V.csv");
		W.Load("W.csv");
		VT=leTranspose(V);
		WT=leTranspose(W);
	}

	if(1)
		initStates.NNStats("NNstats.csv");

	return 0;
}


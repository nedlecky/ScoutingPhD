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

void Summarize(int nSolved,int* count,double* sum,int maxDepth,char* fname=NULL);
void Summarize(int nSolved,int* count,double* sum,int maxDepth,char* fname)
{
	FILE*fp=stdout;
	
	if(fname) fp=fopen(fname,"w");
	if(fp==NULL) return;

	fprintf(fp,"%d puzzles analyzed.\n",nSolved);
	fprintf(fp,"depth,nPuzzle,avgN\n");
	long total=0;
	for(int i=0; i<maxDepth; i++)
	{
		if(count[i]==0) continue;
		double avg=sum[i]/(double)count[i];
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
	if(argc!=3)
	{
byebye:
		printf("Usage: 15puzzlehw 0/1/2 init/cont\n");
		return -1;
	}

	int flavor=0;
	if(1!=sscanf(*++argv,"%d",&flavor))
		goto byebye;

	if(flavor<0 || flavor>2) goto byebye;
	if(flavor==2)
	{
		// merge
		int maxDepth=200;
		int* count=new int[maxDepth];
		double* sum=new double[maxDepth];
		for(int i=0; i<maxDepth; i++)
		{
			count[i]=0;
			sum[i]=0;
		}

		FILE* fp[2];
		fp[0]=fopen("\\Research\\8pdb30.csv","r");
		fp[1]=fopen("\\Research\\8pdb31.csv","r");
		FILE* fpout=fopen("\\Research\\8pdbmerge.csv","w");
		int fSomeone=1;
		int fRead[2];
		int fValid[2];
		int fOutput[2];
		int nSolved[2],hash[2],d[2],nSolve[2],nRun[2];
		double Popt[2];
		long qseedStart[2];
		int fScanningOK[2];
		int nSolvedTotal=0;
		for(i=0; i<2; i++)
		{
			fRead[i]=1;
			fValid[i]=0;
			fScanningOK[i]=1;
		}
		while(!feof(fp[0]) || !feof(fp[1]))
		{
			for(int i=0; i<2; i++)
				if(fRead[i])
				{
					fValid[i]=0;
					char lbuf[128];
					fScanningOK[i]=fscanf(fp[i],"%s",lbuf);
					if(fScanningOK[i]==1)
					{
						int r=sscanf(lbuf,"%d,%d,%d,%d,%d,%lf,%lu",
							nSolved+i,hash+i,d+i,nSolve+i,nRun+i,Popt+i,qseedStart+i);
						if(r==7)
						{
							fValid[i]=1;
							fRead[i]=0;
						}
					}
				}
			fOutput[0]=fValid[0];
			fOutput[1]=fValid[1];
			if(fValid[0] && fValid[1])
			{
				if(nSolved[0]<nSolved[1]) fOutput[1]=0;
				else fOutput[0]=0;
			}
			for(i=0; i<2; i++)
				if(fOutput[i])
				{
					fRead[i]=1;
					fValid[i]=0;
					fScanningOK[i]=0;
					fprintf(fpout,"%d,%d,%d,%d,%d,%lf,%lu\n",
							nSolved[i],hash[i],d[i],nSolve[i],nRun[i],Popt[i],qseedStart[i]);
					count[d[i]]++;
					sum[d[i]]+=nSolve[i];
					nSolvedTotal++;
				}
		}
		fclose(fp[0]);
		fclose(fp[1]);
		fclose(fpout);
		Summarize(nSolvedTotal,count,sum,maxDepth);
		Summarize(nSolvedTotal,count,sum,maxDepth,"\\Research\\8pdbmergeSummary.dat");

		delete sum;
		delete count;
		return 0;
	}

	int fAppend=0;
	char instr[128];
	if(1!=sscanf(*++argv,"%s",&instr))
		goto byebye;
	if(strcmp(instr,"init"))
	{
		if(strcmp(instr,"cont"))
			goto byebye;
		else
			fAppend=1;
	}
	else
		fAppend=0;


	printf("Flavor=%d Append=%d\n",flavor,fAppend);

	// establish output db
	char* outFname;
	if(flavor)
		outFname="\\Research\\8pdb31.csv";
	else
		outFname="\\Research\\8pdb30.csv";

	// where to start?
	int nSolved=0;
	char lbuf[1024];
	if(fAppend)
	{
		FILE* fp=fopen(outFname,"r");
		while(1==fscanf(fp,"%s",lbuf))
		{
		if(1!=sscanf(lbuf,"%d",&nSolved))
			continue;
		}
		fclose(fp);
	}
	int nCompleted=nSolved;

	sqrand(1);

	FILE* fpin=fopen("\\Research\\8pdb2.csv","r");
	FILE* fp=fopen(outFname,fAppend?"a":"w");
	int nPuzzles=181440;

	int goal[]={
		1,2,3,
		8,0,4,
		7,6,5
		};
	int init[9];

	Game3x3 g;
	g.SetGoal(goal);

	int maxDepth=40;
	int maxN=1000000;
	double Plimit=0.90;

	fprintf(fp,"#,puzzle,d,nSolve,n,Popt\n");
	
	// clear stat monitors
	int* count=new int[maxDepth];
	double* sum=new double[maxDepth];
	for(int i=0; i<maxDepth; i++)
	{
		count[i]=0;
		sum[i]=0;
	}

	int fPrint=1;
	while(nSolved<nPuzzles && 1==fscanf(fpin,"%s",lbuf))
	{
		int hash;
		int nRun;
		i=1; // incremental scouting runs (+1)
		int d,nSolve,nLimit;
		double Popt;
		unsigned long qseedStart;
		if(7!=sscanf(lbuf,"%d,%d,%d,%d,%d,%lf,%lu",&nSolved,&hash,&d,&nSolve,&nRun,&Popt,&qseedStart))
			continue;
		if((hash&1)!=flavor) continue;
		if(nSolved<=nCompleted) continue;
		if(Popt>=Plimit)
			goto done;

		printf("Solving puzzle %d [%09d]\n",nSolved,hash);
		g.SetState(hash);
		g.UnloadState(init);
		if(fPrint) g.ShowState();

		d=maxDepth;
		nSolve=-1;
		Popt=0.;
		nLimit=nRun+maxN;
		for(i=nRun+1; i<=nLimit; i++)
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
done:
		if(fPrint) printf("[%d:%.2lf]\n",d,Popt);
		if(nSolve>0)
		{
			count[d]++;
			sum[d]+=nSolve;
		}
		fprintf(fp,"%d,%d,%d,%d,%d,%.4lf,%lu\n",nSolved,hash,d,nSolve,nRun+i-1,Popt,qseedStart);
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
				Summarize(nSolved,count,sum,maxDepth,"\\Research\\dbimpInter.csv");
				break;
			case 'x':
				nSolved=nPuzzles;
			}
		}
	}
	printf("\nDone.\n");
	fclose(fpin);
	fclose(fp);

	Summarize(nSolved,count,sum,maxDepth,"\\Research\\dbimpFinal.csv");


	delete sum;
	delete count;

	return 0;
}


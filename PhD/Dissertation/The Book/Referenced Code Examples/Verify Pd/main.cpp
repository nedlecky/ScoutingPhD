// Scout Cluster Simulation
// Variation to verify equation 4
// 8-puzzle
// Dissertation Example
// 1/20/99  John E. Lecky

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>
#include <math.h>

#define TRUE -1
#define FALSE 0

// DATA REPRESENTATION
// Situation representation
// int situation[10];
//	position map 0 1 2
//				 3 4 5
//				 6 7 8
//  9 is redundant location of blank
// Thus the 8-puzzle:
//	1 8 3
//	  4 2
//	5 7 6
// is represented as {1,8,3,0,4,2,5,7,6,3}


// Action representation
// int action[2];
//	0= move blank from position...
//  1= to position
// Thus if the first move in the example puzzle above is to move
// tile 5 up, the action is {6,3}

// desired goal situation
int Sg[]={
	// 1 2 3
	// 8 0 4
	// 7 6 5  with blank in pos 4
	1,2,3,8,0,4,7,6,5,
	4};

// RULES
// Rules are implemented as a list of possibilites
int rndMove8[][5]={
	{2,1,3,0,0},  // with blank in pos 0, there are 2 moves, 1 and 3
	{3,0,2,4,0},  // with blank in pos 1, there are 3 moves, 0, 2, and 4
	{2,1,5,0,0},  // with blank in pos 2, there are 2 moves, 1 and 5
	{3,0,4,6,0},  // etc.	
	{4,1,3,5,7},
	{3,2,4,8,0},
	{2,3,7,0,0},
	{3,4,6,8,0},
	{2,5,7,0,0}};

// FUNCTION PROTOTYPES
int VRand(int max);
void ScramblePuzzle(int* s,int n);
void ShowSituation(int* s,FILE* fp);
int GC(int* s);
void PA_Scout0(int* a,int* s);
void PA_Scout1(int* a,int* s);
void NS(int* s, int* a);
int Scout(int* s,int d0);
int ScoutCluster(int* s,int d0);

// Function pointer to allow use of 0-scout or 1-scout
void (*PA)(int* a,int* s);

// Global monitoring variables
char soln[1024];		// solution proposed by current scout
char bestSoln[1024];	// best solution found so far
int bestIter;			// scout number that found bestSoln

// Return a pseudo random integer 0 - max-1
// NOTE: C rand() function returns 0 to 32767.  This implementation
//   doubles the range since it calls rand() an odd number of times
int VRand(int max)
{
	return (rand() | rand()<<15 | (rand()&1)<<30)%max;
}

// Make n random moves in a puzzle; useful for generating test puzzles
void ScramblePuzzle(int* situation,int n)
{
	int action[2];
	action[0]=-1;
	
	for(int i=0; i<n; i++)
	{
		PA_Scout1(action,situation);
		NS(situation,action);
	}
}

// Display a game situation 
void ShowSituation(int* s,FILE* fp)
{
	fprintf(fp,"-----\n");
	for(int i=0; i<3; i++)
	{
		char buf[28];
		buf[3]=0;
		for(int j=0; j<3; j++)
			buf[j]='0'+s[i*3+j];
		fprintf(fp,"|%s|\n",buf);
	}
	fprintf(fp,"----%1d\n\n",s[9]);  // shows redundant blank pointer
}

// Is situation in the goal situation?
int GC(int* s)
{
	return 0==memcmp(s,Sg,9*sizeof(int));
}

// Given the current situation, pick a random action
// 0-scout version; no looking back at previous moves
void PA_Scout0(int* a,int* s)
{
	// pick a random move using the possible move table
	int blankPos=s[9];
	int n=rndMove8[blankPos][0];
	int move=rndMove8[blankPos][VRand(n)+1];

	// build action = from,to
	a[0]=blankPos;
	a[1]=move;
}

// Given the current situation, pick a random action
// 1-scout version; looking back at last move only
void PA_Scout1(int* a,int* s)
{
	int blankPos=s[9];
	int lastBlankPos=a[0];

	// keep picking random moves until we aren't backtracking
	int move=lastBlankPos;
	while(move==lastBlankPos)
	{
		int n=rndMove8[blankPos][0];
		move=rndMove8[blankPos][VRand(n)+1];
	}

	// build action = from,to
	a[0]=blankPos;
	a[1]=move;
}

// Perform action a on situation s
void NS(int* s, int* a)
{
	int from=a[0];
	int to=a[1];

	s[from]=s[to];  // move the blank
	s[to]=0;
	s[9]=to;		// update redundant position
}

// Scout Simulator
// return depth of found solution or -1 if no solution found
int Scout(int* Si,int d0)
{
	int s[10];
	memcpy(s,Si,10*sizeof(int));

	int a[2];
	a[0]=-1;  // invalid initial action to be ignored

	int d=0;
	soln[0]=0;

	char tbuf[2];
	tbuf[1]=0;
	while(!GC(s) && d<d0)
	{
		(*PA)(a,s);
		NS(s,a);
		d++;
	}

	if(d<d0)
		return d;
	else
		return -1;
}

// Implement the complete scout cluster
int ScoutCluster(int* s,int n,int d0)
{
	int initd0=d0;
	bestIter=0;
	bestSoln[0]=0;

	for(int i=0; i<n; i++)
	{
		int d=Scout(s,d0-1);
		if(d>=0)
			d0=d;
	}
	
	if(d0<initd0) return d0;
	else return -1;
}

// Run the complete simulation
int main()
{
	// select the scout-1 PA block
	srand(1);
	PA=&PA_Scout1;

	int s[10];

	// automatically generate the puzzles if the puzzles don't
	//   yet exist
	FILE* fp=fopen("pdata.dat","r");
	if(fp==NULL)
	{
		printf("Generating test puzzle database.\n");

		fp=fopen("pdata.dat","w");
		int nPuzzles=10;
		int dSum=0;
		int dMin=9999;
		int dMax=0;
		fprintf(fp,"%d\n",nPuzzles);
		for(int i=0; i<nPuzzles; i++)
		{
			// create the scrambled test puzzle
retry:		memcpy(s,Sg,10*sizeof(int));
			ScramblePuzzle(s,16 + VRand(10));
			printf("Looking for database puzzle %d\n",i+1);
			ShowSituation(s,stdout);

			// solve it with 200,000 scouts-1s.  This should almost
			//   always find the optimal solution
			int d=ScoutCluster(s,200000,100);
			printf("solution d=%d\n",d);

			// restrict database to puzzles with solutions 18-20 moves
			if(d<18 || d>20) goto retry;

			// save puzzle and solution length to database
			for(int j=0; j<10; j++)
				fprintf(fp,"%d ",s[j]);
			fprintf(fp,"%d\n",d);

			// maintain overall puzzle statistics
			dSum+=d;
			if(d<dMin) dMin=d;
			if(d>dMax) dMax=d;
		}

		// add the stats to the puzzle database file
		double dAvg=(double)dSum/(double)nPuzzles;
		printf("dAvg=%.1lf dMin=%d dMax=%d\n",dAvg,dMin,dMax);
		fprintf(fp,"%.1lf %d %d\n",dAvg,dMin,dMax);
		fclose(fp);
	}

	// read in puzzle database
	fp=fopen("pdata.dat","r");
	if(fp==NULL)
	{
		printf("ERROR: cannot find puzzle database.\n");
		return(1);
	}
	
	int nPuzzles;
	double dAvg;
	int dMin,dMax;

	int testS[100][10];
	int solution[100];

	// scan in actual file fields
	if(1!=fscanf(fp,"%d",&nPuzzles))
	{
error:
		fclose(fp);
		printf("FILE ERROR\n");
		return(1);
	}
	for(int i=0; i<nPuzzles; i++)
	{
		for(int j=0; j<10; j++)
			if(1!=fscanf(fp,"%d",&testS[i][j])) goto error;
		if(1!=fscanf(fp,"%d",&solution[i])) goto error;
	}
	if(3!=fscanf(fp,"%lf %d %d",&dAvg,&dMin,&dMax)) goto error;
	fclose(fp);

	// print simulation header
	printf("Puzzle Database: nPuzzles=%d dAvg=%.1lf dMin=%d dMax=%d\n",
		nPuzzles,dAvg,dMin,dMax);

	fp=fopen("pdtest.dat","w");

	// problem assumptions
	PA=&PA_Scout1;  // use scout-1 (b=1.67)
	double b=1.67;  // estimate branching factor
	double d=dAvg;  // estimated solution length
	double m=1.0;   // number of optimal solutions/puzzle; usually only one

	// Run simulations at various desired Pd
	int incr=10;
	for(int Pdtarget=10; Pdtarget<=99; Pdtarget+=incr)
	{
		// adjust incr
		if(Pdtarget==90) incr=5;
		if(Pdtarget==95) incr=2;

		double Pd=Pdtarget/100.;

		// compute theoretical n for this Pd
		double nd = -pow(b,d)/m * log(1. - Pd);
		int n = (int)nd;

		fprintf(fp,"PdTarget=%.02lf n=%d\n",Pd,n);
		printf("PdTarget=%.02lf n=%d\n",Pd,n);

		// run for all puzzles
		int nTotalBest=0;
		int nTotalPuzzles=0;
		for(int p=0; p<nPuzzles; p++)
		{
			fprintf(fp," p%d s=%d",p+1,solution[p]);
			printf("%d ",p+1);
			
			// solve each puzzle repeatedly with n scouts
			int count=20;
			int track[500];
			for(int it=0; it<count; it++)
			{
				int d=ScoutCluster(testS[p],(int)n,100);
				nTotalPuzzles++;
				track[it]=d;
			}

			// analyze how many times the optimal solution was found
			int nBest=0;
			for(it=0; it<count; it++)
				if(track[it]>0 && track[it]<=solution[p])
				{
					if(track[it]<solution[p])
						printf("b%d=%d\n",p+1,track[it]);
					nBest++;
					nTotalBest++;
				}
			
			// compute Pd for this single puzzle and display
			double Pdact=(double)nBest/(double)count;
			fprintf(fp," %d/%d Pd=%.2lf\n",nBest,count,Pdact);
		}

		// compute overal Pd for entire set of puzzles at given n
		double Pdavg=(double)nTotalBest/(double)(nTotalPuzzles);
		fprintf(fp," Pdavg=%.2lf Pdest=%.2lf\n",Pdavg,Pd);
		printf(" Pdact %d/%d=%.2lf Pdest=%.2lf\n",
			nTotalBest,nTotalPuzzles,Pdavg,Pd);
		fflush(fp);
	}

	fclose(fp);
	return 0;
}

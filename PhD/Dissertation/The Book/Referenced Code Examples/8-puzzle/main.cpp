// Scout Cluster Simulation
// 8-puzzle
// Dissertation Example
// 1/18/99  John E. Lecky

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>

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



// specific test puzzle from the dissertation
int testPuzzle[]={
	1,8,3,0,4,2,5,7,6,
	3};

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
void ShowSituation(int* s);
int GC(int* s);
void PA_Scout0(int* a,int* s);
void PA_Scout1(int* a,int* s);
void NS(int* s, int* a);
int Scout(int* s,int d0);
int ScoutCluster(int* s,int d0);
void Solve(int* s,int n,int k,int d0);

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
void ShowSituation(int* s)
{
	printf("-----\n");
	for(int i=0; i<3; i++)
	{
		char buf[28];
		buf[3]=0;
		for(int j=0; j<3; j++)
			buf[j]='0'+s[i*3+j];
		printf("|%s|\n",buf);
	}
	printf("----%1d\n\n",s[9]);  // shows redundant blank pointer
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
		tbuf[0]=a[1]+'0';
		strcat(soln,tbuf);
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
		{
			printf("scout %d found solution d=%d\n",i,d);
			d0=d;
			bestIter=i;
			strcpy(bestSoln,soln);
		}
	}
	
	if(d0<initd0) return d0;
	else return -1;
}

// Solve puzzle s n times with k scouts looking to a maxdepth d0
void Solve(int* s,int n,int k,int d0)
{
	for(int i=0; i<n; i++)
	{
		int d=ScoutCluster(s,k,d0);
		printf("best d=%d scout=%d ",d,bestIter);
		printf("moves=%s\n",bestSoln);
	}
}

// Run the complete simulation
int main()
{
	srand(1);

	// create a few random puzzles
	int sTest[3][10];
	for(int p=0; p<3; p++)
	{
		// build a random puzzle by making 1000000 random moves
		// starting from the goal situation
		memcpy(sTest[p],Sg,10*sizeof(int));
		ScramblePuzzle(sTest[p],1000001);
	}


	// run the examples with scout-0 first, then scout-1
	for(int i=0; i<2; i++)
	{
		if(i==0)
		{
			PA=&PA_Scout0;
			printf("Scout-0 TESTING\n");
		}
		else
		{
			PA=&PA_Scout1;
			printf("Scout-1 TESTING\n");
		}

		// run the test example from the dissertation
		int s[10];
		memcpy(s,testPuzzle,10*sizeof(int));
		ShowSituation(s);
		Solve(s,10,100000,100);

		// run the random examples
		for(p=0; p<3; p++)
		{
			ShowSituation(sTest[p]);
			Solve(sTest[p],10,100000,100);
		}
	}

	return 0;
}



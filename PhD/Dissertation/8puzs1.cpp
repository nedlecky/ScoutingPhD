// Spinner / Spinner2 Simulation
// 8 Puzzle Toy Problem
// 11/05/97 John E. Lecky

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#define TRUE -1
#define FALSE 0

// 8 Puzzle
// with blank in pos n (0-8), first el is #possible moves,
// remainder are moves
int rndMove8[][5]={
	{2,1,3,0,0},  // with blank in pos 0, there are 2 moves, 1 and 3
	{3,0,2,4,0},  // with blank in pos 1, there are 3 moves, 0, 2, and 4
	{2,1,5,0,0},  // etc.
	{3,0,4,6,0},
	{4,1,3,5,7},
	{3,2,4,8,0},
	{2,3,7,0,0},
	{3,4,6,8,0},
	{2,5,7,0,0}};

// action representation
// int action[2];
//	0= move blank from position...
//  1= to

// Situation representation
// int situation[10];
//	position map 0 1 2
//				 3 4 5
//				 6 7 8
//  9 is redundant location of blank

// the test puzzle
int initialSituation[]={
	// 1 8 3
	// 0 4 2
	// 5 7 6  with blank in pos 3
	1,8,3,0,4,2,5,7,6,
	3};

// desired goal
int goalSituation[]={
	// 1 2 3
	// 8 0 4
	// 7 6 5  with blank in pos 4
	1,2,3,8,0,4,7,6,5,
	4};

// display a game situation 
void ShowSituation(int* situation)
{
	printf(" ---\n");
	for(int i=0; i<3; i++)
	{
		char buf[28];
		buf[3]=0;
		for(int j=0; j<3; j++)
			buf[j]='0'+situation[i*3+j];
		printf("|%s|\n",buf);
	}
	printf(" --%1d\n\n",situation[9]);  // shows redundant blank pointer
}

// Is situation in the goal state?
int GoalCheck(int* situation)
{
	return 0==memcmp(situation,goalSituation,9*sizeof(int));
}

// Given the current situation, pick a random action
void GenerateRandomAction(int* action,int* situation)
{
	// pick a random move using the possible move table
	int blankPos=situation[9];
	int n=rndMove8[blankPos][0];
	int move=rndMove8[blankPos][rand()%n+1];

	// build action = from,to
	action[0]=blankPos;
	action[1]=move;
}

// Given the current situation, pick a random action
// AVOID GOING BACK TO UNDO PREVIOUS ACTION
void GenerateRandomAction2(int* action,int* situation)
{
	int blankPos=situation[9];
	int lastBlankPos=action[0];

	// keep picking random moves until we aren't backtracking
	int move=lastBlankPos;
	while(move==lastBlankPos)
	{
		int n=rndMove8[blankPos][0];
		move=rndMove8[blankPos][rand()%n+1];
	}

	// build action = from,to
	action[0]=blankPos;
	action[1]=move;
}

// perform 'action' on 'situation'
void ComputeNewSituation(int* situation, int* action)
{
	int from=action[0];
	int to=action[1];

	situation[from]=situation[to];  // move the blank
	situation[to]=0;
	situation[9]=to;				// update redundant position
}

// Spinner Implementation
// return depth of found solution or -1 if no solution found
int Spinner(int* initialSituation,int maxIterations)
{
	int situation[10];
	memcpy(situation,initialSituation,10*sizeof(int));

	int action[2];
	action[0]=-1;  // invalid initial action to be ignored

	int iterations=0;

	while(!GoalCheck(situation) && iterations<maxIterations)
	{
		GenerateRandomAction(action,situation);
		ComputeNewSituation(situation,action);
		iterations++;
	}

	if(iterations<maxIterations)
		return iterations;
	else
		return -1;
}

int main()
{
	ShowSituation(initialSituation);

	int best=100;
	
	// run 100000 spinners
	srand(time(NULL));
	for(int i=0; i<100000; i++)
	{
		int d=Spinner(initialSituation,best);
		if(d>0 && d<best)
		{
			printf("Found solution spinner %d, depth=%d\n",
				i,d);
			best=d;
		}
	}

	return 0;
}


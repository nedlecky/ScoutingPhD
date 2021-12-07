// Missionaries and Cannibals Scout Simulation
// 1/30/98 John E. Lecky

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>

#define TRUE -1
#define FALSE 0

int VRand(int max)
{
	int r=rand()%max;
	return r;
}

// Situation

// action representation
// int action[2];
//	# missionaries, # cannibals to cross
//  1= to

// Situation representation
// int situation[3];
// # missionaries, # cannibals, # boats on INITAL bank

// desired goal
int goalSituation[]={
	0,0,0};

// intitial situation
int initialSituation[]={
	3,3,1};

// display a game situation 
void ShowSituation(int* situation)
{
	for(int i=0; i<3; i++)
		printf("%d ",situation[i]);
	printf("\n");
}

// Is situation in the goal state?
int GoalCheck(int* situation)
{
	return 0==memcmp(situation,goalSituation,3*sizeof(int));
}

// Given the current situation, pick a random action
void GenerateRandomAction(int* action,int* situation)
{
	// where's the boat?
	int bank=situation[2]?0:1; // 0 is intial bank, 1 is final

	// how many m and c's waiting on the boat side?
	int mFrom=situation[0];
	if(bank) mFrom=3-mFrom;
	int cFrom=situation[1];
	if(bank) cFrom=3-cFrom;

	// how many on other side?
	int cTo=3-cFrom;
	int mTo=3-mFrom;

	//printf("From b%d: %d %d  To: %d %d\n",bank,mFrom,cFrom,mTo,cTo);

	int fNoMove=TRUE;
	int tries=0;
	int last=action[0]*10+action[1];
	while(fNoMove && tries<100)
	{
		tries++;
		switch(VRand(5))
		{
		case 0: // 1 missionary
			if(mFrom>0 && last!=10)
			{
				action[0]=1;
				action[1]=0;
				fNoMove=FALSE;
			}
			break;
		case 1: // 1 cannibal
			if(cFrom>0 && last!=01)
			{
				action[0]=0;
				action[1]=1;
				fNoMove=FALSE;
			}
			break;
		case 2: // 2 missionaries
			if(mFrom>1 && last!=20)
			{
				action[0]=2;
				action[1]=0;
				fNoMove=FALSE;
			}
			break;
		case 3: // 2 cannibals
			if(cFrom>1 && last!=02)
			{
				action[0]=0;
				action[1]=2;
				fNoMove=FALSE;
			}
			break;
		case 4: // 1 of each
			if(mFrom>0 && cFrom>0 && last!=11)
			{
				action[0]=1;
				action[1]=1;
				fNoMove=FALSE;
			}
			break;
		}
	}
	if(tries>=100) action[0]=-1;
	//printf("tries=%d act: %d %d\n",tries,action[0],action[1]);
}

// perform 'action' on 'situation'
int ComputeNewSituation(int* situation, int* action)
{
	//ShowSituation(situation);
	int nM=action[0];
	int nC=action[1];
	if(situation[2]) // boat on this bank
	{
		situation[0]-=action[0];
		situation[1]-=action[1];
		situation[2]=0;
	}
	else
	{
		situation[0]+=action[0];
		situation[1]+=action[1];
		situation[2]=1;
	}

	// Check if new situation is death!
	if(situation[0]>0) // missionaries on initial bank
		if(situation[1]>situation[0]) return FALSE;

	int mOther=3-situation[0];
	int cOther=3-situation[1];
	if(mOther>0)
		if(cOther>mOther) return FALSE;

	//ShowSituation(situation);
	//getch();
	return TRUE;
}

// Spinner2 Implementation
// return depth of found solution or -1 if no solution found
char soln[1024];
int Spinner2(int* initialSituation,int maxIterations)
{
	int situation[3];
	memcpy(situation,initialSituation,3*sizeof(int));

	int action[2];
	action[0]=-1;  // invalid initial action to be ignored

	int iterations=0;
	soln[0]=0;

	char tbuf[48];
	while(!GoalCheck(situation) && iterations<maxIterations)
	{
		GenerateRandomAction(action,situation);
		if(action[0]==-1)
		{
			//printf("no moves\n");
			return -1;
		}
		if(!ComputeNewSituation(situation,action))
		{
			//printf("death in %d moves: ",iterations+1);
			//ShowSituation(situation);
			return -1;
		}
		sprintf(tbuf,"(%d c,%d i)",action[0],action[1]);
		strcat(soln,tbuf);
		iterations++;
	}

	if(iterations<maxIterations)
		return iterations;
	else
		return -1;
}
int bestIter;
char bestSoln[1024];
int Cortex(int* situation,int maxIterations)
{
	int best=100;

	for(int i=0; i<maxIterations; i++)
	{
		int d=Spinner2(situation,best-1);
		if(d>=0 && d<best)
		{
			//printf("Found solution spinner %d, depth=%d\n",i,d);
			//printf("%s\n",soln);
			best=d;
			bestIter=i;
			strcpy(bestSoln,soln);
		}
	}
	if(best<100) return best;
	else return -1;
}

int main()
{
	unsigned int seed=2;
	srand(seed);

	for(int p=0; p<1; p++)
	{
		int situation[3];
		memcpy(situation,initialSituation,3*sizeof(int));
		ShowSituation(situation);

		for(int i=0; i<25; i++)
		{
			//printf("go i=%d p=%d\n",i,p);
			int d=Cortex(situation,20000);
			printf("%d %d %d ",p,d,bestIter);
			printf("%s\n",bestSoln);
		}
		
	}

	return 0;
}


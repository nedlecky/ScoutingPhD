#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>

//#include <sys/types.h>
//#include <sys/timeb.h>

#define TRUE -1
#define FALSE 0

const int EMPTY=0;
const int X=1;
const int O=2;

const int WIN=1;
const int LOSE=2;
const int DRAW=3;
const int INDETERMINATE=4;

// TicTacToe

int* InitialSituation(void)
{
	static int isit[]={0,0,0,0,0,0,0,0,0};

	return isit;
}

void ShowSituation(int* s)
{
	printf(" ---\n");
	for(int i=0; i<3; i++)
		printf("|%1d%1d%1d|\n",s[i*3],s[i*3+1],s[i*3+2]);
	printf(" ---\n\n");
}

int win[][3]={
	{0,1,2},
	{3,4,5},
	{6,7,8},
	{0,3,6},
	{1,4,7},
	{2,5,8},
	{0,4,8},
	{2,4,6}};

int GoalCheck(int* s)
{
	for(int i=0; i<8; i++)
	{
		int player=s[win[i][0]];
		if(player)
			if(player==s[win[i][1]] &&
				player==s[win[i][2]])
				return player;
	}
	for(i=0; i<9; i++)
		if(s[i]==EMPTY) return INDETERMINATE;

	return DRAW;
}

void GenerateFirstSystematicAction(int* action,int* situation,int player)
{
	for(int i=0; i<9; i++)
		if(situation[i]==EMPTY)
		{
			action[0]=player;
			action[1]=i;
			return;
		}
	// no first action
	action[0]=0;
	action[1]=0;
}

void GenerateNextSystematicAction(int* action,int* situation)
{
	int player=action[0];
	int pos=action[1];
	for(int i=pos+1; i<9; i++)
		if(situation[i]==EMPTY)
		{
			action[1]=i;
			return;
		}

		// no next action
	action[0]=action[1]=0;
}

void GenerateRandomAction(int* action,int* situation,int player)
{
	int it=0;
	while(it++<200)
	{
		int i=rand()%9;
		if(situation[i]==EMPTY)
		{
			action[0]=player;
			action[1]=i;
			return;
		}
	}
	// this should never happen
	printf("SOMETHING'S WRONG.  Seems to be no move!\n");
}

void ComputeNewSituation(int* situation, int* action)
{
	situation[action[1]]=action[0];
}

int Spinner2(int* initialSituation,int maxIterations,int player)
{
	int situation[9];
	memcpy(situation,initialSituation,9*sizeof(int));

	int action[2];
	action[0]=action[1]=0;

	int iterations=0;

	int g=GoalCheck(situation);
	while(g==INDETERMINATE && iterations<maxIterations)
	{
		GenerateRandomAction(action,situation,player);
		ComputeNewSituation(situation,action);
		g=GoalCheck(situation);
		//ShowSituation(situation);
		//getch();
		player = player==X ? O:X;
		iterations++;
	}


	return g;
}

// Try playing 'player' from here. firstMoves=-1 is exhaustive, else
//   number of random ones to try.  simulations is games per
//   first move
int* Contemplate(int* s,int player,int firstMoves,int simulations)
{
	int oplayer = player==X?O:X;

	static int bestAction[2];
	int bestSignal=-9999;

	int moreFirstMoves=TRUE;
	int moveCounter=0;
	int movePos=0;
	while(moreFirstMoves)
	{
		int situation[9];
		memcpy(situation,s,9*sizeof(int));
		int action[2];

		if(firstMoves<0)
		{
			if(moveCounter==0)
				GenerateFirstSystematicAction(action,situation,player);
			else
				GenerateNextSystematicAction(action,situation);
			if(action[0]==0)
			{
				moreFirstMoves=FALSE;
				break;
			}
		}
		else
		{
			GenerateRandomAction(action,situation,player);
			if(moveCounter>firstMoves) moreFirstMoves=FALSE;
		}

		ComputeNewSituation(situation,action);
		moveCounter++;

		int nWin=0;
		int nLose=0;
		int nDraw=0;
		for(int j=0; j<simulations; j++)
		{
			int g=Spinner2(situation,8,oplayer);
			if(g==player) nWin++;
			else if(g==oplayer) nLose++;
				else if(g==DRAW) nDraw++;

		}
		int signal=nWin+nDraw-nLose;
		if(signal>bestSignal)
		{
			bestSignal=signal;
			memcpy(bestAction,action,2*sizeof(int));
		}
	}

	return bestAction;
}


int main()
{
	ShowSituation(InitialSituation());

	int depth=100;
	int player=X;
	int situation[9];

	int nWin=0;
	int nLose=0;
	int nDraw=0;

	int intelligence[3];
	intelligence[X]=40;
	intelligence[O]=400;

	int firstMoves[3];
	firstMoves[X]=-1;
	firstMoves[O]=-1;

	for(int i=0; i<50; i++)
	{
		if(!(i%10000))
		{
			unsigned int t=time(NULL);
			srand(t);
			printf("reseeded(%u)\n",t);
		}

		memcpy(situation,InitialSituation(),9*sizeof(int));
		int noWin=TRUE;
		while(noWin)
		{
			int* action=Contemplate(situation,player,
				firstMoves[player],intelligence[player]);
			ComputeNewSituation(situation,action);
			//ShowSituation(situation); getch();
			int g=GoalCheck(situation);
			if(g==INDETERMINATE)
				player=player==X?O:X;
			else
			{
				noWin=FALSE;
				printf("Game Over!  %d\n",g);
				if(g==WIN) nWin++;
				if(g==LOSE) nLose++;
				if(g==DRAW) nDraw++;
			}

		}
	}

	printf("Result: W=%d L=%d D=%d\n",nWin,nLose,nDraw);
	return 0;
}


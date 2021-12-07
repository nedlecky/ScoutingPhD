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
const int Y=2;

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

int GoalCheck(int* s,int player)
{
	int me=player;
	int you = player==X ? Y:X;
	for(int i=0; i<8; i++)
	{
		if(s[win[i][0]]==me && s[win[i][1]]==me &&
			s[win[i][2]]==me) return WIN;
		if(s[win[i][0]]==you && s[win[i][1]]==you &&
			s[win[i][2]]==you) return LOSE;
	}
	for(i=0; i<9; i++)
		if(s[i]==EMPTY) return INDETERMINATE;

	return DRAW;
}

void GenerateRandomAction(int* action,int* situation,int player)
{
	// generate action list
	int nActions=0;
	
	// player,position pairs
	int possibleActions[32];

	for(int i=0; i<9; i++)
	{
		if(situation[i]==EMPTY)
		{
			possibleActions[nActions*2]=player;
			possibleActions[nActions*2+1]=i;
			nActions++;
		}
	}

	// pick one randomly
	int choice=rand()%nActions;
	action[0]=possibleActions[choice*2];
	action[1]=possibleActions[choice*2+1];
}

void ComputeNewSituation(int* situation, int* action)
{
	situation[action[1]]=action[0];
}

int* Spinner2(int* initialSituation,int maxIterations,int player)
{
	static int outcome[3];
	int situation[9];
	memcpy(situation,initialSituation,9*sizeof(int));

	int action[2];
	action[0]=action[1]=0;

	int iterations=0;

	int g=GoalCheck(situation,player);
	int actPlayer=player;
	while(g==INDETERMINATE && iterations<maxIterations)
	{
		GenerateRandomAction(action,situation,player);
		if(iterations==0)
		{
			outcome[1]=action[0];
			outcome[2]=action[1];
		}
		ComputeNewSituation(situation,action);
		g=GoalCheck(situation,actPlayer);
		//ShowSituation(situation);
		//getch();
		player = player==X ? Y:X;
		iterations++;
	}


	outcome[0]=g;
	return outcome;
}

int* TallyAndRecommend(int* s,int player,int scenarios)
{
	int win[9];
	int lose[9];
	int draw[9];
	int legal[9];
	int signal[9];

	for(int i=0; i<9; i++)
	{
		win[i]=0;
		lose[i]=0;
		draw[i]=0;
		legal[i]=FALSE;
	}

	for(i=0; i<scenarios; i++)
	{
		int* outcome=Spinner2(s,9,player);
		//printf("TTT Outcome [%s]\n",outcome);
		int ending=outcome[0];
		int player=outcome[1];
		int action=outcome[2];
		legal[action]=TRUE;
		if(ending==WIN)
			win[action]++;
		if(ending==LOSE)
			lose[action]++;
		if(ending==DRAW)
			draw[action]++;
	}

	int maxSignal=-9999;
	int bestAction=0;
	for(i=0; i<9; i++)
	{
		signal[i]=win[i]+draw[i]-lose[i];
		if(legal[i] && signal[i]>maxSignal)
		{
			maxSignal=signal[i];
			bestAction=i;
		}
	}

//	for(i=0; i<9; i++)
//		printf("%1d:  %3d %3d %3d %3d\n",i,win[i],lose[i],draw[i],signal[i]);

	static int action[2];
	action[0]=player;
	action[1]=bestAction;
	return action;
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
			int* action=TallyAndRecommend(situation,player,400);
			ComputeNewSituation(situation,action);
			//ShowSituation(situation);
			int g=GoalCheck(situation,player);
			if(g==INDETERMINATE)
				player=player==X?Y:X;
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


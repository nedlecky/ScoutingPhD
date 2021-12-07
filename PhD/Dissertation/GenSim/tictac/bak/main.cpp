#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>

//#include <sys/types.h>
//#include <sys/timeb.h>

#define TRUE -1
#define FALSE 0

// TicTacToe

char* InitialSituation(void)
{
	return("         ");
}

void ShowSituation(char* s)
{
	printf(" ---\n");
	for(int i=0; i<3; i++)
		printf("|%.3s|\n",s+i*3);
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

char GoalCheck(char* s,int player)
{
	char me=player+'0';
	int oplayer=player==1?2:1;
	char you=oplayer+'0';
	for(int i=0; i<8; i++)
	{
		if(s[win[i][0]]==me && s[win[i][1]]==me &&
			s[win[i][2]]==me) return 'W';
		if(s[win[i][0]]==you && s[win[i][1]]==you &&
			s[win[i][2]]==you) return 'L';
	}
	if(strchr(s,' ')) return '?';

	return 'D';
}

void GenerateRandomAction(char* action,char* situation,int player)
{
	// generate action list
	int nActions=0;
	char possibleActions[32];
	possibleActions[0]=0;

	for(int i=0; i<9; i++)
	{
		if(situation[i]==' ')
		{
			char tbuf[3];
			sprintf(tbuf,"%1d%1d",player,i);
			strcat(possibleActions,tbuf);
			nActions++;
		}
	}

	// pick one randomly
	char* sAction=possibleActions+((rand()%nActions)*2);

	// no undo action...
	strncpy(action,sAction,2);
}

void ComputeNewSituation(char* situation, char* action)
{
	char player;
	int to;

	sscanf(action,"%c%1d",&player,&to);
	situation[to]=player;
}

char* Spinner2(char* initialSituation,int maxIterations,int player)
{
	char* situation=strdup(initialSituation);
	char action[3];
	strcpy(action,"00");

	char actionHistory[1024];
	actionHistory[0]=0;
	char firstMove[128];

	int iterations=0;

	char g=GoalCheck(situation,player);
	int actPlayer=player;
	while(g=='?' && iterations<maxIterations)
	{
		GenerateRandomAction(action,situation,player);
		strcat(actionHistory,action);
		if(iterations==0) strcpy(firstMove,action);
		ComputeNewSituation(situation,action);
		g=GoalCheck(situation,actPlayer);
		//ShowSituation(situation);
		//getch();
		player=player==1?2:1;
		iterations++;
	}


	delete situation;

	static char outcome[32];
	sprintf(outcome,"%c%s",g,firstMove);
	//printf("%s\n",outcome);
	return outcome;
}

char* TallyAndRecommend(char* s,int player,int scenarios)
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
		char* outcome=Spinner2(s,9,player);
		//printf("TTT Outcome [%s]\n",outcome);
		char ending;
		int player;
		int action;
		sscanf(outcome,"%c%1d%1d",&ending,&player,&action);
		legal[action]=TRUE;
		if(ending=='W')
			win[action]++;
		if(ending=='L')
			lose[action]++;
		if(ending=='D')
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

	static char action[24];
	sprintf(action,"%1d%1d",player,bestAction);
	return action;
}


int main()
{
	ShowSituation(InitialSituation());

	int depth=100;
	int player=1;
	char situation[128];

	int nWin=0;
	int nLose=0;
	int nDraw=0;

	for(int i=0; i<10; i++)
	{
		if(!(i%10000))
		{
			unsigned int t=time(NULL);
			srand(t);
			printf("reseeded(%u)\n",t);
		}

		strcpy(situation,InitialSituation());
		int noWin=TRUE;
		while(noWin)
		{
			char* action=TallyAndRecommend(situation,player,1000);
			ComputeNewSituation(situation,action);
			//ShowSituation(situation);
			char g=GoalCheck(situation,player);
			if(g=='?')
				player=player==1?2:1;
			else
			{
				noWin=FALSE;
				printf("Game Over!  %c\n",g);
				if(g=='W') nWin++;
				if(g=='L') nLose++;
				if(g=='D') nDraw++;
			}

		}
	}

	printf("Result: W=%d L=%d D=%d\n",nWin,nLose,nDraw);
	return 0;
}


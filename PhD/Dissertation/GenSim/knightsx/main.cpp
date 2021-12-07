#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
//#include <sys/types.h>
//#include <sys/timeb.h>

#define TRUE -1
#define FALSE 0

// Knights Crossing
// Situation Format: "W B   W B"
//    9 chars, W,White Knight, B=Black, Space=empty

// Massive scanning gives 16 as best solution

int rules[][2]={
	{5,7},
	{6,8},
	{3,7},
	{2,8},
	{0,0},
	{0,6},
	{1,5},
	{0,2},
	{1,3}};

char* InitialSituation(void)
{
	return("W B   W B");
}

char* GoalSituation(void)
{
	return("B W   B W");
}

void ShowSituation(char* s)
{
	for(int i=0; i<3; i++)
		printf("%.3s\n",s+i*3);
	printf("\n");
}

int GoalCheck(char* s)
{
	return 0==strcmp(s,GoalSituation());
}

void GenerateRandomAction(char* action,char* situation)
{
	// generate action list
	int nActions=0;
	char possibleActions[128];
	possibleActions[0]=0;

	for(int i=0; i<9; i++)
	{
		if(situation[i]!=' ')
		{
			for(int j=0; j<2; j++)
			{
				int to=rules[i][j];
				if(situation[to]==' ')
				{
					char tbuf[3];
					sprintf(tbuf,"%1d%1d",i,to);
					strcat(possibleActions,tbuf);
					nActions++;
				}
			}
		}
	}

	// pick one randomly
	char* sAction=possibleActions+((rand()%nActions)*2);
	char undoAction[3];
	undoAction[0]=action[1];
	undoAction[1]=action[0];
	undoAction[2]=0;
	if(0==strncmp(sAction,undoAction,2))
		sAction=possibleActions+((rand()%nActions)*2);

	strncpy(action,sAction,2);
}

void ComputeNewSituation(char* situation, char* action)
{
	int from,to;

	sscanf(action,"%1d%1d",&from,&to);
	situation[to]=situation[from];
	situation[from]=' ';
}

int Spinner2(char* initialSituation,int maxIterations)
{
	char* situation=strdup(initialSituation);
	char action[3];
	strcpy(action,"00");

	char actionHistory[1024];
	actionHistory[0]=0;

	int iterations=0;

	while(!GoalCheck(situation) && iterations<maxIterations)
	{
		GenerateRandomAction(action,situation);
		strcat(actionHistory,action);
		ComputeNewSituation(situation,action);
		iterations++;
	}

	if(iterations<maxIterations)
	{
		printf("Solved [%s]\n",actionHistory);
		ShowSituation(situation);
	}

	delete situation;
	return iterations;
}


int main()
{
	ShowSituation(InitialSituation());

	int best=100;
	for(int i=0; i<50000; i++)
	{
		if(!(i%10000))
		{
			unsigned int t=time(NULL);
			srand(t);
			printf("reseeded(%u)\n",t);
		}
		int d=Spinner2(InitialSituation(),best);
		if(d!=best)
		{
			printf("Found solution spinner %d, depth=%d\n",
				i,d);
			best=d;
		}
	}
	return 0;
}


// Scouting Simulation
// RushHour Puzzle Problem
// 12/28/98 John E. Lecky

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

// Rush Hour

// action representation
// int action[3];
//	0 = Space Index
//  1 = Move From L,R,U,D
//  2 = Vehicle ID

// Situation representation
// int situation[36];
//	position map  0  1  2  3  4  5
//				  6  7  8  9 10 11
//				 12 13 14 15 16 17
//               18 19 20 21 22 23
//               24 25 26 27 28 29
//               30 31 32 33 34 35

// test puzzles
char* puzzle1[]={
	"AA   O",
	"P  Q O",
	"PXXQ O",
	"P  Q  ",
	"B   CC",
	"B RRR "
};
char* puzzle2[]={
	"A  OOO",
	"A  B P",
	"XX BCP",
	"QQQ CP",
	"  D EE",
	"FFDGG "
};
char* puzzle13[]={
	"AABBC ",
	"  D CO",
	" EDXXO",
	"PE FFO",
	"P  GHH",
	"PIIGKK"
};
char* puzzle14[]={
	"AAB   ",
	"  B CC",
	"DEXXFG",
	"DEHHFG",
	"  I JJ",
	"KKI   "
};
char* puzzle15[]={
	" AABB ",
	"CCDDOP",
	"QRXXOP",
	"QREFOP",
	"QREFGG",
	" HHII "
};


char** puzzles[]={
	puzzle1,
	puzzle2,
	puzzle13,
	puzzle14,
	puzzle15
	};

// load in the int vector situation from a 2-s array
int* LoadSituation(char** p)
{
	int* s=new int[36];
	for(int i=0; i<6; i++)
		for(int j=0; j<6; j++)
			s[i*6+j]=p[i][j];
	return s;
}


// display a game situation 
void ShowSituation(int* situation)
{
	printf("--------\n");
	for(int i=0; i<6; i++)
	{
		char buf[28];
		buf[6]=0;
		for(int j=0; j<6; j++)
			buf[j]=situation[i*6+j];
		printf("|%s|\n",buf);
	}
	printf("--------\n\n",situation[9]);  // shows redundant blank pointer
}

// Is situation in the goal state?
int GoalCheck(int* situation)
{
	for(int check=17; check>=12; check--)
	{
		if(situation[check]=='X') return TRUE;
		else
			if(situation[check]!=' ') return FALSE;
	}
	return FALSE;
}

// Given the current situation, pick a random action
int actions[100][3];
int nMoves=0;
void GenerateActionList(int* situation)
{
	nMoves=0;
	for(int r=0; r<6; r++)
	{
		for(int c=0; c<6; c++)
		{
			if(situation[r*6+c]==' ')
			{
				// something to the left?
				if(c>1 && situation[r*6+c-1]!=' ' &&
					situation[r*6+c-2]==situation[r*6+c-1])
				{
					actions[nMoves][0]=r*6+c;
					actions[nMoves][1]='R';
					actions[nMoves][2]=situation[r*6+c-1];
					nMoves++;
				}
				// something to the right?
				if(c<4 && situation[r*6+c+1]!=' ' &&
					situation[r*6+c+2]==situation[r*6+c+1])
				{
					actions[nMoves][0]=r*6+c;
					actions[nMoves][1]='L';
					actions[nMoves][2]=situation[r*6+c+1];
					nMoves++;
				}
				// something above?
				if(r>1 && situation[(r-1)*6+c]!=' ' &&
					situation[(r-2)*6+c]==situation[(r-1)*6+c])
				{
					actions[nMoves][0]=r*6+c;
					actions[nMoves][1]='D';
					actions[nMoves][2]=situation[(r-1)*6+c];
					nMoves++;
				}
				// something below?
				if(r<4 && situation[(r+1)*6+c]!=' ' &&
					situation[(r+2)*6+c]==situation[(r+1)*6+c])
				{
					actions[nMoves][0]=r*6+c;
					actions[nMoves][1]='U';
					actions[nMoves][2]=situation[(r+1)*6+c];
					nMoves++;
				}
			}
		}
	}

}

// Given the current situation, pick a random action
void GenerateRandomAction(int* action,int* situation)
{
	int lastD=action[1];
	int lastV=action[2];
	
	GenerateActionList(situation);

	int nRetries=0;

redo:
	int n=VRand(nMoves);

	// build action = from,to
	action[0]=actions[n][0];
	action[1]=actions[n][1];
	action[2]=actions[n][2];

	if(nRetries<3 && action[2]==lastV && action[1]!=lastD)
	{
		nRetries++;
		goto redo;
	}
}

// perform 'action' on 'situation'
void ComputeNewSituation(int* situation, int* action)
{
	int r=action[0]/6;
	int c=action[0]%6;
	int v=action[2];
	situation[r*6+c]=v;

	if(action[1]=='L')
	{
		c++;
		while(c<6 && situation[r*6+c+1]==v) c++;
		situation[r*6+c]=' ';
		return;
	}
	if(action[1]=='R')
	{
		c--;
		while(c>=0 && situation[r*6+c-1]==v) c--;
		situation[r*6+c]=' ';
		return;
	}
	if(action[1]=='U')
	{
		r++;
		while(r<6 && situation[(r+1)*6+c]==v) r++;
		situation[r*6+c]=' ';
		return;
	}
	if(action[1]=='D')
	{
		r--;
		while(r>=0 && situation[(r-1)*6+c]==v) r--;
		situation[r*6+c]=' ';
		return;
	}
}

// Spinner2 Implementation
// return depth of found solution or -1 if no solution found
char soln[1024];
int Spinner2(int* initialSituation,int maxIterations)
{
	int situation[36];
	memcpy(situation,initialSituation,36*sizeof(int));

	int action[2];
	action[0]=-1;  // invalid initial action to be ignored

	int iterations=0;
	soln[0]=0;

	char tbuf[32];
	while(!GoalCheck(situation) && iterations<maxIterations)
	{
		GenerateRandomAction(action,situation);
		ComputeNewSituation(situation,action);
		sprintf(tbuf,"%c%c1",action[2],action[1]);
		strcat(soln,tbuf);
		iterations++;
	}

	if(iterations<maxIterations)
	{
//		ShowSituation(situation);
		return iterations;
	}
	else
		return -1;
}
int bestIter;
char bestSoln[1024];
int Cortex(int* situation,int maxIterations)
{
	int best=100;
	bestIter=0;
	bestSoln[0]=0;

	for(int i=0; i<maxIterations; i++)
	{
		int d=Spinner2(situation,best-1);
		if(d>=0 && d<best)
		{
			//printf("Found solution spinner %d, depth=%d\n",i,d);
			best=d;
			bestIter=i;
			strcpy(bestSoln,soln);
		}
	}
	if(best<100) return best;
	else return -1;
}

void Randomize(int* situation,int n)
{
	int action[3];
	action[0]=-1;
	
	for(int i=0; i<n; i++)
	{
		GenerateRandomAction(action,situation);
		ComputeNewSituation(situation,action);
	}
}

int main()
{
	unsigned int seed=2;
	srand(seed);

	for(int p=0; p<5; p++)
	{
		int* situation=LoadSituation(puzzles[p]);
		ShowSituation(situation);


		for(int i=0; i<1; i++)
		{
			int d=Cortex(situation,1000000);
			printf("p=%d i=%d best=%d (%d) ",p,i,d,bestIter);
			printf("%s\n",bestSoln);
		}
	}

	return 0;
}


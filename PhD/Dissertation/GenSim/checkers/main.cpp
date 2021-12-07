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
const int BLACK=1;
const int RED=2;
const int BLACK_KING=5;
const int RED_KING=6;

const int MOVE=1;
const int JUMP=2;
const int STUCK=3;

const int WIN=1;
const int LOSE=2;
const int DRAW=3;
const int INDETERMINATE=4;

const int MAX_UNTIL_DRAW=80;

char* special=NULL;


int Color(int p)
{
	return p&3;
}
int QueryKing(int p)
{
	return p&4;
}

// Checkers
// Situation: 64 squares, moves until draw counter
int* InitialSituation(void)
{
	static int isit[65];

	for(int i=0; i<64; i++)
		isit[i]=EMPTY;
	for(int col=2/*0*/; col<6/*8*/; col+=2)
	{
		isit[0*8+col+1]=BLACK;
		isit[1*8+col]=BLACK;
		isit[2*8+col+1]=BLACK;
		isit[5*8+col]=RED;
		isit[6*8+col+1]=RED;
		isit[7*8+col]=RED;
		
		//isit[1*8+col]=BLACK;
		//isit[5*8+col]=RED;
	}
	
	isit[64]=MAX_UNTIL_DRAW;

	return isit;
}

void ShowSituation(int* s)
{
	printf(" ----------------\n");
	for(int i=0; i<8; i++)
	{
		printf("|");
		for(int j=0; j<8; j++)
			if(i&1 ^ j&1)
				printf("%2d",s[i*8+j]);
			else
				printf("  ");
		printf("|   ");
		for(j=0; j<8; j++)
			if(i&1 ^ j&1)
				printf("%2d",i*8+j);
			else
				printf("  ");
		printf("\n");
	}

	printf(" ----------------\n\n");
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

int moveDestinations[]={
	{-9},
	{-7},
	{ 7},
	{ 9}};

int flag=FALSE;
int GenerateAllActions(int* possibleActions,int* situation,int player)
{
	int oplayer=player==BLACK?RED:BLACK;
	
	// generate action list
	int nActions=0;

	int fCanJump=FALSE;
	
	int dir=0;
	// jumps
	for(int i=0; i<64; i++)
	{
		if(Color(situation[i])==player)
		{
			int sMove;
			int eMove;
			if(QueryKing(situation[i]))
			{
				sMove=0;
				eMove=3;
			}
			else
			{
				if(player==BLACK)
				{
					sMove=2;
					eMove=3;
				}
				else
				{
					sMove=0;
					eMove=1;
				}
			}
			
			// single jumps
			for(int m=sMove; m<=eMove; m++)
			{
				int col=i%8;
				int target=i+moveDestinations[m];
				int dest=i+2*moveDestinations[m];
				int destCol=dest%8;
				if(dest>=0 && dest<64)
				{
					if(situation[dest]==EMPTY && Color(situation[target])==oplayer &&
						abs(destCol-col)==2)
					{
						fCanJump=TRUE;
						//if(flag) printf("poss jump %d %d\n",i,dest);
						if(possibleActions!=NULL)
						{
							possibleActions[nActions*3]=JUMP;
							possibleActions[nActions*3+1]=i;
							possibleActions[nActions*3+2]=dest;
						}
						nActions++;
					}
				}
			}

		}
	}

	// moves
	for(i=0; i<64 && !fCanJump; i++)
	{
		if(Color(situation[i])==player)
		{
			int sMove;
			int eMove;
			if(QueryKing(situation[i]))
			{
				sMove=0;
				eMove=3;
			}
			else
			{
				if(player==BLACK)
				{
					sMove=2;
					eMove=3;
				}
				else
				{
					sMove=0;
					eMove=1;
				}
			}
			
			// regular moves
			for(int m=sMove; m<=eMove; m++)
			{
				int col=i%8;
				int dest=i+moveDestinations[m];
				int destCol=dest%8;
				if(dest>=0 && dest<64)
					if(situation[dest]==EMPTY && abs(destCol-col)==1)
					{
						//if(flag) printf("poss move %d %d\n",i,dest);
						if(possibleActions!=NULL)
						{
							possibleActions[nActions*3]=MOVE;
							possibleActions[nActions*3+1]=i;
							possibleActions[nActions*3+2]=dest;
						}
						nActions++;
					}
			}
		}
	}
	return nActions;
}

int* GoalCheck(int* situation)
{
	static int report[3];
	int final=0;
	int redScore=0;
	int blackScore=0;

	special="???";

	for(int i=0; i<64; i++)
	{
		if(Color(situation[i])==RED)
		{
			redScore++;
			if(QueryKing(situation[i])) redScore++;
		}
		else
			if(Color(situation[i])==BLACK)
			{
				blackScore++;
				if(QueryKing(situation[i])) blackScore++;
			}
	}

	report[1]=redScore;
	report[2]=blackScore;
	if(redScore>0 && blackScore==0)
	{
		report[0]=RED;
		special="RED eliminated all BLACK players";
		return report;
	}
	if(redScore==0 && blackScore>0)
	{
		report[0]=BLACK;
		special="BLACK eliminated all RED players";
		return report;
	}

	// draw check
	if(situation[64]<=0)
	{
		report[0]=DRAW;
		special="Too long since a capture";
		return report;
	}

	// No Legal Moves?
	if(0==GenerateAllActions(NULL,situation,RED))
	{
		report[0]=BLACK;
		special="RED has no legal moves";
		return report;
	}
	if(0==GenerateAllActions(NULL,situation,BLACK))
	{
		report[0]=RED;
		special="BLACK has no legal moves";
		return report;
	}

	// can't really say how its going...
	report[0]=INDETERMINATE;
	return report;
}


int nsa=0;
int nra=0;

void GenerateRandomAction(int* action,int* situation,int player)
{
nra++;
	int possibleActions[1024];
	int nActions=GenerateAllActions(possibleActions,situation,player);


	// pick one randomly
	if(!nActions)
		action[0]=STUCK;
	else
	{
		int choice=rand()%nActions;
		action[0]=possibleActions[choice*3];
		action[1]=possibleActions[choice*3+1];
		action[2]=possibleActions[choice*3+2];
	}
}

typedef struct saTag
{
	int actions[1024];
	int n;
	int index;
} systematicActions;

void GenerateNextSystematicAction(systematicActions* sa,int* action)
{
nsa++;
	if(sa->index>=sa->n)
	{
		action[0]=STUCK;
		action[1]=action[2]=0;
	}
	else
	{
		action[0]=sa->actions[sa->index*3];
		action[1]=sa->actions[sa->index*3+1];
		action[2]=sa->actions[sa->index*3+2];
		sa->index++;
	}
}
int GenerateFirstSystematicAction(systematicActions* sa,int* action,int* situation,int player)
{
nsa++;
	sa->n=GenerateAllActions(sa->actions,situation,player);
	sa->index=0;
	if(sa->n<1)
		action[0]=STUCK;
	else
		GenerateNextSystematicAction(sa,action);
	return sa->n;
}

void ComputeNewSituation(int* situation, int* action)
{
	if(situation[action[1]]==EMPTY)
	{
		printf("from empty square! %d %d %d\n",action[0],action[1],action[2]);
		ShowSituation(situation);
		printf("any key...\n"); getch();
	}
	if(action[0]==MOVE)
	{
		situation[action[2]]=situation[action[1]];
		situation[action[1]]=EMPTY;
		// king me?
		int row=action[2]/8;
		if(row==0 || row==7) situation[action[2]] |= 4;
		situation[64]--;  // one more move without a capture
	}
	if(action[0]==JUMP)
	{
		situation[action[2]]=situation[action[1]];
		situation[action[1]]=EMPTY;
		situation[(action[1]+action[2])/2]=EMPTY;
		// king me?
		int row=action[2]/8;
		if(row==0 || row==7) situation[action[2]] |= 4;
		situation[64]=MAX_UNTIL_DRAW;  // reset capture counter
	}
}

int* Spinner2(int* initialSituation,int maxIterations,int player)
{
	int situation[65];
	memcpy(situation,initialSituation,65*sizeof(int));

	int action[3];
	action[0]=action[1]=action[2]=0;

	int iterations=0;

	int* g=GoalCheck(situation);
	while(g[0]==INDETERMINATE && iterations<maxIterations)
	{
		GenerateRandomAction(action,situation,player);
		if(action[0]==STUCK)
		{
			g[0]=DRAW;
			return g;
		}
		ComputeNewSituation(situation,action);
		g=GoalCheck(situation);
		player = player==RED ? BLACK:RED;
		iterations++;
	}

	return g;
}

// Try playing 'player' from here. firstMoves=-1 is exhaustive, else
//   number of random ones to try.  simulations is games per
//   first move
int ContemplateRandom(int level,int* action,int* s,int player,int firstMoves,int simulations,int depth)
{
//	for(int sp=0; sp<level; sp++) printf("  ");
//	printf("ConRnd%d player=%d fm=%d sim=%d dep=%d\n",level,player,firstMoves,
//		simulations,depth);

	int oplayer = player==RED?BLACK:RED;

	int bestSignal=-9999;

	int moreFirstMoves=TRUE;
	int moveCounter=0;
	int movePos=0;
	int lastAction[3];
	memcpy(lastAction,action,3*sizeof(int));

	systematicActions sa;

	while(moreFirstMoves)
	{
		int situation[65];
		memcpy(situation,s,65*sizeof(int));
		int testAction[3];
		memcpy(testAction,lastAction,3*sizeof(int));

		if(firstMoves<0)
		{
			if(moveCounter==0)
			{
				int n=GenerateFirstSystematicAction(&sa,testAction,situation,player);
				//printf("%d moves to consider...\n",n);
			}
			else
			{
				GenerateNextSystematicAction(&sa,testAction);
				if(testAction[0]!=STUCK && situation[testAction[1]]==EMPTY)
					printf("empty action from nextsys");
			}
			if(testAction[0]==STUCK)
			{
				moreFirstMoves=FALSE;
				break;
			}
		}
		else
		{
			GenerateRandomAction(testAction,situation,player);
			if(moveCounter>firstMoves) moreFirstMoves=FALSE;
		}

		//printf("moving %d %d %d\n",testAction[0],testAction[1],testAction[2]);
		//getch();
		ComputeNewSituation(situation,testAction);
		moveCounter++;

		int nWin=0;
		int nLose=0;
		int nDraw=0;
		int nIndeterminate=0;
		int myScore=0;
		int yourScore=0;
		for(int j=0; j<simulations; j++)
		{
			int* g=Spinner2(situation,depth,oplayer);
			if(g[0]==player) nWin++;
			else if(g[0]==oplayer) nLose++;
				else if(g[0]==DRAW) nDraw++;
					else
					{
						nIndeterminate++;
						if(player==RED)
						{
							myScore+=g[1];
							yourScore+=g[2];
						}
						else
						{
							myScore+=g[2];
							yourScore+=g[1];
						}
					}
		}

		//printf("Contemplated [%d,%d,%d]\n",action[0],action[1],action[2]);
		//printf("w=%d l=%d d=%d i=%d rs=%d bs=%d\n",
		//	nWin,nLose,nDraw,nIndeterminate,redScore,blackScore);
		//getch();
		//int signal=nWin+nDraw-nLose;
		int signal=nWin+nDraw-nLose+myScore-yourScore;
		if(signal>bestSignal)
		{
			bestSignal=signal;
			memcpy(action,testAction,3*sizeof(int));
		}
	}
	return bestSignal;
}

// Try playing 'player' from here. firstMoves=-1 is exhaustive, else
//   number of random ones to try.  simulations is games per
//   first move
int Contemplate(int level,int* action,int* s,int player,int firstMoves,int simulations,int depth)
{
//	for(int sp=0; sp<level; sp++) printf("  ");
//	printf("Con%d player=%d fm=%d sim=%d dep=%d\n",level,player,firstMoves,
//		simulations,depth);

	int oplayer = player==RED?BLACK:RED;

	int bestValue=-9999;
	int worstValue=9999;

	int moreFirstMoves=TRUE;
	int moveCounter=0;
	int movePos=0;
	int lastAction[3];
	memcpy(lastAction,action,3*sizeof(int));

	systematicActions sa;

	while(moreFirstMoves)
	{
		int situation[65];
		memcpy(situation,s,65*sizeof(int));
		int testAction[3];
		memcpy(testAction,lastAction,3*sizeof(int));

		if(firstMoves<0)
		{
			if(moveCounter==0)
			{
				int n=GenerateFirstSystematicAction(&sa,testAction,situation,player);
//				printf("1st Sys %d moves to consider...\n",n);
			}
			else
			{
				GenerateNextSystematicAction(&sa,testAction);
				if(testAction[0]!=STUCK && situation[testAction[1]]==EMPTY)
					printf("empty action from nextsys");
			}
			if(testAction[0]==STUCK)
			{
				moreFirstMoves=FALSE;
				break;
			}
		}
		else
		{
			GenerateRandomAction(testAction,situation,player);
			if(moveCounter>firstMoves) moreFirstMoves=FALSE;
		}

		ComputeNewSituation(situation,testAction);
		moveCounter++;

		int value=0;
		if(level<3)
		{
			value=Contemplate(level+1,testAction,situation,oplayer,firstMoves,simulations,depth);

		}
		else
		{
			value=ContemplateRandom(level+1,testAction,situation,oplayer,firstMoves,simulations,depth);
		}
		if(level&1) // playing for other
		{
			if(value<worstValue)
			{
				worstValue=value;
				if(!level) memcpy(action,testAction,3*sizeof(int));
			}
		}
		else
		{
			if(value>bestValue)
			{
				bestValue=value;
				if(!level) memcpy(action,testAction,3*sizeof(int));
			}
		}
	}

	return level&1 ? worstValue:bestValue;
}

int main()
{
	ShowSituation(InitialSituation());

	int player=BLACK;
	int situation[65];

	int nWin=0;
	int nLose=0;
	int nDraw=0;

	// # moves considered (-1 = all)
	int firstMoves[3];
	firstMoves[RED]=-1;
	firstMoves[BLACK]=-1;

	// # simulations from each proposed move
	int intelligence[3];
	intelligence[RED]=25;
	intelligence[BLACK]=25;

	// simulation depth
	int insight[3];
	insight[RED]=3;
	insight[BLACK]=3;


	for(int i=0; i<10; i++)
	{
		if(!(i%10000))
		{
			unsigned int t=time(NULL);
			srand(t);
			printf("reseeded(%u)\n",t);
		}

		memcpy(situation,InitialSituation(),65*sizeof(int));
		int noWin=TRUE;
		int action[3];
		action[0]=0;
		int fVsHuman=TRUE;
		while(noWin)
		{
			if(fVsHuman && player==BLACK)
			{
				ShowSituation(situation);
				int possibleActions[1024];
				//flag=TRUE;
				int nMoves=GenerateAllActions(possibleActions,situation,player);
				//flag=FALSE;
				for(int m=0; m<nMoves; m++)
				{
					printf("%d: %1d: %2d --> %2d\n",m,
					possibleActions[m*3],possibleActions[m*3+1],possibleActions[m*3+2]);
				}
				printf("Your Move: ( I recommend ");
				nsa=nra=0;
				Contemplate(0,action,situation,player,
					firstMoves[player],intelligence[player],insight[player]);
				printf("%d: %d %d --> %d)\n",player,action[0],action[1],action[2]);
				//printf("nsa=%d nra=%d",nsa,nra);
				scanf("%d",&m);
				printf("\n");
				action[0]=possibleActions[m*3];
				action[1]=possibleActions[m*3+1];
				action[2]=possibleActions[m*3+2];
			}
			else
			{
				Contemplate(0,action,situation,player,
					firstMoves[player],intelligence[player],insight[player]);
				printf("I'll move %d: %d --> %d\n",action[0],action[1],action[2]);
			}

			ComputeNewSituation(situation,action);
			int* g=GoalCheck(situation);
			if(g[0]==INDETERMINATE)
				player=player==RED?BLACK:RED;
			else
			{
				noWin=FALSE;
				printf("Game Over! %s\n",special);
				ShowSituation(situation);
				//getch();
				if(g[0]==BLACK) nWin++;
				if(g[0]==RED) nLose++;
				if(g[0]==DRAW) nDraw++;
			}

		}
	}

	printf("Result: BLACK=%d RED=%d DRAW=%d\n",nWin,nLose,nDraw);
	return 0;
}


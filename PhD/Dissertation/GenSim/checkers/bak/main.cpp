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
const int RED=1;
const int BLACK=2;
const int RED_KING=5;
const int BLACK_KING=6;

const int MOVE=0x100;
const int JUMP=0x200;
const int STUCK=0x300;

const int WIN=1;
const int LOSE=2;
const int DRAW=3;
const int INDETERMINATE=4;

const int MAX_UNTIL_DRAW=50;


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

	for(int i=0; i<64; i++) isit[i]=EMPTY;
	for(int col=0; col<8; col+=2)
	{
		isit[0*8+col+1]=BLACK;
		isit[1*8+col]=BLACK;
		isit[2*8+col+1]=BLACK;
		isit[5*8+col]=RED;
		isit[6*8+col+1]=RED;
		isit[7*8+col]=RED;
	}
	
	isit[64]=MAX_UNTIL_DRAW;

	return isit;
}

void ShowSituation(int* s)
{
	printf(" --------\n");
	for(int i=0; i<8; i++)
	{
		printf("|");
		for(int j=0; j<8; j++) printf("%1d",s[i*8+j]);
		printf("|\n");
	}

	printf(" --------\n\n");
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

int* GoalCheck(int* situation)
{
	static int report[3];
	int final=0;
	int redScore=0;
	int blackScore=0;

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
		return report;
	}
	if(redScore==0 && blackScore>0)
	{
		report[0]=BLACK;
		return report;
	}

	// draw check
	if(situation[64]<=0)
	{
		report[0]=DRAW;
		return report;
	}

	// can't really say how its going...
	report[0]=INDETERMINATE;
	return report;
}

int moveDestinations[]={
	{-9},
	{-7},
	{ 7},
	{ 9}};


int GenerateAllActions(int* possibleActions,int* situation,int player)
{
	int oplayer=player==BLACK?RED:BLACK;
	
	// generate action list
	int nActions=0;

	int fCanJump=FALSE;
	
	int dir=0;
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
					if(situation[dest]==EMPTY && Color(situation[target])==oplayer &&
						abs(destCol-col)==2)
						{
							fCanJump=TRUE;
							possibleActions[nActions*3]=JUMP;
							possibleActions[nActions*3+1]=i;
							possibleActions[nActions*3+2]=dest;
							nActions++;
						}
			}

			// regular moves
			for(m=sMove; m<=eMove && !fCanJump; m++)
			{
				int col=i%8;
				int dest=i+moveDestinations[m];
				int destCol=dest%8;
				if(dest>=0 && dest<64)
					if(situation[dest]==EMPTY && abs(destCol-col)==1)
					{
						possibleActions[nActions*3]=MOVE;
						possibleActions[nActions*3+1]=i;
						possibleActions[nActions*3+2]=dest;
						nActions++;
					}
			}
		}
	}
	return nActions;
}

void GenerateRandomAction(int* action,int* situation,int player)
{
	int possibleActions[1024];
	int nActions=GenerateAllActions(possibleActions,situation,player);

	int backTrack[3];
	if(action[0]==MOVE)
	{
		backTrack[0]=action[0];
		backTrack[1]=action[2];
		backTrack[2]=action[1];
	}
	else backTrack[0]=0;


	// pick one randomly
	if(!nActions)
	{
		action[0]=STUCK;
	}
	else
	{
		int choice=rand()%nActions;
		action[0]=possibleActions[choice*3];
		action[1]=possibleActions[choice*3+1];
		action[2]=possibleActions[choice*3+2];
		if(0)//0==memcmp(action,backTrack,3*sizeof(int)))
		{
			// once more!
			printf("bt avoid\n");
			int choice=rand()%nActions;
			action[0]=possibleActions[choice*3];
			action[1]=possibleActions[choice*3+1];
			action[2]=possibleActions[choice*3+2];
		}
	}
}

int systematicActions[1024];
int systematicN;
int systematicIndex=0;
void GenerateNextSystematicAction(int* action)
{
	if(systematicIndex>=systematicN)
	{
		action[0]=STUCK;
	}
	else
	{
		int backTrack[3];
		if(action[0]==MOVE)
		{
			backTrack[0]=action[0];
			backTrack[1]=action[2];
			backTrack[2]=action[1];
		}
		else backTrack[0]=0;

		action[0]=systematicActions[systematicIndex*3];
		action[1]=systematicActions[systematicIndex*3+1];
		action[2]=systematicActions[systematicIndex*3+2];
		systematicIndex++;

		if(0)//0==memcmp(action,backTrack,3*sizeof(int)))
		{
			// once more!
			printf("bt avoid\n");
			if(systematicIndex>=systematicN)
			{
				action[0]=STUCK;
			}
			else
			{
				action[0]=systematicActions[systematicIndex*3];
				action[1]=systematicActions[systematicIndex*3+1];
				action[2]=systematicActions[systematicIndex*3+2];
				systematicIndex++;
			}
		}
	}
}
int GenerateFirstSystematicAction(int* action,int* situation,int player)
{
	systematicN=GenerateAllActions(systematicActions,situation,player);
	if(systematicN<1)
	{
		action[0]=STUCK;
	}
	else
	{
		systematicIndex=0;
		GenerateNextSystematicAction(action);
	}
	return systematicN;
}

void ComputeNewSituation(int* situation, int* action)
{
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
			break;
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
void Contemplate(int* action,int* s,int player,int firstMoves,int simulations,int depth)
{
	int oplayer = player==RED?BLACK:RED;

	int bestSignal=-9999;

	int moreFirstMoves=TRUE;
	int moveCounter=0;
	int movePos=0;
	int lastAction[3];
	memcpy(lastAction,action,3*sizeof(int));
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
				int n=GenerateFirstSystematicAction(testAction,situation,player);
				//printf("%d moves to consider...\n",n);
			}
			else
				GenerateNextSystematicAction(testAction);
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
							yourScore+=g[1];
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
		int signal=10*nWin-5*nLose+myScore-yourScore;
		if(signal>bestSignal)
		{
			bestSignal=signal;
			memcpy(action,testAction,3*sizeof(int));
		}
	}
}


int main()
{
	ShowSituation(InitialSituation());

	int player=RED;
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
	intelligence[RED]=20;
	intelligence[BLACK]=20;

	// simulation depth
	int insight[3];
	insight[RED]=5;
	insight[BLACK]=5;


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
		while(noWin)
		{
			Contemplate(action,situation,player,
				firstMoves[player],intelligence[player],insight[player]);
			ComputeNewSituation(situation,action);
			//getch();
			//ShowSituation(situation);
			int* g=GoalCheck(situation);
			if(g[0]==INDETERMINATE)
				player=player==RED?BLACK:RED;
			else
			{
				noWin=FALSE;
				printf("Game Over!  %d\n",g[0]);
				ShowSituation(situation);
				getch();
				if(g[0]==RED) nWin++;
				if(g[0]==BLACK) nLose++;
				if(g[0]==DRAW) nDraw++;
			}

		}
	}

	printf("Result: W=%d L=%d D=%d\n",nWin,nLose,nDraw);
	return 0;
}


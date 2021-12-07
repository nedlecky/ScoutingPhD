// Parallel Simulation for Strategy Synthesis
// J.E. (Ned) Lecky
// 8/97 - 12/97

#include "master.h"
#include "TicTacToe.h"

// TIC TAC TOE METHODS
TicTacToe::TicTacToe()
{
	for(int i=0; i<9; i++) board[i]=-1;
}
TicTacToe::~TicTacToe()
{
}
TicTacToe* TicTacToe::operator=(TicTacToe &t)
{
	memcpy(board,t.GetBoard(),9*sizeof(int));
	lastMove=t.LastMove();
	return this;
}
int TicTacToe::OpenSpace(int s)
{
	return board[s]<0;
}
char TicTacToe::PCharacter(int i)
{
	switch(board[i])
	{
		case -1: return ' ';
		case 0:  return 'O';
		case 1:  return 'X';
		default: return '?';
	}
}
void TicTacToe::Show(void)
{
	for(int row=0; row<3; row++)
	{
		char buf[32];
		buf[0]=0;
		for(int col=0; col<3; col++)
		{
			char tbuf[32];
			sprintf(tbuf,"%c%c",PCharacter(row*3+col),col<2?'|':' ');
			strcat(buf,tbuf);
		}
		printf("%s\n",buf);
		if(row<2)
			printf("------\n");
	}
	printf("\n");
}

// does player have a goal move?
int TicTacToe::TwoOfThree(int player,int i1,int i2,int i3)
{
	int p1=board[i1];
	int p2=board[i2];
	int p3=board[i3];

	if(p1==player && p2==player && p3<0) return i3;
	if(p1==player && p3==player && p2<0) return i2;
	if(p2==player && p3==player && p1<0) return i1;
	return -1;
}
// does player have a goal move?
int TicTacToe::GoalMove(int player)
{
	// across
	for(int row=0; row<3; row++)
	{
		int t1=TwoOfThree(player,row*3,row*3+1,row*3+2);
		if(t1>=0) return t1;
	}
	// down
	for(int col=0; col<3; col++)
	{
		int t2=TwoOfThree(player,col,3+col,6+col);
		if(t2>=0) return t2;
	}
	int t3=TwoOfThree(player,0,4,8);
	if(t3>=0) return t3;
	int t4=TwoOfThree(player,2,4,6);
	if(t4>=0) return t4;
	return -1;
}

int TicTacToe::RndMove(void)
{
	int emptyList[9];
	int nEmpty=0;
	for(int i=0; i<9; i++)
		if(board[i]<0)
		{
			emptyList[nEmpty++]=i;
		}
	if(nEmpty==0) return -1;
	int n=rand()%nEmpty;
	return emptyList[n];
}
void TicTacToe::Move(int player,int pos)
{
	board[pos]=player;
	lastMove=pos;
}
int TicTacToe::MakeBestMove(int player)
{
	// the win
	int move=GoalMove(player);
	int fWin=FALSE;
	if(move<0)
	{
		// the block
		move=GoalMove(player==1?0:1);
		if(move<0) move=RndMove();
	}
	else fWin=TRUE;

	Move(player,move);
	return fWin;
}


// TTTSPINNER METHODS
TTTSpinner::TTTSpinner()
{
	ClearTallies();
	SetWeights(0,50,-50,50);
	SetWeights(1,50,-50,50);
}
void TTTSpinner::SimulateFromHere(int player,TicTacToe& t0,int nIts)
{
	ClearTallies();
	simulationPlayer=player;
	for(int i=0; i<nIts; i++)
	{
		TicTacToe t;
		t=t0;
		int iPlayer=player;
		int fWin=FALSE;
		int firstMove=0;
		for(int move=0; move<9 && !fWin; move++)
		{
			fWin=t.MakeBestMove(iPlayer);
			if(move==0) firstMove=t.LastMove();
			if(fWin)
			{
				if(iPlayer==player) winTally[firstMove]++;
				else loseTally[firstMove]++;
			}
			else
				iPlayer=iPlayer==1?0:1;
		}
		if(!fWin) drawTally[firstMove]++;
	}
}
int TTTSpinner::TallySignal(int i)
{
	int signal =
		winTally[i]*winWeight[simulationPlayer] +
		loseTally[i]*loseWeight[simulationPlayer] +
		drawTally[i]*drawWeight[simulationPlayer];
	return signal;
}
void TTTSpinner::SetWeights(int player,int w,int l,int d)
{
	winWeight[player]=w;
	loseWeight[player]=l;
	drawWeight[player]=d;
}


void TTTSpinner::ClearTallies(void)
{
	memset(winTally,0,9*sizeof(int));
	memset(loseTally,0,9*sizeof(int));
	memset(drawTally,0,9*sizeof(int));
}
void TTTSpinner::ShowTallies(void)
{
	printf("    W   L   D     S\n");
	for(int i=0; i<9; i++)
		printf("%1d: %3d %3d %3d = %3d\n",i,
			winTally[i],loseTally[i],drawTally[i],TallySignal(i));
}
int TTTSpinner::MakeBestMove(int player,TicTacToe& t,int maxSimulations)
{
	// the win
	int move=t.GoalMove(player);
	int fWin=FALSE;
	if(move<0)
	{
		// the block
		move=t.GoalMove(player==1?0:1);
		if(move<0)
		{
			// simulation
			SimulateFromHere(player,t,maxSimulations);
			int bestMove=0;
			int bestT=-100000;
			for(int i=0; i<9; i++)
			{
				if(t.OpenSpace(i))
				{
					int t=TallySignal(i);
					if(t>bestT)
					{
						bestT=t;
						bestMove=i;
					}
				}
			}
			move=bestMove;
		}
	}
	else fWin=TRUE;

	t.Move(player,move);
	return fWin;
}


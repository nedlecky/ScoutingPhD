#include <stdio.h>
#include <memory.h>
#include <string.h>
#include <stdlib.h>

#define TRUE -1
#define FALSE 0


int shortestSolution;

// with blank in pos n (0-8), first el is #possible
// followed by moves
int rndMove8[][5]={
	{2,1,3,0,0},
	{3,0,2,4,0},
	{2,1,5,0,0},
	{3,0,4,6,0},
	{4,1,3,5,7},
	{3,2,4,8,0},
	{2,3,7,0,0},
	{3,4,6,8,0},
	{2,5,7,0,0}};
int rndMove15[][5]={
	{2,1,4,0,0},
	{3,0,2,5,0},
	{3,1,3,6,0},
	{2,2,7,0,0},
	{3,0,5,8,0},
	{4,1,4,6,9},
	{4,2,5,7,10},
	{3,3,6,11,0},
	{3,4,9,12,0},
	{4,5,8,10,13},
	{4,6,9,11,14},
	{3,7,10,15,0},
	{2,8,13,0,0},
	{3,9,12,14,0},
	{3,10,13,15,0},
	{2,11,14,0,0}};


class Puzzle
{
private:
	int* map;
	int size;
	int lSide;
	int blank;
	int lastMove;
public:
	Puzzle(int s);
	~Puzzle();
	int operator==(Puzzle &p1);
	Puzzle* operator=(Puzzle &p1);
	int* GetMap(void) {return map;}
	int GetBlank(void) {return blank;}
	int Size(void) {return size;}
	void MakeGoal(void);
	void Show(void);
	void MoveRandom(void);
	void MovesRandom(int n);
	void MovePosition(int pos);
	int RndState(int now);
	int RndStateExcept(int now,int except);
};

class TicTacToe
{
private:
	int board[9];
	int lastMove;
public:
	TicTacToe();
	~TicTacToe();
	TicTacToe* operator=(TicTacToe &t);
	int OpenSpace(int s);
	int* GetBoard(void) {return board;}
	void Show(void);
	char PCharacter(int i);
	int TwoOfThree(int player,int i1,int i2,int i3);
	int GoalMove(int player);
	int RndMove(void);
	void Move(int player,int pos);
	int LastMove(void) {return lastMove;}
	int MakeBestMove(int player);
};

class Vortex
{
private:
	int **states;
	int nRings;
	int nCircum;
	int totalConsidered;

public:
	Vortex(int nrings,int circum);
	~Vortex();
	void Clear(void);
	void Show(void);
	void SetInput(int input);
	void NextStates(Puzzle& p);
	int GoalCheck(Puzzle& pIn,Puzzle& goalPuzzle);
	void Whirl(int nIts,Puzzle& p, Puzzle& goalPuzzle);
};

class Spinner
{
private:
	int state;
	int totalConsidered;
public:
	Spinner()  {state=0;}
	~Spinner() {};
	void SetInput(int input) {state=input;}
	void Whirl(int nIts,Puzzle& p, Puzzle& goalPuzzle);
};

class TTTSpinner
{
private:
	int winTally[9];
	int loseTally[9];
	int drawTally[9];
	int winWeight[2];
	int loseWeight[2];
	int drawWeight[2];
	int simulationPlayer;
public:
	TTTSpinner();
	~TTTSpinner() {};
	void SimulateFromHere(int player,TicTacToe& t,int nIts);
	int TallySignal(int i);
	int MakeBestMove(int player,TicTacToe& t,int maxSimulations);
	void ClearTallies(void);
	void ShowTallies(void);
	void SetWeights(int player,int w,int l,int d);
};

class Spinner2
{
private:
	int state[2];
	int totalConsidered;
public:
	Spinner2()  {};
	~Spinner2() {};
	void SetInput(int input) {state[0]=input;}
	void Whirl(int nIts,Puzzle& p, Puzzle& goalPuzzle);
};

// PUZZLE METHODS
Puzzle::Puzzle(int s)
{
	if(s<15)
	{
		s=9;
		lSide=3;
	}
	else
	{
		s=16;
		lSide=4;
	}
	size=s;
	map=new int[size];
	MakeGoal();
	lastMove=-1;
}
Puzzle::~Puzzle()
{
	delete map;
}
int Puzzle::operator==(Puzzle &p1)
{
	if(0==memcmp(map,p1.GetMap(),size*sizeof(int)))
		return -1;
	else
		return 0;
}
Puzzle* Puzzle::operator=(Puzzle &p1)
{
	memcpy(map,p1.GetMap(),size*sizeof(int));
	blank=p1.GetBlank();
	return this;
}

void Puzzle::MakeGoal(void)
{
	if(size==9)
	{
		map[0]=1;
		map[1]=2;
		map[2]=3;
		map[3]=8;
		map[4]=0;
		map[5]=4;
		map[6]=7;
		map[7]=6;
		map[8]=5;
		blank=4;
	}
	if(size==16)
	{
		for(int i=0; i<size; i++) map[i]=i;
		blank=0;
	}
}
void Puzzle::Show(void)
{
	for(int row=0; row<lSide; row++)
	{
		char buf[64];
		for(int col=0; col<lSide; col++)
			sprintf(buf+col*3,"%2d ",map[row*lSide+col]);
		if(row==0) putchar('p');
		else putchar(' ');
		printf("%s\n",buf);
	}
}
int Puzzle::RndState(int now)
{
	if(size==9)
	{
		int n=rndMove8[now][0];
		return rndMove8[now][rand()%n+1];
	}
	else
	{
		int n=rndMove15[now][0];
		return rndMove15[now][rand()%n+1];
	}
}
int Puzzle::RndStateExcept(int now,int except)
{
	int move=except;
	while(move==except)
	{
		if(size==9)
		{
			int n=rndMove8[now][0];
			move=rndMove8[now][rand()%n+1];
		}
		else
		{
			int n=rndMove15[now][0];
			move=rndMove15[now][rand()%n+1];
		}
	}
	return move;
}
void Puzzle::MovePosition(int pos)
{
	lastMove=blank;
	map[blank]=map[pos];
	blank=pos;
	map[blank]=0;
}
void Puzzle::MoveRandom(void)
{
	MovePosition(RndStateExcept(blank,lastMove));
}
void Puzzle::MovesRandom(int n)
{
	for(int i=0; i<n; i++) MoveRandom();
}

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

// VORTEX METHODS
Vortex::Vortex(int rings,int circum)
{
	nRings=rings;
	nCircum=circum;
	states=new int*[nRings];
	for(int i=0; i<nRings; i++)
		states[i]=new int[nCircum];
	Clear();
}
Vortex::~Vortex()
{
	for(int i=0; i<nRings; i++)
		delete states[i];
	delete states;
}

void Vortex::Clear(void)
{
	for(int i=0; i<nRings; i++)
		memset(states[i],0,nCircum*sizeof(int));
}

void Vortex::Show(void)
{
	for(int i=nRings-1; i>=0; i--)
	{
		char buf[128];
		buf[0]=0;
		for(int j=0; j<nCircum; j++)
		{
			char tbuf [20];
			sprintf(tbuf,"%1d",states[i][j]);
			strcat(buf,tbuf);
		}
		printf("%02d: %s\n",i,buf);
	}
}

void Vortex::SetInput(int input)
{
	for(int i=0; i<nCircum; i++)
		states[0][i]=input;
}
void Vortex::NextStates(Puzzle& p)
{
	for(int j=1; j<nRings; j++)
		for(int i=0; i<nCircum; i++)
			if(j>1)
				states[j][i]=p.RndStateExcept(states[j-1][i],states[j-2][i]);
			else
				states[j][i]=p.RndState(states[j-1][i]);
}
int Vortex::GoalCheck(Puzzle& pIn,Puzzle& goalPuzzle)
{
	for(int i=0; i<nCircum; i++)
	{
		Puzzle p(pIn.Size());
		p=pIn;
		for(int step=1; step<nRings; step++)
		{
			p.MovePosition(states[step][i]);
			totalConsidered++;
			if(p==goalPuzzle)
			{
				printf("Goal Reached col %d, %d steps.\n",i,step);
				if(step<shortestSolution) shortestSolution=step;
				//Puzzle pDisp=pIn;
				//pDisp.Show();
				//for(int s=1; s<=step; s++)
				//{
				//	pDisp.MovePosition(states[s][i]);
				//	pDisp.Show();
				//}
				return 1;
			}
		}
	}
	return 0;
}
void Vortex::Whirl(int nIts,Puzzle& p, Puzzle& goalPuzzle)
{
	totalConsidered=0;
	for(int i=0; i<nIts; i++)
	{
		if(GoalCheck(p,goalPuzzle))
		{
			printf("Solved in %d iterations! (considered %d)\n",
				i,totalConsidered);
			return;
		}
		NextStates(p);
	}
	printf("No solution in %d iterations! (considered %d)\n",
		i,totalConsidered);
}

// SPINNER METHODS
void Spinner::Whirl(int nIts,Puzzle& p0, Puzzle& goalPuzzle)
{
	totalConsidered=0;
	Puzzle p(p0.Size());
	p=p0;
	for(int i=0; i<nIts; i++)
	{
		if(p==goalPuzzle)
		{
			printf("Solved in %d iterations! (considered %d)\n",
				i,totalConsidered);
			if(i<shortestSolution) shortestSolution=i;
			return;
		}
		totalConsidered++;
		state=p.RndState(state);
		p.MovePosition(state);
	}
	//printf("No solution in %d iterations! (considered %d)\n",
	//	i,totalConsidered);
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
void Spinner2::Whirl(int nIts,Puzzle& p0, Puzzle& goalPuzzle)
{
	totalConsidered=0;
	Puzzle p(p0.Size());
	p=p0;
	int nextState=0;
	for(int i=0; i<nIts; i++)
	{
		if(p==goalPuzzle)
		{
			printf("Solved in %d iterations! (considered %d)\n",
				i,totalConsidered);
			if(i<shortestSolution) shortestSolution=i;
			return;
		}
		totalConsidered++;
		int lastState=nextState;
		nextState^=1;
		if(i==0)
			state[nextState]=p.RndState(state[lastState]);
		else
			state[nextState]=p.RndStateExcept(
				state[lastState],state[nextState]);
		p.MovePosition(state[nextState]);
	}
	//printf("No solution in %d iterations! (considered %d)\n",
	//	i,totalConsidered);
}

int main()
{
	/*
	Puzzle goalPuzzle(8);

	Puzzle p(8);
	p.MovesRandom(20000);
	p.Show();

	
	shortestSolution=120;
	printf("Vortex:\n");
	for(int i=0; i<4; i++)
	{
		Vortex* vp=new Vortex(shortestSolution,1);
		vp->SetInput(p.GetBlank());
		vp->Whirl(50000,p,goalPuzzle);
	}
	

	shortestSolution=120;
	printf("Spinner:\n");
	for(i=0; i<100000; i++)
	{
		Spinner* sp=new Spinner();
		sp->SetInput(p.GetBlank());
		sp->Whirl(shortestSolution,p,goalPuzzle);
	}

	
	shortestSolution=180;
	printf("Spinner2:\n");
	for(int i=0; i<1000000; i++)
	{
		Spinner2* sp2=new Spinner2();
		sp2->SetInput(p.GetBlank());
		sp2->Whirl(shortestSolution,p,goalPuzzle);
	}
	*/

	srand(123);

	int wins[2];
	wins[0]=0;
	wins[1]=0;
	int total=50;

	for(int g=0; g<total; g++)
	{
		TicTacToe t;
		int player=1;
		int fWin=FALSE;
		for(int move=0; move<9 && !fWin; move++)
		{
			TTTSpinner s;
			s.SetWeights(0,1,-1,1);
			s.SetWeights(1,1,-1,1);
			fWin=s.MakeBestMove(player,t,1000);
			//if(g<1) s.ShowTallies();
			if(fWin) wins[player]++;
			if(0)//g<10)
			{
				t.Show();
				getchar();
			}
			player=player==1?0:1;
		}
	}
	printf("X wins %d, O wins %d, Draws %d\n",wins[1],wins[0],
		total-wins[0]-wins[1]);

	/*
	int wins[2];
	wins[0]=0;
	wins[1]=0;
	for(int g=0; g<100; g++)
	{
		printf("G=%d\n",g);
		TicTacToe t;
		//t.Show();
		int player=1;
		int fDone=FALSE;
		for(int i=0; i<9 && !fDone; i++)
		{
			int fWin=t.MakeBestMove(player);
			if(fWin)
			{
				wins[player]++;
				t.Show();
			}
			if(player==0) player=1;
			else player=0;
		}
	}
	printf("X wins %d, O wins %d\n",wins[1],wins[0]);
	*/

	return 0;
}



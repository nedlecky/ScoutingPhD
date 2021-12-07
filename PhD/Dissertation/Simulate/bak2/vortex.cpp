#include <stdio.h>
#include <memory.h>
#include <string.h>
#include <stdlib.h>


int shortestSolution;

// with blank in pos n (0-8), first el is #possible
// followed by moves
int rndMove[][9]={
	{2,1,3,0,0},
	{3,0,2,4,0},
	{2,1,5,0,0},
	{3,0,4,6,0},
	{4,1,3,5,7},
	{3,2,4,8,0},
	{2,3,7,0,0},
	{3,4,6,8,0},
	{2,5,7,0,0}};
// [i][j] i=where blank IS  j=where you're considering putting it
int nextMove[][9]={
	{1,3,1,1,1,1,1,1,1},
	{2,0,4,0,0,0,0,0,0},
	{1,5,1,1,1,1,1,1,1},
	{4,0,0,0,6,0,0,0,0},
	{1,3,1,5,1,7,1,1,1},
	{2,2,4,2,8,2,2,2,2},
	{3,3,3,7,3,3,3,3,3},
	{4,4,4,4,6,4,8,4,4},
	{5,5,5,5,5,7,5,5,5}};


enum eMoveDir{Up,Down,Left,Right};
class Puzzle
{
private:
	int map[9];
	int blank;
	int lastMove;
public:
	Puzzle();
	~Puzzle();
	int operator==(Puzzle &p1);
	Puzzle* operator=(Puzzle &p1);
	int* GetMap(void) {return map;}
	int GetBlank(void) {return blank;}
	void MakeGoal(void);
	void Show(void);
	void MoveDirection(eMoveDir dir);
	void MoveRandom(void);
	void MovesRandom(int n);
	void MovePosition(int pos);
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
	void NextStates(void);
	int NextState(int now,int consider);
	int RndState(int now);
	int RndStateExcept(int now,int except);
	int GoalCheck(Puzzle& pIn,Puzzle& goalPuzzle);
	void Whirl(int nIts,Puzzle& p, Puzzle& goalPuzzle);
};

// PUZZLE METHODS
Puzzle::Puzzle()
{
	MakeGoal();
	lastMove=-1;
}
Puzzle::~Puzzle()
{
}
int Puzzle::operator==(Puzzle &p1)
{
	if(0==memcmp(map,p1.GetMap(),9*sizeof(int)))
		return -1;
	else
		return 0;
}
Puzzle* Puzzle::operator=(Puzzle &p1)
{
	memcpy(map,p1.GetMap(),9*sizeof(int));
	blank=p1.GetBlank();
	return this;
}

void Puzzle::MakeGoal(void)
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
void Puzzle::Show(void)
{
	for(int row=0; row<3; row++)
	{
		char buf[4];
		for(int col=0; col<3; col++)
			sprintf(buf+col,"%1d",map[row*3+col]);
		if(row==0) putchar('p');
		else putchar(' ');
		printf("%s\n",buf);
	}
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
	int move=lastMove;
	while(move==lastMove)
	{
		int nMove=rand()%rndMove[blank][0];
		move=rndMove[blank][nMove+1];
	}
	MovePosition(move);
}
void Puzzle::MovesRandom(int n)
{
	for(int i=0; i<n; i++) MoveRandom();
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
void Vortex::NextStates(void)
{
	for(int j=1; j<nRings; j++)
	{
//		for(int i=1; i<ringSize; i++)
//			vortex[j][i]=NextState(vortex[j-1][i],vortex[j][i-1]);
//		vortex[j][0]=NextState(vortex[j-1][0],vortex[j][ringSize-1]);

//		for(int i=0; i<nCircum; i++)
//			states[j][i]=RndState(states[j-1][i]);
		
		for(int i=0; i<nCircum; i++)
			if(j>1)
				states[j][i]=RndStateExcept(states[j-1][i],states[j-2][i]);
			else
				states[j][i]=RndState(states[j-1][i]);
	}
}
int Vortex::NextState(int now,int consider)
{
	int next=nextMove[now][consider];
//	printf("ns now=%d cons=%d give=%d\n",now,consider,next);
	return next;
}
int Vortex::RndState(int now)
{
	int n=rndMove[now][0];
	return rndMove[now][rand()%n+1];
}
int Vortex::RndStateExcept(int now,int except)
{
	int move=except;
	while(move==except)
	{
		int n=rndMove[now][0];
		move=rndMove[now][rand()%n+1];
	}
	return move;
}
int Vortex::GoalCheck(Puzzle& pIn,Puzzle& goalPuzzle)
{
	for(int i=0; i<nCircum; i++)
	{
		Puzzle p=pIn;
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
		NextStates();
	}
	printf("No solution in %d iterations! (considered %d)\n",
		i,totalConsidered);
}

int main()
{
	Puzzle goalPuzzle;

	Puzzle p;
	p.MovesRandom(71399);
	p.Show();

	shortestSolution=40;
	for(int i=0; i<7; i++)
	{
		Vortex* vp=new Vortex(shortestSolution,1);
		vp->SetInput(p.GetBlank());
		vp->Whirl(50000,p,goalPuzzle);
	}

	return 0;
}



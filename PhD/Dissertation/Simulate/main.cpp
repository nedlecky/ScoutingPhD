// Parallel Simulation for Strategy Synthesis
// J.E. (Ned) Lecky
// 8/97 - 12/97

#include <conio.h>

#include "Master.h"
#include "Puzzle.h"
#include "Spinner.h"
#include "Spinner2.h"
#include "Vortex.h"
#include "TicTacToe.h"
#include "NPuzzle.h"

const int puzzleSize=15;


int shortestSolution;
int WLD[][3]={
	{1,-1,1},
	{1,-1,1}};

void NumIn(char* prompt,int* n)
{
	printf("%s: [%d]? ",prompt,*n);
	char buf[128];
	char* p=buf;
	char c;
	while((c=_getche())!='\r')
		*p++=c;
	putchar('\n');
	*p=0;
	sscanf(buf,"%d",n);
}

void ShowWLDs(int n=2)
{
	n++;

	printf("   Win Lose Draw\n");
	if(n&2) printf("X: %3d %3d %3d\n",WLD[1][0],WLD[1][1],WLD[1][2]);
	if(n&1) printf("O: %3d %3d %3d\n",WLD[0][0],WLD[0][1],WLD[0][2]);
}


void SetWLDs(void)
{
	printf("Player X:\n");
	NumIn(" Win",WLD[1]+0);
	NumIn(" Lose",WLD[1]+1);
	NumIn(" Draw",WLD[1]+2);
	printf("Player O:\n");
	NumIn(" Win",WLD[0]+0);
	NumIn(" Lose",WLD[0]+1);
	NumIn(" Draw",WLD[0]+2);
	ShowWLDs();
}

void DoVortex(NPuzzle& p)
{
	NPuzzle goalPuzzle(puzzleSize);

	shortestSolution=120;

	printf("Vortex:\n");
	Vortex* vp=new Vortex(shortestSolution,1);
	for(int i=0; i<4; i++)
	{
		vp->SetInput(p.GetBlank());
		vp->Whirl(50000,shortestSolution,p,goalPuzzle);
	}
	delete vp;
}

void DoSpinner(NPuzzle& p)
{
	NPuzzle goalPuzzle(puzzleSize);

	shortestSolution=120;
	printf("Spinner:\n");
	Spinner* sp=new Spinner();
	for(int i=0; i<100000; i++)
	{
		sp->SetInput(p.GetBlank());
		if(sp->Whirl(shortestSolution,p,goalPuzzle))
		{
			printf("Solved by spinner #%d.\n",i);
			i=0;
		}
	}
	delete sp;
}

void DoSpinner2(NPuzzle& p)
{
	NPuzzle goalPuzzle(puzzleSize);

	shortestSolution=100;

	printf("Spinner2 Initial Depth %d:\n",shortestSolution);
	Spinner2* sp2=new Spinner2();
	for(int i=0; i<1000000; i++)
	{
		sp2->SetInput(p.GetBlank());
		if(sp2->Whirl(shortestSolution,p,goalPuzzle))
		{
			printf("Solved by spinner #%d.\n",i);
			i=0;
		}
	}
	delete sp2;
}

void DoTicTacToe(void)
{
	printf("TicTacToe Simulation:\n");
	ShowWLDs();
	int wins[2];
	wins[0]=0;
	wins[1]=0;
	int total=50;
	int lookAhead=1000;
	NumIn("Look ahead how many paths",&lookAhead);
	NumIn("Play how many games",&total);

	TTTSpinner s;
	s.SetWeights(0,WLD[0][0],WLD[0][1],WLD[0][2]);
	s.SetWeights(1,WLD[1][0],WLD[1][1],WLD[1][2]);

	for(int g=0; g<total; g++)
	{
		TicTacToe t;
		int player=1;
		int fWin=FALSE;
		for(int move=0; move<9 && !fWin; move++)
		{
			fWin=s.MakeBestMove(player,t,lookAhead);
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
	printf("RESULTS:\nX wins %d, O wins %d, Draws %d\n",wins[1],wins[0],
		total-wins[0]-wins[1]);
}

void PlayTicTacToe(void)
{
	printf("TicTacToe Playing:\n");

	int hplayer=-1;
	while(hplayer==-1)
	{
		printf("You are X (moves first) or O (moves second)? ");
		char c=getche();
		printf("\n");
		if(c=='x') hplayer=1;
		if(c=='o') hplayer=0;
	}

	ShowWLDs(hplayer==0?1:0);

	int lookAhead=1000;
	NumIn("Look ahead how many paths",&lookAhead);

	TTTSpinner s;
	s.SetWeights(0,WLD[0][0],WLD[0][1],WLD[0][2]);
	s.SetWeights(1,WLD[1][0],WLD[1][1],WLD[1][2]);

redo:
	TicTacToe t;
	int player=0;
	int fWin=FALSE;
	t.Show();
	for(int move=0; move<9 && !fWin; move++)
	{
		player=player==1?0:1;
		if(player==hplayer)
		{
			int pos=-1;
			int goalMove=t.GoalMove(player);
			while(pos==-1)
			{
				NumIn("YOUR MOVE",&pos);
				if(pos<0) pos=-1;
				if(pos>8) pos=-1;
				if(pos>=0 && !t.OpenSpace(pos)) pos=-1;
			}
			t.Move(player,pos);
			fWin=pos==goalMove;
		}
		else
			fWin=s.MakeBestMove(player,t,lookAhead);
		t.Show();
	}

	if(fWin)
		printf("YOU %s\n",player==hplayer?"WIN":"LOSE");
	else
		printf("DRAW\n");

	printf("Play Again? (y/n)");
	char c=getch();
	printf("\n");
	if(c=='y') goto redo;
}

NPuzzle* NewPuzzle(int nMoves)
{
	NPuzzle* p=new NPuzzle(puzzleSize);
	p->MovesRandom(nMoves);
	return p;
}
NPuzzle* DoNewPuzzle(void)
{
	int n=50;
	NumIn("How many randomizations",&n);
	NPuzzle* p=NewPuzzle(n);
	p->Show();
	return p;
}


int main()
{
	srand(1);
	NPuzzle* p=NewPuzzle(1000001);
	p->Show();

	int fDone=FALSE;
	int fPuzzles=TRUE;
	while(!fDone)
	{
		if(fPuzzles)
		{
			printf("\nPUZZLES:  (g) goes to games; (x) exits program\n");
			printf("(N)ew puzzle;  Show (P)uzzle\n");
			printf("(V)ortex; (S)pinner1; Spinner(2) ?");
			char c=_getch();
			printf("\n");
			switch(c)
			{
			case 'n': p=DoNewPuzzle(); break;
			case 'p': p->Show(); break;
			case 'v': DoVortex(*p); break;
			case 's': DoSpinner(*p); break;
			case '2': DoSpinner2(*p); break;
			case 'g': fPuzzles=FALSE; break;
			case 'x': fDone=TRUE; break;
			default: printf("Invalid Input.\n");
			}
		}
		else
		{
			printf("\nGAMES:  (p) goes to puzzles; (x) exits program\n");
			printf("(S)et WLDs; Show (W)LDs\n");
			printf("(T)TT simulation; (I)nteractive play ?");
			char c=_getch();
			printf("\n");
			switch(c)
			{
			case 't': DoTicTacToe(); break;
			case 'i': PlayTicTacToe(); break;
			case 's': SetWLDs(); break;
			case 'w': ShowWLDs(); break;
			case'p': fPuzzles=TRUE; break;
			case 'x': fDone=TRUE; break;
			default: printf("Invalid Input.\n");
			}
		}
	}

	return 0;
}



// Parallel Simulation for Strategy Synthesis
// J.E. (Ned) Lecky
// 8/97 - 12/97

#include "master.h"
#include "vortex.h"

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
				states[j][i]=p.RndStateExcept(states[j-1][i],-1);
}
int Vortex::GoalCheck(Puzzle& pIn,Puzzle& goalPuzzle)
{
	for(int i=0; i<nCircum; i++)
	{
		Puzzle* p=pIn.Clone();
		for(int step=1; step<nRings; step++)
		{
			p->MovePosition(states[step][i]);
			totalConsidered++;
			if(*p==goalPuzzle)
			{
				printf("Goal Reached col %d, %d steps.\n",i,step);
				if(step<shortestSolution) shortestSolution=step;
				//Puzzle* pDisp=pIn.Clone();
				//pDisp->Show();
				//for(int s=1; s<=step; s++)
				//{
				//	pDisp->MovePosition(states[s][i]);
				//	pDisp->Show();
				//	getchar();
				//}
				return 1;
			}
		}
	}
	return 0;
}
void Vortex::Whirl(int nIts,int maxDepth,Puzzle& p, Puzzle& goalPuzzle)
{
	totalConsidered=0;
	nRings=maxDepth;
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

// Parallel Simulation for Strategy Synthesis
// J.E. (Ned) Lecky
// 8/97 - 12/97

#include "Master.h"
#include "Spinner2.h"

int Spinner2::Whirl(int nIts,Puzzle& p0, Puzzle& goalPuzzle)
{
	totalConsidered=0;
	Puzzle* p=p0.Clone();
	int nextState=0;
	state[1]=p0.CurrentState();
	for(int i=0; i<nIts; i++)
	{
		if(*p==goalPuzzle)
		{
			printf("Solved in %d iterations! (considered %d)\n",
				i,totalConsidered);
			if(i<shortestSolution) shortestSolution=i;
			delete p;
			return TRUE;
		}
		totalConsidered++;
		int lastState=nextState;
		nextState^=1;
		state[nextState]=p->RndStateExcept(
				state[lastState],state[nextState]);
		p->MovePosition(state[nextState]);
	}
	//printf("No solution in %d iterations! (considered %d)\n",
	//	i,totalConsidered);
	delete p;
	return FALSE;
}

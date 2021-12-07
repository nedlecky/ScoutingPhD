// Parallel Simulation for Strategy Synthesis
// J.E. (Ned) Lecky
// 8/97 - 12/97

#include "Master.h"
#include "Spinner.h"

// SPINNER METHODS
int Spinner::Whirl(int nIts,Puzzle& p0, Puzzle& goalPuzzle)
{
	totalConsidered=0;
	Puzzle* p=p0.Clone();
	for(int i=0; i<nIts; i++)
	{
		if(*p==goalPuzzle)
		{
			printf("Solved in %d iterations! (considered %d)\n",
				i,totalConsidered);
			if(i<shortestSolution) shortestSolution=i;
			return TRUE;
		}
		totalConsidered++;
		state=p->RndStateExcept(state,-1);
		p->MovePosition(state);
	}
	//printf("No solution in %d iterations! (considered %d)\n",
	//	i,totalConsidered);
	return FALSE;
}

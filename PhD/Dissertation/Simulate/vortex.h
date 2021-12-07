// Parallel Simulation for Strategy Synthesis
// J.E. (Ned) Lecky
// 8/97 - 12/97

#if !defined(vortex_h)
#define vortex_h

#include "Puzzle.h"

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
	void Whirl(int nIts,int maxDepth,Puzzle& p, Puzzle& goalPuzzle);
};

#endif
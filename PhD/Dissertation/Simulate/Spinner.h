// Parallel Simulation for Strategy Synthesis
// J.E. (Ned) Lecky
// 8/97 - 12/97

#if !defined(spinner_h)
#define spinner_h

#include "Puzzle.h"

class Spinner
{
private:
	int state;
	int totalConsidered;
public:
	Spinner()  {state=0;}
	~Spinner() {};
	void SetInput(int input) {state=input;}
	int Whirl(int nIts,Puzzle& p, Puzzle& goalPuzzle);
};

#endif



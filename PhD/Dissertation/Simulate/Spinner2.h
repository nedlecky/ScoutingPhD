// Parallel Simulation for Strategy Synthesis
// J.E. (Ned) Lecky
// 8/97 - 12/97

#if !defined(spinner2_h)
#define spinner2_h

#include "Puzzle.h"

class Spinner2
{
private:
	int state[2];
	int totalConsidered;
public:
	Spinner2()  {};
	~Spinner2() {};
	void SetInput(int input) {state[0]=input;}
	int Whirl(int nIts,Puzzle& p, Puzzle& goalPuzzle);
};

#endif

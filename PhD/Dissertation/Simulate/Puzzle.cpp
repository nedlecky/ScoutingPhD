// Parallel Simulation for Strategy Synthesis
// J.E. (Ned) Lecky
// 8/97 - 12/97

#include "master.h"
#include "Puzzle.h"

int Puzzle::operator==(Puzzle &p1)
{
	return Compare(this,&p1);
}
Puzzle* Puzzle::operator=(Puzzle &p1)
{
	Assign(this,&p1);
	return this;
}

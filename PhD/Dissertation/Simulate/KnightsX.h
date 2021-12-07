#if !defined(KnightsX_h)
#define KnightsX_h

#include "Puzzle.h"

class KnightsCrossing : public Puzzle
{
private:
	int* map;
	int lastMove;
public:
	KnightsCrossing();
	~NPuzzle();
	Puzzle* Clone(void);
	int Compare(Puzzle* p1,Puzzle* p2);
	Puzzle* Assign(Puzzle* p1,Puzzle* p2);
	int* GetMap(void) {return map;}
	void MakeGoal(void);
	void Show(void);
	void MovePosition(int pos);
	int RndStateExcept(int now,int except);
};

#endif
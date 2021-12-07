// Parallel Simulation for Strategy Synthesis
// J.E. (Ned) Lecky
// 8/97 - 12/97

#if !defined(NPuzzle_h)
#define NPuzzle_h

#include "Puzzle.h"

class NPuzzle : public Puzzle
{
private:
	int* map;
	int size;
	int lSide;
	int blank;
	int lastMove;
public:
	NPuzzle(int s=9);
	~NPuzzle();
	Puzzle* Clone(void);
	void SetSize(int s);
	int Compare(Puzzle* p1,Puzzle* p2);
	Puzzle* Assign(Puzzle* p1,Puzzle* p2);
	int* GetMap(void) {return map;}
	int GetBlank(void) {return blank;}
	void SetBlank(int b) {blank=b;}
	int Size(void) {return size;}
	void MakeGoal(void);
	void Show(void);
	void MoveRandom(void);
	void MovesRandom(int n);
	void MovePosition(int pos);
	int RndStateExcept(int now,int except);
	int CurrentState(void) {return blank;}
};

#endif
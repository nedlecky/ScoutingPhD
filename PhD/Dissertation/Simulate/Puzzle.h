// Parallel Simulation for Strategy Synthesis
// J.E. (Ned) Lecky
// 8/97 - 12/97

#if !defined(Puzzle_h)
#define Puzzle_h

class Puzzle
{
private:
public:
	Puzzle() {};
	~Puzzle() {};
	int operator==(Puzzle &p1);
	Puzzle* operator=(Puzzle &p1);
	virtual Puzzle* Clone(void)=0;
	virtual int Compare(Puzzle* p1,Puzzle* p2)=0;
	virtual Puzzle* Assign(Puzzle* p1,Puzzle* p2)=0;
	virtual void MakeGoal(void)=0;
	virtual void Show(void)=0;
	virtual void MoveRandom(void)=0;
	virtual void MovesRandom(int n)=0;
	virtual void MovePosition(int pos)=0;
	virtual int RndStateExcept(int now,int except)=0;
	virtual int CurrentState(void)=0;
};

#endif
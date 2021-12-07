#if !defined(CORE_H)
#define CORE_H

class Square
{
private:
	int cur;
	int lastFrom;
	int goal;
	int index;
	Square* udlr[4];
public:
	Square(int i);
	~Square();
	int Cur(void) {return cur;}
	void SetCur(int i,int f) {cur=i; lastFrom=f;}
	int Goal(void) {return goal;}
	void SetGoal(int i) {goal=i;}
	int Index(void) {return index;}
	void SetNeighbors(Square* u,Square* d,Square* l,Square* r);
	int Move(void);
};

class Game3x3
{
private:
	Square* square[9];
	int empty;
public:
	Game3x3();
	~Game3x3();
	void SetGoal(int* x);
	void SetState(int* x);
	void UnloadState(int* x);
	int Hash(void);
	void ShowState(void);
	void ShowState(FILE* fp);
	void Move(void);
	int IsGoal(void);
};


#endif
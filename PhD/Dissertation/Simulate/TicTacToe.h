// Parallel Simulation for Strategy Synthesis
// J.E. (Ned) Lecky
// 8/97 - 12/97

#if !defined(ttt_h)
#define ttt_h

class TicTacToe
{
private:
	int board[9];
	int lastMove;
public:
	TicTacToe();
	~TicTacToe();
	TicTacToe* operator=(TicTacToe &t);
	int OpenSpace(int s);
	int* GetBoard(void) {return board;}
	void Show(void);
	char PCharacter(int i);
	int TwoOfThree(int player,int i1,int i2,int i3);
	int GoalMove(int player);
	int RndMove(void);
	void Move(int player,int pos);
	int LastMove(void) {return lastMove;}
	int MakeBestMove(int player);
};

class TTTSpinner
{
private:
	int winTally[9];
	int loseTally[9];
	int drawTally[9];
	int winWeight[2];
	int loseWeight[2];
	int drawWeight[2];
	int simulationPlayer;
public:
	TTTSpinner();
	~TTTSpinner() {};
	void SimulateFromHere(int player,TicTacToe& t,int nIts);
	int TallySignal(int i);
	int MakeBestMove(int player,TicTacToe& t,int maxSimulations);
	void ClearTallies(void);
	void ShowTallies(void);
	void SetWeights(int player,int w,int l,int d);
};

#endif
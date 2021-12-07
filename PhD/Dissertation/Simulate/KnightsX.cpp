#include "master.h"
#include "KnightsX.h"

int rndKMove[][2]={
	{5,7},
	{6,8},
	{3,7},
	{2,8},
	{0,0},
	{0,6},
	{1,5},
	{0,2},
	{1,3}};

// KNIGHTSCROSSING METHODS
KnightsCrossing::KnightsCrossing(int s)
{
	map=new int[9];

	// classic initial setup
	memset(map,0,9*sizeof(int);
	map[0]=2;
	map[6]=2;
	map[2]=1;
	map[8]=1;

	lastMove=0;
}
KnightsCrossing::~KnightsCrossing()
{
	delete map;
}
Puzzle* KnightsCrossing::Clone(void)
{
	KnightsCrossing* np=new KnightsCrossing();
	Assign(np,this);
	return np;
}
int KnightsCrossing::Compare(Puzzle* p1,Puzzle* p2)
{
	KnightsCrossing* np1=(KnightsCrossing*)p1;
	KnightsCrossing* np2=(KnightsCrossing*)p2;

	if(0==memcmp(np1->GetMap(),np2->GetMap(),np1->Size()*sizeof(int)))
		return TRUE;
	else
		return FALSE;
}
Puzzle* KnightsCrossing::Assign(Puzzle* p1,Puzzle* p2)
{
	KnightsCrossing* np1=(KnightsCrossing*)p1;
	KnightsCrossing* np2=(KnightsCrossing*)p2;
	memcpy(np1->GetMap(),np2->GetMap(),np1->Size()*sizeof(int));
	return np1;
}

void KnightsCrossing::MakeGoal(void)
{
	memset(map,0,9*sizeof(int);
	map[0]=1;
	map[6]=1;
	map[2]=2;
	map[8]=2;
}
void KnightsCrossing::Show(void)
{
	for(int row=0; row<lSide; row++)
	{
		char buf[64];
		for(int col=0; col<lSide; col++)
			sprintf(buf+col*3,"%2d ",map[row*lSide+col]);
		if(row==0) putchar('k');
		else putchar(' ');
		printf("%s\n",buf);
	}
}
int KnightsCrossing::RndStateExcept(int now,int except)
{
	int move=except;
	while(move==except)
		move=rndKMove[now][rand()%2];
	return move;
}
void KnightsCrossing::MovePosition(int pos)
{
	lastMove=blank;
	map[blank]=map[pos];
	blank=pos;
	map[blank]=0;
}
void KnightsCrossing::MoveRandom(void)
{
	MovePosition(RndStateExcept(blank,lastMove));
}
void KnightsCrossing::MovesRandom(int n)
{
	for(int i=0; i<n; i++) MoveRandom();
}

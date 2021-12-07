// Parallel Simulation for Strategy Synthesis
// J.E. (Ned) Lecky
// 8/97 - 12/97

#include "master.h"
#include "NPuzzle.h"

// with blank in pos n (0-8), first el is #possible
// followed by moves
int rndMove8[][5]={
	{2,1,3,0,0},
	{3,0,2,4,0},
	{2,1,5,0,0},
	{3,0,4,6,0},
	{4,1,3,5,7},
	{3,2,4,8,0},
	{2,3,7,0,0},
	{3,4,6,8,0},
	{2,5,7,0,0}};
int rndMove15[][5]={
	{2,1,4,0,0},
	{3,0,2,5,0},
	{3,1,3,6,0},
	{2,2,7,0,0},
	{3,0,5,8,0},
	{4,1,4,6,9},
	{4,2,5,7,10},
	{3,3,6,11,0},
	{3,4,9,12,0},
	{4,5,8,10,13},
	{4,6,9,11,14},
	{3,7,10,15,0},
	{2,8,13,0,0},
	{3,9,12,14,0},
	{3,10,13,15,0},
	{2,11,14,0,0}};

// NPUZZLE METHODS
NPuzzle::NPuzzle(int s)
{
	size=0;
	map=NULL;
	SetSize(s);
	MakeGoal();
	lastMove=0;
}
NPuzzle::~NPuzzle()
{
	delete map;
}
Puzzle* NPuzzle::Clone(void)
{
	NPuzzle* np=new NPuzzle();
	Assign(np,this);
	return np;
}
void NPuzzle::SetSize(int s)
{
	if(size==s) return;

	if(s<15)
	{
		s=9;
		lSide=3;
	}
	else
	{
		s=16;
		lSide=4;
	}
	size=s;
	if(map!=NULL) delete map;
	map=new int[size];
}
int NPuzzle::Compare(Puzzle* p1,Puzzle* p2)
{
	NPuzzle* np1=(NPuzzle*)p1;
	NPuzzle* np2=(NPuzzle*)p2;
	if(np1->Size()!=np2->Size()) return FALSE;

	if(0==memcmp(np1->GetMap(),np2->GetMap(),np1->Size()*sizeof(int)))
		return TRUE;
	else
		return FALSE;
}
Puzzle* NPuzzle::Assign(Puzzle* p1,Puzzle* p2)
{
	NPuzzle* np1=(NPuzzle*)p1;
	NPuzzle* np2=(NPuzzle*)p2;
	np1->SetSize(np2->Size());
	memcpy(np1->GetMap(),np2->GetMap(),np1->Size()*sizeof(int));
	np1->SetBlank(np2->GetBlank());
	return np1;
}

void NPuzzle::MakeGoal(void)
{
	if(size==9)
	{
		map[0]=1;
		map[1]=2;
		map[2]=3;
		map[3]=8;
		map[4]=0;
		map[5]=4;
		map[6]=7;
		map[7]=6;
		map[8]=5;
		blank=4;
	}
	if(size==16)
	{
		map[0]=9;
		map[1]=10;
		map[2]=11;
		map[3]=12;
		map[4]=13;
		map[5]=1;
		map[6]=2;
		map[7]=3;
		map[8]=14;
		map[9]=8;
		map[10]=0;
		map[11]=4;
		map[12]=15;
		map[13]=7;
		map[14]=6;
		map[15]=5;
		blank=10;
	}
}
void NPuzzle::Show(void)
{
	for(int row=0; row<lSide; row++)
	{
		char buf[64];
		for(int col=0; col<lSide; col++)
			sprintf(buf+col*3,"%2d ",map[row*lSide+col]);
		if(row==0) putchar('p');
		else putchar(' ');
		printf("%s\n",buf);
	}
}
int NPuzzle::RndStateExcept(int now,int except)
{
	int move=except;
	while(move==except)
	{
		if(size==9)
		{
			int n=rndMove8[now][0];
			move=rndMove8[now][rand()%n+1];
		}
		else
		{
			int n=rndMove15[now][0];
			move=rndMove15[now][rand()%n+1];
		}
	}
	return move;
}
void NPuzzle::MovePosition(int pos)
{
	lastMove=blank;
	map[blank]=map[pos];
	blank=pos;
	map[blank]=0;
}
void NPuzzle::MoveRandom(void)
{
	MovePosition(RndStateExcept(blank,lastMove));
}
void NPuzzle::MovesRandom(int n)
{
	for(int i=0; i<n; i++) MoveRandom();
}

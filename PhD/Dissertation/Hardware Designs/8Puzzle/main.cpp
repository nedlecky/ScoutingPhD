#include <stdio.h>

//Scenario 1
// Situation (36 bits)
// Tile 0 (blank) through 8 is 0000 through 1000
// aquare 0 through 8
// 000011112222333344445555666677778888

// Action (4 bits)
// to square y
// TTTT


// Scenario 2
// Situation (21 bits)
// Tile# is always relative to sorted tiles not yet placed
// 1:9 1:8 1:7 1:6 1:5 1:4 1:3 1:2
// 000011122233344455667

// Action (2 bits)
// U,D,L,R
// DD

// C Representations 
int GoalPuzzle[]={
	1,2,3,
	8,0,4,
	7,6,5
};

char* Num2Binary(int n)
{
	printf("look at %d\n",n);
	static char buf[5];
	buf[4]=0;
	int p=8;
	for(int i=0; i<4; i++)
	{
		buf[i]=(p&n)?'1':'0';
		p>>=1;
	}
	return buf;
}
char* C2Bits(int* puzzle)
{
	static char buf[37];
	for(int i=0; i<9; i++)
		sprintf(buf+i*4,"%s",Num2Binary(puzzle[i]));
	return buf;
}

int main()
{
	printf("Goal State: %s\n",C2Bits(GoalPuzzle));

	return 0;
}
	
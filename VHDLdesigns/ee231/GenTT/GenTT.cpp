// GenTT.cpp : Generates the truth table for and abs(a-b) circuit
// a and b are 3 bits
// EE 231 Digital Computer Design I
// Dr. Ned Lecky

#include "stdafx.h"

// Print int 'x' in binary with width 'w'; assumes 32-bit integers
void BinPrint(int x,int w)
{
	if(w>32) w=32;
	if(w<1) w=1;

	if(w<32 && x>=1<<w) printf("OVERFLOW");

	for(int i=w-1; i>=0; i--)
		if(x&1<<i) printf("1"); else printf("0");
	printf("\n");
}

int main(int argc, char* argv[])
{
	printf("Truth Table Generator for abs(a-b)\n");

	BinPrint(3,32);
	BinPrint(3/2,32);
	BinPrint(3>>1,32);
	BinPrint(3*2,32);
	BinPrint(3<<1,32);

	BinPrint(-3,32);
	BinPrint(-3/2,32);
	BinPrint(-3>>1,32);
	BinPrint(-3*2,32);
	BinPrint(-3<<1,32);



	return 0;
}


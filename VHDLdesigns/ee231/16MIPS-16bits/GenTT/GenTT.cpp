// GenTT.cpp : MIPS Alu Control Analysis
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
}

int main(int argc, char* argv[])
{
	printf("MIPS ALU Control Analysis\n");

	int function_opcode;
	int r_format;
	int branch;

	printf("ffffff\n");
	printf("oooooo        aaa \n");
	printf("543210     rb 210\n");
	printf("=================\n");
	for(r_format=0; r_format<2; r_format++)
		for(branch=0; branch<2; branch++)
			for(function_opcode=0; function_opcode<16; function_opcode++)
			{
				BinPrint(function_opcode,6);
				printf("(%2d) ",function_opcode);
				BinPrint(r_format,1);
				BinPrint(branch,1);
				printf(" ");

				int alu_ctl[3];
				alu_ctl[0] = (function_opcode&1 || function_opcode&8) && r_format;
				alu_ctl[1] = !(function_opcode&4) || !r_format;
				alu_ctl[2] = (function_opcode&2 && r_format) || branch;
				int alu_ctli = alu_ctl[0] | (alu_ctl[1]<<1) | (alu_ctl[2]<<2);
				BinPrint(alu_ctli,3);
				printf("\n");
			}
	return 0;
}


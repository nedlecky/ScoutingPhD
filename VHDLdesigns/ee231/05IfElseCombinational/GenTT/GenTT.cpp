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
}

// Convert bool lists to SOP and POS expressions
void SOPPOS(int size,bool a[],char* name)
{
	printf("%s = SOP(",name);
	bool first=true;
	for(int i=0; i<size; i++)
	{
		if(a[i])
		{
			if(!first) printf(",");
			else first=false;
			printf("%d",i);
		}
	}
	printf(")\n");

	printf("%s = POS(",name);
	first=true;
	for(i=0; i<size; i++)
	{
		if(!a[i])
		{
			if(!first) printf(",");
			else first=false;
			printf("%d",i);
		}
	}
	printf(")\n");
}

// Convert bool lists to SOP and POS VHDL expressions of the form
//	WITH conv_integer(composite) SELECT
//		name <= '1' WHEN 7|13|14|15|19|20|21|22|23|25|26|27|28|29|30|31,
//				'0' WHEN others;
void SOPPOSvhdl(int size,bool a[],char* name)
{
	printf("with inputs select\n\t%s <= '1' when ",name);
	bool first=true;
	for(int i=0; i<size; i++)
	{
		if(a[i])
		{
			if(!first) printf("|");
			else first=false;
			printf("%d",i);
		}
	}
	printf(",\n\t'0' when others;\n\n");

	printf("with inputs select\n\t%s <= '0' when ",name);
	first=true;
	for(i=0; i<size; i++)
	{
		if(!a[i])
		{
			if(!first) printf("|");
			else first=false;
			printf("%d",i);
		}
	}
	printf(",\n\t'1' when others;\n\n");
}

int main(int argc, char* argv[])
{
	printf("Truth Table Generator for abs(a-b)\n");

	int a,b;
	int out;
	bool out2[64];
	bool out1[64];
	bool out0[64];

	printf("aaabbb fff\n");
	printf("210210 210\n");
	printf("==========\n");
	int row=0;
	for(a=0; a<8; a++)
		for(b=0; b<8; b++)
		{
			BinPrint(a,3);
			BinPrint(b,3);
			printf(" ");
			
			if(a>b)
				out=a-b;
			else
				if(b>a)
					out=b-a;
				else
					out=0;
			out2[row] = (out&4) > 0;
			out1[row] = (out&2) > 0;
			out0[row] = (out&1) > 0;
			row++;
			BinPrint(out,3);
			printf("\n");
		}

	SOPPOS(64,out2,"out2");
	SOPPOS(64,out1,"out1");
	SOPPOS(64,out0,"out0");

	SOPPOSvhdl(64,out2,"out2");
	SOPPOSvhdl(64,out1,"out1");
	SOPPOSvhdl(64,out0,"out0");

	return 0;
}


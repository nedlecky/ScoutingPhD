// GenTT.cpp : Generates the truth table for a PairAdder
// Dr. Ned Lecky

#include "stdafx.h"

// Print int 'x' in binary with width 'w'
void BinPrint(int x,int w)
{
	if(w>32) w=32;
	if(w<1) w=1;

	if(w<32 && x>=1<<w) printf("OVERFLOW");

	for(int i=w-1; i>=0; i--)
		if(x&1<<i) printf("1"); else printf("0");
}

// Convert bool lists to SOP and POS forms
void SOPPOS(bool a[],char* name)
{
	printf("%s = SOP(",name);
	bool first=true;
	for(int i=0; i<32; i++)
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
	for(i=0; i<32; i++)
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

// Convert bool lists to SOP and POS VHDL
//	WITH conv_integer(composite) SELECT
//		name <= '1' WHEN 7|13|14|15|19|20|21|22|23|25|26|27|28|29|30|31,
//				'0' WHEN others;
void SOPPOSvhdl(bool a[],char* name)
{
	printf("with inputs select\n\t%s <= '1' when ",name);
	bool first=true;
	for(int i=0; i<32; i++)
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
	for(i=0; i<32; i++)
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
	printf("Design Problem 1: PairAdder Truth Table Generator\n");

	int a,b,cin;
	int sum;
	bool co[32];
	bool s1[32];
	bool s0[32];

	printf("aabbc css\n");
	printf("1010i o10\n");
	printf("=========\n");
	int row=0;
	for(a=0; a<4; a++)
		for(b=0; b<4; b++)
			for(cin=0; cin<2; cin++)
			{
				BinPrint(a,2);
				BinPrint(b,2);
				BinPrint(cin,1);
				printf(" ");
				
				sum=a+b+cin;
				co[row] = (sum&4) > 0;
				s1[row] = (sum&2) > 0;
				s0[row] = (sum&1) > 0;
				row++;
				BinPrint(sum,3);
				printf("\n");
			}

	SOPPOS(co,"co");
	SOPPOS(s1,"s1");
	SOPPOS(s0,"s0");

	SOPPOSvhdl(co,"co");
	SOPPOSvhdl(s1,"s1");
	SOPPOSvhdl(s0,"s0");

	return 0;
}


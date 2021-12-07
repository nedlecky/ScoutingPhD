// GenTT.cpp : Generates the truth table for a 5-bit Majority Circuit
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
	printf("5-bit Majority Truth Table Generator\n");

	int x;
	bool maj5[32];

	printf("xxxxx \n");
	printf("12345 f\n");
	printf("=======\n");
	int row=0;
	for(x=0; x<32; x++)
	{
		BinPrint(x,5);

		int x0=x&1;
		int x1=(x&2)>0;
		int x2=(x&4)>0;
		int x3=(x&8)>0;
		int x4=(x&16)>0;

		maj5[x]=(x0+x1+x2+x3+x4)>=3;

		printf(" %d\n",maj5[x]);
	}

	SOPPOS(maj5,"f");

	SOPPOSvhdl(maj5,"f");

	return 0;
}


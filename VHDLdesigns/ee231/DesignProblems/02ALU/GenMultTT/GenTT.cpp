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

	for(int i=w-1; i>=0; i--)
		if(x&1<<i) printf("1"); else printf("0");
}

// Convert bool lists to SOP and POS expressions
void SOPPOS(int size,bool a[],char* name)
{
	// which is smallest?
	int count=0;
	for(int i=0; i<size; i++) count+=a[i];

	char* funcname="???";
	bool val=1;
	if(count<size/2)
	{
		funcname="SOP";
		val=1;
	}
	else
	{
		funcname="POS";
		val=0;
	}

	printf("%s = %s(",name,funcname);
	bool first=true;
	for(i=0; i<size; i++)
	{
		if(a[i]==val)
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
	// which is smallest?
	int count=0;
	for(int i=0; i<size; i++) count+=a[i];

	bool val=1;
	if(count<size/2)
	{
		val=1;
	}
	else
	{
		val=0;
	}

	printf("\twith inputs select\n\t%s <= '%d' when\n\t",name,val);
	bool first=true;
	int counter=0;
	for(i=0; i<size; i++)
	{
		if(a[i]==val)
		{
			if(!first) printf("|");
			else first=false;
			printf("%d",i);
			counter++;
			if(counter>20)
			{
				printf("\n\t");
				counter=0;
			}
		}
	}
	printf(",\n\t'0' when others;\n\n");
}

int main(int argc, char* argv[])
{
	printf("Truth Table Generator for 5-bit signed a*b\n");

	int a,b;
	int out;
	bool outbits[10][1024];

	printf("aaaaabbbbb ffffffffff\n");
	printf("4321043210 9876543210\n");
	printf("=====================\n");
	int row=0;
	for(a=0; a<32; a++)
		for(b=0; b<32; b++)
		{
			BinPrint(a,5);
			BinPrint(b,5);
			printf(" ");

			int asex=a;
			if(a&16) asex=0xfffffff0|a;
			int bsex=b;
			if(b&16) bsex=0xfffffff0|b;
			out=asex*bsex;
			
			for(int i=0; i<10; i++)
				outbits[i][row] = (out & (1<<i)) > 0;
			row++;

			BinPrint(out,10);
			printf("\n");
		}

	for(int i=0; i<10; i++)
	{
		char name[128];
		sprintf(name,"out%d",i);
		//SOPPOS(1024,outbits[i],name);
		SOPPOSvhdl(1024,outbits[i],name);
	}

	return 0;
}


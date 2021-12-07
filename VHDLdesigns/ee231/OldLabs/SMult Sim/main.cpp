// Signed and Unsigned Array Multiplier Simulation
// John E. Lecky
// 2/10/98

// This is a C++ simulator for hardware array multipliers taking signed and
// unsigned inputs.  The simulation is written to be a hardware simulator, not
// not a behavioral simulator.

// SUPPORT
#include <stdio.h>
#include <memory.h>
#include <string.h>
#include <conio.h>
#include <math.h>
#include <stdlib.h>

// BASIC DEFINES
typedef int BOOL;
typedef int bit;
#define TRUE -1
#define FALSE 0
#define SIGNED 1
#define UNSIGNED 0
struct AdderOut
{
	bit sum;
	bit carry;
};

// This is the BitVector class which represents arbitrary width signals
// It is designed to be aware of the signed or unsigned nature of the signal
class BitVector
{
private:
	bit fSigned;
	int len;
	bit* bits;
	char* printBuf;
public:
	BitVector();
	BitVector(int i,int n,int s);
	~BitVector();
	void Set(int i,int n,int s);
	int Integer(void);
	char* Show(BOOL fConvertToo=1);
	bit& operator[](int i);
	int Len(void) {return len;}
	bit Signed(void) {return fSigned;}
};

// BASIC GATES
void AND(bit a,bit b,bit& y);

// ADDER BLOCK PROTOTYPES
void FA(bit a,bit b,bit c,bit& sum,bit& carry);		// standard FA
void FAMMP(bit a,bit b,bit c,bit& sum,bit& carry);	// FA with first 2 inputs considered negative
void HA(bit a,bit b,bit& sum,bit& carry);			// Standard HA
void HAMP(bit a,bit b,bit& sum,bit& carry);			// HA with first input considered negative

// MULTIPLIER PROTOTYPES
int SignedArrayMultiply(BitVector& m0,BitVector& m1);
int UnsignedArrayMultiply(BitVector& m0,BitVector& m1);

// TEST VECTOR DEFINITION
struct TestVector
{
	int opr1;		// operand 1
	int opr2;		// operand 2
	int len;		// operand length in bits
	int fSigned;	// signed or unsigned data
	int result;		// expected result
};


int main()
{
	// setup parameters
	const int width=8;
	const int nTests=128;

	// create random test vectors
	int powN=(int)pow(2,width);
	int powNm1=(int)pow(2,width-1);
	int mask=powN-1;
	TestVector* tv=new TestVector[nTests];
	for(int i=0; i<nTests; i++)
	{
		tv[i].len=width;
		tv[i].opr1=rand()&mask;
		tv[i].opr2=rand()&mask;
		tv[i].fSigned=rand()&1;	// 50% signed; offset if signed
		if(tv[i].fSigned)
		{
			tv[i].opr1-=powNm1;
			tv[i].opr2-=powNm1;
		}
		tv[i].result=tv[i].opr1*tv[i].opr2;	// expected result
	}


	// apply test vectors
	int nPass=0;
	int nFail=0;
	for(i=0; i<nTests; i++)
	{
		BitVector m0;
		BitVector m1;
		m0.Set(tv[i].opr1,tv[i].len,tv[i].fSigned);
		m1.Set(tv[i].opr2,tv[i].len,tv[i].fSigned);
		int ret;
		if(tv[i].fSigned)
			ret=SignedArrayMultiply(m0,m1);
		else
			ret=UnsignedArrayMultiply(m0,m1);
		if(ret==tv[i].result)
		{
			printf("PASS\n");
			nPass++;
		}
		else
		{
			printf("FAIL expected %d got %d\n",tv[i].result,ret);
			nFail++;
			getch();  // pause on failure
		}
	}

	printf("PASSES: %d  FAILS: %d\n",nPass,nFail);
	return 0;
}


// UNSIGNED ARRAY MULTIPLY
int UnsignedArrayMultiply(BitVector& m0,BitVector& m1)
{
	int width=m0.Len();

	printf("Unsigned Multiplier Simulation\n");
	printf("%*s%s\nx\n%*s%s\n",width+2,"",m0.Show(),width+2,"",m1.Show());
	for(int i=0; i<width*2+2; i++)
		printf("=");
	printf("\n");

	if(m0.Len()!=m1.Len())
	{
		printf("ERROR: Length Mismatch\n");
		return 0;
	}

	// setup intermediate signal vectors
	BitVector* ands=new BitVector[width];
	BitVector* sums=new BitVector[width-1];
	BitVector* carries=new BitVector[width-1];
	BitVector result;

	// size and initialize intermediate signals
	for(i=0; i<width; i++)
		ands[i].Set(0,width,UNSIGNED);
	for(i=0; i<width-1; i++)
	{
		sums[i].Set(0,width+1,UNSIGNED);
		carries[i].Set(0,width,UNSIGNED);
	}
	result.Set(0,width*2,UNSIGNED);

	// compute AND tree
	for(i=0; i<=width-1; i++)
		for(int j=0; j<width; j++)
			AND(m0[j],m1[i],ands[i][j]);

	// first sum row
	HA(ands[0][1],ands[1][0],
		sums[0][0],carries[0][0]);
	for(int j=1; j<=width-2; j++)
		FA(ands[0][j+1],ands[1][j],carries[0][j-1],
			sums[0][j],carries[0][j]);
	HA(ands[1][width-1],carries[0][width-2],
		sums[0][width-1],sums[0][width]);

	// rest of the sum rows
	for(i=1; i<=width-2; i++)
	{
		HA(sums[i-1][1],ands[i+1][0],
			sums[i][0],carries[i][0]);
		for(int j=1; j<=width-1; j++)
			FA(sums[i-1][j+1],ands[i+1][j],carries[i][j-1],
				sums[i][j],carries[i][j]);
		sums[i][width]=carries[i][width-1]; // drop carry into bit n of the sum
	}

	// pull result bits down
	result[0]=ands[0][0];
	for(i=1; i<=width-2; i++)
		result[i]=sums[i-1][0];
	for(i=0; i<=width; i++)
		result[i+width-1]=sums[width-2][i];

	// show AND tree
	printf("AND ARRAY\n");
	for(i=0; i<width; i++)
		printf("%*s%s\n",width+2-i," ",ands[i].Show(FALSE));

	// show sums
	printf("PIPELINED SUMS\n");
	for(i=0; i<width-1; i++)
		printf("%*s%s\n",width-i," ",sums[i].Show(FALSE));

	// show result
	printf("RESULT\n");
	printf("  %s\n",result.Show());

	return result.Integer();
}


// SIGNED ARRAY MULTIPLY
int SignedArrayMultiply(BitVector& m0,BitVector& m1)
{
	int width=m0.Len();

	printf("Signed Multiplier Simulation\n");
	printf("%*s%s\nx\n%*s%s\n",width+2,"",m0.Show(),width+2,"",m1.Show());
	for(int i=0; i<width*2+2; i++)
		printf("=");
	printf("\n");

	if(m0.Len()!=m1.Len())
	{
		printf("ERROR: Length Mismatch\n");
		return 0;
	}

	// setup intermediate signal vectors
	BitVector* ands=new BitVector[width];
	BitVector* sums=new BitVector[width-1];
	BitVector* carries=new BitVector[width-1];
	BitVector result;

	// size and initialize intermediate signals
	for(i=0; i<width; i++)
		ands[i].Set(0,width,SIGNED);
	for(i=0; i<width-1; i++)
	{
		sums[i].Set(0,width+1,SIGNED);
		carries[i].Set(0,width,SIGNED);
	}
	result.Set(0,width*2,SIGNED);

	// compute AND tree
	for(i=0; i<=width-1; i++)
		for(int j=0; j<width; j++)
			AND(m0[j],m1[i],ands[i][j]);

	// first sum row
	HA(ands[0][1],ands[1][0],
		sums[0][0],carries[0][0]);
	for(i=1; i<=width-2; i++)
		FA(ands[0][i+1],ands[1][i],carries[0][i-1],
			sums[0][i],carries[0][i]);
	FAMMP(ands[0][width-1],ands[1][width-1],carries[0][width-2], // sign extend and[0]
		sums[0][width-1],sums[0][width]);

	// interior sum rows
	for(i=1; i<=width-3; i++)
	{
		HA(sums[i-1][1],ands[i+1][0],sums[i][0],carries[i][0]);
		for(int j=1; j<=width-2; j++)
			FA(sums[i-1][j+1],ands[i+1][j],carries[i][j-1],
				sums[i][j],carries[i][j]);
		FAMMP(sums[i-1][width],ands[i+1][width-1],carries[i][width-2],
			sums[i][width-1],sums[i][width]);
	}

	// last sum row
	HAMP(ands[width-1][0],sums[width-3][1],
		sums[width-2][0],carries[width-2][0]);
	for(int j=1; j<=width-2; j++)
		FAMMP(ands[width-2+1][j],carries[width-2][j-1],
			sums[width-2-1][j+1],
			sums[width-2][j],carries[width-2][j]);
	FAMMP(sums[width-3][width],carries[width-2][width-2],
		ands[width-1][width-1],
		sums[width-2][width-1],sums[width-2][width]);
	
	// pull down the result
	result[0]=ands[0][0];
	for(i=1; i<=width-2; i++)
		result[i]=sums[i-1][0];
	for(i=0; i<=width; i++)
		result[i+width-1]=sums[width-2][i];

	// show AND tree
	printf("AND ARRAY\n");
	for(i=0; i<width; i++)
		printf("%*s%s\n",width+2-i," ",ands[i].Show(FALSE));

	// show sums
	printf("PIPELINED SUMS\n");
	for(i=0; i<width-1; i++)
		printf("%*s%s\n",width-i," ",sums[i].Show(FALSE));

	// show result
	printf("RESULT\n");
	printf("  %s\n",result.Show());

	return result.Integer();
}


// BASIC GATES
void AND(bit a,bit b,bit& y)
{
	if(a&b) y=1;
	else y=0;
}

// ADDER BLOCKS
// Standard Full Adder
void FA(bit a,bit b,bit c,bit& sum,bit& carry)
{
	static AdderOut faTable[]=
	{
				// + + +
		{0,0},	// 0 0 0
		{1,0},	// 0 0 1
		{1,0},	// 0 1 0
		{0,1},	// 0 1 1
		{1,0},	// 1 0 0
		{0,1},	// 1 0 1
		{0,1},	// 1 1 0
		{1,1}	// 1 1 1
	};

	int index = a<<2 | b<<1 | c;
	sum=faTable[index].sum;
	carry=faTable[index].carry;
}

// Full Adder with first two inputs negative
void FAMMP(bit a,bit b,bit c,bit& sum,bit& carry)
{
	static AdderOut fammpTable[]=
	{
				// - - +
		{0,0},	// 0 0 0
		{1,0},	// 0 0 1
		{1,1},	// 0 1 0
		{0,0},	// 0 1 1
		{1,1},	// 1 0 0
		{0,0},	// 1 0 1
		{0,1},	// 1 1 0
		{1,1}	// 1 1 1
	};

	int index = a<<2 | b<<1 | c;
	sum=fammpTable[index].sum;
	carry=fammpTable[index].carry;
}

// Classic Half Adder
void HA(bit a,bit b,bit& sum,bit& carry)
{
	static AdderOut haTable[]=
	{
				// + +
		{0,0},	// 0 0
		{1,0},	// 0 1
		{1,0},	// 1 0
		{0,1}	// 1 1
	};

	int index = a<<1 | b;
	sum=haTable[index].sum;
	carry=haTable[index].carry;
}

// Half Adder with first input negated
void HAMP(bit a,bit b,bit& sum,bit& carry)
{
	static AdderOut hampTable[]=
	{
				// - +
		{0,0},	// 0 0
		{1,0},	// 0 1
		{1,1},	// 1 0
		{0,0}	// 1 1
	};

	int index = a<<1 | b;
	sum=hampTable[index].sum;
	carry=hampTable[index].carry;
}


// BITVECTOR CLASS METHODS
// Create/Destroy
BitVector::BitVector()
{
	fSigned=0;
	len=0;
	bits=NULL;
	printBuf=NULL;
}
BitVector::BitVector(int val,int n,int s)
{
	bits=NULL;
	printBuf=NULL;
	Set(val,n,s);
}
BitVector::~BitVector()
{
	if(bits!=NULL) delete bits;
	if(printBuf!=NULL) delete printBuf;
}

// Set to integer value
void BitVector::Set(int val,int n,int s)
{
	if(n!=len)
	{
		if(bits!=NULL) delete bits;
		bits=new bit[n];
	}
	fSigned=s;
	len=n;
	int mask=1;
	for(int i=0; i<len; i++)
	{
		bits[i]=(mask&val)?1:0;
		mask<<=1;
	}
}

//Print out; each keeps its own printable representation
int last=0;
char* BitVector::Show(BOOL fConvertToo)
{
	if(printBuf==NULL)
		printBuf=new char[64];

	for(int i=0; i<len; i++)
		printBuf[len-i-1]=bits[i]+'0';
	printBuf[len]=0;

	if(fConvertToo)
	{
		char buf[128];
		sprintf(buf," (%d)",Integer());
		strcat(printBuf,buf);
	}

	return printBuf;
}

// Convert to integer
int BitVector::Integer(void)
{
	int mult=1;
	int val=0;
	for(int i=0; i<len; i++)
	{
		if(bits[i])
			if(!fSigned || i<len-1) val+=mult;
			else val-=mult;
		mult*=2;
	}
	return val;
}

// bit index operator
bit& BitVector::operator[](int i)
{
	if(i<0 || i>=len)
	{
		printf("BitVector Error len=%d, accessing %d\n",len,i);
		static bit bz=0;
		return bz;
	}
	else
		return bits[i];
}

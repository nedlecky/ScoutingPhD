#include "stdafx.h"
#include "LEneuralnet.h"

int main(int argc, char* argv[])
{
	printf("Example 1.1.1 Page 5 with extra neuron\n");

	LEmatrix V("V",3,2);
	V[0][0] = -0.93;
	V[1][0] = -4.79;
	V[2][0] = 5.90;
	V[0][1] = 0;
	V[1][1] = -.1;
	V[2][1] = 10;
	LEmatrix VT("VT");
	VT=Transpose(V);

	LEmatrix x("x",3,1);
	x[0][0] = 1;
	x[1][0] = 2;
	x[2][0] = 2;

	Print(V);
	Print(VT);
	Print(x);

	double minX[]={-2,-2};;
	double maxX[]={2,2};
	double stepX[]={0.25,0.25};
	LEmatrix result1("result1");
	LEmatrix result2("result2");
	ResultLabels(result1,minX,maxX,stepX);
	ResultLabels(result2,minX,maxX,stepX);


	for(int s=0; s<8; s++)
	{
		LEmatrix r;
		ActivationFunction func;
		switch(s)
		{
			case 0:	result1.SetName("hardlimit1");
					result2.SetName("hardlimit2");
					func=LEAhardlimit;		break;
			case 1:	result1.SetName("symhardlimit1");
					result2.SetName("symhardlimit2");
					func=LEAsymhardlimit;	break;
			case 2:	result1.SetName("linearthresh1");
					result2.SetName("linearthresh2");
					func=LEAlinearthresh;	break;
			case 3:	result1.SetName("sigmoid1");
					result2.SetName("sigmoid2");
					func=LEAsigmoid;		break;
			case 4:	result1.SetName("symsigmoid1");
					result2.SetName("symsigmoid2");
					func=LEAsymsigmoid;		break;
			case 5:	result1.SetName("tanh1");
					result2.SetName("tanh2");
					func=LEAtanh;			break;
			case 6:	result1.SetName("augrat1");
					result2.SetName("augrat2");
					func=LEAaugrat;			break;
			case 7:	result1.SetName("RBF1");
					result2.SetName("RBF2");
					LEARBFvariance=0.3;
					func=LEARBF;			break;
		}

		int rIndex=1;
		for(double x1=minX[0]; x1<=maxX[0]+stepX[0]/2; x1+=stepX[0])
		{
			x[1][0]=x1;
			int cIndex=1;
			for(double x2=minX[1]; x2<=maxX[1]+stepX[1]/2; x2+=stepX[1])
			{
				x[2][0]=x2;
				r=OneLayer(VT,x,func);
				result1[rIndex][cIndex]=r[0][0];
				result2[rIndex][cIndex++]=r[1][0];
			}
			rIndex++;
		}

		char filename[128];
		sprintf(filename,"result1_%d.csv",s);
		result1.Save(filename);
		sprintf(filename,"result2_%d.csv",s);
		result2.Save(filename);
	}

	return 0;
}


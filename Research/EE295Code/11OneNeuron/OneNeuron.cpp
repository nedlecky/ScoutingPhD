#include "stdafx.h"
#include "LEneuralnet.h"

int main(int argc, char* argv[])
{
	printf("Example 1.1.1 Page 5\n");

	LEmatrix v("v",3,1);
	v[0][0] = -0.93;
	v[1][0] = -4.79;
	v[2][0] = 5.90;
	LEmatrix vT("vT");
	vT=Transpose(v);

	LEmatrix x("x",3,1);
	x[0][0] = 1;
	x[1][0] = 2;
	x[2][0] = 2;

	Print(v);
	Print(vT);
	Print(x);

	double minX[]={-2,-2};;
	double maxX[]={2,2};
	double stepX[]={0.25,0.25};
	LEmatrix result("result");
	ResultLabels(result,minX,maxX,stepX);

	for(int s=0; s<8; s++)
	{
		LEmatrix r;
		ActivationFunction func;
		switch(s)
		{
			case 0:	result.SetName("hardlimit");
					func=LEAhardlimit;		break;
			case 1:	result.SetName("symhardlimit");
					func=LEAsymhardlimit;	break;
			case 2:	result.SetName("linearthresh");
					func=LEAlinearthresh;	break;
			case 3:	result.SetName("sigmoid");
					func=LEAsigmoid;		break;
			case 4:	result.SetName("symsigmoid");
					func=LEAsymsigmoid;	break;
			case 5:	result.SetName("tanh");
					func=LEAtanh;			break;
			case 6:	result.SetName("augrat");
					func=LEAaugrat;		break;
			case 7:	result.SetName("RBF");
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
				r=OneNeuron(vT,x,func);
				result[rIndex][cIndex++]=r[0][0];
			}
			rIndex++;
		}

		char filename[128];
		sprintf(filename,"result%d.csv",s);
		result.Save(filename);
	}

	return 0;
}


#include "stdafx.h"
#include "LEneuralnet.h"


int main(int argc, char* argv[])
{
	printf("Example 1.1.2 Page 10\n");

	LEmatrix Vbar("Vbar",2,2);
	Vbar[0][0] = -2.69;
	Vbar[0][1] = -2.80;
	Vbar[1][0] = -3.39;
	Vbar[1][1] = -4.56;

	LEmatrix bv("bv",2,1);
	bv[0][0] = -2.21;
	bv[1][0] = 4.76;

	LEmatrix Wbar("Wbar",1,2);
	Wbar[0][0] = -4.91;
	Wbar[0][1] = 4.95;

	LEmatrix bw("bw",1,1);
	bw[0][0] = -2.28;

	LEmatrix xbar("xbar",2,1);
	xbar[0][0] = 2;
	xbar[1][0] = 2;

	Print(Vbar);
	Print(bv);
	Print(Wbar);
	Print(bw);


	double minX[]={-2,-2};;
	double maxX[]={2,2};
	double stepX[]={0.25,0.25};
	LEmatrix result("result");
	ResultLabels(result,minX,maxX,stepX);

	for(int s=0; s<8; s++)
	{
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
					func=LEAaugrat;			break;
			case 7:	result.SetName("RBF");
					LEARBFvariance=0.3;
					func=LEARBF;			break;
		}

		int rIndex=1;
		LEmatrix r;
		for(double x1=minX[0]; x1<=maxX[0]+stepX[0]/2; x1+=stepX[0])
		{
			xbar[0][0]=x1;
			int cIndex=1;
			for(double x2=minX[1]; x2<=maxX[1]+stepX[1]/2; x2+=stepX[1])
			{
				xbar[1][0]=x2;
				r=TwoLayerLinearUnaug(Vbar,bv,Wbar,bw,xbar,func);
				result[rIndex][cIndex++]=r[0][0];
			}
			rIndex++;
		}

		char filename[128];
		sprintf(filename,"result_%d.csv",s);
		result.Save(filename);
	}

	return 0;
}


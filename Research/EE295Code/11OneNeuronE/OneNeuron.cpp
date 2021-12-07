#include "stdafx.h"
#include "LEneuralnet.h"
#include <math.h>

int main(int argc, char* argv[])
{
	LEmatrix p("p");
	p.Load("pData.csv");

	LEmatrix Y("Y");
	Y.Load("tData.csv");

	LEmatrix X("P",1,p.Ncols());
	X=1;
	X=AppendRows(X,p);

	LEmatrix v("v",2,1);
	v[0][0]=0;
	v[1][0]=1;
	LEmatrix vT("vT");
	vT=Transpose(v);

	//for(int i=0; i<Y.Ncols(); i++)
		//Y[0][i]=LEAtanh(X[1][i]);
		//Y[0][i]=X[1][i]*X[1][i];
		//Y[0][i]=sin(X[1][i]);

	Print(X);
	Print(Y);
	Print(v);
	Print(vT);

	LEmatrix y("y");
	LEmatrix e("e");

	double minX[]={-10,-10};
	double maxX[]={10,10};
	double stepX[]={.2,.2};
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
					func=LEAsymsigmoid;		break;
			case 5:	result.SetName("tanh");
					func=LEAtanh;			break;
			case 6:	result.SetName("augrat");
					func=LEAaugrat;			break;
			case 7:	result.SetName("RBF");
					LEARBFvariance=0.3;
					func=LEARBF;			break;
		}

		int rIndex=1;
		LEmatrix y("y");
		LEmatrix e("e");
		for(double x1=minX[0]; x1<=maxX[0]+stepX[0]/2; x1+=stepX[0])
		{
			v[0][0]=x1;
			int cIndex=1;
			for(double x2=minX[1]; x2<=maxX[1]+stepX[1]/2; x2+=stepX[1])
			{
				v[1][0]=x2;
				vT=Transpose(v);
				y=OneNeuron(vT,X,func);
				e=Y-y;
				double E=0.5*Trace(e*Transpose(e));
				result[rIndex][cIndex++]=E;
			}
			rIndex++;
		}

		char filename[128];
		sprintf(filename,"result%d.csv",s);
		result.Save(filename);
	}

	return 0;
}


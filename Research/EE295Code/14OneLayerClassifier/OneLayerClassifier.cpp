#include "stdafx.h"
#include "LEneuralnet.h"
#include <stdlib.h>
#include <conio.h>

int main(int argc, char* argv[])
{
	printf("Example 1.3.2 Page 40\n");

	LEmatrix p("p");
	p.Load("pData.csv");

	LEmatrix Y("Y");
	Y.Load("tData.csv");

	LEmatrix V("V",3,2);
	V.Randomize(-1,1);

	LEmatrix VT("VT");
	VT=Transpose(V);

	LEmatrix X("P",1,p.Ncols());
	X=1;
	X=AppendRows(X,p);

	Print(X);
	Print(Y);
	Print(VT);


	LEmatrix y("y");
	LEmatrix e("e");
	double E=100;
	int epoch=1;
	int maxEpochs=1000;
	double eta=.1;
	bool fSequential=false;
	if(fSequential)
	{
		// sequential
		printf("Sequential Epoch:");
		while(epoch<maxEpochs)
		{
			for(int c=0; c<X.Ncols(); c++)
			{
				LEmatrix x("x");
				x=Column(X,c);
				y=OneLayer(VT,x,LEAhardlimit);

				e=Column(Y,c)-y;

				V = V + x*Transpose(e)*eta;
				VT=Transpose(V);
			}

			y=OneLayer(VT,X,LEAhardlimit);
			e=Y-y;
			E=0.5*Trace(e*Transpose(e));
			if(E<0.001) break;

			printf(" %d",epoch);
			epoch++;
		}
	}
	else
	{
		// batch
		printf("Batch Epoch:");
		while(epoch<maxEpochs)
		{
			y=OneLayer(VT,X,LEAhardlimit);

			e=Y-y;
			E=0.5*Trace(e*Transpose(e));

			if(E<0.001) break;

			V = V + X*Transpose(e)*eta;
			VT=Transpose(V);
			printf(" %d",epoch);
			epoch++;
		}
	}

	printf("\n");
	printf("Final NN\n");
	V.Print();

	LEmatrix x("x",3,1);
	x[0][0]=1;
	double minX[]={-3,-3};;
	double maxX[]={3,3};
	double stepX[]={0.25,0.25};
	LEmatrix result("result");
	ResultLabels(result,minX,maxX,stepX);

	int rIndex=1;
	for(double x1=minX[0]; x1<=maxX[0]+stepX[0]/2; x1+=stepX[0])
	{
		x[1][0]=x1;
		int cIndex=1;
		for(double x2=minX[1]; x2<=maxX[1]+stepX[1]/2; x2+=stepX[1])
		{
			x[2][0]=x2;
			y=OneLayer(VT,x,LEAhardlimit);
			result[rIndex][cIndex++]=y[0][0]+2*y[1][0];
		}
		rIndex++;
	}

	char filename[128];
	sprintf(filename,"result_%s.csv",fSequential ? "seq" : "batch");
	result.Save(filename);

	return 0;
}


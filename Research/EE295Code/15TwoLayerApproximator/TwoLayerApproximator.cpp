#include "stdafx.h"
#include "LEneuralnet.h"
#include <stdlib.h>
#include <conio.h>
#include <math.h>

LEmatrix z("z");

// 2 Layer NN, tanh layer1 linear layer2, V&Wtranspose
LEmatrix& MyTwoLayer(LEmatrix& VT,LEmatrix& WT,LEmatrix& x)
{
	static LEmatrix y("y");
	z = sigma(VT*x,LEAtanh);
	y = WT*z;
	return y;
}

int main(int argc, char* argv[])
{
	printf("Example 1.3.3 Page 48\n");

	LEmatrix p("p");
	p.Load("pData.csv");

	LEmatrix Y("Y");
	Y.Load("tData.csv");
	
	int n=p.Nrows();	// number of inputs
	int m=Y.Nrows();	// number of outputs
	int L=5;			// number of hidden neurons

	LEmatrix V("V",n+1,L);
	/*
	V[0][0]=-2.711;
	V[1][0]=3.6204;
	V[0][1]=1.2214;
	V[1][1]=3.8180;
	V[0][2]=-0.7778;
	V[1][2]=3.5548;
	V[0][3]=2.1751;
	V[1][3]=3.0169;
	V[0][4]=2.9979;
	V[1][4]=3.6398;
	*/
	V.Randomize(-2,2);
	
	LEmatrix W("W",L+1,m);
	/*
	W[0][0]=-1.0295;
	W[1][0]=-.6334;
	W[2][0]=-1.2985;
	W[3][0]=.8719;
	W[4][0]=.5937;
	W[5][0]=.9906;
	*/
	W.Randomize(-2,2);
	
	LEmatrix VT("VT");
	VT=Transpose(V);
	LEmatrix WT("WT");
	WT=Transpose(W);

	LEmatrix X("X",1,p.Ncols());
	X=1;
	X=AppendRows(X,p);

	LEmatrix y("y");
	LEmatrix e("e");
	LEmatrix del1("del1");
	LEmatrix del2("del2");
	double E=100;
	int epoch=0;
	int maxEpochs=20000;
	double eta=.1;
	bool fSequential=true;

	y=MyTwoLayer(VT,WT,X);
	LEmatrix I("I");
	I=Identity(z.Nrows());

	if(fSequential)
	{
		// sequential
		printf("Sequential Epoch:");
		while(epoch<maxEpochs)
		{
			for(int c=0; c<X.Ncols(); c++)
			{
				int doCol=c;
				LEmatrix x("x");
				x=Column(X,doCol);
				y=MyTwoLayer(VT,WT,x);

				e=Column(Y,doCol)-y;
				del2=e;
				del1=(I-Diag(z)*Diag(z))*W*del2;
				//del1=(I+Diag(z)*(I-Diag(z)))*W*del2;

				LEmatrix del1t("del1t");
				del1t.SetSize(del1.Nrows()-1,1);
				for(int i=0; i<del1t.Nrows(); i++) del1t[i][0]=del1[i+1][0];
				W = W + (z*Transpose(del2)*eta);
				V = V + (x*Transpose(del1t)*eta);
				VT=Transpose(V);
				WT=Transpose(W);
			}

			if(epoch%200 == 0)
			{
				y=MyTwoLayer(VT,WT,X);

				e=Y-y;
				E=0.5*Trace(e*Transpose(e));
				printf("epoch %d E=%.3lf eta=%.3lf\n",epoch,E,eta);
			}
			char cc=0;
			if(kbhit()) cc=getch();
			if(cc=='x' || E<=0.005)
			{
				break;
			}
			epoch++;
		}
	}
	else
	{
		// batch
		printf("Batch Epoch:");
		LEmatrix Xavg("Xavg");
		Xavg=ColumnAverage(X);
		while(epoch<maxEpochs)
		{
			y=MyTwoLayer(VT,WT,X);

			e=Y-y;
			e=ColumnAverage(e);
			z=ColumnAverage(z);


			del2=e;
			del1=(I+Diag(z)*(I-Diag(z)))*W*del2;

			LEmatrix del1t("del1t");
			del1t.SetSize(del1.Nrows()-1,1);
			for(int i=0; i<del1t.Nrows(); i++) del1t[i][0]=del1[i+1][0];
			W = W + (z*Transpose(del2)*eta);
			V = V + (Xavg*Transpose(del1t)*eta);
			VT=Transpose(V);
			WT=Transpose(W);

			if(epoch%200 == 0)
			{
				y=MyTwoLayer(VT,WT,X);

				e=Y-y;
				E=0.5*Trace(e*Transpose(e));
				printf("epoch %d E=%.3lf eta=%.3lf\n",epoch,E,eta);
			}
			char cc=0;
			if(kbhit()) cc=getch();
			if(cc=='x' || E<0.005)
			{
				Y.Print();
				y.Print();
				break;
			}
			epoch++;
		}
	}

	printf("\n");
	printf("Final NN\n");
	V.Print();
	W.Print();

	LEmatrix x("x",2,1);
	x[0][0]=1;
	double minX[]={-5};
	double maxX[]={5};
	double stepX[]={0.025};
	int outputRows=(int)((maxX[0]-minX[0]+stepX[0]/2)/stepX[0]+1);
	LEmatrix result("result",outputRows+1,3);

	// fill in the axis labels in row 0 and col 0
	int index=1;
	result[0][0]=0;
	int yindex=0;
	for(double x1=minX[0]; x1<=maxX[0]+stepX[0]/2.; x1+=stepX[0])
	{
		result[index][0]=x1;
		if(fabs(x1-X[1][yindex])<.01)
			result[index][2]=Y[0][yindex++];
		index++;
	}


	int rIndex=1;
	for(x1=minX[0]; x1<=maxX[0]+stepX[0]/2; x1+=stepX[0])
	{
		x[1][0]=x1;
		y=MyTwoLayer(VT,WT,x);
		result[rIndex][1]=y[0][0];
		rIndex++;
	}

	char filename[128];
	sprintf(filename,"result_%s.csv",fSequential ? "seq" : "batch");
	result.Save(filename);

	return 0;
}


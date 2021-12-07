// ActivationTilting.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "LEneuralnet.h"

// returns 1/2 of the sum of the squares of ALL elements of e
// This is equivalent to 0.5*leTrace(e*leTranpose(e)) but MUCH faster
double leEfunc(LEmatrix& e)
{
	// this is equivalent to
	//return 0.5*leTrace(e*leTranspose(e));

	double sum=0;
	for(int i=0; i<e.Nrows(); i++)
		for(int j=0; j<e.Ncols(); j++)
			sum+=e[i][j]*e[i][j];

	return 0.5*sum;
}

// Internally defined activation functions
double LEAtanhtilt(double x)
{
	return LEAtanh(x) + 0.01*x;
}
double LEAhardlimittilt(double x)
{
	return LEAhardlimit(x) + 0.01*x;
}

// Create a column vector initialized from dmin to dmax in increments of dstep
LEmatrix& leStepVector(double dmin,double dmax, double dstep)
{
	static LEmatrix s("StepVector");
	
	if(dstep==0)
	{
		s.SetSize(1,1);
		s[0][0]=0;
		return s;
	}
	
	int rows = (int)((dmax-dmin)/dstep + 1.5);
	s.SetSize(rows,1);
	for(int i=0; i<rows; i++)
		s[i][0]=dmin+dstep*i;

	return s;
}

void VaryWeights(LEmatrix& result,LEmatrix& X,LEmatrix& Y,ActivationFunction func)
{
	LEmatrix y("y");
	LEmatrix e("e");

	// place computed weights in vt (saves repeated transposes)
	LEmatrix vt("vt",1,2);
	for(int v0=1; v0<result.Nrows(); v0++)
	{
		vt[0][0]=result[v0][0];
		for(int v1=1; v1<result.Ncols(); v1++)
		{
			vt[0][1]=result[0][v1];
			y=leOneNeuron(vt,X,func);
			e=Y-y;
			double E=leEfunc(e);

			result[v0][v1]=E;
		}
	}
}

int main(int argc, char* argv[])
{
	printf("Activation Tilting Demo\n");

	// create a set of incrementing inputs
	LEmatrix Xbar("Xbar");
	Xbar=leTranspose(leStepVector(-3,3,.1));

	LEmatrix X("X");
	X.SetSize(1,Xbar.Ncols());
	X=1;
	X.AppendRows(Xbar);

	// create a set of outputs as a standard f(x)
	LEmatrix Y("Y");
	Y.SetSize(1,X.Ncols());


	// create result space; this is the domain over which v0 and v1 will run
	double minV[]={-20,-20};
	double maxV[]={20,20};
	double stepV[]={.5,.5};
	LEmatrix result("result");
	result.SizeAndLabel(minV,maxV,stepV);

	// attempt y = 2x + 3
	for(int i=0; i<Y.Ncols(); i++)
		Y[0][i]=2*X[1][i]+3;
	VaryWeights(result,X,Y,LEAlinear);
	result.Save("linear_linear.csv");

	// attempt y = x**2
	for(i=0; i<Y.Ncols(); i++)
		Y[0][i]=X[1][i]*X[1][i];
	VaryWeights(result,X,Y,LEAsigmoid);
	result.Save("sigmoid_square.csv");

	// attempt y=tanh(x)
	for(i=0; i<Y.Ncols(); i++)
		Y[0][i]=LEAtanh(X[1][i]);
	VaryWeights(result,X,Y,LEAtanh);
	result.Save("tanh_tanh.csv");

	// also try tilted tanh
	VaryWeights(result,X,Y,LEAtanhtilt);
	result.Save("tanhtilt_tanh.csv");

	// One Layer Classifer; try to train quadrant checker
	int nTrain=500;
	double eta=.01;

	// create random training data
	X.SetSize(3,nTrain);
	X.Randomize(-1,1);
	Y.SetSize(2,nTrain);
	for(i=0; i<nTrain; i++)
	{
		X[0][i]=1; // first input must be one for bias implementation
		int quadrant=0;
		if(X[1][i]>0) quadrant++;
		if(X[2][i]>0) quadrant+=2;
		Y[0][i]=quadrant&1;
		Y[1][i]=(quadrant&2)>>1;
	}
	
	// resize/relabel result matrix for x1,x2 input
	double minX[]={-3,-3};;
	double maxX[]={3,3};
	double stepX[]={0.25,0.25};
	result.SizeAndLabel(minX,maxX,stepX);
	
	LEmatrix y("y");
	LEmatrix e("e");
	double E;

	// main loop; try both types of training
	for(int fSequential=0; fSequential<2; fSequential++)
	{
		// we'll setup the initial V matrix as all 0s
		LEmatrix V("V",3,2);
		V.SetZero();
		V.Randomize(-2,2);

		int epoch=1;
		int adjustments=0;
		int maxEpochs=10000;
		
		if(fSequential)
		{
			// sequential training
			printf("Sequential Epoch: ");
			while(epoch<maxEpochs)
			{
				// pick out ONE input
				for(int c=0; c<X.Ncols(); c++)
				{
					LEmatrix x("x");
					x=leCol(X,c);
					y=leOneLayer(leTranspose(V),x,LEAhardlimit);

					// compute error to corresponding column of Y
					e=leCol(Y,c)-y;

					// update weights!
					V = V + x*leTranspose(e)*eta;
					adjustments++;
				}

				// now, we must see if we're done.  Apply ALL inputs
				//   and compute total error
				y=leOneLayer(leTranspose(V),X,LEAhardlimit);
				e=Y-y;
				E=leEfunc(e);
				if(E<0.001) break;

				if(epoch%100==0) printf("%d(%.4lf) ",epoch,E);
				epoch++;
			}
		}
		else
		{
			// batch training
			printf("Batch Epoch: ");
			while(epoch<maxEpochs)
			{
				// apply ALL inputs and compute global error
				y=leOneLayer(leTranspose(V),X,LEAhardlimit);
				e=Y-y;
				E=leEfunc(e);

				if(E<0.001) break;

				// update weights
				V = V + X*leTranspose(e)*eta;
				adjustments++;

				if(epoch%100==0) printf("%d(%.4lf) ",epoch,E);
				epoch++;
			}
		}

		printf("\n");
		printf("Final NN: E=%.4lf %d epochs, %d adjustments\n",E,epoch,adjustments);
		V.Print(4);

		LEmatrix x("x",3,1);
		x[0][0]=1;

		// simulate the net on a broad input range
		for(int x1=1; x1<result.Nrows(); x1++)
		{
			x[1][0]=result[x1][0];
			for(int x2=1; x2<result.Ncols(); x2++)
			{
				x[2][0]=result[0][x2];
				y=leOneLayer(leTranspose(V),X,LEAhardlimit);
				result[x1][x2] = y[0][0] + 2*y[1][0];
			}
		}

		char filename[128];
		sprintf(filename,"onelayer_%s.csv",fSequential ? "seq" : "batch");
		result.Save(filename);
	}

	return 0;
}


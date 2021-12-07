// NetCoeffs.cpp : Defines the entry point for the console application.
//
#include "stdafx.h"

#include "LEmatrix.h"
#include "LEneuralnet.h"
#include <conio.h>

// LINEAR TEST SYSTEM
// REAL 
LEmatrix A("A");
LEmatrix B("B");
LEmatrix& RealSystem(LEmatrix& x,LEmatrix& u)
{
	static LEmatrix y("y");

	y = A*x;
	y = y + B*u;

	return y;
}

// NN MODEL
LEmatrix& NNSystem(LEmatrix& V,LEmatrix& x)
{
	static LEmatrix y("y");

	y = leTranspose(V)*x;

	return y;
}


int main(int argc, char* argv[])
{
	// Real system parameters
	A.SetSize(2,2);
	A[0][0]=1;	A[0][1]=2;
	A[1][0]=4;	A[1][1]=3;
	B.SetSize(2,2);
	B[0][0]=3;	B[0][1]=4;
	B[1][0]=2;	B[1][1]=1;

	// Initialize NN
	LEmatrix V("V");
	V.SetSize(5,2);
	V.SetZero();

	LEmatrix x("x",2,1);
	LEmatrix u("u",2,1);
	LEmatrix e("e");
	LEmatrix xnn("xnn",5,1);
	xnn[0][0]=1;
	LEmatrix yReal("yReal");
	LEmatrix yNN("yNN");

	double eta=0.1;
	int eMemoryLength=20;
	int eIndex=0;
	LEmatrix eMemory("eMemory",2,1);
	for(int i=0; i<100; i++)
	{
		x[0][0]=leRandInt(-200,200)/100.;
		x[1][0]=leRandInt(-200,200)/100.;
		u[0][0]=leRandInt(-200,200)/100.;
		u[1][0]=leRandInt(-200,200)/100.;

		yReal=RealSystem(x,u);

		xnn[1][0]=x[0][0];
		xnn[2][0]=x[1][0];
		xnn[3][0]=u[0][0];
		xnn[4][0]=u[1][0];
		yNN=NNSystem(V,xnn);

		/*
		x.Print();
		u.Print();
		xnn.Print();
		yReal.Print();
		yNN.Print();
		getch();
		*/

		e=yReal-yNN;

		if(eIndex==eMemoryLength)
			eIndex=0;
		else
			if(eIndex>=eMemory.Ncols())
			{
				eMemory.SetSize(2,eIndex+1);
			}

		//e.Print();
		eMemory[0][eIndex]=e[0][0];
		eMemory[1][eIndex++]=e[1][0];
		double E=leEcalc(eMemory);
		printf("%.3lf ",E);
		V = V + xnn*leTranspose(e)*eta;
	}

	printf("\n");
	A.Print();
	B.Print();
	V.Print();

	return 0;
}


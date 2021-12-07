// VelocityEstimation.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "LEneuralnet.h"
#include <math.h>

int main(int argc, char* argv[])
{
	int size=1000;
	
	LEmatrix pos("pos",1,size);
	LEmatrix vel("vel",1,size);
	LEmatrix estVel1("estVel1",1,size);
	LEmatrix estVel2("estVel2",1,size);
	LEmatrix estVel3("estVel3",1,size);
	LEmatrix estVel4("estVel3",1,size);

	for(int i=0; i<size; i++)
	{
		pos[0][i]=sin(.62*i);
		vel[0][i]=.62*cos(.62*i);
	}

	for(i=2; i<size; i++)
	{
		// laggard
		estVel1[0][i]=pos[0][i]-pos[0][i-1];

		// linear acceleration assumption
		double v0=pos[0][i]-pos[0][i-1];
		double v1=pos[0][i-1]-pos[0][i-2];
		double a0=v0-v1;
		estVel2[0][i] = v0 + a0/2;

		// Lagrange Interp Poly (Ge pg. 141)
		// Same as linear accel assumption!
		estVel3[0][i] = (pos[0][i-2] - 4*pos[0][i-1] + 3*pos[0][i])/2;

		// Lagrange Interp Poly (Ge pg. 141)
		// Same as linear accel assumption!
		if(i>2)
		{
			double v2=pos[0][i-2]-pos[0][i-3];
			double a1=v1-v2;
			double aavg=a0 + 3*(a0-a1)/4;
			estVel4[0][i] = v0 + aavg/2;
		}
	}


	LEmatrix e1("e1");
	e1=estVel1-vel;
	Print(e1*Transpose(e1));
	double E1=Trace(e1*Transpose(e1))/size;
	
	LEmatrix e2("e2");
	e2=estVel2-vel;
	double E2=Trace(e2*Transpose(e2))/size;

	LEmatrix e3("e3");
	e3=estVel3-vel;
	double E3=Trace(e3*Transpose(e3))/size;

	LEmatrix e4("e4");
	e4=estVel4-vel;
	double E4=Trace(e4*Transpose(e4))/size;

	printf("E1=%.5lf E2=%.5lf E3=%.5lf E4=%.5lf\n",E1,E2,E3,E4);

	//Print(pos);
	//Print(vel);
	//Print(estVel1);
	//Print(estVel2);
	//Print(estVel3);
	//Print(estVel4);
	return 0;
}


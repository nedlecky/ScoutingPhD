// Encoder01.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <math.h>
#include <conio.h>

const double PI=3.14159265;
const double TWOPI=2.0*PI;
double motionOmega;
double a0=1;

// Actual x(t) as measured by sensor
double Sense(double t)
{
	double x = 1.0*sin(motionOmega*t);

	return x;
}

// Known exact v(t) (Used for error checking only)
double V(double t)
{
	double v = 1.0*motionOmega*cos(motionOmega*t);

	return v;
}

// Known exact a(t) (Used for error checking only)
double A(double t)
{
	double a = -1.0*motionOmega*motionOmega*sin(motionOmega*t);

	return a;
}

int main(int argc, char* argv[])
{
	motionOmega = 0.2*TWOPI;  // 0.2 Hz motion, T=5s
	double Ts=0.01;

	double bw = 1/Ts;//20*TWOPI;
	double damping = 0.707;
	double K1 = bw*bw;
	double K2 = 2*damping*bw;

	double t0=0;
	double tf=10;

	double x;
	double xe,ve,ae;
	double xep,vep;
	double xErr,vErr,aErr;

	double xErrSum=0;
	double vErrSum=0;
	double aErrSum=0;
	int nErr=0;

	double t=t0;
	ae=0;
	ve=0;
	xe=0;
	printf("bw=%8.3lf damping=%8.3lf   K1=%9.3lf K2=%9.3lf\n",bw,damping,K1,K2);
	printf("t        xErr     vErr     aErr\n");
	
	FILE* fp=fopen("test.csv","w");
	fprintf(fp,"t,xErr,vErr,aErr,x\n");
	
	while(t<tf)
	{
		// Read position sensor
		x=Sense(t);

		// As in Lee and Song's Paper (erroneous)
		//ae = K1*(x-xe) - K2*ve;
		//vep = ae*Ts;
		//xep = ve*Ts + ae*Ts*Ts;

		// Lee and Song, corrected MSE 0.010 0.013 0.009
		ae = K1*(x-xe) - K2*ve;
		vep = ve + ae*Ts;
		xep = xe + ve*Ts + 0.5*ae*Ts*Ts;

		// Idea #1 MSE 0.010 0.007 0.002
		//ae = K1*(x-xe) - K2*ve;
		//vep = ve + ae*Ts;
		//xep = xe + ve*Ts;

		// Error measurement
		xErr = xe-x;
		vErr = ve-V(t);
		aErr = ae-A(t);
		printf("%4.2lf %8.3lf %8.3lf %8.3lf %6.3lf\n",t,xErr,vErr,aErr,x);
		fprintf(fp,"%.2lf,%.3lf,%.3lf,%.3lf,%.3lf\n",
			t,xErr,vErr,aErr,x);

		// Accumulate statistics
		if(t>1.0) // wait for initial settling
		{
			xErrSum+=xErr*xErr;
			vErrSum+=vErr*vErr;
			aErrSum+=aErr*aErr;
			nErr++;
		}

		t+=Ts;
		xe=xep;
		ve=vep;
	}
	printf("ME: x=%8.3lf v=%8.3lf a=%8.3lf\n",
		sqrt(xErrSum/nErr),
		sqrt(vErrSum/nErr),
		sqrt(aErrSum/nErr));
	fprintf(fp,"%.5lf,%.5lf%.5lf\n",
		sqrt(xErrSum/nErr),
		sqrt(vErrSum/nErr),
		sqrt(aErrSum/nErr));
	fclose(fp);

	return 0;
}


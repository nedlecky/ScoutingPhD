// Encoder03.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <math.h>
#include <conio.h>

const double PI=3.14159265;
const double TWOPI=2.0*PI;
double a0=1;

// Known exact a(t) (Used for error checking only)
double A(double t)
{

	double a;
	if(t<=2) a = a0;
	else if(t<=8) a = 0;
	else a = -a0;

	return a;
}

int main(int argc, char* argv[])
{
	double t0=0;
	double tf=10;
	double Ts=0.02;

	double x,v,a;
	double xnew,vnew,anew;
	double xe,ve,ae;
	double xep,vep;
	double xErr,vErr,aErr;
	double xei;

	for(Ts=0.0005; Ts<=0.01; Ts+=0.0005)
	{
		double damping = 1/sqrt(2);

		double tau = Ts;
		double alpha = 1/tau;
		double omegan = alpha/damping;

		double K1 = omegan*omegan;
		double K2 = 2*damping*omegan;
		double K3 = 100000;

		double xErrSum=0;
		double vErrSum=0;
		double aErrSum=0;
		int nErr=0;

		double t=t0;
		ae=0;
		ve=0;
		xe=0;
		xei=0;
		a=v=x=0;
		printf("Ts=%8.4lf omegan=%8.3lf damping=%8.3lf   K1=%11.3lf K2=%9.3lf K3=%9.3lf ",Ts,omegan,damping,K1,K2,K3);
		//printf("t        xErr     vErr     aErr\n");
	
		FILE* fp=fopen("test.csv","w");
		fprintf(fp,"t,xErr,vErr,aErr,x\n");
	
		while(t<tf)
		{
			// Read position sensor
			anew = A(t);
			vnew = v + (a+anew)*Ts/2;
			xnew = x + (v+vnew)*Ts/2 + 0.5*(a+anew)*Ts*Ts/2;

			a=anew;
			v=vnew;
			x=xnew;

			// As in Lee and Song's Paper (erroneous)
			//ae = K1*(x-xe) - K2*ve;
			//vep = ae*Ts;
			//xep = ve*Ts + ae*Ts*Ts;

			// Lee and Song, corrected
			xei = xei + (x-xe)*Ts;
			ae = K1*(x-xe) - K2*ve + K3*xei;
			vep = ve + ae*Ts;
			xep = xe + ve*Ts + 0.5*ae*Ts*Ts;

\			// Error measurement
			xErr = xe-x;
			vErr = ve-v;
			aErr = ae-a;
			//printf("%4.2lf %8.3lf %8.3lf %8.3lf %6.3lf\n",t,xErr,vErr,aErr,x);
			fprintf(fp,"%.3lf,%.5lf,%.5lf,%.5lf,%.5lf,%.5lf,%.5lf\n",
				t,xErr,vErr,aErr,
				x,v,a);

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
		double mex=sqrt(xErrSum/nErr);
		double mev=sqrt(vErrSum/nErr);
		double mea=sqrt(aErrSum/nErr);
		printf("ME: x=%8.3lf v=%8.3lf a=%8.3lf sum=%8.3lf\n",mex,mev,mea,mex+mev+mea);
		fprintf(fp,"%.5lf,%.5lf%.5lf,%.3lf,%.3lf,%.3lf\n",mex,mev,mea);
		fclose(fp);
	}

	return 0;
}


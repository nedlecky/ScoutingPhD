// Encoder01.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <math.h>
#include <conio.h>
#include "stockcar.h"

const double PI=3.14159265;
const double TWOPI=2.0*PI;
double motionOmega;
double a0=1;

const int bufSize=40;
double buffer[bufSize];
int bufIndex=0;
bool bufFull=false;

void PushBuf(double x)
{
	buffer[bufIndex++]=x;
	if(bufIndex>=bufSize)
	{
		bufIndex=0;
		bufFull=true;
	}
}

double AvgBuf(void)
{
	int count=bufSize;
	int last=bufSize;
	double sum=0;
	if(!bufFull)
	{
		last=bufIndex;
		count=bufIndex;
		if(count<1) return 0;
	}

	for(int i=0; i<last; i++)
		sum+=buffer[i];

	return sum/(double)count;
}
// Actual x(t) as measured by sensor
double Sense(double t)
{
	double x = 1.0*sin(motionOmega*t);

	return x;
}

// Known exact v(t) (Used for error checking only)
double Vel(double t)
{
	double v = 1.0*motionOmega*cos(motionOmega*t);

	return v;
}

// Known exact a(t) (Used for error checking only)
double Acc(double t)
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

	LEmatrixObj V("V",2,1);
	LEmatrixObj Xnn("Xnn",2,1);
	V[0][0]=K1;//*0.5;
	V[1][0]=K2;//*1.5;
	V.Print();
	double eta=20;

	double t0=0;
	double tf=10;

	double x;
	double xe,ve,ae;
	double xep,vep;
	double xErr,vErr,aErr;
	double E,Eavg;

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

		// Lee and Song, corrected MSE 0.012 0.016 0.013
		//ae = K1*(x-xe) - K2*ve;
		//vep = ve + ae*Ts;
		//xep = xe + ve*Ts + 0.5*ae*Ts*Ts;

		// Lee and Song, partially corrected MSE 0.012 0.022 0.020
		//ae = K1*(x-xe) - K2*ve;
		//vep = ve + ae*Ts;
		//xep = xe + ve*Ts + ae*Ts*Ts;

		// Idea #1 MSE 0.012 0.010 0.006
		//ae = K1*(x-xe) - K2*ve;
		//vep = ve + ae*Ts;
		//xep = xe + ve*Ts;

		// Single Neuron
		Xnn[0][0] = x-xe;
		Xnn[1][0] = -ve;
		ae = (lemTranspose(V)*Xnn)[0][0];
		vep = ve + ae*Ts;
		xep = xe + ve*Ts;
		E=fabs(x-xe);
		PushBuf(E);
		Eavg=AvgBuf();
		V = V + eta*Eavg*Xnn;
		//if(V[0][0]<0) V[0][0]=0;
		//if(V[1][0]<0) V[1][0]=0;
		V.Print();

		// Error measurement
		xErr = xe-x;
		vErr = ve-Vel(t);
		aErr = ae-Acc(t);
		printf("%4.2lf %8.3lf %8.3lf %8.3lf %6.3lf %6.3lf\n",t,xErr,vErr,aErr,x,Eavg);
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
		//if(fmod(t,10)<0.1) V.Print();
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

	V.Print();

	return 0;
}


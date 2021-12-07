// RobotSim.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "LEmatrix.h"
#include <math.h>

// global robot parameters
double m1;
double m2;
double a1;
double a2;
double g;

double alpha;
double beta;
double eta;
double e1;

LEmatrix& Inv22(LEmatrix& x)
{
	static LEmatrix Inv("Inv",2,2);

	double det = x[0][0]*x[1][1] - x[0][1]*x[1][0];

	if(det==0)
	{
		Inv.MakeZero();
	}
	else
	{
		Inv[0][0] = x[1][1]/det;
		Inv[1][1] = x[0][0]/det;
		Inv[0][1] = -x[0][1]/det;
		Inv[1][0] = -x[1][0]/det;
	}

	return Inv;
}
LEmatrix& M(LEmatrix& q)
{
	static LEmatrix M("M",2,2);

	double cq2=cos(q[1][0]);
	M[0][0] = alpha + beta + 2 * eta * cq2;
	M[0][1] = beta + eta * cq2;
	M[1][0] = M[0][1];
	M[1][1] = beta;

	return M;
}

LEmatrix& Vm(LEmatrix& q,LEmatrix& qd)
{
	static LEmatrix Vm("Vm",2,2);

	double sq2=sin(q[1][0]);
	Vm[0][0] = -eta * qd[1][0] * sq2;
	Vm[0][1] = -eta * (qd[0][0] + qd[1][0]) * sq2;
	Vm[1][0] = eta * qd[0][0] * sq2;
	Vm[1][1] = 0;

	return Vm;
}

LEmatrix& V(LEmatrix& q,LEmatrix& qd)
{
	static LEmatrix V("V",2,2);

	V = Vm(q,qd) * qd;

	return V;
}

LEmatrix& F(LEmatrix& qd)
{
	static LEmatrix F("F",2,1);

	F[0][0] = 0;
	F[1][0] = 0;

	return F;
}

LEmatrix& G(LEmatrix& q)
{
	static LEmatrix G("G",2,1);

	double cq12 = cos(q[0][0] + q[1][0]);
	G[0][0] = alpha * e1 * cos(q[0][0]) + eta * e1 * cq12;
	G[1][0] = eta * e1 * cq12;

	return G;
}

LEmatrix& N(LEmatrix& q,LEmatrix& qd)
{
	static LEmatrix N("N",2,1);

	N = Vm(q,qd) * qd + F(qd) + G(q);

	return N;
}

int main(int argc, char* argv[])
{
	m1=1;
	m2=1;
	a1=1;
	a2=1;
	g=9.8;

	// useful constants
	alpha = (m1+m2) * pow(a1,2);
	beta = m2 * pow(a2,2);
	eta = m2* a1 * a2;
	e1 = g / a1;

	LEmatrix M0("M");
	LEmatrix Vm0("Vm");
	LEmatrix V0("V");
	LEmatrix F0("F");
	LEmatrix G0("G");
	LEmatrix N0("N");

	LEmatrix q("q",2,1);
	LEmatrix qd("q",2,1);
	LEmatrix qdd("q",2,1);
	q[0][0]=1;
	q[1][0]=1;
	qd[0][0]=1;
	qd[1][0]=1;

	M0=M(q);
	Vm0=Vm(q,qd);
	V0=V(q,qd);
	F0=F(qd);
	G0=G(q);
	N0=N(q,qd);

	Print(M0);
	Print(Vm0);
	Print(V0);
	Print(F0);
	Print(G0);
	Print(N0);
	Print(Inv22(M0));
	Print(Inv22(M(q))*N(q,qd));


	return 0;
}


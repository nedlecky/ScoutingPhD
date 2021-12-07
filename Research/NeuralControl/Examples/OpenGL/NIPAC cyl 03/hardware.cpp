#include "stdafx.h"
#include "const.h"
#include "hardware.h"
#include "LEsimulate.h"

Hardware::Hardware(int n)
{
	nAxes=n;

	axisMin=new double[nAxes];
	axisMax=new double[nAxes];
	t=0;
	integration_t=0.02;
}
Hardware::~Hardware()
{
	if(axisMin) delete axisMin;
	if(axisMax) delete axisMax;
}

int Hardware::SetTau(LEmatrix& tau_spec)
{
	tau=tau_spec;
	return 0;
}
LEmatrix& Hardware::get_q(void)
{
	static LEmatrix q("q");

	q.SetSize(nAxes,1);
	for(int i=0; i<nAxes; i++)
		q[i][0]=x[i][0];

	return q;
}

LEmatrix& Hardware::get_qdot(void)
{
	static LEmatrix q_dot("q_dot");

	q_dot.SetSize(nAxes,1);
	for(int i=0; i<nAxes; i++)
		q_dot[i][0]=x[i+nAxes][0];

	return q_dot;
}

void Cylindrical01System(double x[],double xdot[],void* params)
{
	Cylindrical01Params* p=(Cylindrical01Params*) params;

	// x, xdot definitions
	//0  time
	//1  pos1 theta    2  pos2 h     3  pos3 r
	//4  vel1          5  vel2       6  vel3
	double theta=x[1];
	double h=x[2];
	double r=x[3];
	double thetadot=x[4];
	double hdot=x[5];
	double rdot=x[6];
	p->gq_dot[0][0]=x[4];
	p->gq_dot[1][0]=x[5];
	p->gq_dot[2][0]=x[6];

	// Fill in inertia matrix
	p->gM[0][0] = p->J + p->m2*r*r;

	// Fill in Vm
	p->gVm[0][0]=p->m2*r*rdot;
	p->gVm[0][2]=p->m2*r*thetadot;
	p->gVm[2][0]=-p->gVm[0][2];

	// True acceleration
	p->gq_dotdot=leInvert(p->gM)*(*(p->ptau) - p->gVm*p->gq_dot - p->gG);

	// System Equations
	xdot[1] = x[4];
	xdot[2] = x[5];
	xdot[3] = x[6];
	xdot[4] = p->gq_dotdot[0][0];
	xdot[5] = p->gq_dotdot[1][0];
	xdot[6] = p->gq_dotdot[2][0];
}

Cylindrical01::Cylindrical01() : Hardware(3)
{
	p.ptau=&tau;

	axisMin[0]=-.2;
	axisMin[1]=-0.1;
	axisMin[2]=-0.1;

	axisMax[0]=2.1*pi;
	axisMax[1]=3;
	axisMax[2]=2;
}
Cylindrical01::~Cylindrical01()
{
}

void Cylindrical01::SetParameters(double new_m1,double new_m2,double new_J,double new_g)
{
	p.m1=new_m1;
	p.m2=new_m2;
	p.J=new_J;
	p.g=new_g;

	p.gM.SetName("gM");
	p.gM.SetSize(3,3);
	p.gVm.SetName("gVm");
	p.gVm.SetSize(3,3);
	p.gG.SetName("gG");
	p.gG.SetSize(3,1);
	p.gMinv.SetName("gMinv");
	p.gMinv.SetSize(3,3);
	p.gN.SetName("gN");
	p.gN.SetSize(3,1);
	p.gq_dot.SetName("gq_dot");
	p.gq_dot.SetSize(3,1);
	p.gq_dotdot.SetName("gq_dotdot");
	p.gq_dotdot.SetSize(3,1);
	p.ptau->SetName("tau");
	p.ptau->SetSize(3,1);

	p.gM=0;
	p.gM[1][1] = p.m1+p.m2;
	p.gM[2][2] = p.m2;

	p.gG=0;
	p.gG[1][0] = (p.m1+p.m2)*p.g;

	p.gVm=0;
}

bool Cylindrical01::Run(double dt,LEmatrix* result)
{
	bool fDiverged=false;
	
	// Integrate us forward one update step
	if(dt<integration_t) integration_t=dt;
	stepResult=leODErk4Aug(Cylindrical01System,
		t,t+dt,integration_t,x,(void*)&p);

	// Make stepResult into just its last row (final result)
	stepResult=leRow(stepResult,stepResult.Nrows()-1);
		
	// Copy down new t,x (last row of integration results)
	t=stepResult[0][0];
	for(int i=0; i<nAxes*2; i++)
	{
		x[i][0]=stepResult[0][i+1];

		// constrain physical limits
		if(i<nAxes)
		{
			if(x[i][0]<axisMin[i]) x[i][0]=axisMin[i];
			else if(x[i][0]>axisMax[i]) x[i][0]=axisMax[i];
		}

		if(_isnan(x[i][0]))
		{
			fDiverged=true;
			break;
		}
	}

	if(!fDiverged)
	{
		if(result)
			// append step integration results to entire result
			result->AppendRows(stepResult);
	}

	return fDiverged;
}


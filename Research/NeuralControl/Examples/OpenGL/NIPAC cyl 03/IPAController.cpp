#include "stdafx.h"
#include "IPAController.h"
#include "animator.h"
#include <math.h>

IPAController::IPAController(pHardware hw0,pWaypointSchedule waypoint0)
{
	hw=hw0;
	waypoint=waypoint0;
	x0.SetSize(hw->get_nAxes()*2,1);
	x0=0;
	nAxes=hw->get_nAxes();
}

IPAController::~IPAController()
{
}

LEmatrix& IPAController::ComputeAcc(double t,LEmatrix& y,LEmatrix& ydot)
{
	static LEmatrix dest("dest");
	static LEmatrix tf("tf");
	static LEmatrix yf("yf");
	static LEmatrix ydotf("ydotf");
	static LEmatrix tr("tr");
	static LEmatrix yr("yr");
	static LEmatrix yddot("yddot");
	
	dest=waypoint->Destination(t);
	tf=leCol(dest,0);
	yf=leCol(dest,1);
	ydotf=leCol(dest,2);

	// time and distance remaining to goal
	tr=tf-t;
	yr=yf-y;

	yddot.SetSize(nAxes,1);
	for(int i=0; i<nAxes; i++)
		yddot[i][0] = 2*(3*yr[i][0]/tr[i][0] - 2*ydot[i][0] - ydotf[i][0])/tr[i][0];

	return yddot;
}

// Build Phis
// Note   q  = pos pos pos vel vel vel
//        qd = pos pos pos vel vel vel acc acc acc
LEmatrix& PhiM(LEmatrix& q)
{
	static LEmatrix phiM("phiM");

	phiM.SetSize(5,1);
	phiM[0][0]=1;
	phiM[1][0]=q[0][0];
	phiM[2][0]=q[1][0];
	phiM[3][0]=q[2][0];
	phiM[4][0]=q[2][0]*q[2][0];  // r*r
	
	return phiM;
}
LEmatrix& PhiV(LEmatrix& q,LEmatrix& q_dot)
{
	static LEmatrix phiV("phiV");
	static LEmatrix extra("extra",2,1);

	//double theta=q[0][0];
	//double h=q[1][0];
	double r=q[2][0];
	double thetadot=q_dot[0][0];
	//double hdot=q_dot[1][0];
	double rdot=q_dot[2][0];

	extra[0][0] = r*rdot*thetadot;
	extra[1][0] = r*thetadot*thetadot;

	phiV.SetSize(1,1);
	phiV[0][0]=1;
	phiV.AppendRows(q);
	phiV.AppendRows(extra);
	
	return phiV;
}
LEmatrix& PhiG(LEmatrix& q)
{
	static LEmatrix phiG("phiG");

	phiG.SetSize(4,1);
	phiG[0][0]=1;
	phiG[1][0]=q[0][0];
	phiG[2][0]=q[1][0];
	phiG[3][0]=q[2][0];
	
	return phiG;
}
LEmatrix& SquareMat(LEmatrix& m)
{
	static LEmatrix r("r");

	int n=(int)sqrt(m.Nrows());
	if(n<1)
	{
		r.SetSize(1,1);
		r=0;
		return r;
	}

	r.SetSize(n,n);
	for(int i=0; i<n; i++)
		for(int j=0; j<n; j++)
			r[i][j]=m[i*n+j][0];
	return r;
}

void IPAController::Setup(void)
{
	// Simulation Parameters
	t0=0;
	tf=waypoint->get_tMove();
	tServo=0.05;

	int nAxes=hw->get_nAxes();

	// Initial Conditions
	q0.SetSize(nAxes,1);
	qdot0.SetSize(nAxes,1);
	q0=0;
	qdot0=0;
	
	x0=q0;
	x0.AppendRows(qdot0);

	// Desired Control Coefficients
	Kv=20*leIdentMat(nAxes);
	
	// Setup Ws
	phiM=PhiM(q0);
	phiV=PhiV(q0,qdot0);
	phiG=PhiG(q0);
	LM=phiM.Nrows();
	LV=phiV.Nrows();
	LG=phiG.Nrows();
	m=nAxes;
	WM.SetSize(m*m,LM);
	WV.SetSize(m*m,LV);
	WG.SetSize(m,LG);
	M.SetSize(nAxes,nAxes);
	Vm.SetSize(nAxes,nAxes);
	G.SetSize(nAxes,1);
	WM=0;
	WV=0;
	WG=0;
	printf("nAxes=%d LM=%d LV=%d LG=%d m=%d\n",nAxes,LM,LV,LG,m);

	// Adaptive Learning Rates
	FMscalar=0.05;
	FVscalar=0.05;
	FGscalar=20;
	FM=FMscalar*tServo*leIdentMat(WM.Nrows());
	FV=FVscalar*tServo*leIdentMat(WV.Nrows());
	FG=FGscalar*tServo*leIdentMat(WG.Nrows());

	// estimate of maximum rows for result and control
	int maxRows=(int)(tf*100);
	
	// Initial result matrix with row of initial conditions
	result.SetName("result");
	result.SetSize(maxRows,x0.Nrows()+1);
	result.SetSize(1,result.Ncols());
	result[0][0]=t0;
	for(int i=0; i<x0.Nrows(); i++)
		result[0][i+1]=x0[i][0];

	// Initial control effort matrix
	control.SetName("control");
	control.SetSize(maxRows,nAxes+1);
	control.SetSize(1,control.Ncols());

	// Internal Control Variables
	q.SetSize(nAxes,1);
	q_dot.SetSize(nAxes,1);
	qd.SetSize(nAxes,1);
	qd_dot.SetSize(nAxes,1);
	qd_dotdot.SetSize(nAxes,1);
	
	// Error integration variables
	e_dot.SetSize(nAxes,1);
	r.SetSize(nAxes,1);

	qd_dot=0;
}

void IPAController::RunRepetitiveMotion(void)
{
	bool fDiverged=false;
	int increaseEvery=20;
	double showEvery=0.2;
	int fileEvery=5;
	for(int pass=0; !fDiverged; pass++)
	{
		
		result.SetSize(1,x0.Nrows()+1);
		hw->set_t(t0);
		double showTime=t0;
		hw->set_x(x0);
		RunMotion(true,true);

		char filename[128];
		if(fDiverged || ((pass+1)%increaseEvery ==0) || (pass%fileEvery == 0))
		{
			// Save results
			sprintf(filename,"sim_%06d.csv",pass);
			result.Save(filename);

			sprintf(filename,"control_%06d.csv",pass);
			control.Save(filename);

			// Save NN weights
			sprintf(filename,"WM_%06d.csv",pass);
			WM.Save(filename);
			sprintf(filename,"WV_%06d.csv",pass);
			WV.Save(filename);
			sprintf(filename,"WG_%06d.csv",pass);
			WG.Save(filename);
		}

	}
	
}

bool IPAController::RunMotion(bool fAnimate,bool fTraining)
{
	hw->set_t(0);
	hw->set_x(x0);
	result.SetSize(1,x0.Nrows()+1);

	double showEvery=0.2;
	double showTime=0;


	bool fDiverged=false;
	while(hw->get_t()<tf)
	{
		// where are we?
		q=hw->get_q();
		q_dot=hw->get_qdot();
			
		// IPAC control law
		qd_dotdot=ComputeAcc(hw->get_t(),q,q_dot);

		// state errors
		e_dot=qd_dot-q_dot;

		// project next qd_dot
		qd_dot=q_dot+qd_dotdot*tServo;

		// filtered error
		r = e_dot;// + lam*e;

		// torque
		LEmatrix tau;
		if(0)//pass==0)
		{
			tau=Kv*r;
			hw->SetTau(tau);	// classical controller only
		}
		else
		{
			phiM=PhiM(q);
			phiV=PhiV(q,q_dot);
			phiG=PhiG(q);
			M=SquareMat(WM*phiM);
			Vm=SquareMat(WV*phiV);
			G=WG*phiG;

			tau=M*qd_dotdot + Vm*qd_dot + G;
			hw->SetTau(tau);

			if(fTraining)
			{
			// Weight update
			for(int i=0; i<WM.Nrows(); i++)
			{
				int k=i/nAxes;
				int l=i%nAxes;
				double mult=r[k][0]*qd_dotdot[l][0];
				for(int j=0; j<WM.Ncols(); j++)
					WM[i][j] += FM[i][i]*
						phiM[j][0]*mult;
			}
			for(i=0; i<WV.Nrows(); i++)
			{
				int k=i/nAxes;
				int l=i%nAxes;
				double mult=r[k][0]*q_dot[l][0];
				for(int j=0; j<WV.Ncols(); j++)
					WV[i][j] += FV[i][i]*
						phiV[j][0]*mult;
			}
			for(i=0; i<WG.Nrows(); i++)
			{
				for(int j=0; j<WG.Ncols(); j++)
					WG[i][j] += FG[i][i]*
						phiG[j][0]*r[i][0];
			}
			}
		}

		// Append control effort
		controlRecord.SetSize(1,1);
		controlRecord[0][0]=hw->get_t();
		controlRecord.AppendCols(leTranspose(tau));
		if(hw->get_t()==t0)
			control=controlRecord;
		else
			control.AppendRows(controlRecord);

		bool fDiverged=hw->Run(tServo,&result);
		if(fDiverged)
		{
			printf(" CONTROLLER DIVERGED");
			return true;
		}

		if(!fDiverged)
		{
			// animate
			if(fAnimate)
			{
				if(hw->get_t()>=showTime)
				{
					animator->Display(hw->get_x());
					showTime+=showEvery;
				}
			}
		}
	}
	return false;
}

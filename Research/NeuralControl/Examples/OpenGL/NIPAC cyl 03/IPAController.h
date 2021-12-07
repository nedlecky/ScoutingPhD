#if !defined(IPACONTROLLER_H)
#define IPACONTROLLER_H

#include "hardware.h"
#include "waypoint.h"
//#include "animator.h"
#include "LEmatrix.h"

class DrivingAnimator;
#if !defined(pAnimator)
typedef DrivingAnimator* pDrivingAnimator;
#endif

class IPAController
{
private:
	pHardware hw;
	pWaypointSchedule waypoint;
	pDrivingAnimator animator;
	int nAxes;

	LEmatrix Xd;
	LEmatrix phiM;
	LEmatrix phiG;
	LEmatrix phiV;
	LEmatrix WM;
	LEmatrix WV;
	LEmatrix WG;
	LEmatrix M;
	LEmatrix Vm;
	LEmatrix G;
	LEmatrix q0;
	LEmatrix qdot0;
	LEmatrix x0;
	LEmatrix Kv;
	int LM;
	int LV;
	int LG;
	int m;

	double FMscalar;
	double FVscalar;
	double FGscalar;
	LEmatrix FM;
	LEmatrix FV;
	LEmatrix FG;

	LEmatrix result;
	LEmatrix control;

	LEmatrix q;
	LEmatrix q_dot;
	LEmatrix qd;
	LEmatrix qd_dot;
	LEmatrix qd_dotdot;
	LEmatrix controlRecord;
	
	// Error integration variables
	LEmatrix e_dot;
	LEmatrix r;

	double t0;
	double tf;
	double tServo;
public:
	IPAController(pHardware hw0,pWaypointSchedule waypoint0);
	~IPAController();
	void SetAnimator(pDrivingAnimator anim) {animator=anim;}
	void Setup(void);
	LEmatrix& ComputeAcc(double t,LEmatrix& y,LEmatrix& ydot);
	bool RunMotion(bool fAnimate,bool fTraining);
	void RunRepetitiveMotion(void);
};

#endif
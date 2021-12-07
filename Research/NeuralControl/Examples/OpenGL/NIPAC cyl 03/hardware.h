#if !defined(HARDWARE_H)
#define HARDWARE_H

#include "LEmatrix.h"

class Hardware
{
protected:
	int nAxes;
	double t;
	double integration_t;
	double* axisMin;
	double* axisMax;

	// generic 
	LEmatrix stepResult;
	LEmatrix x;

	LEmatrix tau;
public:
	Hardware(int n);
	~Hardware();
	int get_nAxes(void) {return nAxes;}
	double get_t(void) {return t;}
	void set_t(double t0) {t=t0;}
	void set_x(LEmatrix& x0) {x=x0;}
	LEmatrix& get_x(void) {return x;}
	LEmatrix& get_q(void);
	LEmatrix& get_qdot(void);
	int SetTau(LEmatrix& tau_spec);

	virtual bool Run(double dt,LEmatrix* result=NULL)=0;
};
typedef Hardware* pHardware;


// 3-Link Cylindrical Robot System
void Cylindrical01System(double x[],double xdot[],void* params);
struct Cylindrical01Params
{
	pLEmatrix ptau;

	double m1,m2;
	double J;
	double g;
	LEmatrix gM;
	LEmatrix gVm;
	LEmatrix gG;
	LEmatrix gMinv;
	LEmatrix gN;
	LEmatrix gq_dot;
	LEmatrix gq_dotdot;
};

class Cylindrical01 : public Hardware
{
private:
	Cylindrical01Params p;

public:
	Cylindrical01();
	~Cylindrical01();
	void SetParameters(double new_m1,double new_m2,double new_J,double new_g=9.8);
	void System(double x[],double xdot[]);
	bool Run(double dt,LEmatrix* result=NULL);
};
typedef Cylindrical01* pCylindrical01;

#endif

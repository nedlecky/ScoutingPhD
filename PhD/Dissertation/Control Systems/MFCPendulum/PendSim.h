#if !defined PendSim_H
#define PendSim_H

struct Situation
{
	double theta;
	double omega;
	double t;
};

enum eInputTypes{eForce=1,ePower,eVoltage,eCurrent};
struct Action
{
	int dir;
	eInputTypes inputType;
	double dinput;
	double input;
	double dt;
};


class PendulumSimulator
{
private:
	double timeStep;
	int maxDepth,nScouts,initRand;
	double M;
	double B;
	double G;
	double L;
	eInputTypes inputType;
	double maxInput,minInput,inputSlew;
	int integrationsPerStep;

	double initialTheta,initialOmega;
	double finalTheta,finalOmega;
	double finalThetaTol,finalOmegaTol;

	// temps
	double MLLinv;
	double MGL;
	BOOL fRun;

	int nGC,nPA,nNS;

public:
	// save arrays
	int arraySize;
	int lastLen;
	double* trackT;
	double* trackTheta;
	double* trackOmega;
	double* trackInput;
	double* trackInputA1;
	double* trackInputA2;

public:
	PendulumSimulator();
	~PendulumSimulator();
	void ClearData(void);
	void SetArraySize(int n);
	void SetTimeStep(double x) {timeStep=x;}
	void SetMaxDepth(int x) {maxDepth=x;}
	void SetNScouts(int x) {nScouts=x;}
	void SetInitRand(int x) {initRand=x;}
	void SetM(double x) {M=x; SetConst();}
	void SetB(double x) {B=x; SetConst();}
	void SetG(double x) {G=x; SetConst();}
	void SetL(double x) {L=x; SetConst();}
	void SetInputType(eInputTypes x) {inputType=x;}
	void SetMaxInput(double x) {maxInput=x;}
	void SetMinInput(double x) {minInput=x;}
	void SetInputSlew(double x) {inputSlew=x;}
	void SetIPS(int x) {integrationsPerStep=x;}
	void SetInitial(double t,double o) {initialTheta=t; initialOmega=o;}
	void SetFinal(double t,double o) {finalTheta=t; finalOmega=o;}
	void SetTols(double t,double o) {finalThetaTol=t; finalOmegaTol=o;}
	int GetLastLen(void) {return lastLen;}
	int GetNPA(void) {return nPA;}
	int GetNGC(void) {return nGC;}
	int GetNNS(void) {return nNS;}

	void SetConst(void);
	void NextSituation(Situation& s,Action& a);
	void PickAction(Action& a);
	BOOL GoalCheck(Situation& s);
	void SaveStatus(int i,Situation& s,Action& a);
	int Scout(int maxLen,int fSave);
	int Solve(void);
	void AbortScouting(void);
};



#endif

#if !defined(ANIMATOR_H)
#define ANIMATOR_H

#include <glut.h>
#include "LEmatrix.h"
//#include <stdlib.h>

enum eTimerMessages {eSimStart,eSimContinue,eSimStop};

class IPAController;
typedef IPAController* pIPAController;

class DrivingAnimator
{
protected:
	pIPAController controller;
	int pass;
	int increaseEvery;
	double showEvery;
	int animateEvery;
	bool fSimulating;
	LEmatrix showPos;
	bool fTraining;
public:
	DrivingAnimator(pIPAController control);
	~DrivingAnimator();

	virtual int Init(int argc,char* argv[],bool fSolidModeling)=0;
	virtual void Display(void)=0;
	virtual void Display(LEmatrix& show)=0;
	virtual void Go(void)=0;
};

class GlutDriver : public DrivingAnimator
{
private:

	GLfloat ambientLight[4];
	GLfloat diffuseLight[4];
	GLfloat whiteLight[4];
	GLfloat specularLight[4];
	GLfloat specularity[4];
	GLfloat lightPos[4];
	bool fWireFrame;

	double baseX;
	double baseY;
	double baseZ;
	double towerX;
	double towerY;
	double towerZ;
	double towerSpacing;
	double capX;
	double capY;
	double capZ;
	double tblockX;
	double tblockY;
	double tblockZ;
	double armX;
	double armY;
	double armZ;
	double toolX;
	double toolY;
	double toolZ;
	double zOffset;
	double rOffset;

	GLfloat eyeX,eyeY,eyeZ;
	GLfloat lookatX,lookatY,lookatZ;

public:
	GlutDriver(pIPAController control);
	~GlutDriver();
	int Init(int argc,char* argv[],bool fSolidModeling);
	void Go(void);

	void SetupRC(void);
	void Display(LEmatrix& show);
	void Display(void);
	void ReshapeFunc(int w,int h);
	void KeyboardFunc(unsigned char key,int x,int y);
	void SpecialFunc(int key, int x, int y);
	void TimerFunc(int n);
};

extern GlutDriver *globalGlut;
void GlutDisplayFunc(void);
void GlutReshapeFunc(int w,int h);
void GlutKeyboardFunc(unsigned char key,int x,int y);
void GlutSpecialFunc(int key, int x, int y);
void GlutTimerFunc(int n);

#endif

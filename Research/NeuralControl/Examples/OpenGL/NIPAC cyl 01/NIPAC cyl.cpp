// NIPAC Controller with full SystemID
//	Cylindrical robot
//  5-10-00
//  Prof. Ned Lecky

#include "stdafx.h"
#include <LEsimulate.h>
#include <math.h>
#include <float.h>
#include <conio.h>
double pi=3.14159;

class RobotAnimation
{
public:
	RobotAnimation();
	~RobotAnimation();
};

// 3-Link Cylindrical Robot System
struct Cylindrical01Params
{
	LEmatrix tau;

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
class Cylindrical01
{
private:
	int nAxes;
	double t;
	double integration_t;
	double* axisMin;
	double* axisMax;

	// generic 
	LEmatrix stepResult;
	LEmatrix x;

	Cylindrical01Params p;

public:
	Cylindrical01();
	~Cylindrical01();
	void SetParameters(double new_m1,double new_m2,double new_J,double new_g=9.8);
	void System(double x[],double xdot[]);
	int SetTau(LEmatrix& tau_spec);
	int SetX(LEmatrix& x_spec);
	LEmatrix& GetX(void) {return x;}
	LEmatrix& GetQ(void);
	LEmatrix& GetQdot(void);
	double Time(void) {return t;}
	void Time(double t_spec) {t=t_spec;}
	bool Run(double dt,LEmatrix* result=NULL);
};

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
	p->gq_dotdot=leInvert(p->gM)*(p->tau - p->gVm*p->gq_dot - p->gG);

	// System Equations
	xdot[1] = x[4];
	xdot[2] = x[5];
	xdot[3] = x[6];
	xdot[4] = p->gq_dotdot[0][0];
	xdot[5] = p->gq_dotdot[1][0];
	xdot[6] = p->gq_dotdot[2][0];
}

Cylindrical01::Cylindrical01()
{
	nAxes=3;

	axisMin=new double[nAxes];
	axisMax=new double[nAxes];

	axisMin[0]=-.2;
	axisMin[1]=-0.1;
	axisMin[2]=-0.1;

	axisMax[0]=2.1*pi;
	axisMax[1]=3;
	axisMax[2]=2;

	t=0;
	integration_t=0.05;
}
Cylindrical01::~Cylindrical01()
{
	if(axisMin) delete axisMin;
	if(axisMax) delete axisMax;
}

int Cylindrical01::SetTau(LEmatrix& tau_spec)
{
	p.tau=tau_spec;
	return 0;
}

int Cylindrical01::SetX(LEmatrix& x_spec)
{
	x=x_spec;
	return 0;
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
	p.tau.SetName("tau");
	p.tau.SetSize(3,1);

	p.gM=0;
	p.gM[1][1] = p.m1+p.m2;
	p.gM[2][2] = p.m2;

	p.gG=0;
	p.gG[1][0] = (p.m1+p.m2)*p.g;

	p.gVm=0;
}

LEmatrix& Cylindrical01::GetQ(void)
{
	static LEmatrix q("q");

	q.SetSize(nAxes,1);
	for(int i=0; i<nAxes; i++)
		q[i][0]=x[i][0];

	return q;
}

LEmatrix& Cylindrical01::GetQdot(void)
{
	static LEmatrix q_dot("q_dot");

	q_dot.SetSize(nAxes,1);
	for(int i=0; i<nAxes; i++)
		q_dot[i][0]=x[i+nAxes][0];

	return q_dot;
}

bool Cylindrical01::Run(double dt,LEmatrix* result)
{
	bool fDiverged=false;
//	printf("t is %.4lf\n",t);
	
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

void RunSimulation(void);


// BEGIN OPENGL CYLBOT SIMULATION
#include <glut.h>
#include <stdlib.h>

int step = 0;

GLfloat ambientLight[]={.2,.2,.2,1};
GLfloat diffuseLight[]={.4,.4,.4,1};
GLfloat specularLight[]={.6,.6,.6,1};
GLfloat specularity[]={1,1,1,1};
GLfloat lightPos[]={1,1,1,1};
void SetupRC(void) 
{
	glEnable(GL_DEPTH_TEST);
	glFrontFace(GL_CCW);
	glEnable(GL_CULL_FACE);

	glShadeModel(GL_SMOOTH);

	glEnable(GL_LIGHTING);
	
	//glLightModelfv(GL_LIGHT_MODEL_AMBIENT,whiteLight);

	glLightfv(GL_LIGHT0,GL_AMBIENT,ambientLight);
	glLightfv(GL_LIGHT0,GL_DIFFUSE,diffuseLight);
	glLightfv(GL_LIGHT0,GL_SPECULAR,specularLight);
	glLightfv(GL_LIGHT0,GL_POSITION,lightPos);
	glEnable(GL_LIGHT0);


	glEnable(GL_COLOR_MATERIAL);
	glColorMaterial(GL_FRONT,GL_AMBIENT_AND_DIFFUSE);
	glMaterialfv(GL_FRONT,GL_SPECULAR,specularity);
	glMateriali(GL_FRONT,GL_SHININESS,128);


	glClearColor(0,0,0,1);
}

double baseX=1.2;
double baseY=1.2;
double baseZ=0.8;
double towerX=0.125;
double towerY=0.125;
double towerZ=3.6;
double towerSpacing=0.5;
double capX=0.3;
double capY=towerSpacing+0.3;
double capZ=0.125;
double tblockX=0.35;
double tblockY=0.8;
double tblockZ=0.5;
double armX=3;
double armY=0.15;
double armZ=0.15;
double toolX=0.5;
double toolY=0.4;
double toolZ=0.4;
double zOffset=0.1;
double rOffset=0.1;

LEmatrix showPos("showPos",3,1);
GLfloat eyeX,eyeY,eyeZ;
GLfloat lookatX,lookatY,lookatZ;
void DisplayFunc(void)
{
	GLfloat theta,height,radxtnd;
	theta=showPos[0][0]*180/pi;
	height=showPos[1][0];
	radxtnd=showPos[2][0];
	
	glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// align axes and set viewing position
	glPushMatrix();
	gluLookAt(eyeX,eyeY,eyeZ,
		lookatX,lookatY,lookatZ,
		0,0,1);
//GLfloat lightPos[4];
//lightPos[0]=eyeX;
//lightPos[0]=eyeY;
//lightPos[0]=eyeZ;
//lightPos[3]=1;
//glLightfv(GL_LIGHT0,GL_POSITION,lightPos);

	// lay7 down floor
	glPushMatrix();
	glColor3f(.5,.5,.5);
	glScalef (5,5,0.01f);
	glutSolidCube (1);
	glPopMatrix();
	
	// put on the base
	glPushMatrix();
	glTranslatef (0,0,baseZ/2);
	glScalef (baseX,baseY,baseZ);
	glColor3b(100,0,0);
	glutSolidCube (1);
	glPopMatrix();

	// raise the two towers
	glPushMatrix();
	glColor3b(0,100,0);
	glRotatef (theta,0,0,1);
	glTranslatef (0,-towerSpacing/2,baseZ+towerZ/2);
	glScalef (towerX,towerY,towerZ);
	glutSolidCube (1.0);
	glTranslatef (0,towerSpacing/towerY,0);
	glutSolidCube (1.0);
	glPopMatrix();

	// put on the cap
	glPushMatrix();
	glRotatef (theta,0,0,1);
	glTranslatef (0,0,baseZ+towerZ+capZ/2);
	glScalef (capX,capY,capZ);
	glutSolidCube (1);
	glPopMatrix();

	// put up the translational joint 
	glPushMatrix();
	glColor3b(0,0,100);
	glRotatef(theta,0,0,1);
	glTranslatef(0,0,zOffset+baseZ+height+tblockZ/2);
	glScalef(tblockX,tblockY,tblockZ);
	glutSolidCube(1);
	glPopMatrix();

	// put up the arm
	glPushMatrix();
	glColor3b(40,40,0);
	glRotatef (theta,0,0,1);
	glTranslatef (rOffset+radxtnd-armX/2+tblockX/2,0,zOffset+baseZ+height+tblockZ/2);
	glRotatef (45,1,0,0);
	glScalef (armX,armY,armZ);
	glutSolidCube (1.0);
	glPopMatrix();

	// put up the tool holder
	glPushMatrix();
	glColor3f(1,1,0);
	glRotatef (theta,0,0,1);
	glTranslatef (rOffset+radxtnd+tblockX/2+toolX/2,0,zOffset+baseZ+height+tblockZ/2);
	glScalef (toolX,toolY,toolZ);
	glutSolidCube(1.0);
//glRotatef(90,1,0,0);
//glutSolidSphere(1,20,20);
	glPopMatrix();

	glPopMatrix();

	glutSwapBuffers();
}

void ReshapeFunc(int w,int h)
{
   glViewport (0, 0, (GLsizei) w, (GLsizei) h); 
   glMatrixMode (GL_PROJECTION);
   glLoadIdentity ();
   gluPerspective(50, (GLfloat) w/(GLfloat) h, 1.0, 2000.0);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
   glTranslatef (0.0, 0.0, -5.0);
}

void KeyboardFunc(unsigned char key,int x,int y)
{
	switch (key) {
/*
      case 't':		//true time forward animation (calculates
					//neccesary fps
		 step = getPosIndex(getTimePassed());
		 if (step < pos.Nrows()) 
		 {	 
			theta = 180*pos[step][1]/pi;
			height = pos[step][2];
			radxtnd = pos[step][3];  
			glutPostRedisplay();
		 }
		 break;
      case 'z':
		 step=0;
		 while(step<pos.Nrows()) 
		 {	 
			theta = 180*pos[step][1]/pi;
			height = pos[step][2];
			radxtnd = pos[step][3];  
			display();
			//glutPostRedisplay();
			step++;
		 }
		 break;
	 case 'r':
		firsttime = 0;   //resets true time animation
		 if (step > 0) 
		 {	 
			theta = 180*pos[--step][1]/pi; 
			height =  pos[step][2];
			radxtnd = pos[step][3];
			glutPostRedisplay();
		 }
	   break;
	case 'f':
		firsttime = 0;
		 if (step < pos.Nrows()-1) // -1 needed to let t go again
		 {	 
			theta = 180*pos[step][1]/pi; 
			height =  pos[step][2];
			radxtnd = pos[step++][3];
			glutPostRedisplay();
		 }
	   break;
*/	
	case 'u':
		diffuseLight[0]+=0.1;
		diffuseLight[1]+=0.1;
		diffuseLight[2]+=0.1;
		glLightfv(GL_LIGHT0,GL_DIFFUSE,diffuseLight);
		glutPostRedisplay();
		break;
	case 'd':
		diffuseLight[0]-=0.1;
		diffuseLight[1]-=0.1;
		diffuseLight[2]-=0.1;
		glLightfv(GL_LIGHT0,GL_DIFFUSE,diffuseLight);
		glutPostRedisplay();
		break;
	case 'U':
		lightPos[3]+=0.1;
		glLightfv(GL_LIGHT0,GL_POSITION,lightPos);
		glutPostRedisplay();
		break;
	case 'D':
		lightPos[3]-=0.1;
		glLightfv(GL_LIGHT0,GL_POSITION,lightPos);
		glutPostRedisplay();
		break;
	case 'r':
		RunSimulation();
		break;
	case 27:
		exit(1);
	break;
	
	default:
         break;
   }
}

void SpecialFunc(int key, int x, int y)
{
	if (key==GLUT_KEY_LEFT)
	{
		eyeX-=0.1f;
		glutPostRedisplay();
	}

	if (key==GLUT_KEY_RIGHT)
	{
		eyeX+=0.1f;
		glutPostRedisplay();
	}
	if (key==GLUT_KEY_UP)
	{
		eyeZ+=0.1f;
		glutPostRedisplay();
	}

	if (key==GLUT_KEY_DOWN)
	{
		eyeZ-=0.1f;
		glutPostRedisplay();
	}

}

void TimerFunc(int n)
{
	printf("timer %d\n",n);
}


int OpenGLInit(int argc, char* argv[])
{
	eyeX=4;
	eyeY=4;
	eyeZ=4;
	lookatX=0;
	lookatY=0;
	lookatZ=0;
	showPos.SetSize(3,1);
	showPos=0;

	glutInit(&argc, argv);
	glutInitDisplayMode (GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
	glutInitWindowSize (500, 500); 
	glutInitWindowPosition (100, 100);
	glutCreateWindow (argv[0]);
	SetupRC ();
	glutDisplayFunc(DisplayFunc); 
	glutReshapeFunc(ReshapeFunc);
	glutKeyboardFunc(KeyboardFunc);
	glutSpecialFunc(SpecialFunc);
	glutTimerFunc(1000,TimerFunc,1);
	glutTimerFunc(800,TimerFunc,2);
	glutMainLoop();

	return 0;
}


// END OPENGL CYLBOT SIMULATION

const int nAxes=3;
double tMove=10;
double posFinal[nAxes];
double velFinal[nAxes];

LEmatrix& Destination(double t)
{
	static LEmatrix dest("dest",nAxes,3);

	double tGoOn=tMove/100;

	// first goal
	if(t<tMove-tGoOn)
	{
		dest[0][0]=tMove;
		dest[1][0]=tMove;
		dest[2][0]=tMove;
		dest[0][1]=posFinal[0];
		dest[1][1]=posFinal[1];
		dest[2][1]=posFinal[2];
		dest[0][2]=velFinal[0];
		dest[1][2]=velFinal[1];
		dest[2][2]=velFinal[2];

		return dest;
	}

	// second goal: return to 0
	if(t<tMove*2-tGoOn)
	{
		dest=0;
		dest[0][0]=tMove*2;
		dest[1][0]=tMove*2;
		dest[2][0]=tMove*2;
		return dest;
	}

	// implement hold state
	double tHold=tMove/50;
	dest=0;
	dest[0][0]=t+tHold;
	dest[1][0]=t+tHold;
	dest[2][0]=t+tHold;
	return dest;
}


// IPAC Control Law
LEmatrix& ComputeAcc(double t,LEmatrix& y,LEmatrix& ydot)
{
	static LEmatrix dest("dest");
	static LEmatrix tf("tf");
	static LEmatrix yf("yf");
	static LEmatrix ydotf("ydotf");
	static LEmatrix tr("tr");
	static LEmatrix yr("yr");
	static LEmatrix yddot("yddot");
	
	dest=Destination(t);
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
LEmatrix& PhiV(LEmatrix& q)
{
	static LEmatrix phiV("phiV");
	static LEmatrix extra("extra",2,1);

	//double theta=q[0][0];
	//double h=q[1][0];
	double r=q[2][0];
	double thetadot=q[3][0];
	//double hdot=x[4][0];
	double rdot=q[5][0];

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

int main(int argc, char* argv[])
{
	printf("NIPAC Simulator Cylindrical Robot\n");

	OpenGLInit(argc,argv);

	return 0;
}

void RunSimulation(void)
{
	// Robot Parameters
	Cylindrical01 robot;
	robot.SetParameters(2,3,4);
	
	// Goal parameters
	tMove=10.0;
	posFinal[0]=2*pi;  //( radians!)
	posFinal[1]=2.8;
	posFinal[2]=1.8;
	velFinal[0]=0;
	velFinal[1]=0;
	velFinal[2]=0;

	// Simulation Parameters
	double t0=0;			// start time
	double tfMax=tMove*2.1;	// final time

	// Initial Conditions
	LEmatrix x0("x0",nAxes*2,1);
	x0=0;

	// Desired Control Coefficients
	LEmatrix Kv("Kv");
	Kv=20*leIdentMat(nAxes);
	
	// Setup Ws
	LEmatrix Xd("Xd");
	LEmatrix phiM("phiM");
	LEmatrix phiG("phiG");
	LEmatrix phiV("phiV");
	phiM=PhiM(x0);
	phiV=PhiV(x0);
	phiG=PhiG(x0);
	int LM=phiM.Nrows();
	int LV=phiV.Nrows();
	int LG=phiG.Nrows();
	int m=nAxes;
	LEmatrix WM("WM",m*m,LM);
	LEmatrix WV("WV",m*m,LV);
	LEmatrix WG("WG",m,LG);
	LEmatrix M("M",nAxes,nAxes);
	LEmatrix Vm("Vm",nAxes,nAxes);
	LEmatrix G("G",nAxes,1);
	WM=0;
	WV=0;
	WG=0;
	printf("nAxes=%d LM=%d LV=%d LG=%d m=%d\n",nAxes,LM,LV,LG,m);

	// Adaptive Learning Rates
	double FMscalar=0.05;
	double FVscalar=0.05;
	double FGscalar=20;
	LEmatrix FM("FM");
	LEmatrix FV("FV");
	LEmatrix FG("FG");

	// estimate of maximum rows for result and control
	int maxRows=tfMax*100;
	
	// Initial result matrix with row of initial conditions
	LEmatrix result("result",maxRows,x0.Nrows()+1);
	result.SetSize(1,result.Ncols());
	result[0][0]=t0;
	for(int i=0; i<x0.Nrows(); i++)
		result[0][i+1]=x0[i][0];

	// Initial control effort matrix
	LEmatrix control("control",maxRows,nAxes+1);
	control.SetSize(1,control.Ncols());

	// Internal Control Variables
	LEmatrix q("q",nAxes,1);
	LEmatrix q_dot("q_dot",nAxes,1);
	LEmatrix qd("qd",nAxes,1);
	LEmatrix qd_dot("qd_dot",nAxes,1);
	LEmatrix qd_dotdot("qd_dotdot",nAxes,1);
	LEmatrix controlRecord;
	
	// Error integration variables
	LEmatrix e_dot("e_dot",nAxes,1);
	LEmatrix r("r",nAxes,1);

	qd_dot=0;

	// Multiple rehearsal driver
	bool fDiverged=false;
	int increaseEvery=20;
	double tf;
	double updateDt;
	double showEvery=0.1;
	int fileEvery=50;
	for(int pass=0; !fDiverged; pass++)
	{
		if(pass%increaseEvery == 0)
		{
			tMove*=0.8;
			tf=tMove*2.1;
			updateDt=tMove/150;
			if(1/updateDt>200) break;
		}

		printf("Starting pass %06d (t=%0.3lf, %.1lf Hz)   ",pass,tMove,1/updateDt);
		
		// set learning rates
		FM=FMscalar*updateDt*leIdentMat(WM.Nrows());
		FV=FVscalar*updateDt*leIdentMat(WV.Nrows());
		FG=FGscalar*updateDt*leIdentMat(WG.Nrows());
		
		result.SetSize(1,x0.Nrows()+1);
		robot.Time(t0);
		double showTime=t0;
		robot.SetX(x0);
		while(!fDiverged && robot.Time()<tf)
		{
			// where are we?
			q=robot.GetQ();
			q_dot=robot.GetQdot();
			
			// IPAC control law
			qd_dotdot=ComputeAcc(robot.Time(),q,q_dot);

			// state errors
			e_dot=qd_dot-q_dot;

			// project next qd_dot
			qd_dot=q_dot+qd_dotdot*updateDt;

			// filtered error
			r = e_dot;// + lam*e;

			// torque
			LEmatrix tau;
			if(0)//pass==0)
			{
				tau=Kv*r;
				robot.SetTau(tau);	// classical controller only
			}
			else
			{
				// one layer multi-NN controller
				LEmatrix x;
				x=robot.GetX();

				phiM=PhiM(x);
				phiV=PhiV(x);
				phiG=PhiG(x);
				M=SquareMat(WM*phiM);
				Vm=SquareMat(WV*phiV);
				G=WG*phiG;

				tau=M*qd_dotdot + Vm*qd_dot + G;
				robot.SetTau(tau);

				// Weight update
				for(i=0; i<WM.Nrows(); i++)
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

			// Append control effort
			controlRecord.SetSize(1,1);
			controlRecord[0][0]=robot.Time();
			controlRecord.AppendCols(leTranspose(tau));
			if(robot.Time()==t0)
				control=controlRecord;
			else
				control.AppendRows(controlRecord);

			fDiverged=robot.Run(updateDt,&result);
			if(fDiverged) printf(" CONTROLLER DIVERGED");

			if(!fDiverged)
			{
				// animate
				if(pass<5 ||((pass+1)%increaseEvery == 0))
				{
					if(robot.Time()>=showTime)
					{
						showPos=robot.GetX();
						DisplayFunc();
						showTime+=showEvery;
					}
				}
			}
		}
		printf("\n");

		char filename[128];
		if(fDiverged || ((pass+1)%increaseEvery ==0) || pass%fileEvery == 0)
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

		// Crude UI for live updates
		if(kbhit())
		{
			char c=getch();

			switch(c)
			{
			case 'x':
				return;
			case 'm':
				M.Print(3);
				Vm.Print(3);
				G.Print(3);
				break;
			case 'a':
//				gM.Print(3);
//				gVm.Print(3);
//				gG.Print(3);
				break;
			case '-':
				Kv = Kv*0.9;
				Kv.Print();
				break;
			case '+':
				Kv = Kv*1.1;
				Kv.Print();
				break;
			}
		}

	}
}



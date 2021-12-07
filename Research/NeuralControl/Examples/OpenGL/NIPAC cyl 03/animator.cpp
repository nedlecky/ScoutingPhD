#include "stdafx.h"
#include "const.h"
#include "animator.h"
#include "IPAController.h"
#include <stdlib.h>

GlutDriver *globalGlut;
void GlutDisplayFunc(void)
{
	globalGlut->Display();
}
void GlutReshapeFunc(int w,int h)
{
	globalGlut->ReshapeFunc(w,h);
}
void GlutKeyboardFunc(unsigned char key,int x,int y)
{
	globalGlut->KeyboardFunc(key,x,y);
}
void GlutSpecialFunc(int key, int x, int y)
{
	globalGlut->SpecialFunc(key,x,y);
}
void GlutTimerFunc(int n)
{
	globalGlut->TimerFunc(n);
}

DrivingAnimator::DrivingAnimator(pIPAController control)
{
	fTraining=false;
	controller=control;
	pass=0;
	increaseEvery=20;
	showEvery=0.2;
	animateEvery=20;
	fSimulating=false;
}
DrivingAnimator::~DrivingAnimator()
{
}


GlutDriver::GlutDriver(pIPAController control) : DrivingAnimator(control)
{
	fSimulating=false;

	ambientLight[0]=0.2f;
	ambientLight[1]=0.2f;
	ambientLight[2]=0.2f;
	ambientLight[3]=1.0f;

	diffuseLight[0]=0.4f;
	diffuseLight[1]=0.4f;
	diffuseLight[2]=0.4f;
	diffuseLight[3]=1.0f;

	whiteLight[0]=0.8f;
	whiteLight[1]=0.8f;
	whiteLight[2]=0.8f;
	whiteLight[3]=1.0f;

	specularLight[0]=0.6f;
	specularLight[1]=0.6f;
	specularLight[2]=0.6f;
	specularLight[3]=1.0f;

	lightPos[0]=1.0f;
	lightPos[1]=1.0f;
	lightPos[2]=1.0f;
	lightPos[3]=1.0f;

	specularity[0]=1.0f;
	specularity[1]=1.0f;
	specularity[2]=1.0f;
	specularity[3]=1.0f;

	fWireFrame=true;

	baseX=1.2;
	baseY=1.2;
	baseZ=0.8;
	towerX=0.125;
	towerY=0.125;
	towerZ=3.6;
	towerSpacing=0.5;
	capX=0.3;
	capY=towerSpacing+0.3;
	capZ=0.125;
	tblockX=0.35;
	tblockY=0.8;
	tblockZ=0.5;
	armX=3;
	armY=0.15;
	armZ=0.15;
	toolX=0.5;
	toolY=0.4;
	toolZ=0.4;
	zOffset=0.1;
	rOffset=0.1;

	globalGlut=this;
}

GlutDriver::~GlutDriver()
{
}

void GlutDriver::SetupRC(void) 
{
	bool fSolidModeling=!fWireFrame;

	if(fSolidModeling)
	{
		glEnable(GL_DEPTH_TEST);
		glFrontFace(GL_CCW);
		glEnable(GL_CULL_FACE);
		glShadeModel(GL_SMOOTH);
	}

	glEnable(GL_LIGHTING);
	
	if(fSolidModeling)
	{
		glLightfv(GL_LIGHT0,GL_AMBIENT,ambientLight);
		glLightfv(GL_LIGHT0,GL_DIFFUSE,diffuseLight);
		glLightfv(GL_LIGHT0,GL_SPECULAR,specularLight);
		glLightfv(GL_LIGHT0,GL_POSITION,lightPos);
		glEnable(GL_LIGHT0);

		glEnable(GL_COLOR_MATERIAL);
		glColorMaterial(GL_FRONT,GL_AMBIENT_AND_DIFFUSE);
		glMaterialfv(GL_FRONT,GL_SPECULAR,specularity);
		glMateriali(GL_FRONT,GL_SHININESS,128);
		fWireFrame=false;
	}
	else
	{
		glLightModelfv(GL_LIGHT_MODEL_AMBIENT,whiteLight);
		glEnable(GL_COLOR_MATERIAL);
		glColorMaterial(GL_FRONT,GL_AMBIENT);
		fWireFrame=true;
	}

	glClearColor(0,0,0,1);
}

void GlutDriver::Display(LEmatrix& show)
{
	showPos=show;
	Display();
}

void GlutDriver::Display(void)
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

	// lay7 down floor
	glPushMatrix();
	glColor3f(.5,.5,.5);
	glScalef (5,5,0.01f);
	if(fWireFrame)
		glutWireCube(1);
	else
		glutSolidCube(1);
	glPopMatrix();
	
	// put on the base
	glPushMatrix();
	glTranslatef (0,0,baseZ/2);
	glScalef (baseX,baseY,baseZ);
	glColor3b(100,0,0);
	if(fWireFrame)
		glutWireCube(1);
	else
		glutSolidCube(1);
	glPopMatrix();

	// raise the two towers
	glPushMatrix();
	glColor3b(0,100,0);
	glRotatef (theta,0,0,1);
	glTranslatef (0,-towerSpacing/2,baseZ+towerZ/2);
	glScalef (towerX,towerY,towerZ);
	if(fWireFrame)
		glutWireCube(1);
	else
		glutSolidCube(1);
	glTranslatef (0,towerSpacing/towerY,0);
	if(fWireFrame)
		glutWireCube(1);
	else
		glutSolidCube(1);
	glPopMatrix();

	// put on the cap
	glPushMatrix();
	glRotatef (theta,0,0,1);
	glTranslatef (0,0,baseZ+towerZ+capZ/2);
	glScalef (capX,capY,capZ);
	if(fWireFrame)
		glutWireCube(1);
	else
		glutSolidCube(1);
	glPopMatrix();

	// put up the translational joint 
	glPushMatrix();
	glColor3b(0,0,100);
	glRotatef(theta,0,0,1);
	glTranslatef(0,0,zOffset+baseZ+height+tblockZ/2);
	glScalef(tblockX,tblockY,tblockZ);
	if(fWireFrame)
		glutWireCube(1);
	else
		glutSolidCube(1);
	glPopMatrix();

	// put up the arm
	glPushMatrix();
	glColor3b(40,40,0);
	glRotatef (theta,0,0,1);
	glTranslatef (rOffset+radxtnd-armX/2+tblockX/2,0,zOffset+baseZ+height+tblockZ/2);
	glRotatef (45,1,0,0);
	glScalef (armX,armY,armZ);
	if(fWireFrame)
		glutWireCube(1);
	else
		glutSolidCube(1);
	glPopMatrix();

	// put up the tool holder
	glPushMatrix();
	glColor3f(1,1,0);
	glRotatef (theta,0,0,1);
	glTranslatef (rOffset+radxtnd+tblockX/2+toolX/2,0,zOffset+baseZ+height+tblockZ/2);
	glScalef (toolX,toolY,toolZ);
	if(fWireFrame)
		glutWireCube(1);
	else
		glutSolidCube(1);
	glPopMatrix();

	glPopMatrix();

	glutSwapBuffers();
}

void GlutDriver::ReshapeFunc(int w,int h)
{
   glViewport(0, 0, (GLsizei) w, (GLsizei) h); 
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   gluPerspective(50,(GLfloat)w/(GLfloat)h,1.0,2000.0);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
   glTranslatef (0.0,0.0,-5.0);
}

void GlutDriver::KeyboardFunc(unsigned char key,int x,int y)
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
		diffuseLight[0]+=0.1f;
		diffuseLight[1]+=0.1f;
		diffuseLight[2]+=0.1f;
		glLightfv(GL_LIGHT0,GL_DIFFUSE,diffuseLight);
		glutPostRedisplay();
		break;
	case 'd':
		diffuseLight[0]-=0.1f;
		diffuseLight[1]-=0.1f;
		diffuseLight[2]-=0.1f;
		glLightfv(GL_LIGHT0,GL_DIFFUSE,diffuseLight);
		glutPostRedisplay();
		break;
	case 'U':
		lightPos[3]+=0.1f;
		glLightfv(GL_LIGHT0,GL_POSITION,lightPos);
		glutPostRedisplay();
		break;
	case 'D':
		lightPos[3]-=0.1f;
		glLightfv(GL_LIGHT0,GL_POSITION,lightPos);
		glutPostRedisplay();
		break;
	case 'r':
		//RunSimulation();
		break;
	case 'g':
		glutTimerFunc(1,GlutTimerFunc,eSimStart);
		break;
	case 't':
		fTraining=!fTraining;
		printf("Training is %s\n",fTraining?"ON":"OFF");
		break;
	case 27:
		glutTimerFunc(0,GlutTimerFunc,eSimStop);
		break;
	case 'x':
		exit(1);
	break;
	
	default:
         break;
   }
}

void GlutDriver::SpecialFunc(int key, int x, int y)
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

void GlutDriver::TimerFunc(int n)
{
	switch(n)
	{
	case eSimStart:
		if(fSimulating) break;
		
		printf("Sim Start\n");
		fSimulating=true;
		controller->Setup();
		pass=0;
		glutTimerFunc(0,GlutTimerFunc,eSimContinue);
		break;
	case eSimContinue:
		if(!fSimulating) break;

/*		if(pass%increaseEvery == 0)
		{
			if(pass>0) tMove*=0.8;
			tf=tMove;
			updateDt=tMove/400;
			if(1/updateDt>200) break;
		}
*/
//		printf("Starting pass %06d (t=%0.3lf, %.1lf Hz)   ",pass,tMove,1/updateDt);
		pass++;
		printf("Starting pass %06d\n",pass);
		
		// set learning rates
		//FM=FMscalar*updateDt*leIdentMat(WM.Nrows());
		//FV=FVscalar*updateDt*leIdentMat(WV.Nrows());
		//FG=FGscalar*updateDt*leIdentMat(WG.Nrows());
		bool fAnimate;
		if(pass<5 || pass%animateEvery==0)
			fAnimate=true;
		else fAnimate=false;
		
		controller->RunMotion(fAnimate,fTraining);
		glutTimerFunc(1,GlutTimerFunc,eSimContinue);
		break;
	case eSimStop:
		if(!fSimulating) break;

		printf("Sim Stop\n");
		fSimulating=false;
		break;
	}
}

int GlutDriver::Init(int argc,char* argv[],bool fSolidModeling)
{
	fWireFrame=!fSolidModeling;

	eyeX=4;
	eyeY=4;
	eyeZ=4;
	lookatX=0;
	lookatY=0;
	lookatZ=0;
	showPos.SetSize(3,1);
	showPos=0;

	glutInit(&argc, argv);
	
	if(fSolidModeling)
		glutInitDisplayMode (GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
	else
		glutInitDisplayMode (GLUT_DOUBLE | GLUT_RGB);
	
	glutInitWindowSize (500, 500); 
	glutInitWindowPosition (100, 100);
	glutCreateWindow (argv[0]);
	
	SetupRC();
	
	glutDisplayFunc(GlutDisplayFunc); 
	glutReshapeFunc(GlutReshapeFunc);
	glutKeyboardFunc(GlutKeyboardFunc);
	glutSpecialFunc(GlutSpecialFunc);

	return 0;
}

void GlutDriver::Go(void)
{
	glutMainLoop();
}

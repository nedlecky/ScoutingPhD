/*******************************************************
CYLINDRICAL ROBOT ANIMATION PROGRAM      


VERSION:		1.0

PROGRAMMER:		Jake Galbreath

RELEASE DATE:	May 04, 2000


USE: 
loads time and position data from the first four
columns of a LEmatrix stored in a comma delimited file.
If the name of the file is not passed as a command line 
parameter, the opening file is hardwired to sim_result.csv,
where sim_result.csv must be in the same directory as the 
executable.   
  
For the current version, the robot model uses maximum values of
8 for the arm elevation and extension.  The next revision to
this program should query max position values and possibly
origin values.
   
INSTRUCTIONS:
-Press and hold 't' to run through the animation in true time.
-Press 'f' to step forward through each frame of the animation.
-Press 'r' to step backwards through each frame of the animation.
-Press the left key to rotate the viewing angle to the left.
-Press the right key to rotate the viewing angle to the right.
-Press ESC to exit.\n");

For help with installing OPENGL dlls and lib files, see the
accompanying file setup.txt.

********************************************************/


//Adapted from SGI example -> 
/*
 * Copyright (c) 1993-1997, Silicon Graphics, Inc.
 */


  
#include <stdlib.h>
#include "stdafx.h"
#include "..\util\glut.h"
#include "..\util\LEmatrix.h"
#include <conio.h>
#include "timing.h"

//***************************
double pi=3.14159;
int step = 0;
static GLfloat theta = 0, height = 0, radxtnd = 0;

GLfloat camera_plane_encircle,camera_plane_elevation;
LEmatrix pos;
DWORD currenttime, firsttime;


void init(void) 
{
   glClearColor (0.0, 0.0, 0.0, 0.0);
   glShadeModel (GL_FLAT);
}

double baseX=1.2;
double baseY=1.2;
double baseZ=0.8;
double towerX=0.125;
double towerY=0.125;
double towerZ=3.2;
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

void display(void)
{
	
	glClear (GL_COLOR_BUFFER_BIT);
	
	// align axes and set viewing position
	glPushMatrix();
	glRotatef (-90,1,0,0);
	glRotatef (camera_plane_encircle,0,0,1);
	glTranslatef (0,0,-camera_plane_elevation);

	// lay7 down floor
	glPushMatrix();
	glColor3b(100,100,100);
	glScalef (5,5,0.01);
	glutWireCube (1);
	glPopMatrix();
	
	// put on the base
	glPushMatrix();
	glTranslatef (0,0,baseZ/2);
	glScalef (baseX,baseY,baseZ);
	glColor3b(100,0,0);
	glutWireCube (1);
	glPopMatrix();

	// raise the two towers
	glPushMatrix();
	glColor3b(0,100,0);
	glRotatef (theta,0,0,1);
	glTranslatef (0,-towerSpacing/2,baseZ+towerZ/2);
	glScalef (towerX,towerY,towerZ);
	glutWireCube (1.0);
	glTranslatef (0,towerSpacing/towerY,0);
	glutWireCube (1.0);
	glPopMatrix();

	// put on the cap
	glPushMatrix();
	glRotatef (theta,0,0,1);
	glTranslatef (0,0,baseZ+towerZ+capZ/2);
	glScalef (capX,capY,capZ);
	glutWireCube (1);
	glPopMatrix();

	// put up the translational joint 
	glPushMatrix();
	glColor3b(0,0,100);
	glRotatef(theta,0,0,1);
	glTranslatef(0,0,baseZ+height+tblockZ/2);
	glScalef(tblockX,tblockY,tblockZ);
	glutWireCube(1);
	glPopMatrix();

	// put up the arm
	glPushMatrix();
	glColor3b(100,0,0);
	glRotatef (theta,0,0,1);
	glTranslatef (radxtnd-armX/2+tblockX/2,0,baseZ+height+tblockZ/2);
	glRotatef (45,1,0,0);
	glScalef (armX,armY,armZ);
	glutWireCube (1.0);
	glPopMatrix();

	// put up the tool holder
	glPushMatrix();
	glRotatef (theta,0,0,1);
	glTranslatef (radxtnd+tblockX/2+toolX/2,0,baseZ+height+tblockZ/2);
	glScalef (toolX,toolY,toolZ);
	glutWireCube (1.0);
	glPopMatrix();

	glPopMatrix();

   glutSwapBuffers();
}

void reshape (int w, int h)
{
   glViewport (0, 0, (GLsizei) w, (GLsizei) h); 
   glMatrixMode (GL_PROJECTION);
   glLoadIdentity ();
   gluPerspective(85.0, (GLfloat) w/(GLfloat) h, 1.0, 20.0);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
   glTranslatef (0.0, 0.0, -5.0);
}

void keyboard (unsigned char key, int x, int y)
{

	//static bool f_pressedlast;
	switch (key) {
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
	
	case 27:
		exit(1);
	break;
	
	default:
         break;
   }
}

void specialKeyboard(int key, int x, int y)
{
	if (key==GLUT_KEY_LEFT)
	{
		camera_plane_encircle--;
		glutPostRedisplay();
	}

	if (key==GLUT_KEY_RIGHT)
	{
		camera_plane_encircle++;
		glutPostRedisplay();
	}
	if (key==GLUT_KEY_UP)
	{
		camera_plane_elevation+=0.1;
		glutPostRedisplay();
	}

	if (key==GLUT_KEY_DOWN)
	{
		camera_plane_elevation-=0.1;
		glutPostRedisplay();
	}

}

void consoleInformation()
{
	printf("\t\t\t*********************************\n");
	printf("\t\t\t*  CYLINDRICAL ROBOT ANIMATION  *\n");
	printf("\t\t\t*  Written by Jake Galbreath    *\n");
	printf("\t\t\t*********************************\n");
	printf("\n\n");
	
	printf("\tDESCRIPTION:\n");
	printf("\t This program enables simple 3D animations of computer-simulated   \n");
	printf("\t cylindrical robot motions.  If the name of the file is not passed \n");
	printf("\t as a command line parameter, the opening file is hardwired to     \n");
	printf("\t sim_result.csv, either of which should contain an LEmatrix with   \n");
	printf("\t time in the first column, base angle in the second column (rads), \n");
	printf("\t arm elevation in the third column (max value of 8), and extension \n");
	printf("\t in the fourth column (maxvalue of 8).                             \n");
	
	printf("\n\n");
	
	printf("\tINSTRUCTIONS:\n");
	printf("\t-Press and hold 't' to run through the animation in true time. \n");
	printf("\t-Press 'f' to run forward through each frame of the animation.\n");
	printf("\t-Press 'r' to run backwards through each frame of the animation.\n");
	printf("\t-Press the left key to rotate the viewing angle to the left.\n");
	printf("\t-Press the right key to rotate the viewing angle to the right.\n");
	printf("\t-Press ESC to exit.\n");
}

int main(int argc, char** argv)
{
	camera_plane_elevation=1.5;
	camera_plane_encircle=195;

	char filename[200];

	if (argc == 2)
		strcpy(filename,argv[1]);	
	else 
		  strcpy(filename,"sim_result.csv");	 

    if (pos.Load(filename))
	  printf("Couldn't load file %s", filename);
	else 
	{
		consoleInformation();
		glutInit(&argc, argv);
		glutInitDisplayMode (GLUT_DOUBLE | GLUT_RGB);
		glutInitWindowSize (500, 500); 
		glutInitWindowPosition (100, 100);
		glutCreateWindow (argv[0]);
		init ();
		glutDisplayFunc(display); 
		glutReshapeFunc(reshape);
		glutKeyboardFunc(keyboard);
		glutSpecialFunc(specialKeyboard);
		glutMainLoop();
	}

   return 0;
}

/*******************************************************
2LINK ROBOT ANIMATION PROGRAM    

VERSION:		1.0

PROGRAMMER:		Jake Galbreath

RELEASE DATE:	May 04, 2000

  
USE: 
loads time and position data from the first 3
columns of a LEmatrix stored in a comma delimited file.
If the name of the file is not passed as a command line 
parameter, the opening file is hardwired to 2link_sim_result.csv,
where 2link_sim_result.csv must be in the same directory as the 
executable.   
  
All anglular position values from columns 2 and 3 in the 
csv are expected to be in radians.
   
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
#include "timing.h"


double pi=3.14159;
int step = 0;
static int shoulder = 0, elbow = 0, camera_plane_encircle = 0;
LEmatrix pos;
DWORD currenttime, firsttime;



void init(void) 
{
   glClearColor (0.0, 0.0, 0.0, 0.0);
   glShadeModel (GL_FLAT);
}

void display(void)
{
   glPushMatrix();
   glRotatef (camera_plane_encircle, 0.0, 1.0, 0.0);

   glClear (GL_COLOR_BUFFER_BIT);
   glPushMatrix();
   glTranslatef (-1.0, 0.0, 0.0);
   glRotatef ((GLfloat) shoulder, 0.0, 0.0, 1.0);
   glTranslatef (1.0, 0.0, 0.0);
   glPushMatrix();
   glScalef (2.0, 0.4, 1.0);
   glutWireCube (1.0);
   glPopMatrix();

   glTranslatef (1.0, 0.0, 0.0);
   glRotatef ((GLfloat) elbow, 0.0, 0.0, 1.0);
   glTranslatef (1.0, 0.0, 0.0);
   glPushMatrix();
   glScalef (2.0, 0.4, 1.0);
   glutWireCube (1.0);
   glPopMatrix();

   glPopMatrix();
   glutSwapBuffers();

   glPopMatrix();
}

void reshape (int w, int h)
{
   glViewport (0, 0, (GLsizei) w, (GLsizei) h); 
   glMatrixMode (GL_PROJECTION);
   glLoadIdentity ();
   gluPerspective(65.0, (GLfloat) w/(GLfloat) h, 1.0, 20.0);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
   glTranslatef (0.0, 0.0, -5.0);
}

void keyboard (unsigned char key, int x, int y)
{
   switch (key) 
   {
    case 't':     //true time forward animation (calculates
					//neccesary fps
		 step = getPosIndex(getTimePassed());
         if (step < pos.Nrows()) 
		 {	 
			shoulder = (int) (180/pi)*pos[step][1];
			elbow =  (int) (180/pi)*pos[step][2];
			glutPostRedisplay();
		 }
	break;
	case 'r':		//reverse frame animation (showing all frames)
        firsttime = 0; 
		if (step > 0) 
		 {	 
			shoulder = (int) (180/pi)*pos[--step][1];
			elbow =  (int) (180/pi)*pos[step][2];
			glutPostRedisplay();
		 }
	break;
	case 'f':		//forward frame animation (showing all frames)
        firsttime = 0; 
		if (step < pos.Nrows()-1)  //-1 needed for t to go again 
		 {	 
			shoulder = (int) (180/pi)*pos[step][1];
			elbow =  (int) (180/pi)*pos[step++][2];
			glutPostRedisplay();
		 }
	break;
	case 27:  //ESCAPE key
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

}


void consoleInformation()
{
	printf("\t\t\t*********************************\n");
	printf("\t\t\t*   2 LINK ROBOT ANIMATION      *\n");
	printf("\t\t\t*  Written by Jake Galbreath    *\n");
	printf("\t\t\t*********************************\n");
	printf("\n\n");
	
	printf("\tDESCRIPTION:\n");
	printf("\t This program enables simple 3D animations of computer-simulated   \n");
	printf("\t planar 2 link robot motions.  If the name of the file is not      \n");
	printf("\t passed as a command line parameter, the opening file is hardwired \n");
	printf("\t to 2link_sim_result.csv - either of which should contain an       \n");
	printf("\t LEmatrix with time in the first column, and base and secondary    \n");
	printf("\t link angle information (radians) in the second and third columns, \n");
	printf("\t respectively.													 \n");
	
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
	char filename[200];

	if (argc == 2)
		strcpy(filename,argv[1]);	
	else 
		  strcpy(filename,"2link_sim_result.csv");	 

    if (pos.Load(filename))
	  printf("Couldn't load file %s\n\n", filename);
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

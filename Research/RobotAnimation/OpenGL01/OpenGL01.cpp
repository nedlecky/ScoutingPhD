// OpenGL01.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include <windows.h>
#include <gl\glut.h>

void RenderScene(void)
{
	glClear(GL_COLOR_BUFFER_BIT);

	glFlush();
}

void SetupRC(void)
{
	glClearColor(0,0,1,1);
}

int main(int argc, char* argv[])
{
	printf("Hello World!\n");

	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);

	glutCreateWindow("Simple");
	glutDisplayFunc(RenderScene);

	SetupRC();

	glutMainLoop();

	return 0;
}


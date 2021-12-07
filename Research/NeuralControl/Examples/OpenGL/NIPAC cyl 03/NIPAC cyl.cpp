#include "stdafx.h"
#include "const.h"
#include <conio.h>

#include "hardware.h"
#include "waypoint.h"
#include "IPAController.h"
#include "animator.h"

int main(int argc, char* argv[])
{
	printf("OpenGL Glut NIPAC Simulator\n");

	pCylindrical01 hw=new Cylindrical01();
	hw->SetParameters(2,3,4);

	pInOutWaypointSchedule waypoint=new InOutWaypointSchedule(hw);
	waypoint->set_tMove(25);
	LEmatrix posFinal("p",3,1);
	LEmatrix velFinal("v",3,1);
	posFinal[0][0]=2*pi;  //( radians!)
	posFinal[1][0]=2.8;
	posFinal[2][0]=1.8;
	velFinal[0][0]=0;
	velFinal[1][0]=0;
	velFinal[2][0]=0;
	waypoint->set_posFinal(posFinal);
	waypoint->set_velFinal(velFinal);

	pIPAController controller=new IPAController(hw,waypoint);
	
	DrivingAnimator* anim=new GlutDriver(controller);
	controller->SetAnimator(anim);

	bool fUnknown=true;
	bool fSolidModeling;
	while(fUnknown)
	{
		printf("[W]ireframe or [S]olid? ");

		char c=toupper(getch());
		printf("%c\n",c);
		switch(c)
		{
		case 'W':
			fSolidModeling=false;
			fUnknown=false;
			break;
		case 'S':
			fSolidModeling=true;
			fUnknown=false;
			break;
		}
	}

	anim->Init(argc,argv,fSolidModeling);

	anim->Go();

	delete anim;
	delete controller;
	delete waypoint;
	delete hw;

	return 0;
}


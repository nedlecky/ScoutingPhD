#include "stdafx.h"
#include "waypoint.h"

WaypointSchedule::WaypointSchedule(pHardware hw0)
{
	hw=hw0;
}
WaypointSchedule::~WaypointSchedule()
{
}


InOutWaypointSchedule::InOutWaypointSchedule(pHardware hw) :
	WaypointSchedule(hw)
{
		posFinal.SetName("posFinal");
		posFinal.SetSize(hw->get_nAxes(),1);
		velFinal.SetName("velFinal");
		velFinal.SetSize(hw->get_nAxes(),1);
}

InOutWaypointSchedule::~InOutWaypointSchedule()
{
}

LEmatrix& InOutWaypointSchedule::Destination(double t)
{
	static LEmatrix dest("dest",hw->get_nAxes(),3);

	double t1=tMove*0.45;
	double t2=tMove*0.5;
	double t3=tMove*0.95;
	
	double tGoOn=tMove/100;

	if(t<t1-tGoOn)
	{
		dest[0][0]=t1;
		dest[1][0]=t1;
		dest[2][0]=t1;
		dest[0][1]=posFinal[0][0];
		dest[1][1]=posFinal[1][0];
		dest[2][1]=posFinal[2][0];
		dest[0][2]=velFinal[0][0];
		dest[1][2]=velFinal[1][0];
		dest[2][2]=velFinal[2][0];

		return dest;
	}

	if(t<t2-tGoOn)
	{
		dest[0][0]=t2;
		dest[1][0]=t2;
		dest[2][0]=t2;
		dest[0][1]=posFinal[0][0];
		dest[1][1]=posFinal[1][0];
		dest[2][1]=posFinal[2][0];
		dest[0][2]=velFinal[0][0];
		dest[1][2]=velFinal[1][0];
		dest[2][2]=velFinal[2][0];

		return dest;
	}

	if(t<t3-tGoOn)
	{
		dest=0;
		dest[0][0]=t3;
		dest[1][0]=t3;
		dest[2][0]=t3;

		return dest;
	}

	if(t<tMove-tGoOn)
	{
		dest=0;
		dest[0][0]=tMove;
		dest[1][0]=tMove;
		dest[2][0]=tMove;

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

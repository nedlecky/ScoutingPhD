#if !defined(WAYPOINT_H)
#define WAYPOINT_H

#include "hardware.h"
#include "LEmatrix.h"

class WaypointSchedule
{
protected:
	pHardware hw;
	double tMove;
public:
	WaypointSchedule(Hardware* hw0);
	~WaypointSchedule();
	virtual LEmatrix& Destination(double t)=0;
	double get_tMove(void) {return tMove;}
	void set_tMove(double t) {tMove=t;}
};
typedef WaypointSchedule* pWaypointSchedule;

class InOutWaypointSchedule : public WaypointSchedule
{
private:
	LEmatrix posFinal;
	LEmatrix velFinal;
public:
	InOutWaypointSchedule(pHardware hw);
	~InOutWaypointSchedule();
	LEmatrix& Destination(double t);
	void set_posFinal(LEmatrix& p) {posFinal=p;}
	void set_velFinal(LEmatrix& v) {velFinal=v;}
};
typedef InOutWaypointSchedule* pInOutWaypointSchedule;

#endif

#ifndef TIMING_H
#define TIMING_H

#include <windows.h>
#include <mmsystem.h>
#include "..\util\LEmatrix.h"


//****************************
//Timing functions specific to robotsim.cpp
float getTimePassed();
int getPosIndex(double time);
//****************************

#endif
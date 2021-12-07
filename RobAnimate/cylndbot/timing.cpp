#include "timing.h"

extern int step;
extern LEmatrix pos;
extern DWORD currenttime, firsttime;

float getTimePassed() 
{
	float timepassed;
	if (firsttime == 0) 
		firsttime = timeGetTime();
	currenttime = timeGetTime();
	timepassed = (float) currenttime - firsttime;
	return timepassed / 1000;
}

int getPosIndex(double time)
{
	//This function was created under the assumption that
	//subsequent calls would pass similar times 
	//thus the iterative, instead of the binary search.

	//might throw in interpolation later if it runs fast enough

	int i = 0, max = pos.Nrows()-1;

	if (time > pos[max][0])
		i = max;
	else if (time < pos[0][0])
		i = 0;
	else
	{
		i = step;   //step = current index
		if(time > pos[i][0])  
			while ((time > pos[i][0]) && (i < max))
				i++;
		else if (time < pos[i][0]) 
			while ((time < pos[i][0]) && (i > 0))
				i--; 
		//else if time = pos[i][0] just return i
	}
	return i;  //index of row w/ time similar to that of passed time

}

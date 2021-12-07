// Spinner / Spinner2 Simulation
// Stream Crossig
// 12/31/97 John E. Lecky

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>
#include <math.h>

#define TRUE -1
#define FALSE 0

double maxStrideDist=5.0;

int VRand(int max)
{
	int r=rand()%max;
	return r;
}

// Stream Bed
class Rock
{
private:
	double xval;
	double yval;
public:
	Rock();
	void Set(double x,double y);
	double GetX(void) {return xval;}
	double GetY(void) {return yval;}
	double DistanceTo(double x,double y);
};
Rock::Rock()
{
	xval=yval=0;
}
void Rock::Set(double x,double y)
{
	xval=x;
	yval=y;
}
double Rock::DistanceTo(double x,double y)
{
	double dx=xval-x;
	double dy=yval-y;
	return _hypot(dx,dy);
}

class StreamBed
{
private:
	int nReachable;
	int* reachable;
	int nRocks;
	Rock* rocks;
public:
	StreamBed();
	~StreamBed();
	void ClearData(void);
	void GenerateRocks(int seed,double width,double length,int nRocks);
	void Show(void);
	int ComputeReachable(int curRock,double maxStride);
	int Reachable(int i);
	double Between(int rock1,int rock2);
	Rock* GetRock(int i) {return &rocks[i];}
} s;

StreamBed::StreamBed()
{
	nRocks=nReachable=0;
	rocks=NULL;
	reachable=NULL;
	ClearData();
}
StreamBed::~StreamBed()
{
	ClearData();
}
void StreamBed::GenerateRocks(int seed,double width,double length,int n)
{
	ClearData();

	srand(seed);

	rocks=new Rock[n+2];
	reachable=new int[n+2];
	nRocks=n;

	// default Initial position
	rocks[0].Set(width/2.,0);

	// default Final position
	rocks[nRocks+1].Set(width/2.,length);

	for(int i=1; i<nRocks+1; i++)
	{
		double r1=(double)rand()/(double)RAND_MAX;
		double r2=(double)rand()/(double)RAND_MAX;

		double x=width*r1;
		double y=length*r2;

		rocks[i].Set(x,y);
	}
}
void StreamBed::ClearData(void)
{
	if(rocks!=NULL)
		delete rocks;
	if(reachable!=NULL)
		delete reachable;

	rocks=NULL;
	reachable=NULL;
	nRocks=0;
	nReachable=0;
}

void StreamBed::Show(void)
{
	for(int i=0; i<nRocks+2; i++)
		printf("%d %.2lf %.2lf\n",i,rocks[i].GetX(),rocks[i].GetY());
}

double StreamBed::Between(int rock1,int rock2)
{
	double x1=rocks[rock1].GetX();
	double y1=rocks[rock1].GetY();
	return rocks[rock2].DistanceTo(x1,y1);
}

int StreamBed::ComputeReachable(int curRock,double maxStride)
{
	nReachable=0;
	double curX=rocks[curRock].GetX();
	double curY=rocks[curRock].GetY();
	for(int i=1; i<nRocks+2; i++)
		if(i!=curRock && rocks[i].DistanceTo(curX,curY)<=maxStride &&
			rocks[i].GetY()>curY)
			reachable[nReachable++]=i;
	return nReachable;
}
int StreamBed::Reachable(int i)
{
	return reachable[i];
}

// action representation
// int action[2];
//	0= move from rock
//  1= to rock

// Situation representation
// int situation[2]; // current rock,final rock

// display a game situation 
void ShowSituation(int* situation)
{
	printf("on %d, final=%d\n",situation[0],situation[1]);
	getche();
}

// Is situation in the goal state?
int GoalCheck(int* situation)
{
	return situation[0]==situation[1];
}

// Given the current situation, pick a random action
// AVOID GOING BACK TO UNDO PREVIOUS ACTION
int GenerateRandomAction2(int* action,int* situation)
{
	int lastRock=action[0];

	int n=s.ComputeReachable(situation[0],maxStrideDist);
	if(n==0) return FALSE;
	int move=s.Reachable(VRand(n));
	if(move==lastRock)
		move=s.Reachable(VRand(n));

	// build action = from,to
	action[0]=situation[0];
	action[1]=move;
	return TRUE;
}

// perform 'action' on 'situation'
void ComputeNewSituation(int* situation, int* action)
{
	int from=action[0];
	int to=action[1];

	situation[0]=to;
	//ShowSituation(situation);
}

// Spinner2 Implementation
// return depth of found solution or -1 if no solution found
char tList[1024];
int Spinner2(int* initialSituation,int maxIterations)
{
	int situation[2];
	memcpy(situation,initialSituation,2*sizeof(int));

	int action[2];
	action[0]=-1;  // invalid initial action to be ignored

	int iterations=0;
	tList[0]=0;

	while(!GoalCheck(situation) && iterations<maxIterations)
	{
		if(!GenerateRandomAction2(action,situation)) return -1;
		ComputeNewSituation(situation,action);
		char tbuf[128];
		sprintf(tbuf,"%d %.2lf %.2lf %.2lf\n",action[1],
			s.GetRock(action[1])->GetX(),s.GetRock(action[1])->GetY(),
			s.Between(action[0],action[1]));
		strcat(tList,tbuf);
		iterations++;
	}

	if(iterations<maxIterations)
		return iterations;
	else
		return -1;
}
char rockList[1024];
int Cortex(int* situation,int maxIterations)
{
	int best=100;

	for(int i=0; i<maxIterations; i++)
	{
		int d=Spinner2(situation,best-1);
		if(d>=0 && d<best)
		{
			printf("Found solution spinner %d, depth=%d\n",i,d);
			best=d;
			strcpy(rockList,tList);
		}
	}
	if(best<100) return best;
	else return -1;
}


#include <time.h>
int main()
{
	struct tm *newtime;
	time_t aclock;

	time(&aclock);
	newtime=localtime(&aclock);

	unsigned int seed=1;
	srand(seed);

	int nRocks=35;
	maxStrideDist=15;
	int width=20;
	int length=100;

	for(int p=0; p<10; p++)
	{
		int seed=p;
		printf("Stream Crossing %s",asctime(newtime));
		printf("seed=%d w=%d l=%d nr=%d\n",seed,width,length,nRocks);
		s.GenerateRocks(seed,width,length,nRocks);
		s.Show();

		int situation[2];
		situation[0]=0;
		situation[1]=nRocks+1;

		int d=Cortex(situation,10000);
		printf("Puzzle: %d ",p);
		if(d>=0)
		{
			printf("Solution: %d\n",d);
			printf("RockList:\n%s",rockList);
		}
		else printf("NO SOLUTION\n");
		
	}

	return 0;
}


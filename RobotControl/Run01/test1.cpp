#include "stdafx.h"

#include <windows.h>
#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <winioctl.h>
#include "PHDIoctl.h"

typedef unsigned char  BYTE;
typedef unsigned short WORD;

HANDLE hPhdAnalogOut=NULL;

// The Axes
#define THETA 1
#define H 2
#define R 3

double vout[6];
double Volt(BYTE chan)
{
	return vout[chan-1];
}
WORD AOUT_BASE=0x300;



#define length(x) (sizeof(x)/sizeof(x[0]))
BYTE WriteAnalog[] =
{
	PHDIO_WRITE, 0, 0,	// reg,value
	PHDIO_DELAY, 1,		// delay 1us
	PHDIO_WRITE, 1, 0,	// reg,value
};
void SetVoltage(BYTE channel,double v)
{
	if(channel<1 || channel>6) return;

	if(v<0.0) v=0.0;
	if(v>10.0) v=10.0;

	BYTE port=2*(channel-1);

	WORD code=(WORD)(v*4095/10);
	BYTE lsb=code&255;
	BYTE msn=(code>>8)&15;

	WriteAnalog[1]=port;
	WriteAnalog[2]=lsb;
	WriteAnalog[6]=port+1;
	WriteAnalog[7]=msn;

	DWORD BytesReturned;
	WORD rv[3];
	if(!DeviceIoControl(hPhdAnalogOut,IOCTL_PHDIO_RUN_CMDS,
		WriteAnalog,length(WriteAnalog),
		rv, sizeof(rv),										// Output
		&BytesReturned, NULL))
	{
		printf("WriteAnalog failed %d\n",GetLastError());
	}

	vout[channel-1]=v;
}

bool Dir(BYTE chan)
{
	return vout[chan+3-1]>2.5;
}

void SetDirection(BYTE axis,bool val)
{
	if(axis<1 || axis>3) return;

	SetVoltage(axis+3,val?5.0:0.0);
}

void MakeSafe(void)
{
	SetVoltage(THETA,3);
	SetVoltage(H,3);
	SetVoltage(R,3);

	SetDirection(THETA,false);
	SetDirection(H,false);
	SetDirection(R,false);
}

int main()
{
	printf("Robot Control Tester 1.1\n");
	printf("========================\n\n");
	
	hPhdAnalogOut = CreateFile("\\\\.\\PHDIo\\isa\\io300,16\\override", GENERIC_READ|GENERIC_WRITE, 0,
		NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if(hPhdAnalogOut==INVALID_HANDLE_VALUE)
	{
		printf("Could not open AnalogOut device\n");
		return 1;
	}
	printf("Analog Out Opened OK\n");




	bool fContinue=true;
	
	int chan=THETA;

	MakeSafe();

	while(fContinue)
	{
		printf("(SPACE)MakeSafe ");
		printf("(1)H (2)R (3)Theta ");
		printf("(D)irection ");
		printf("(+) (-) ");
		printf("E(x)it ");
		printf("\n");
		for(int i=1; i<4; i++)
			printf("%1d %5.2lf\n",Dir(i),Volt(i));

		char c=tolower(getch());
		switch(c)
		{
			case ' ':
				MakeSafe();
				break;
			case '1':
			case '2':
			case '3':
				chan=c-'0';
				printf("Channel %d selected\n",chan);
				printf("D=%d V=%.2lf\n",Dir(chan),Volt(chan));
				break;
			case '+':
			case '=':
				SetVoltage(chan,Volt(chan)+0.1);
				printf("Channel %d: %.2lf\n",chan,Volt(chan));
				break;
			case '-':
			case '_':
				SetVoltage(chan,Volt(chan)-0.1);
				printf("Channel %d: %.2lf\n",chan,Volt(chan));
				break;
			case 'd':
				SetDirection(chan,!Dir(chan));
				break;
			case 'x':
				fContinue=false;
				break;
		}
	}

	MakeSafe();

	if(!CloseHandle(hPhdAnalogOut))
		printf("Close AnalogOut failed %d\n",GetLastError());
	else
		printf("Close AnalogOut worked\n");

	
	printf("bye.\n");

	return 0;
}
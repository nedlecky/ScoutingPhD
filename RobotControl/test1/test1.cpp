#include "stdafx.h"

#include <stdio.h>
#include <conio.h>
#include <stdlib.h>

typedef unsigned char  BYTE;
typedef unsigned short WORD;

// The Axes
#define THETA 1
#define H 2
#define R 3

double vout[3];
double Volt(BYTE chan)
{
	return vout[chan-1];
}
WORD AOUT_BASE=0x300;
void SetVoltage(BYTE channel,double v)
{
	if(channel<1 || channel>3) return;

	WORD port=AOUT_BASE+2*(channel-1);

	WORD code=(WORD)(v*4095/10);
	BYTE lsb=code&255;
	BYTE msn=(code>>8)&15;
	_outp(port,lsb);
	_outp(port+1,msn);

	vout[channel-1]=v;
}

bool dout[8];
bool Dir(BYTE chan)
{
	return dout[chan-1+3];
}
bool Enable(BYTE chan)
{
	return dout[chan-1];
}
void SetDigital(BYTE channel,bool x)
{
	if(channel<0 || channel>7) return;

	dout[channel]=x;
}

void SetEnable(BYTE axis,bool val)
{
	if(axis<1 || axis>3) return;

	SetDigital(axis-1,val);
}

void SetDirection(BYTE axis,bool val)
{
	if(axis<1 || axis>3) return;

	SetDigital(axis-1+3,val);
}

void MakeSafe(void)
{
	SetVoltage(THETA,5);
	SetVoltage(H,5);
	SetVoltage(R,5);

	SetEnable(THETA,0);
	SetEnable(H,0);
	SetEnable(R,0);

	SetDirection(THETA,0);
	SetDirection(H,0);
	SetDirection(R,0);
}

int main()
{
	printf("Robot Control Tester 1.0\n");
	printf("========================\n\n");

	bool fContinue=true;
	
	int chan=THETA;

	MakeSafe();

	while(fContinue)
	{
		printf("(SPACE)MakeSafe ");
		printf("(1)Theta (2)H (3)R ");
		printf("(E)nable (D)irection ");
		printf("(+) (-) ");
		printf("E(x)it ");
		printf("\n");
		for(int i=1; i<4; i++)
			printf("%1d %1d %5.2lf\n",Enable(i),Dir(i),Volt(i));

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
				printf("E=%d D=%d V=%.2lf\n",Enable(chan),Dir(chan),Volt(chan));
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
			case 'e':
				SetEnable(chan,!Enable(chan));
				break;
			case 'x':
				fContinue=false;
				break;
		}
	}

	MakeSafe();
	printf("bye.\n");

	return 0;
}
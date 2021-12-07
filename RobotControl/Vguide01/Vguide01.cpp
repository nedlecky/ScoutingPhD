#include "stdafx.h"
#include "Vguide01.h"
#include <winioctl.h>
#include "PHDIoctl.h"
#include <1394Camera.h>
#include "Stockcar.h"
#include <conio.h>
#include <math.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif
HANDLE hPhdAnalogOut=NULL;

// The Axes
#define H 1
#define R 2
#define THETA 3

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
	if(vout[channel-1]==v) return; // already set!

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

void CommandLegend(void)
{
		printf("(SPACE)MakeSafe ");
		printf("(1)H (2)R (3)Theta ");
		printf("(D)irection ");
		printf("(+) (-) ");
		printf("E(x)it ");
		printf("\n");
		for(int i=1; i<4; i++)
			printf("%1d %5.2lf\n",Dir(i),Volt(i));
}

C1394Camera cam;
int InitCamera(void) 
{
	// verify 1394 link to camera is operational
	printf("Checking link...");
	if(cam.CheckLink())
	{
		printf("Bad 1394 connection.\n");
		return 1;
	}
	else
		printf("OK.\n");

	// reset link just in case
/*	printf("Resetting link.");
	Sleep(1000);
	printf("..");
	cam.ResetLink(true);
	cam.m_cameraInitialized = false;
	Sleep(3000);
	printf("OK.\n");
*/
	// Initialize
	printf("Initing camera...");
	cam.InitCamera();
	cam.InquireControlRegisters();
	cam.StatusControlRegisters();

	// Set camera control defaults
	cam.SetShutter(2048);
	cam.m_controlShutter.SetAutoMode(false);

	cam.SetGain(0);
	cam.m_controlGain.SetAutoMode(false);

	cam.SetAutoExposure(128);
	cam.m_controlAutoExposure.TurnOn(false);

	cam.SetWhiteBalance(128,128);
	cam.m_controlWhiteBalance.SetAutoMode(false);

	cam.SetHue(128);
	cam.SetSaturation(128);

	cam.SetBrightness(128);
	cam.SetSharpness(20);
	cam.SetGamma(128);

	// FPS 0=2 1=4 2=7 3=15 4=30 5=60
	cam.SetVideoFrameRate(4);

	// 640x480 YUV 411
	cam.SetVideoFormat(0);
	cam.SetVideoMode(2);

	printf("OK.\n");

	return 0;
}

#define KEY_UP 72
#define KEY_DOWN 80
#define KEY_LEFT 75
#define KEY_RIGHT 77

int Guidance(void)
{
	hPhdAnalogOut = CreateFile("\\\\.\\PHDIo\\isa\\io300,16\\override", GENERIC_READ|GENERIC_WRITE, 0,
		NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if(hPhdAnalogOut==INVALID_HANDLE_VALUE)
	{
		printf("Could not open AnalogOut device\n");
		return 1;
	}
	printf("Analog Out Opened OK\n");
	MakeSafe();

	if(InitCamera()) return 1;
	
	if(cam.StartImageAcquisition())
		printf("Can't start acquisition.\n");
	else
		printf("Acquisition started.\n");

	// image storage structure
	pLEimage im=levCreate(LEV_Y8,cam.m_width,cam.m_height);
	pLEimage imTmp=levCreate(LEV_Y8,1,1);
	//pLEimage roi=levRroiCreate(im,220,50,300,180);
	pLEimage roi=levRroiCreate(im,50,50,540,400);
	pLEblobParams bp=levBlobParamsCreate();
	pLEblobResults br=levBlobResultsCreate(100,1);

	bp->blob_color=0;
	bp->min_area=2124;
	bp->max_area=4424;
	bp->min_height=36;
	bp->max_height=56;
	bp->min_width=59;
	bp->max_width=79;
	bp->sortType=LEV_SORT_AREA_MAX;


	BOOL fContinue=true;
	BOOL fTrack=false;
	BOOL fGrayscale=true;
	printf("Hit 'x' to stop program.\n");
	int targetX=-1;
	int targetY=-1;
	double sumErrX,sumErrY;
	int dist=10;
	while (fContinue)
	{
		int n,area,height,width;
		double cx,cy;
		double t0,t1,t2,t3,t4;
		if(kbhit())
		{
			char c=getch();
			switch(c)
			{
			case 'x':
				fContinue=false;
				break;
			case '0':
				targetX=cx;
				targetY=cy;
				break;
			case '+':
			case '=':
				dist++;
				if(dist>10) dist=10;
				printf("incr=%d\n",dist);
				break;
			case '-':
			case '_':
				dist--;
				if(dist<1) dist=1;
				printf("incr=%d\n",dist);
				break;
			case 'i':
				printf("Last: acq=%.1lf conv=%.1lf proc=%.1lf disp=%.1lf\n",
					t1-t0,t2-t1,t3-t2,t4-t3);
				printf("Last: cx=%.1lf cy=%.1lf a=%d h=%d w=%d\n",
					cx,cy,area,height,width);
				break;
			case 'g':
				fGrayscale^=1;
				break;
			case 't':
				fTrack^=1;
				if(fTrack)
				{
					sumErrX=0;
					sumErrY=0;
				}
				else
					MakeSafe();
				break;
			case -32: // extended codes
				switch(getch())
				{
				case KEY_UP:
					targetY-=dist;
					break;
				case KEY_DOWN:
					targetY+=dist;
					break;
				case KEY_LEFT:
					targetX-=dist;
					break;
				case KEY_RIGHT:
					targetX+=dist;
					break;
				}
			}
		continue;
		}

		t0=leMsec();
		if(cam.AcquireImage())
			printf("Acquisition error\n");
		t1=leMsec();


		// Convert camera YUV411 to RGB24
		levCopyYUV411RawToY8(im,(PBYTE)cam.m_pData,cam.m_width,cam.m_height);
		t2=leMsec();

		legrClear(im,0);
		levProcessDrawRois(im);
		if(targetX>0)
		{
			legrRect(im,targetX-10,targetY-10,20,20);
			legrCrosshair(im,targetX,targetY,5);
		}

		// find dot
		if(fGrayscale) levCopy(imTmp,im);
		levThresh(roi,128);
		levBlobFind(roi,bp,br);
		if(fGrayscale) levCopy(im,imTmp);
		n=br->num_blobs_found;
		if(n!=1)
		{
			MakeSafe();
			fTrack=false;
		}
		else
		{
			cx=levBlobGet_xcent(br,0);
			cy=levBlobGet_ycent(br,0);
			if(targetX==-1)
			{
				targetX=cx;
				targetY=cy;
			}

			area=levBlobGet_area(br,0);
			width=levBlobGet_width(br,0);
			height=levBlobGet_height(br,0);
			legrCrosshair(roi,cx,cy,5);
		}
		t3=leMsec();

		// tracker
		if(fTrack)
		{
			double errX=targetX-cx;
			double errY=cy-targetY;
			//printf("errX=%.1lf errY=%.1lf\n",errX,errY);

			sumErrX+=errX;
			sumErrY+=errY;
			//printf("sumErrX=%.1lf sumErrY=%.1lf\n",sumErrX,sumErrY);


			//double Rvoltage=errX*0.02 + sumErrX*.002;
			//double Hvoltage=errY*0.02 + sumErrY*.002;
			double Rvoltage=errX*0.01 + sumErrX*.001;
			double Hvoltage=errY*0.01 + sumErrY*.001;

			// gravity offset
			Hvoltage+=0.6;

			bool Rdirection= Rvoltage>0;
			bool Hdirection= Hvoltage>0;
			SetDirection(R,Rdirection);
			SetDirection(H,Hdirection);

			Rvoltage=fabs(Rvoltage)+3.0;
			Hvoltage=fabs(Hvoltage)+3.0;

			if(Rvoltage>4) Rvoltage=4;
			if(Hvoltage>5) Hvoltage=5;

			SetVoltage(R,Rvoltage);
			SetVoltage(H,Hvoltage);

			//printf("H %d %.2lf   R %d %.2lf\n",
			//	Hdirection,Hvoltage,
			//	Rdirection,Rvoltage);

		}


		// Send to Viewer application
		levViewerSend(im);
		t4=leMsec();
	}
	MakeSafe();

	levViewerStop();
	levDestroy(im);
	levDestroy(imTmp);
	levBlobParamsDestroy(bp);
	levBlobResultsDestroy(br);

	if(cam.StopImageAcquisition())
		printf("Can't stop acquisition.\n");
	else
		printf("Acquisition stopped.\n");


	if(!CloseHandle(hPhdAnalogOut))
		printf("Close AnalogOut failed %d\n",GetLastError());
	else
		printf("Close AnalogOut worked\n");

	
	printf("bye.\n");

	return 0;
}

/////////////////////////////////////////////////////////////////////////////
// The one and only application object

CWinApp theApp;

using namespace std;

int _tmain(int argc, TCHAR* argv[], TCHAR* envp[])
{
	int nRetCode = 0;

	// initialize MFC and print and error on failure
	if (!AfxWinInit(::GetModuleHandle(NULL), NULL, ::GetCommandLine(), 0))
	{
		// TODO: change error code to suit your needs
		cerr << _T("Fatal Error: MFC initialization failed") << endl;
		nRetCode = 1;
	}
	else
	{
		Guidance();
	}

	return nRetCode;
}



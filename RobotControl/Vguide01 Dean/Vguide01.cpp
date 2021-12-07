#include "stdafx.h"
#include "Vguide01.h"
#include <winioctl.h>
#include "PHDIoctl.h"
#include <1394Camera.h>
#include "Stockcar.h"
#include <conio.h>
#include <math.h>
#include "LEsimulate.h"
#include "LEneuralnet.h"
#include "LEmatrix.h"

double pi=3.14159;

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

// 2 Layer NN, sigmoid layer1 linear layer2, V&Wtranspose
LEmatrix z("z");
LEmatrix& TwoLayerNN(LEmatrix& VT,LEmatrix& WT,LEmatrix& x)
{
	static LEmatrix y("y");
	z = leSigma(VT*x,LEAsigmoid);
	y = WT*z;
	return y;
}

// Build real NN input composite
LEmatrix& MakeNNx(LEmatrix& e,LEmatrix& edot,LEmatrix& qd)
{
	static LEmatrix NNx("NNx");

	NNx.SetSize(1,1);
	NNx=1;
	NNx.AppendRows(e);
	NNx.AppendRows(edot);
	NNx.AppendRows(qd);//Xd from Guidance

	return NNx;
}

LEmatrix& ComputeXd(int targetX, int targetY)
{
	static LEmatrix Xd("Xd",6,1);

	//position
	Xd[0][0]=targetX;
	Xd[1][0]=targetY;
	//velocity
	Xd[2][0]=0;//desired velocity is zero
	Xd[3][0]=0;
	//acceleration
	Xd[4][0]=0;//desired acceleration is zero
	Xd[5][0]=0;

	return Xd;
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
	printf("Hit 'x' to stop program.\n");
	int targetX=-1;
	int targetY=-1;
	int dist=1;

	//need r defined here to be able to reset
	//the error for a new iteration
	LEmatrix r("r",2,1); //from r = edot + lam*e;

	// Desired Control Coefficients
	double updateFreq=100;
	LEmatrix Kv("Kv");
	LEmatrix lam("lam");
	LEmatrix tau("tau",2,1);
	Kv = 0.001 * leIdentMat(2);
	lam= 20 * leIdentMat(2);//consider changing weight to a higher
	//number since we are only concerned with position error
		
	// Computed Constants
	double updateDt=1/updateFreq;	// control loop update frequency Hz

	LEmatrix Xd("Xd");
	LEmatrix NNx("NNx");
	//LEmatrix r defined above the case statements

	// error integration
	LEmatrix e("e",2,1);//position error in x and y axes
	LEmatrix edot("edot",2,1);//edot is the velocity error compared to zero

	// Setup V and W
	Xd=ComputeXd(targetX, targetY);
	NNx=MakeNNx(e,edot,Xd);

	int n=NNx.Nrows()-1;
	int L=10;
	int m=tau.Nrows();
	LEmatrix V("V",n+1,L);
	LEmatrix W("W",L+1,m);
	
	//tried to randomize V and W but
	//didn't work properly
	V=0;
	W=0;

	LEmatrix VT("VT");
	LEmatrix WT("WT");
	VT=leTranspose(V);
	WT=leTranspose(W);

	// NN Learning Rates
	double eta1=0.000001;
	double eta2=0.000001;

	tau=TwoLayerNN(VT,WT,NNx);
	LEmatrix Iz("Iz");
	Iz=leIdentMat(z.Nrows());

	LEmatrix del1("del1");
	LEmatrix del2("del2");
	LEmatrix tmpmat("tmpmat");

	double oldcx=0;//last x-position
	double oldcy=0;//last y-position
	double oldtime=0;//set to curtime after loop
	double curtime;//current time
	double diffx;//difference in x
	double diffy;//difference in y
	double difft;//difference in time

	while (fContinue)
	{
		int num,area,height,width;//used for blob analysis
		double cx,cy;//current positions
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
			case 't':
				fTrack^=1;
				if(fTrack)
				{
					//reset the error to zero for new iteration
					r[0][0]=0;
					r[1][0]=0;
				}
				else
					MakeSafe();
				break;
			case -32: // extended codes
				switch(getch())
				{
				case KEY_UP:
					targetY-=dist+10;
					break;
				case KEY_DOWN:
					targetY+=dist+10;
					break;
				case KEY_LEFT:
					targetX-=dist+10;
					break;
				case KEY_RIGHT:
					targetX+=dist+10;
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
		levYUV411toY8(im,(PBYTE)cam.m_pData,cam.m_width,cam.m_height);
		t2=leMsec();

		legrClear(im,0);
		levProcessDrawRois(im);
		if(targetX>0)
		{
			legrRect(im,targetX-10,targetY-10,20,20);
			legrCrosshair(im,targetX,targetY,5);
		}

		// find dot
		levThresh(roi,128);
		levBlobFind(roi,bp,br);
		num=br->num_blobs_found;
		if(num!=1)//did not find the one blob necessary
		{
			MakeSafe();
			fTrack=false;
		}
		else
		{
			//set the coordinates of the desired position
			cx=levBlobGet_xcent(br,0);
			cy=levBlobGet_ycent(br,0);
			if(targetX==-1)//set values the first time through
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
		//this is where everything happens
		if(fTrack)
		{
			curtime=leMsec();
			Xd=ComputeXd(targetX, targetY);

			//e is a 2x1 matrix of position error
			e[0][0]=targetX-cx;//position error in x-axis
			e[1][0]=cy-targetY;//position error in y-axis
			
			if (oldcx!=0)
			{
				//this loop does not run the first time through
				diffx=cx-oldcx;
				diffy=oldcy-cy;
				difft=abs(curtime-oldtime);
				
				if (difft!=0)//don't want to divide by zero
				{
					//velocity
					edot[0][0]=diffx/difft;
					edot[1][0]=diffy/difft;
				}
			}
	
			oldcx=cx;
			oldcy=cy;
			oldtime=curtime;
			e.Print();
			edot.Print();
			
			// Filtered error
			r = edot + lam*e;//2x1 matrix
			r.Print();

			NNx=MakeNNx(e,edot,Xd);
			tau = TwoLayerNN(VT,WT,NNx) + Kv*r;
			
			double Rvoltage=tau[0][0];
			double Hvoltage=tau[1][0];

			del2=r;//filtered error
			//z is lematrix from TwoLayerNN
			//z = leSigma(VT*x,LEAsigmoid)
			tmpmat=leDiag(z);
			del1=tmpmat*(Iz-tmpmat)*W*r;
			
			//leading 1 in del1 need to be removed
			for (int i=1;i<del1.Nrows();i++) 
			{
				del1[i-1][0]=del1[i][0];
			}

			del1.SetSize(del1.Nrows()-1,del1.Ncols());

			W = W + eta2*z*leTranspose(del2);
			V = V + eta1*NNx*leTranspose(del1);
			VT=leTranspose(V);
			WT=leTranspose(W);

			bool Rdirection= Rvoltage>0;
			bool Hdirection= Hvoltage>0;
			SetDirection(R,Rdirection);
			SetDirection(H,Hdirection);

			// gravity offset
			//Hvoltage+=0.9;

			//leave until the system is working
			Rvoltage=fabs(Rvoltage); 
			Hvoltage=fabs(Hvoltage);

			//motor thresholds
			Rvoltage+=3.0;
			Hvoltage+=3.0;

			//keep the system slow for now
			//could be set higher once the system
			//shows stability
			if(Rvoltage>5) Rvoltage=5;
			if(Hvoltage>6) Hvoltage=6;

			SetVoltage(R,Rvoltage);
			SetVoltage(H,Hvoltage);
			printf("volts: %.1lf %.1lf\n",Hvoltage,Rvoltage);

		}

		// Send to Viewer application
		levViewerSend(im);
		t4=leMsec();
	}
	MakeSafe();

	levViewerStop();
	levDestroy(im);
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



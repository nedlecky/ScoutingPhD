#include "stdafx.h"
#include "Vguide02.h"
#include <winioctl.h>
#include "PHDIoctl.h"
#include <1394Camera.h>
#include "Stockcar.h"
#include "LEneuralnet.h"
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

// 2 Layer NN, sigmoid layer1 linear layer2, V&Wtranspose
// Leaves output of layer 1 around in global z for training purposes
LEmatrix z("z");
LEmatrix& TwoLayerNN(LEmatrix& VT,LEmatrix& WT,LEmatrix& x)
{
	static LEmatrix y("y");
	z = leSigma(VT*x,LEAsigmoid);
	y = WT*z;
	return y;
}

// Desired Trajectory
double amp1;
double amp2;
double fact;
LEmatrix& ComputeXd(int targetX,int targetY)
{
	static LEmatrix Xd("Xd",6,1);

	Xd[0][0]=targetX;
	Xd[1][0]=targetY;
	Xd[2][0]=0;
	Xd[3][0]=0;
	Xd[4][0]=0;
	Xd[5][0]=0;

	return Xd;
}
// Build real NN input composite
LEmatrix& MakeNNx(LEmatrix& e,LEmatrix& edot,LEmatrix& qd)
{
	static LEmatrix NNx("NNx");

	NNx.SetSize(1,1);
	NNx=1;
	NNx.AppendRows(e);
	NNx.AppendRows(edot);
	NNx.AppendRows(qd);

	return NNx;
}



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

	// Initial Conditions
	LEmatrix x0("x0",4,1);
	x0=0;

	// Desired Control Coefficients
	LEmatrix Kv("Kv");
	LEmatrix lam("lam");
	Kv=10*leIdentMat(2);
	lam=10*leIdentMat(2);
	
	LEmatrix x("x");
	LEmatrix Xd("Xd");
	LEmatrix NNx("NNx");
	
	// error integration
	LEmatrix e("e",2,1);
	LEmatrix edot("edot",2,1);
	LEmatrix r("r",2,1);
	LEmatrix tau("tau",2,1);
	LEmatrix voltage("voltage",2,1);
	
	LEmatrix D("D",2,2);
	D[0][0] = 0.00015;	D[0][1] = 0.00015;
	D[1][0] = 0;		D[1][1] = -0.0003;
	//D[0][0] = 0.0003;	D[0][1] = 0;
	//D[1][0] = 0;		D[1][1] = -0.0003;

	// Setup V and W
	Xd=ComputeXd(0,0);
	NNx=MakeNNx(e,edot,Xd);
	int n=NNx.Nrows()-1;
	int L=20;
	int m=tau.Nrows();
	LEmatrix V("V",n+1,L);
	LEmatrix W("W",L+1,m);
	printf("n=%d L=%d m=%d\n",n,L,m);
	V=0;
	W=0;

	LEmatrix VT("VT");
	LEmatrix WT("WT");
	VT=leTranspose(V);
	WT=leTranspose(W);

	// NN Learning Rates
	double eta1=0.05;
	double eta2=0.05;

	tau=TwoLayerNN(VT,WT,NNx);
	LEmatrix Iz("Iz");
	Iz=leIdentMat(z.Nrows());

	LEmatrix del1("del1");
	LEmatrix del2("del2");
	LEmatrix tmpmat("tmpmat");

	BOOL fContinue=true;
	BOOL fTrack=false;
	BOOL fGrayscale=true;
	BOOL fTrainNet=false;
	printf("Hit 'x' to stop program.\n");
	int targetX=-1;
	int targetY=-1;
	int dist=5;
	int nFails=0;
	double cxLast,cyLast,tLast;
	while (fContinue)
	{
		int n,area,height,width;
		double cx,cy;
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
				printf("Last: cx=%.1lf cy=%.1lf a=%d h=%d w=%d\n",
					cx,cy,area,height,width);
				break;
			case 'g':
				fGrayscale^=1;
				break;
			case 'n':
				fTrainNet^=1;
				printf("NeuralNet Training %s\n",fTrainNet?"ON":"OFF");
				break;
			case 't':
				fTrack^=1;
				if(fTrack)
				{
					cxLast=cx;
					cyLast=cy;
					tLast=leMsec();
					Sleep(10);
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

		if(cam.AcquireImage())
			printf("Acquisition error\n");

		// Convert camera YUV411 to RGB24
		levYUV411toY8(im,(PBYTE)cam.m_pData,cam.m_width,cam.m_height);

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
			if(nFails++>4)
			{
				MakeSafe();
				fTrack=false;
			}
		}
		else
		{
			nFails=0;
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

		// tracker
		if(fTrack && nFails==0)
		{
			double t=leMsec()/1000;
			double dt=t-tLast;
			Xd=ComputeXd(targetX,targetY); // pos1 pos2 vel1 vel2 acc1 acc2

			double x1=cx;
			double x2=cy;
			double x3=(cx-cxLast)/dt;
			double x4=(cy-cyLast)/dt;
			cxLast=cx;
			cyLast=cy;
			tLast=t;

			// state errors
			e[0][0]=Xd[0][0]-x1;	e[1][0]=Xd[1][0]-x2;
			edot[0][0]=Xd[2][0]-x3;	edot[1][0]=Xd[3][0]-x4;

			// Filtered error
			r = edot + lam*e;

			NNx=MakeNNx(e,edot,Xd);

			tau = TwoLayerNN(VT,WT,NNx) + Kv*r;
			//printf("dt=%.5lf\n",dt);

			if(fTrainNet)
			{
				del2=r;

				tmpmat=leDiag(z);
				del1=tmpmat*(Iz-tmpmat)*W*r;
		
				// del1 has a leading 1 that isn't necessary
				for(int i=1; i<del1.Nrows(); i++) del1[i-1][0]=del1[i][0];
				del1.SetSize(del1.Nrows()-1,del1.Ncols());

				W = W + eta2*z*leTranspose(del2);
				V = V + eta1*NNx*leTranspose(del1);

				VT=leTranspose(V);
				WT=leTranspose(W);
			}

			voltage=D*tau;
			double Rvoltage = voltage[0][0];
			double Hvoltage = voltage[1][0];

			bool Rdirection= Rvoltage>0;
			bool Hdirection= Hvoltage>0;
			SetDirection(R,Rdirection);
			SetDirection(H,Hdirection);

			Rvoltage=fabs(Rvoltage)+3.0;
			Hvoltage=fabs(Hvoltage)+3.0;

			if(Rvoltage>9) Rvoltage=9;
			if(Hvoltage>9) Hvoltage=9;

			SetVoltage(R,Rvoltage);
			SetVoltage(H,Hvoltage);

			//printf("H %d %.2lf   R %d %.2lf\n",
			//	Hdirection,Hvoltage,
			//	Rdirection,Rvoltage);
		}


		// Send to Viewer application
		levViewerSend(im);
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



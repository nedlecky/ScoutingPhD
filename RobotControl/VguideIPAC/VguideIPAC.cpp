#include "stdafx.h"
#include "VguideIPAC.h"
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

int targetX[3]={-1,-1,-1};
int targetY[3]={-1,-1,-1};
int curTarget=0;

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
LEmatrixObj z("z");
LEmatrixObj& TwoLayerNN(LEmatrixObj& VT,LEmatrixObj& WT,LEmatrixObj& x)
{
	static LEmatrixObj y("y");
	z = lennSigma(VT*x,lennSigmoid);
	y = WT*z;
	return y;
}

int nAxes=2;
double tMove=1;
LEmatrixObj& Destination(double t)
{
	static LEmatrixObj dest("dest",nAxes,3);

	double tGoOn=0.1;

	// first goal
	if(t<tMove-tGoOn)
	{
		dest[0][0]=tMove;
		dest[1][0]=tMove;
		dest[0][1]=targetX[0];
		dest[1][1]=targetY[0];
		dest[0][2]=0;
		dest[1][2]=0;

		return dest;
	}

	// second goal
	if(t<tMove*2-tGoOn)
	{
		dest[0][0]=tMove*2;
		dest[1][0]=tMove*2;
		dest[0][1]=targetX[1];
		dest[1][1]=targetY[1];
		dest[0][2]=0;
		dest[1][2]=0;

		return dest;
	}

	// third goal
	if(t<tMove*3-tGoOn)
	{
		dest[0][0]=tMove*3;
		dest[1][0]=tMove*3;
		dest[0][1]=targetX[2];
		dest[1][1]=targetY[2];
		dest[0][2]=0;
		dest[1][2]=0;

		return dest;
	}

	// return goal
	if(t<tMove*4-tGoOn)
	{
		dest[0][0]=tMove*4;
		dest[1][0]=tMove*4;
		dest[0][1]=targetX[0];
		dest[1][1]=targetY[0];
		dest[0][2]=0;
		dest[1][2]=0;

		return dest;
	}

	// implement hold state
	double tHold=0.4;
	dest[0][0]=t+tHold;
	dest[1][0]=t+tHold;
	return dest;
}


// IPAC Control Law
LEmatrixObj& ComputeAcc(double t,LEmatrixObj& y,LEmatrixObj& ydot)
{
	static LEmatrixObj dest("dest");
	static LEmatrixObj tf("tf");
	static LEmatrixObj yf("yf");
	static LEmatrixObj ydotf("ydotf");
	static LEmatrixObj tr("tr");
	static LEmatrixObj yr("yr");
	static LEmatrixObj yddot("yddot");
	
	dest=Destination(t);
	tf=lemExtractCol(dest,0);
	yf=lemExtractCol(dest,1);
	ydotf=lemExtractCol(dest,2);

	// time and distance remaining to goal
	tr=tf-t;
	yr=yf-y;

	yddot.SetSize(nAxes,1);
	for(int i=0; i<nAxes; i++)
		yddot[i][0] = 2*(3*yr[i][0]/tr[i][0] - 2*ydot[i][0] - ydotf[i][0])/tr[i][0];

	return yddot;
}

// Build Phis
// Note   q  = pos pos pos vel vel vel
//        qd = pos pos pos vel vel vel acc acc acc
LEmatrixObj& PhiM(LEmatrixObj& q)
{
	static LEmatrixObj phiM("phiM");

	phiM.SetSize(3,1);
	phiM[0][0]=1;
	phiM[1][0]=q[0][0];
	phiM[2][0]=q[1][0];
	
	return phiM;
}
LEmatrixObj& PhiV(LEmatrixObj& q)
{
	static LEmatrixObj phiV("phiV");
	//static LEmatrixObj extra("extra",2,1);

	//double theta=q[0][0];
	//double h=q[1][0];
	//double r=q[2][0];
	//double thetadot=q[3][0];
	//double hdot=x[4][0];
	//double rdot=q[5][0];

	//extra[0][0] = r*rdot*thetadot;
	//extra[1][0] = r*thetadot*thetadot;

	phiV.SetSize(1,1);
	phiV[0][0]=1;
	phiV.AppendRows(q);
	//phiV.AppendRows(extra);
	
	return phiV;
}
LEmatrixObj& PhiG(LEmatrixObj& q)
{
	static LEmatrixObj phiG("phiG");

	phiG.SetSize(3,1);
	phiG[0][0]=1;
	phiG[1][0]=q[0][0];
	phiG[2][0]=q[1][0];
	
	return phiG;
}
LEmatrixObj& SquareMat(LEmatrixObj& m)
{
	static LEmatrixObj r("r");

	int n=(int)sqrt(m.mRows());
	if(n<1)
	{
		r.SetSize(1,1);
		r=0;
		return r;
	}

	r.SetSize(n,n);
	for(int i=0; i<n; i++)
		for(int j=0; j<n; j++)
			r[i][j]=m[i*n+j][0];
	return r;
}
LEmatrixObj& leSgn(LEmatrixObj& m)
{
	static LEmatrixObj sgn("sgn");

	sgn.MakeSameSize(m);

	for(UINT i=0; i<m.mRows(); i++)
		for(UINT j=0; j<m.nCols(); j++)
			sgn[i][j] = m[i][j]>=0;

	return sgn;
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
	LEmatrixObj x0("x0",4,1);
	x0=0;

	// Desired Control Coefficients
	LEmatrixObj Kv("Kv");
	LEmatrixObj lam("lam");
	Kv=10*lemIdentMat(2);
	lam=10*lemIdentMat(2);
	
	LEmatrixObj x("x");
	LEmatrixObj NNx("NNx");
	
	// error integration
	LEmatrixObj e("e",2,1);
	LEmatrixObj e_dot("edot",2,1);
	LEmatrixObj r("r",2,1);
	LEmatrixObj tau("tau",2,1);
	LEmatrixObj voltage("voltage",2,1);
	
		// Internal Control Variables
	LEmatrixObj q("q",nAxes,1);
	LEmatrixObj q_dot("q_dot",nAxes,1);
	LEmatrixObj qd("qd",nAxes,1);
	LEmatrixObj qd_dot("qd_dot",nAxes,1);
	LEmatrixObj qd_dotdot("qd_dotdot",nAxes,1);

	LEmatrixObj D("D",2,2);
	D[0][0] = 0.00015;	D[0][1] = 0.00015;
	D[1][0] = 0;		D[1][1] = -0.0003;
	//D[0][0] = 0.0003;	D[0][1] = 0;
	//D[1][0] = 0;		D[1][1] = -0.0003;

	LEmatrixObj Xd("Xd");
	LEmatrixObj phiM("phiM");
	LEmatrixObj phiG("phiG");
	LEmatrixObj phiV("phiV");
	phiM=PhiM(x0);
	phiV=PhiV(x0);
	phiG=PhiG(x0);
	int LM=phiM.mRows();
	int LV=phiV.mRows();
	int LG=phiG.mRows();
	int m=nAxes;
	LEmatrixObj WM("WM",m*m,LM);
	LEmatrixObj WV("WV",m*m,LV);
	LEmatrixObj WG("WG",m,LG);
	LEmatrixObj M("M",nAxes,nAxes);
	LEmatrixObj Vm("Vm",nAxes,nAxes);
	LEmatrixObj G("G",nAxes,1);
	WM=0;
	WV=0;
	WG=0;
	printf("nAxes=%d LM=%d LV=%d LG=%d m=%d\n",nAxes,LM,LV,LG,m);

	// Adaptive Learning Rates
	double updateDt=0.01;
	double FMscalar=0.05;
	double FVscalar=0.05;
	double FGscalar=10;
	LEmatrixObj FM("FM");
	LEmatrixObj FV("FV");
	LEmatrixObj FG("FG");
	FM=FMscalar*updateDt*lemIdentMat(WM.mRows());
	FV=FVscalar*updateDt*lemIdentMat(WV.mRows());
	FG=FGscalar*updateDt*lemIdentMat(WG.mRows());

	// NN Learning Rates
	double eta1=0.002;
	double eta2=0.002;

	LEmatrixObj del1("del1");
	LEmatrixObj del2("del2");
	LEmatrixObj tmpmat("tmpmat");

	BOOL fContinue=true;
	BOOL fTrack=false;
	BOOL fGrayscale=true;
	BOOL fTrainNet=false;
	BOOL fRun=false;
	double tStart;
	printf("Hit 'x' to stop program.\n");
	int dist=40;
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
			case 'w':
				//V=0;
				//W=0;
				//VT=lemTranspose(V);
				//WT=lemTranspose(W);
				printf("NN Weights reset to 0\n");
				break;
			case '0':
				targetX[curTarget]=cx;
				targetY[curTarget]=cy;
				printf("Zeroed\n");
				break;
			case '1':
				curTarget=0;
				break;
			case '2':
				curTarget=1;
				break;
			case '3':
				curTarget=2;
				break;
			case '+':
			case '=':
				dist+=2;
				if(dist>50) dist=50;
				printf("incr=%d\n",dist);
				break;
			case '-':
			case '_':
				dist-=2;
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
			case 'r':
				fRun^=1;
				printf("Running %s\n",fRun?"ON":"OFF");
				if(fRun) tStart=leMsec();
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
					targetY[curTarget]-=dist;
					break;
				case KEY_DOWN:
					targetY[curTarget]+=dist;
					break;
				case KEY_LEFT:
					targetX[curTarget]-=dist;
					break;
				case KEY_RIGHT:
					targetX[curTarget]+=dist;
					break;
				}
			}
		continue;
		}

		if(cam.AcquireImage())
			printf("Acquisition error\n");

		// Convert camera YUV411 to RGB24
		levCopyYUV411RawToY8(im,(PBYTE)cam.m_pData,cam.m_width,cam.m_height);

		legrClear(im,0);
		levProcessDrawRois(im);
		if(targetX[0]>0)
		{
			legrRect(im,targetX[0]-5,targetY[0]-5,10,10);
			legrCrosshair(im,targetX[0],targetY[0],5);
		}
		if(targetX[1]>0)
		{
			legrRect(im,targetX[1]-10,targetY[1]-10,20,20);
			legrCrosshair(im,targetX[1],targetY[1],10);
		}
		if(targetX[2]>0)
		{
			legrRect(im,targetX[2]-15,targetY[2]-15,30,30);
			legrCrosshair(im,targetX[2],targetY[2],15);
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
			if(targetX[curTarget]==-1)
			{
				targetX[curTarget]=cx;
				targetY[curTarget]=cy;
			}

			area=levBlobGet_area(br,0);
			width=levBlobGet_width(br,0);
			height=levBlobGet_height(br,0);
			legrCrosshair(roi,cx,cy,5);
		}

		// tracker
		if(fTrack && nFails==0)
		{
			double t = tStart - leMsec()/1000;
			double dt = t-tLast;

			double x1=cx;
			double x2=cy;
			double x3=(cx-cxLast)/dt;
			double x4=(cy-cyLast)/dt;
			cxLast=cx;
			cyLast=cy;
			tLast=t;

			// where are we?
			q[0][0]=x1;
			q[1][0]=x2;
			q_dot[0][0]=x3;
			q_dot[1][0]=x4;
			
			// IPAC control law
			qd_dotdot=ComputeAcc(t,q,q_dot);

			// state errors
			e_dot=qd_dot-q_dot;

			// project next qd_dot
			qd_dot=q_dot+qd_dotdot*updateDt;

			// filtered error
			r = e_dot;// + lam*e;

			// torque
			if(0)// pass==0)
				tau = Kv*r;	// classical controller only
			else
			{
				// one layer multi-NN controller
				phiM=PhiM(x);
				phiV=PhiV(x);
				phiG=PhiG(x);
				M=SquareMat(WM*phiM);
				Vm=SquareMat(WV*phiV);
				G=WG*phiG;

				tau = M*qd_dotdot + Vm*qd_dot + G;

				// Weight update
				for(int i=0; i<WM.mRows(); i++)
				{
					int k=i/nAxes;
					int l=i%nAxes;
					double mult=r[k][0]*qd_dotdot[l][0];
					for(UINT j=0; j<WM.nCols(); j++)
						WM[i][j] += FM[i][i]*
							phiM[j][0]*mult;
				}
				for(i=0; i<WV.mRows(); i++)
				{
					int k=i/nAxes;
					int l=i%nAxes;
					double mult=r[k][0]*q_dot[l][0];
					for(UINT j=0; j<WV.nCols(); j++)
						WV[i][j] += FV[i][i]*
							phiV[j][0]*mult;
				}
				for(i=0; i<WG.mRows(); i++)
				{
					for(UINT j=0; j<WG.nCols(); j++)
						WG[i][j] += FG[i][i]*
							phiG[j][0]*r[i][0];
				}
			}


			voltage=D*tau;
			double Rvoltage = voltage[0][0];
			double Hvoltage = voltage[1][0];

			bool Rdirection= Rvoltage>0;
			bool Hdirection= Hvoltage>0;
			SetDirection(R,Rdirection);
			SetDirection(H,Hdirection);

			Rvoltage=fabs(Rvoltage);//+3.0;
			Hvoltage=fabs(Hvoltage);//+3.0;

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



// Simulate.cpp : implementation file
//

#include "stdafx.h"
#include "MFCPendulum.h"
#include "Simulate.h"
#include "PendSim.h"
#include <math.h>
#include "ScoutingDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

ScoutingDlg *pScoutingDlg = NULL;
HANDLE hScoutingDoneEvent;

int nRunning=0;
UINT ScoutingThreadProc( LPVOID pParam )
{
	PendulumSimulator* ps = (PendulumSimulator*)pParam;

	nRunning++;
	ps->Solve();

	// Tricky deal to make sure dialog is up before killing it
	nRunning--;
	if(pScoutingDlg && nRunning==0)
	{
//		while (pScoutingDlg->m_hWnd == NULL)
//			Sleep(10);
		Sleep(100);
		if(pScoutingDlg && pScoutingDlg->m_hWnd!=NULL)
			pScoutingDlg->EndDialog(0);
		//pScoutingDlg->DestroyWindow();
		//delete pScoutingDlg;
		//pScoutingDlg=NULL;
		//pScoutingDlg->EndDialog(0);
	}

	SetEvent(hScoutingDoneEvent);
    return 0;    // thread completed successfully
}

	/////////////////////////////////////////////////////////////////////////////
// Simulate dialog


Simulate::Simulate(CWnd* pParent /*=NULL*/)
	: CDialog(Simulate::IDD, pParent)
{
	//{{AFX_DATA_INIT(Simulate)
	m_MASS = 1.;
	m_GRAVITY = 1.;
	m_LENGTH = 2;
	m_DAMPING = 1.5;
	m_FOMEGA = 0.0;
	m_FTHETA = 180.0;
	m_IOMEGA = 0.0;
	m_ITHETA = 0.0;
	m_OMEGATOL = 2;
	m_THETATOL = 2;
	m_IPS = 8;
	m_MAXSTEPS = 250;
	m_NSCOUTS = 10000;
	m_TIMESTEP = 0.025;
	m_MAXINPUT = 8.0;
	m_MININPUT = -8.0;
	m_INPUTSLEW = 0.4;
	m_INPUTTYPE = 1;
	//}}AFX_DATA_INIT

	Create(Simulate::IDD);

	numGraphs=3;
	graph=new GraphDlg*[numGraphs];
	graph[0]=new GraphDlg(0,"Motion Plan");
	graph[1]=new GraphDlg(1,"Control Coefficients");
	graph[2]=new GraphDlg(2,"Input Error");
}

BOOL Simulate::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	CDialog::OnInitDialog();
	AppRestoreWinPos("Simulate", this, FALSE);
	
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

void Simulate::OnClose() 
{
	// TODO: Add your message handler code here and/or call default
	AppSaveWinPos("Simulate", this, TRUE);
	for(int i=0; i<numGraphs; i++)
	{
		if(graph[i])
		{
			graph[i]->DestroyWindow();
			delete graph[i];
		}
	}
	if(graph) delete graph;
	
	CDialog::OnClose();
}

void Simulate::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(Simulate)
	DDX_Text(pDX, IDC_EDIT_MASS, m_MASS);
	DDV_MinMaxDouble(pDX, m_MASS, 0, 100.);
	DDX_Text(pDX, IDC_EDIT_GRAVITY, m_GRAVITY);
	DDV_MinMaxDouble(pDX, m_GRAVITY, 0., 100.);
	DDX_Text(pDX, IDC_EDIT_LENGTH, m_LENGTH);
	DDV_MinMaxDouble(pDX, m_LENGTH, 0.1, 100.);
	DDX_Text(pDX, IDC_EDIT_DAMPING, m_DAMPING);
	DDV_MinMaxDouble(pDX, m_DAMPING, 0., 100.);
	DDX_Text(pDX, IDC_EDIT_FOMEGA, m_FOMEGA);
	DDV_MinMaxDouble(pDX, m_FOMEGA, -360., 360.);
	DDX_Text(pDX, IDC_EDIT_FTHETA, m_FTHETA);
	DDV_MinMaxDouble(pDX, m_FTHETA, -360., 360.);
	DDX_Text(pDX, IDC_EDIT_IOMEGA, m_IOMEGA);
	DDV_MinMaxDouble(pDX, m_IOMEGA, -360., 360.);
	DDX_Text(pDX, IDC_EDIT_ITHETA, m_ITHETA);
	DDV_MinMaxDouble(pDX, m_ITHETA, -360., 360.);
	DDX_Text(pDX, IDC_EDIT_OMEGATOL, m_OMEGATOL);
	DDV_MinMaxDouble(pDX, m_OMEGATOL, 0., 90.);
	DDX_Text(pDX, IDC_EDIT_THETATOL, m_THETATOL);
	DDV_MinMaxDouble(pDX, m_THETATOL, 0., 90.);
	DDX_Text(pDX, IDC_EDIT_IPS, m_IPS);
	DDV_MinMaxInt(pDX, m_IPS, 1, 100);
	DDX_Text(pDX, IDC_EDIT_MAXSTEPS, m_MAXSTEPS);
	DDV_MinMaxInt(pDX, m_MAXSTEPS, 100, 5000);
	DDX_Text(pDX, IDC_EDIT_NSCOUTS, m_NSCOUTS);
	DDV_MinMaxInt(pDX, m_NSCOUTS, 1, 200000);
	DDX_Text(pDX, IDC_EDIT_TIMESTEP, m_TIMESTEP);
	DDV_MinMaxDouble(pDX, m_TIMESTEP, 1.e-003, 10.);
	DDX_Text(pDX, IDC_EDIT_MAXINPUT, m_MAXINPUT);
	DDX_Text(pDX, IDC_EDIT_MININPUT, m_MININPUT);
	DDX_Text(pDX, IDC_EDIT_INPUTSLEW, m_INPUTSLEW);
	DDV_MinMaxDouble(pDX, m_INPUTSLEW, 0., 100.);
	DDX_Text(pDX, IDC_EDIT_INPUTTYPE, m_INPUTTYPE);
	DDV_MinMaxInt(pDX, m_INPUTTYPE, 1, 4);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(Simulate, CDialog)
	//{{AFX_MSG_MAP(Simulate)
	ON_BN_CLICKED(IDC_SIMULATE, OnSimulate)
	ON_WM_CLOSE()
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_MASS, OnDeltaposSpinMass)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_DAMPING, OnDeltaposSpinDamping)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_GRAVITY, OnDeltaposSpinGravity)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_LENGTH, OnDeltaposSpinLength)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_FOMEGA, OnDeltaposSpinFomega)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_FTHETA, OnDeltaposSpinFtheta)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_IOMEGA, OnDeltaposSpinIomega)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_ITHETA, OnDeltaposSpinItheta)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_OMEGATOL, OnDeltaposSpinOmegatol)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_THETATOL, OnDeltaposSpinThetatol)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_IPS, OnDeltaposSpinIps)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_MAXSTEPS, OnDeltaposSpinMaxsteps)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_NSCOUTS, OnDeltaposSpinNscouts)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_TIMESTEP, OnDeltaposSpinTimestep)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_MAXINPUT, OnDeltaposSpinMaxinput)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_MININPUT, OnDeltaposSpinMininput)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_INPUTSLEW, OnDeltaposSpinInputslew)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN_INPUTTYPE, OnDeltaposSpinInputtype)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// Simulate message handlers
CWnd* tempWnd=NULL;
double RadToDeg(double x)
{
	return x*180/PI;
}
double DegToRad(double x)
{
	return x*PI/180;
}
void Simulate::OnSimulate() 
{
	UpdateData();

	int nThreads=1;
	PendulumSimulator* ps=new PendulumSimulator[nThreads];

	int nScoutsPerThread=m_NSCOUTS/nThreads;

	for(int i=0; i<nThreads; i++)
	{
		ps[i].SetInitRand(nScoutsPerThread*i);
		ps[i].SetTimeStep(m_TIMESTEP);
		ps[i].SetMaxDepth(m_MAXSTEPS);
		ps[i].SetNScouts(nScoutsPerThread);
		ps[i].SetM(m_MASS);
		ps[i].SetB(m_DAMPING);
		ps[i].SetG(m_GRAVITY);
		ps[i].SetL(m_LENGTH);
		ps[i].SetInputType((eInputTypes)m_INPUTTYPE);
		ps[i].SetMaxInput(m_MAXINPUT);
		ps[i].SetMinInput(m_MININPUT);
		ps[i].SetInputSlew(m_INPUTSLEW);
		ps[i].SetIPS(m_IPS);
		ps[i].SetInitial(DegToRad(m_ITHETA),DegToRad(m_IOMEGA));
		ps[i].SetFinal(DegToRad(m_FTHETA),DegToRad(m_FOMEGA));
		ps[i].SetTols(DegToRad(m_THETATOL),DegToRad(m_OMEGATOL));
	}

	SetDlgItemText(IDC_STATUS,"Simulating...");
	SetDlgItemText(IDC_STATUS2,"");

	ScoutingDlg scoutingDlg(ps,nThreads);
	pScoutingDlg = &scoutingDlg;
	
	hScoutingDoneEvent = CreateEvent(NULL,FALSE,FALSE,NULL);

	for(i=0; i<nThreads; i++)
		AfxBeginThread(ScoutingThreadProc,&ps[i],THREAD_PRIORITY_NORMAL);

	char buf[128];
	sprintf(buf,"%d threads running",nThreads);
	SetDlgItemText(IDC_STATUS2,buf);

	pScoutingDlg->DoModal();
	pScoutingDlg=NULL;

//	for(i=nThreads; i>0; i--)
//	{
		WaitForSingleObject(hScoutingDoneEvent,INFINITE);
//		sprintf(buf,"%d threads running",i-1);
//		SetDlgItemText(IDC_STATUS2,buf);
//	}

	CloseHandle(hScoutingDoneEvent);

	// determine best
	int bestLen=999999;
	int bestCluster=0;
	for(i=0; i<nThreads; i++)
	{
		int len=ps[i].GetLastLen();
		if(len<bestLen)
		{
			bestLen=len;
			bestCluster=i;
		}
	}

	PendulumSimulator& best=ps[bestCluster];
	if(bestLen>0)
	{

		char* label;
		switch((eInputTypes)m_INPUTTYPE)
		{
			case eForce: label="TORQUE"; break;
			case ePower: label="POWER"; break;
			case eVoltage: label="VOLTAGE"; break;
			case eCurrent: label="CURRENT"; break;
			default: label="???"; break;
		}
		graph[0]->SetDataTimeline(bestLen,3,best.trackT,"Time");
		graph[0]->SetData(0,best.trackTheta,"Theta");
		graph[0]->SetData(1,best.trackOmega,"Omega");
		graph[0]->SetData(2,best.trackInput,label);
		graph[0]->Regraph();

		graph[1]->SetDataTimeline(bestLen,2,best.trackT,"Time");
		graph[1]->SetData(0,best.trackInputA1,"A1");
		graph[1]->SetData(1,best.trackInputA2,"A2");
		graph[1]->Regraph();

		double* inputError=new double[bestLen];
		for(int i=0; i<bestLen; i++)
		{
			double controlInput = 
				best.trackInputA1[i]*(best.trackTheta[i]+100) +
				best.trackInputA2[i]*(best.trackOmega[i]+100)
				- 100;
			inputError[i]=controlInput-best.trackInput[i];
			DMSG(0,"[%3.1lf] %8.3lg %8.3lg cinp=%8.2lf err=%8.2lf",
				best.trackT[i],best.trackInputA1[i],best.trackInputA2[i],
				controlInput,inputError[i]);
		}
		
		graph[2]->SetDataTimeline(bestLen,1,best.trackT,"Time");
		graph[2]->SetData(0,inputError,"Input Error");
		graph[2]->Regraph();
		delete inputError;
	}

	sprintf(buf,"%d steps (%.3lf sec)",bestLen,best.trackT[bestLen-1]);
	SetDlgItemText(IDC_STATUS2,buf);
	sprintf(buf,"Complete. (pa=%d ns=%d gc=%d)",
		best.GetNPA(),best.GetNNS(),best.GetNGC());
	SetDlgItemText(IDC_STATUS,buf);

	//delete ps;
	delete pScoutingDlg;
	
}


void Simulate::OnDeltaposSpinMass(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;
	
	UpdateData();
	dUpdateSpin(m_MASS,-pNMUpDown->iDelta/10.,0,100);
	UpdateData(FALSE);

	*pResult = 0;
}

void Simulate::OnDeltaposSpinDamping(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;
	
	UpdateData();
	dUpdateSpin(m_DAMPING,-pNMUpDown->iDelta/10.,0,100);
	UpdateData(FALSE);
	
	*pResult = 0;
}

void Simulate::OnDeltaposSpinGravity(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;

	UpdateData();
	dUpdateSpin(m_GRAVITY,-pNMUpDown->iDelta/10.,0,100);
	UpdateData(FALSE);

	*pResult = 0;
}

void Simulate::OnDeltaposSpinLength(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;
	
	UpdateData();
	dUpdateSpin(m_LENGTH,-pNMUpDown->iDelta/10.,0.1,100);
	UpdateData(FALSE);
	
	*pResult = 0;
}


void Simulate::OnDeltaposSpinFomega(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;

	UpdateData();
	dUpdateSpin(m_FOMEGA,-pNMUpDown->iDelta,-360,360);
	UpdateData(FALSE);
	
	*pResult = 0;
}

void Simulate::OnDeltaposSpinFtheta(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;

	UpdateData();
	dUpdateSpin(m_FTHETA,-pNMUpDown->iDelta,-360,360);
	UpdateData(FALSE);
	
	*pResult = 0;
}

void Simulate::OnDeltaposSpinIomega(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;
	// TODO: Add your control notification handler code here

	UpdateData();
	dUpdateSpin(m_IOMEGA,-pNMUpDown->iDelta,-360,360);
	UpdateData(FALSE);
	
	*pResult = 0;
}

void Simulate::OnDeltaposSpinItheta(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;

	UpdateData();
	dUpdateSpin(m_ITHETA,-pNMUpDown->iDelta,-360,360);
	UpdateData(FALSE);
	
	*pResult = 0;
}

void Simulate::OnDeltaposSpinOmegatol(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;

	UpdateData();
	dUpdateSpin(m_OMEGATOL,-pNMUpDown->iDelta,0,90);
	UpdateData(FALSE);
	
	*pResult = 0;
}

void Simulate::OnDeltaposSpinThetatol(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;

	UpdateData();
	dUpdateSpin(m_THETATOL,-pNMUpDown->iDelta,0,90);
	UpdateData(FALSE);
	
	*pResult = 0;
}

void Simulate::OnDeltaposSpinIps(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;

	UpdateData();
	iUpdateSpin(m_IPS,-pNMUpDown->iDelta,1,100);
	UpdateData(FALSE);
	
	*pResult = 0;
}


void Simulate::OnDeltaposSpinMaxsteps(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;

	UpdateData();
	iUpdateSpin(m_MAXSTEPS,-pNMUpDown->iDelta,1,200000);
	UpdateData(FALSE);
	
	*pResult = 0;
}

void Simulate::OnDeltaposSpinNscouts(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;

	UpdateData();
	iUpdateSpin(m_NSCOUTS,-pNMUpDown->iDelta,100,5000);
	UpdateData(FALSE);
	
	*pResult = 0;
}

void Simulate::OnDeltaposSpinTimestep(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;

	UpdateData();
	dUpdateSpin(m_TIMESTEP,-pNMUpDown->iDelta/100.,0.001,10);
	UpdateData(FALSE);
	
	*pResult = 0;
}

void Simulate::OnDeltaposSpinMaxinput(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;
	
	UpdateData();
	dUpdateSpin(m_MAXINPUT,-pNMUpDown->iDelta/10.,-100,100);
	UpdateData(FALSE);
	
	*pResult = 0;
}

void Simulate::OnDeltaposSpinMininput(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;

	UpdateData();
	dUpdateSpin(m_MININPUT,-pNMUpDown->iDelta/10.,-100,100);
	UpdateData(FALSE);
	
	*pResult = 0;
}

void Simulate::OnDeltaposSpinInputslew(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;

	UpdateData();
	dUpdateSpin(m_INPUTSLEW,-pNMUpDown->iDelta/100.,.01,.90);
	UpdateData(FALSE);
	
	*pResult = 0;
}

void Simulate::OnDeltaposSpinInputtype(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;

	UpdateData();
	iUpdateSpin(m_INPUTTYPE,-pNMUpDown->iDelta,1,4);
	UpdateData(FALSE);
	
	*pResult = 0;
}

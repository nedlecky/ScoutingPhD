// GraphDlg.cpp : implementation file
//

#include "stdafx.h"
#include "MFCPendulum.h"
#include "GraphDlg.h"
#include "\GrphcSrv\gsw.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// GraphDlg dialog


GraphDlg::GraphDlg(int id,char* title0,CWnd* pParent /*=NULL*/)
	: CDialog(GraphDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(GraphDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	ID=id;
	len=nGroups=0;
	itsWindowNumber=-1;
	timeData=NULL;
	data=NULL;
	legend=NULL;
	title=strdup(title0);
	Create(GraphDlg::IDD);
	xLabel=NULL;
}
GraphDlg::~GraphDlg()
{
	ClearData();
	if(title) delete title;
}

void GraphDlg::ClearData(void)
{
	if(nGroups && legend)
	{
		for(int i=0; i<nGroups; i++)
		{
			delete legend[i];
		}
		delete legend;
	}
	legend=NULL;

	if(timeData) delete timeData;
	timeData=NULL;

	if(data) delete data;
	data=NULL;

	if(xLabel) delete xLabel;
	xLabel=NULL;

	len=0;
	nGroups=0;
}


void GraphDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(GraphDlg)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(GraphDlg, CDialog)
	//{{AFX_MSG_MAP(GraphDlg)
	ON_WM_CLOSE()
	ON_WM_SIZE()
	ON_WM_PAINT()
	ON_WM_DESTROY()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// GraphDlg message handlers


BOOL GraphDlg::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	// TODO: Add extra initialization here

	char buf[128];
	sprintf(buf,"Graph%d",ID);
	AppRestoreWinPos(buf, this, TRUE);

	sprintf(buf,"%s Graph",title);
	SetWindowText(buf);

	Sleep(300);
	double fParentWid = GSGetAXExt(m_hWnd);
	double fParentHt = GSGetAYExt(m_hWnd);
	itsWindowNumber = GSOpenChildWin(m_hWnd,
			           0,0,
			           fParentWid,fParentHt,
			           1000,
			           0,
			           OWMFLEXIBLE | OWMCENTRED,
			           "" );
	GSSetBG(WHITE);
	GSClearView(CLOPAQUE);
	

	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

void GraphDlg::OnClose() 
{
	// TODO: Add your message handler code here and/or call default
	
	GSCloseWin(itsWindowNumber);
	char buf[128];
	sprintf(buf,"Graph%d",ID);
	AppSaveWinPos(buf, this, TRUE);
	CDialog::OnClose();
}

void GraphDlg::OnSize(UINT nType, int cx, int cy) 
{
	if (itsWindowNumber == -1) return;
	CDialog::OnSize(nType, cx, cy);
	if (nType == SIZEFULLSCREEN || nType == SIZE_RESTORED)
	{
		::MoveWindow(GSWinHandle(itsWindowNumber),0,0,cx,cy,TRUE);
		Regraph();
	}
	
	// TODO: Add your message handler code here
}


void GraphDlg::SetDataTimeline(int l,int g,double* x,char* name)
{
	ClearData();

	len=l;
	nGroups=g;

	timeData=new double[len];
	data=new double[len*nGroups];

	if(name) xLabel=strdup(name);

	legend=new char*[nGroups];
	for(int i=0; i<nGroups; i++)
		legend[i]=NULL;

	memcpy(timeData,x,len*sizeof(double));
}


void GraphDlg::SetData(int g,double* x,char* name)
{
	if(g<0 || g>=nGroups) return;

	if(legend[g]!=NULL)
	{
		delete legend[g];
		legend[g]=NULL;
	}
	if(name) legend[g]=strdup(name);

	for(int i=0; i<len; i++)
		data[i*nGroups+g]=x[i];
}

const int patt[]=
{
	LSSOLID,
	LSDASHDOT,
	LSDOT
};

const int color[]=
{
	BLACK,
	GREEN,
	RED
};
void GraphDlg::Regraph(void)
{

	if (len<1 || itsWindowNumber == -1) return;

	GSUseView(itsWindowNumber,0);
	GSClearView(CLOPAQUE);

	AGOpen();

	AGDist(len,(const double*)timeData);
	AGAmp(len,nGroups,(const double*)data);

	AGFontStyle(AGFUSETITG,FOSWISS,FOBOLD,100);
	AGTitleG(title);
	AGTitleX((const char*)xLabel);
	AGLegend(nGroups,(const char**)(legend));
	AGPatt(nGroups,&patt[0]);
	AGClr(nGroups,&color[0]);
	AGLegendStyle(
		0,  // nVert
		0,  // nHoriz
		80, // nSize
		nGroups,  // nClr
		0   // nMode
		);

	//AGTimeGraph(256,1,2,0,0);
	AGShow(
      //AGLOGLIN,
      AGLINE,
      AGLINEYGRID | AGLINEPATT,
      0);
	AGClose();
}

void GraphDlg::OnPaint() 
{
	const BOOL UseWinPaint = TRUE;

	CRect rect;
	GetClientRect(&rect);

	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
//		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
		if (UseWinPaint)
		{
			GSUseView(itsWindowNumber,0);
			GSWinPaint(WPPAINT);
		}
		else
			::InvalidateRect(GSWinHandle(itsWindowNumber),NULL,TRUE);
	}
}

void GraphDlg::OnDestroy() 
{
	GSCloseWin(itsWindowNumber);
	AppSaveWinPos("Graph", this, TRUE);
	CDialog::OnDestroy();
	
	// TODO: Add your message handler code here
	
}

// ScoutingDlg.cpp : implementation file
//

#include "stdafx.h"
#include "MFCPendulum.h"
#include "ScoutingDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// ScoutingDlg dialog


ScoutingDlg::ScoutingDlg(PendulumSimulator* ps0,int nClusters0)
	: CDialog(ScoutingDlg::IDD, NULL)
{
	nClusters=nClusters0;
	ps=ps0;
	//Create(ScoutingDlg::IDD);
	//{{AFX_DATA_INIT(ScoutingDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}
ScoutingDlg::ScoutingDlg(CWnd* pParent /*=NULL*/)
	: CDialog(ScoutingDlg::IDD, pParent)
{
	ps=NULL;
	//Create(ScoutingDlg::IDD);
	//{{AFX_DATA_INIT(ScoutingDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void ScoutingDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(ScoutingDlg)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(ScoutingDlg, CDialog)
	//{{AFX_MSG_MAP(ScoutingDlg)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// ScoutingDlg message handlers

void ScoutingDlg::OnCancel() 
{
	// TODO: Add extra cleanup here
	if(ps)
	{
		for(int i=0; i<nClusters; i++)
			ps[i].AbortScouting();
	}
	
	CDialog::OnCancel();
}

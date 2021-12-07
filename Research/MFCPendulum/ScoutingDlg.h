#if !defined(AFX_SCOUTINGDLG_H__F3111D41_FE8D_11D1_BB96_00104B641283__INCLUDED_)
#define AFX_SCOUTINGDLG_H__F3111D41_FE8D_11D1_BB96_00104B641283__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#include "PendSim.h"

// ScoutingDlg.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// ScoutingDlg dialog

class ScoutingDlg : public CDialog
{
// Construction
public:
	ScoutingDlg(PendulumSimulator* ps0,int nClusters0);
	ScoutingDlg(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(ScoutingDlg)
	enum { IDD = IDD_SCOUTING_DLG };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(ScoutingDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	int nClusters;
	PendulumSimulator* ps;

	// Generated message map functions
	//{{AFX_MSG(ScoutingDlg)
	virtual void OnCancel();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_SCOUTINGDLG_H__F3111D41_FE8D_11D1_BB96_00104B641283__INCLUDED_)

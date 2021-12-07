// MFCPendulum.h : main header file for the MFCPENDULUM application
//

#if !defined(AFX_MFCPENDULUM_H__85946174_FBFD_11D1_BB94_00104B641283__INCLUDED_)
#define AFX_MFCPENDULUM_H__85946174_FBFD_11D1_BB94_00104B641283__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMFCPendulumApp:
// See MFCPendulum.cpp for the implementation of this class
//

class CMFCPendulumApp : public CWinApp
{
public:
	CMFCPendulumApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMFCPendulumApp)
	public:
	virtual BOOL InitInstance();
	virtual int ExitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CMFCPendulumApp)
	afx_msg void OnAppAbout();
	afx_msg void OnSimulateGo();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MFCPENDULUM_H__85946174_FBFD_11D1_BB94_00104B641283__INCLUDED_)

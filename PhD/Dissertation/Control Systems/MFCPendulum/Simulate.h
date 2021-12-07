#if !defined(AFX_SIMULATE_H__85946185_FBFD_11D1_BB94_00104B641283__INCLUDED_)
#define AFX_SIMULATE_H__85946185_FBFD_11D1_BB94_00104B641283__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#include "GraphDlg.h"
#include "\GrphcSrv\gsw.h"
// Simulate.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// Simulate dialog

class Simulate : public CDialog
{
// Construction
public:
	Simulate(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(Simulate)
	enum { IDD = IDD_SIMULATE };
	double	m_MASS;
	double	m_GRAVITY;
	double	m_LENGTH;
	double	m_DAMPING;
	double	m_FOMEGA;
	double	m_FTHETA;
	double	m_IOMEGA;
	double	m_ITHETA;
	double	m_OMEGATOL;
	double	m_THETATOL;
	int		m_IPS;
	int		m_MAXSTEPS;
	int		m_NSCOUTS;
	double	m_TIMESTEP;
	double	m_MAXINPUT;
	double	m_MININPUT;
	double	m_INPUTSLEW;
	int		m_INPUTTYPE;
	//}}AFX_DATA

	int numGraphs;
	GraphDlg** graph;

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(Simulate)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(Simulate)
	afx_msg void OnSimulate();
	virtual BOOL OnInitDialog();
	afx_msg void OnClose();
	afx_msg void OnDeltaposSpinMass(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinDamping(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinGravity(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinLength(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinFomega(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinFtheta(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinIomega(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinItheta(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinOmegatol(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinThetatol(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinIps(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinMaxsteps(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinNscouts(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinTimestep(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinMaxinput(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinMininput(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinInputslew(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDeltaposSpinInputtype(NMHDR* pNMHDR, LRESULT* pResult);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_SIMULATE_H__85946185_FBFD_11D1_BB94_00104B641283__INCLUDED_)

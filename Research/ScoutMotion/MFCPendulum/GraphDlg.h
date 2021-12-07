#if !defined(AFX_GRAPHDLG_H__ED97E592_FC2E_11D1_BB96_00104B641283__INCLUDED_)
#define AFX_GRAPHDLG_H__ED97E592_FC2E_11D1_BB96_00104B641283__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000
// GraphDlg.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// GraphDlg dialog

class GraphDlg : public CDialog
{
// Construction
public:
	GraphDlg(int ID,char* title0,CWnd* pParent = NULL);   // standard constructor
	~GraphDlg();
	void ClearData(void);
	void Regraph(void);
	void SetDataTimeline(int l,int g,double* x,char* name);
	void SetData(int g,double* y0,char* name);

// Dialog Data
	//{{AFX_DATA(GraphDlg)
	enum { IDD = IDD_GRAPH };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(GraphDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(GraphDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnClose();
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnPaint();
	afx_msg void OnDestroy();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

		int ID;
		int itsWindowNumber;
		int len;
		int nGroups;
		double* timeData;
		double* data;
		char** legend;
		char* title;
		char* xLabel;
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_GRAPHDLG_H__ED97E592_FC2E_11D1_BB96_00104B641283__INCLUDED_)

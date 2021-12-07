// MFCPendulumView.h : interface of the CMFCPendulumView class
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_MFCPENDULUMVIEW_H__8594617C_FBFD_11D1_BB94_00104B641283__INCLUDED_)
#define AFX_MFCPENDULUMVIEW_H__8594617C_FBFD_11D1_BB94_00104B641283__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

class CMFCPendulumView : public CView
{
protected: // create from serialization only
	CMFCPendulumView();
	DECLARE_DYNCREATE(CMFCPendulumView)

// Attributes
public:
	CMFCPendulumDoc* GetDocument();

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMFCPendulumView)
	public:
	virtual void OnDraw(CDC* pDC);  // overridden to draw this view
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	protected:
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo);
	virtual void OnBeginPrinting(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnEndPrinting(CDC* pDC, CPrintInfo* pInfo);
	//}}AFX_VIRTUAL

// Implementation
public:
	virtual ~CMFCPendulumView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	//{{AFX_MSG(CMFCPendulumView)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

#ifndef _DEBUG  // debug version in MFCPendulumView.cpp
inline CMFCPendulumDoc* CMFCPendulumView::GetDocument()
   { return (CMFCPendulumDoc*)m_pDocument; }
#endif

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MFCPENDULUMVIEW_H__8594617C_FBFD_11D1_BB94_00104B641283__INCLUDED_)

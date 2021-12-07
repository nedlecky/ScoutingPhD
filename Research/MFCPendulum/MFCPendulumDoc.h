// MFCPendulumDoc.h : interface of the CMFCPendulumDoc class
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_MFCPENDULUMDOC_H__8594617A_FBFD_11D1_BB94_00104B641283__INCLUDED_)
#define AFX_MFCPENDULUMDOC_H__8594617A_FBFD_11D1_BB94_00104B641283__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000


class CMFCPendulumDoc : public CDocument
{
protected: // create from serialization only
	CMFCPendulumDoc();
	DECLARE_DYNCREATE(CMFCPendulumDoc)

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMFCPendulumDoc)
	public:
	virtual BOOL OnNewDocument();
	virtual void Serialize(CArchive& ar);
	//}}AFX_VIRTUAL

// Implementation
public:
	virtual ~CMFCPendulumDoc();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	//{{AFX_MSG(CMFCPendulumDoc)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MFCPENDULUMDOC_H__8594617A_FBFD_11D1_BB94_00104B641283__INCLUDED_)

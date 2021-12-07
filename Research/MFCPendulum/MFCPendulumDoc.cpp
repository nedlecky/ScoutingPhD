// MFCPendulumDoc.cpp : implementation of the CMFCPendulumDoc class
//

#include "stdafx.h"
#include "MFCPendulum.h"

#include "MFCPendulumDoc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CMFCPendulumDoc

IMPLEMENT_DYNCREATE(CMFCPendulumDoc, CDocument)

BEGIN_MESSAGE_MAP(CMFCPendulumDoc, CDocument)
	//{{AFX_MSG_MAP(CMFCPendulumDoc)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code!
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CMFCPendulumDoc construction/destruction

CMFCPendulumDoc::CMFCPendulumDoc()
{
	// TODO: add one-time construction code here

}

CMFCPendulumDoc::~CMFCPendulumDoc()
{
}

BOOL CMFCPendulumDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	// TODO: add reinitialization code here
	// (SDI documents will reuse this document)

	return TRUE;
}



/////////////////////////////////////////////////////////////////////////////
// CMFCPendulumDoc serialization

void CMFCPendulumDoc::Serialize(CArchive& ar)
{
	if (ar.IsStoring())
	{
		// TODO: add storing code here
	}
	else
	{
		// TODO: add loading code here
	}
}

/////////////////////////////////////////////////////////////////////////////
// CMFCPendulumDoc diagnostics

#ifdef _DEBUG
void CMFCPendulumDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CMFCPendulumDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CMFCPendulumDoc commands

// MFCPendulumView.cpp : implementation of the CMFCPendulumView class
//

#include "stdafx.h"
#include "MFCPendulum.h"

#include "MFCPendulumDoc.h"
#include "MFCPendulumView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CMFCPendulumView

IMPLEMENT_DYNCREATE(CMFCPendulumView, CView)

BEGIN_MESSAGE_MAP(CMFCPendulumView, CView)
	//{{AFX_MSG_MAP(CMFCPendulumView)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code!
	//}}AFX_MSG_MAP
	// Standard printing commands
	ON_COMMAND(ID_FILE_PRINT, CView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, CView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, CView::OnFilePrintPreview)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CMFCPendulumView construction/destruction

CMFCPendulumView::CMFCPendulumView()
{
	// TODO: add construction code here

}

CMFCPendulumView::~CMFCPendulumView()
{
}

BOOL CMFCPendulumView::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	return CView::PreCreateWindow(cs);
}

/////////////////////////////////////////////////////////////////////////////
// CMFCPendulumView drawing

void CMFCPendulumView::OnDraw(CDC* pDC)
{
	CMFCPendulumDoc* pDoc = GetDocument();
	ASSERT_VALID(pDoc);

	// TODO: add draw code for native data here
}

/////////////////////////////////////////////////////////////////////////////
// CMFCPendulumView printing

BOOL CMFCPendulumView::OnPreparePrinting(CPrintInfo* pInfo)
{
	// default preparation
	return DoPreparePrinting(pInfo);
}

void CMFCPendulumView::OnBeginPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add extra initialization before printing
}

void CMFCPendulumView::OnEndPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add cleanup after printing
}

/////////////////////////////////////////////////////////////////////////////
// CMFCPendulumView diagnostics

#ifdef _DEBUG
void CMFCPendulumView::AssertValid() const
{
	CView::AssertValid();
}

void CMFCPendulumView::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}

CMFCPendulumDoc* CMFCPendulumView::GetDocument() // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CMFCPendulumDoc)));
	return (CMFCPendulumDoc*)m_pDocument;
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CMFCPendulumView message handlers

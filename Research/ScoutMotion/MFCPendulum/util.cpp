#include "stdafx.h"
#include "MFCPendulum.h"
#include "util.h"

extern CMFCPendulumApp theApp;
UINT AppGetProfileInt( LPCTSTR lpszSection, LPCTSTR lpszEntry, int nDefault )
{
	return theApp.GetProfileInt(lpszSection,lpszEntry,nDefault);
}
CString AppGetProfileString( LPCTSTR lpszSection, LPCTSTR lpszEntry)
{
	return theApp.GetProfileString(lpszSection,lpszEntry,NULL);  
}
BOOL AppWriteProfileString( LPCTSTR lpszSection, LPCTSTR lpszEntry, LPCTSTR lpszValue )
{
	return theApp.WriteProfileString(lpszSection,lpszEntry,lpszValue);
}
BOOL AppWriteProfileInt( LPCTSTR lpszSection, LPCTSTR lpszEntry, int nValue)
{
	return theApp.WriteProfileInt(lpszSection,lpszEntry,nValue);
}
void AppRestoreWinPos(LPCTSTR lpszSection, CWnd* wnd, BOOL four_sides)
{
	WINDOWPLACEMENT wndpl;
    wndpl.length = sizeof(WINDOWPLACEMENT);
	ASSERT(wnd);
	wnd->GetWindowPlacement(&wndpl);
	int w = wndpl.rcNormalPosition.right-wndpl.rcNormalPosition.left;
	int h = wndpl.rcNormalPosition.bottom-wndpl.rcNormalPosition.top;
	wndpl.rcNormalPosition.left = AppGetProfileInt(lpszSection, "PosLeft", wndpl.rcNormalPosition.left);
	wndpl.rcNormalPosition.top = AppGetProfileInt(lpszSection, "PosTop", wndpl.rcNormalPosition.top);
	if (four_sides)
	{
		wndpl.rcNormalPosition.right = AppGetProfileInt(lpszSection, "PosRight", wndpl.rcNormalPosition.right);
		wndpl.rcNormalPosition.bottom = AppGetProfileInt(lpszSection, "PosBottom", wndpl.rcNormalPosition.bottom);
		wndpl.showCmd = AppGetProfileInt(lpszSection, "ShowCmd", wndpl.showCmd);
	}
	else
	{
		wndpl.rcNormalPosition.right = wndpl.rcNormalPosition.left+w;
		wndpl.rcNormalPosition.bottom = wndpl.rcNormalPosition.top+h;
	}
	wnd->SetWindowPlacement(&wndpl);
}

void AppSaveWinPos(LPCTSTR lpszSection, CWnd* wnd, BOOL four_sides)
{
	WINDOWPLACEMENT wndpl;
    wndpl.length = sizeof(WINDOWPLACEMENT);
	ASSERT(wnd);
	wnd->GetWindowPlacement(&wndpl);
	AppWriteProfileInt(lpszSection, "PosLeft", wndpl.rcNormalPosition.left);
	AppWriteProfileInt(lpszSection, "PosTop", wndpl.rcNormalPosition.top);
	if (four_sides)
	{
		AppWriteProfileInt(lpszSection, "PosRight", wndpl.rcNormalPosition.right);
		AppWriteProfileInt(lpszSection, "PosBottom", wndpl.rcNormalPosition.bottom);
		AppWriteProfileInt(lpszSection, "ShowCmd", wndpl.showCmd);
	}
}

void dUpdateSpin(double& d,double incr,double dmin,double dmax)
{
	d += incr;

	if(d<dmin) d=dmin;
	if(d>dmax) d=dmax;
}

void iUpdateSpin(int& i,int incr,int imin,int imax)
{
	i += incr;

	if(i<imin) i=imin;
	if(i>imax) i=imax;
}



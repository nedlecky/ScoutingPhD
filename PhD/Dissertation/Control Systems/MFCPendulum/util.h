#if !defined(UTIL_H)
#define UTIL_H

const double PI=3.1415926535897932;
UINT AppGetProfileInt( LPCTSTR lpszSection, LPCTSTR lpszEntry, int nDefault );
CString AppGetProfileString( LPCTSTR lpszSection, LPCTSTR lpszEntry);
BOOL AppWriteProfileString( LPCTSTR lpszSection, LPCTSTR lpszEntry, LPCTSTR lpszValue );
BOOL AppWriteProfileInt( LPCTSTR lpszSection, LPCTSTR lpszEntry, int nValue);
void AppRestoreWinPos(LPCTSTR lpszSection, CWnd* wnd, BOOL four_sides);
void AppSaveWinPos(LPCTSTR lpszSection, CWnd* wnd, BOOL four_sides);
void dUpdateSpin(double& d,double incr,double dmin,double dmax);
void iUpdateSpin(int& i,int incr,int imin,int imax);

#endif
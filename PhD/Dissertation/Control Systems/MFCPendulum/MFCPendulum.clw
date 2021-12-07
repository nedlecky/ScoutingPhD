; CLW file contains information for the MFC ClassWizard

[General Info]
Version=1
LastClass=Simulate
LastTemplate=CDialog
NewFileInclude1=#include "stdafx.h"
NewFileInclude2=#include "MFCPendulum.h"
LastPage=0

ClassCount=8
Class1=CMFCPendulumApp
Class2=CMFCPendulumDoc
Class3=CMFCPendulumView
Class4=CMainFrame

ResourceCount=5
Resource1=IDD_GRAPH
Resource2=IDD_SCOUTING_DLG
Class5=CAboutDlg
Class6=Simulate
Resource3=IDR_MAINFRAME
Class7=GraphDlg
Resource4=IDD_ABOUTBOX
Class8=ScoutingDlg
Resource5=IDD_SIMULATE

[CLS:CMFCPendulumApp]
Type=0
HeaderFile=MFCPendulum.h
ImplementationFile=MFCPendulum.cpp
Filter=N
LastObject=CMFCPendulumApp
BaseClass=CWinApp
VirtualFilter=AC

[CLS:CMFCPendulumDoc]
Type=0
HeaderFile=MFCPendulumDoc.h
ImplementationFile=MFCPendulumDoc.cpp
Filter=N
LastObject=CMFCPendulumDoc

[CLS:CMFCPendulumView]
Type=0
HeaderFile=MFCPendulumView.h
ImplementationFile=MFCPendulumView.cpp
Filter=C
LastObject=CMFCPendulumView

[CLS:CMainFrame]
Type=0
HeaderFile=MainFrm.h
ImplementationFile=MainFrm.cpp
Filter=T
LastObject=CMainFrame
BaseClass=CFrameWnd
VirtualFilter=fWC



[CLS:CAboutDlg]
Type=0
HeaderFile=MFCPendulum.cpp
ImplementationFile=MFCPendulum.cpp
Filter=D
LastObject=ID_APP_ABOUT

[DLG:IDD_ABOUTBOX]
Type=1
Class=CAboutDlg
ControlCount=4
Control1=IDC_STATIC,static,1342177283
Control2=IDC_STATIC,static,1342308480
Control3=IDC_STATIC,static,1342308352
Control4=IDOK,button,1342373889

[MNU:IDR_MAINFRAME]
Type=1
Class=CMainFrame
Command1=ID_FILE_NEW
Command2=ID_FILE_OPEN
Command3=ID_FILE_SAVE
Command4=ID_FILE_SAVE_AS
Command5=ID_FILE_PRINT
Command6=ID_FILE_PRINT_PREVIEW
Command7=ID_FILE_PRINT_SETUP
Command8=ID_FILE_MRU_FILE1
Command9=ID_APP_EXIT
Command10=ID_EDIT_UNDO
Command11=ID_EDIT_CUT
Command12=ID_EDIT_COPY
Command13=ID_EDIT_PASTE
Command14=ID_SIMULATE_GO
Command15=ID_VIEW_TOOLBAR
Command16=ID_VIEW_STATUS_BAR
Command17=ID_APP_ABOUT
CommandCount=17

[ACL:IDR_MAINFRAME]
Type=1
Class=CMainFrame
Command1=ID_FILE_NEW
Command2=ID_FILE_OPEN
Command3=ID_FILE_SAVE
Command4=ID_FILE_PRINT
Command5=ID_EDIT_UNDO
Command6=ID_EDIT_CUT
Command7=ID_EDIT_COPY
Command8=ID_EDIT_PASTE
Command9=ID_EDIT_UNDO
Command10=ID_EDIT_CUT
Command11=ID_EDIT_COPY
Command12=ID_EDIT_PASTE
Command13=ID_NEXT_PANE
Command14=ID_PREV_PANE
CommandCount=14

[TB:IDR_MAINFRAME]
Type=1
Class=?
Command1=ID_FILE_NEW
Command2=ID_FILE_OPEN
Command3=ID_FILE_SAVE
Command4=ID_EDIT_CUT
Command5=ID_EDIT_COPY
Command6=ID_EDIT_PASTE
Command7=ID_APP_ABOUT
Command8=ID_FILE_PRINT
CommandCount=8

[DLG:IDD_SIMULATE]
Type=1
Class=Simulate
ControlCount=62
Control1=IDC_STATUS,static,1350701056
Control2=IDC_SIMULATE,button,1342242816
Control3=IDC_STATIC,button,1342177287
Control4=IDC_STATIC,static,1342308354
Control5=IDC_EDIT_MASS,edit,1350631552
Control6=IDC_SPIN_MASS,msctls_updown32,1342177312
Control7=IDC_STATIC,static,1342308354
Control8=IDC_STATIC,static,1342308354
Control9=IDC_STATIC,static,1342308354
Control10=IDC_EDIT_DAMPING,edit,1350631552
Control11=IDC_EDIT_LENGTH,edit,1350631552
Control12=IDC_EDIT_GRAVITY,edit,1350631552
Control13=IDC_SPIN_DAMPING,msctls_updown32,1342177320
Control14=IDC_SPIN_LENGTH,msctls_updown32,1342177320
Control15=IDC_SPIN_GRAVITY,msctls_updown32,1342177320
Control16=IDC_STATIC,button,1342177287
Control17=IDC_STATIC,static,1342308354
Control18=IDC_EDIT_MAXINPUT,edit,1350631552
Control19=IDC_SPIN_MAXINPUT,msctls_updown32,1342177320
Control20=IDC_STATIC,static,1342308354
Control21=IDC_EDIT_ITHETA,edit,1350631552
Control22=IDC_SPIN_ITHETA,msctls_updown32,1342177320
Control23=IDC_STATIC,static,1342308354
Control24=IDC_EDIT_IOMEGA,edit,1350631552
Control25=IDC_SPIN_IOMEGA,msctls_updown32,1342177320
Control26=IDC_STATIC,button,1342177287
Control27=IDC_STATIC,static,1342308354
Control28=IDC_EDIT_FTHETA,edit,1350631552
Control29=IDC_SPIN_FTHETA,msctls_updown32,1342177320
Control30=IDC_STATIC,static,1342308354
Control31=IDC_EDIT_FOMEGA,edit,1350631552
Control32=IDC_SPIN_FOMEGA,msctls_updown32,1342177320
Control33=IDC_STATIC,static,1342308354
Control34=IDC_EDIT_THETATOL,edit,1350631552
Control35=IDC_SPIN_THETATOL,msctls_updown32,1342177320
Control36=IDC_STATIC,static,1342308354
Control37=IDC_EDIT_OMEGATOL,edit,1350631552
Control38=IDC_SPIN_OMEGATOL,msctls_updown32,1342177320
Control39=IDC_STATIC,static,1342312449
Control40=IDC_STATIC,static,1342308354
Control41=IDC_EDIT_IPS,edit,1350631552
Control42=IDC_SPIN_IPS,msctls_updown32,1342177320
Control43=IDC_STATUS2,static,1350701056
Control44=IDC_STATIC,static,1342308354
Control45=IDC_EDIT_NSCOUTS,edit,1350631552
Control46=IDC_SPIN_NSCOUTS,msctls_updown32,1342177320
Control47=IDC_STATIC,static,1342308354
Control48=IDC_EDIT_MAXSTEPS,edit,1350631552
Control49=IDC_SPIN_MAXSTEPS,msctls_updown32,1342177320
Control50=IDC_STATIC,button,1342177287
Control51=IDC_STATIC,static,1342308354
Control52=IDC_EDIT_TIMESTEP,edit,1350631552
Control53=IDC_SPIN_TIMESTEP,msctls_updown32,1342177320
Control54=IDC_STATIC,static,1342308354
Control55=IDC_EDIT_MININPUT,edit,1350631552
Control56=IDC_SPIN_MININPUT,msctls_updown32,1342177320
Control57=IDC_STATIC,static,1342308354
Control58=IDC_EDIT_INPUTSLEW,edit,1350631552
Control59=IDC_SPIN_INPUTSLEW,msctls_updown32,1342177320
Control60=IDC_STATIC,static,1342308354
Control61=IDC_EDIT_INPUTTYPE,edit,1350631552
Control62=IDC_SPIN_INPUTTYPE,msctls_updown32,1342177320

[CLS:Simulate]
Type=0
HeaderFile=Simulate.h
ImplementationFile=Simulate.cpp
BaseClass=CDialog
Filter=D
VirtualFilter=dWC
LastObject=IDC_EDIT_DAMPING

[DLG:IDD_GRAPH]
Type=1
Class=GraphDlg
ControlCount=0

[CLS:GraphDlg]
Type=0
HeaderFile=GraphDlg.h
ImplementationFile=GraphDlg.cpp
BaseClass=CDialog
Filter=D
LastObject=GraphDlg
VirtualFilter=dWC

[DLG:IDD_SCOUTING_DLG]
Type=1
Class=ScoutingDlg
ControlCount=2
Control1=IDCANCEL,button,1342242816
Control2=IDC_STATIC,static,1342308353

[CLS:ScoutingDlg]
Type=0
HeaderFile=ScoutingDlg.h
ImplementationFile=ScoutingDlg.cpp
BaseClass=CDialog
Filter=D
VirtualFilter=dWC
LastObject=ScoutingDlg


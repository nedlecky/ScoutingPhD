VERSION 5.00
Begin VB.Form MainForm 
   Caption         =   "Tic Tac Toe"
   ClientHeight    =   6165
   ClientLeft      =   2550
   ClientTop       =   3135
   ClientWidth     =   6030
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6165
   ScaleWidth      =   6030
   Begin VB.CheckBox HaltOWinChk 
      Caption         =   "Halt O Win"
      Height          =   255
      Left            =   4680
      TabIndex        =   65
      Top             =   4320
      Width           =   1095
   End
   Begin VB.CheckBox HaltXWinChk 
      Caption         =   "Halt X Win"
      Height          =   255
      Left            =   4680
      TabIndex        =   63
      Top             =   3960
      Width           =   1215
   End
   Begin VB.Frame statFrm 
      Caption         =   "Stats"
      Height          =   1335
      Left            =   120
      TabIndex        =   38
      Top             =   4560
      Width           =   5655
      Begin VB.CommandButton clearBtn 
         Caption         =   "Clear"
         Height          =   615
         Left            =   4680
         TabIndex        =   45
         Top             =   360
         Width           =   735
      End
      Begin VB.Label ncatFld 
         BorderStyle     =   1  'Fixed Single
         Caption         =   "0"
         Height          =   255
         Left            =   2160
         TabIndex        =   44
         Top             =   720
         Width           =   855
      End
      Begin VB.Label Label4 
         Alignment       =   2  'Center
         Caption         =   "Cat Wins"
         Height          =   255
         Left            =   2160
         TabIndex        =   43
         Top             =   360
         Width           =   855
      End
      Begin VB.Label noFld 
         BorderStyle     =   1  'Fixed Single
         Caption         =   "0"
         Height          =   255
         Left            =   1200
         TabIndex        =   42
         Top             =   720
         Width           =   855
      End
      Begin VB.Label Label2 
         Alignment       =   2  'Center
         Caption         =   "O Wins"
         Height          =   255
         Left            =   1200
         TabIndex        =   41
         Top             =   360
         Width           =   855
      End
      Begin VB.Label nxFld 
         BorderStyle     =   1  'Fixed Single
         Caption         =   "0"
         Height          =   255
         Left            =   120
         TabIndex        =   40
         Top             =   720
         Width           =   855
      End
      Begin VB.Label Label1 
         Alignment       =   2  'Center
         Caption         =   "X Wins"
         Height          =   255
         Left            =   120
         TabIndex        =   39
         Top             =   360
         Width           =   855
      End
   End
   Begin VB.CommandButton HaltBtn 
      Caption         =   "Halt"
      Enabled         =   0   'False
      Height          =   375
      Left            =   4680
      TabIndex        =   37
      Top             =   3480
      Width           =   975
   End
   Begin VB.CommandButton CycleBtn 
      Caption         =   "Cycle"
      Height          =   375
      Left            =   3600
      TabIndex        =   36
      Top             =   3480
      Width           =   975
   End
   Begin VB.Frame XAlgorithmFrm 
      Caption         =   "Algorithm"
      Height          =   2775
      Left            =   3600
      TabIndex        =   31
      Top             =   120
      Width           =   2055
      Begin VB.OptionButton AlgRadio 
         Caption         =   "Smart All"
         Height          =   255
         Index           =   8
         Left            =   120
         TabIndex        =   66
         Top             =   2400
         Value           =   -1  'True
         Width           =   1335
      End
      Begin VB.OptionButton AlgRadio 
         Caption         =   "Smart ForceS"
         Height          =   255
         Index           =   7
         Left            =   120
         TabIndex        =   60
         Top             =   2160
         Width           =   1335
      End
      Begin VB.OptionButton AlgRadio 
         Caption         =   "Smart Ahead2"
         Height          =   255
         Index           =   6
         Left            =   120
         TabIndex        =   58
         Top             =   1920
         Width           =   1335
      End
      Begin VB.OptionButton AlgRadio 
         Caption         =   "Smart Ahead"
         Height          =   255
         Index           =   5
         Left            =   120
         TabIndex        =   56
         Top             =   1680
         Width           =   1335
      End
      Begin VB.OptionButton AlgRadio 
         Caption         =   "Smart Crnr"
         Height          =   255
         Index           =   4
         Left            =   120
         TabIndex        =   54
         Top             =   1440
         Width           =   1335
      End
      Begin VB.Frame Frame1 
         Height          =   2775
         Left            =   1560
         TabIndex        =   48
         Top             =   0
         Width           =   495
         Begin VB.OptionButton OAlgRadio 
            Height          =   255
            Index           =   8
            Left            =   120
            TabIndex        =   67
            Top             =   2400
            Value           =   -1  'True
            Width           =   255
         End
         Begin VB.OptionButton OAlgRadio 
            Height          =   255
            Index           =   7
            Left            =   120
            TabIndex        =   61
            Top             =   2160
            Width           =   255
         End
         Begin VB.OptionButton OAlgRadio 
            Height          =   255
            Index           =   6
            Left            =   120
            TabIndex        =   59
            Top             =   1920
            Width           =   255
         End
         Begin VB.OptionButton OAlgRadio 
            Height          =   255
            Index           =   5
            Left            =   120
            TabIndex        =   57
            Top             =   1680
            Width           =   255
         End
         Begin VB.OptionButton OAlgRadio 
            Height          =   255
            Index           =   4
            Left            =   120
            TabIndex        =   55
            Top             =   1440
            Width           =   255
         End
         Begin VB.OptionButton OAlgRadio 
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   52
            Top             =   480
            Width           =   255
         End
         Begin VB.OptionButton OAlgRadio 
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   51
            Top             =   720
            Width           =   255
         End
         Begin VB.OptionButton OAlgRadio 
            Height          =   255
            Index           =   2
            Left            =   120
            TabIndex        =   50
            Top             =   960
            Width           =   255
         End
         Begin VB.OptionButton OAlgRadio 
            Height          =   255
            Index           =   3
            Left            =   120
            TabIndex        =   49
            Top             =   1200
            Width           =   255
         End
         Begin VB.Label Label5 
            Alignment       =   2  'Center
            Caption         =   "O"
            Height          =   255
            Left            =   120
            TabIndex        =   53
            Top             =   240
            Width           =   255
         End
      End
      Begin VB.OptionButton AlgRadio 
         Caption         =   "Smart Random"
         Height          =   255
         Index           =   3
         Left            =   120
         TabIndex        =   35
         Top             =   1200
         Width           =   1455
      End
      Begin VB.OptionButton AlgRadio 
         Caption         =   "Smart Seq"
         Height          =   255
         Index           =   2
         Left            =   120
         TabIndex        =   34
         Top             =   960
         Width           =   1455
      End
      Begin VB.OptionButton AlgRadio 
         Caption         =   "Random"
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   33
         Top             =   720
         Width           =   1335
      End
      Begin VB.OptionButton AlgRadio 
         Caption         =   "Sequential"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   32
         Top             =   480
         Width           =   1455
      End
      Begin VB.Label Label3 
         Alignment       =   2  'Center
         Caption         =   "X"
         Height          =   255
         Left            =   120
         TabIndex        =   47
         Top             =   240
         Width           =   255
      End
   End
   Begin VB.CommandButton Auto1Btn 
      Caption         =   "Make One Move"
      Height          =   495
      Left            =   3600
      TabIndex        =   30
      Top             =   3960
      Width           =   975
   End
   Begin VB.CommandButton NewGameBtn 
      Caption         =   "New Game"
      Height          =   375
      Left            =   3600
      TabIndex        =   29
      Top             =   3000
      Width           =   975
   End
   Begin VB.CommandButton ExitBtn 
      Caption         =   "Exit"
      Height          =   375
      Left            =   4680
      TabIndex        =   28
      Top             =   3000
      Width           =   975
   End
   Begin VB.Frame GameFrame 
      Caption         =   "The Game"
      Height          =   3975
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   3375
      Begin VB.CheckBox autoChk 
         Caption         =   "Computer goes auto!"
         Height          =   255
         Left            =   120
         TabIndex        =   64
         Top             =   3240
         Value           =   1  'Checked
         Width           =   2175
      End
      Begin VB.CheckBox animateChk 
         Caption         =   "Animate"
         Height          =   195
         Left            =   2280
         TabIndex        =   62
         Top             =   3240
         Value           =   1  'Checked
         Width           =   975
      End
      Begin VB.CommandButton Obtn 
         Caption         =   "O"
         Height          =   255
         Index           =   8
         Left            =   2640
         TabIndex        =   27
         Top             =   2880
         Width           =   375
      End
      Begin VB.CommandButton Xbtn 
         Caption         =   "X"
         Height          =   255
         Index           =   8
         Left            =   2280
         TabIndex        =   26
         Top             =   2880
         Width           =   375
      End
      Begin VB.CommandButton Obtn 
         Caption         =   "O"
         Height          =   255
         Index           =   7
         Left            =   1680
         TabIndex        =   24
         Top             =   2880
         Width           =   375
      End
      Begin VB.CommandButton Xbtn 
         Caption         =   "X"
         Height          =   255
         Index           =   7
         Left            =   1320
         TabIndex        =   23
         Top             =   2880
         Width           =   375
      End
      Begin VB.CommandButton Obtn 
         Caption         =   "O"
         Height          =   255
         Index           =   6
         Left            =   720
         TabIndex        =   21
         Top             =   2880
         Width           =   375
      End
      Begin VB.CommandButton Xbtn 
         Caption         =   "X"
         Height          =   255
         Index           =   6
         Left            =   360
         TabIndex        =   20
         Top             =   2880
         Width           =   375
      End
      Begin VB.CommandButton Obtn 
         Caption         =   "O"
         Height          =   255
         Index           =   5
         Left            =   2640
         TabIndex        =   18
         Top             =   1920
         Width           =   375
      End
      Begin VB.CommandButton Xbtn 
         Caption         =   "X"
         Height          =   255
         Index           =   5
         Left            =   2280
         TabIndex        =   17
         Top             =   1920
         Width           =   375
      End
      Begin VB.CommandButton Obtn 
         Caption         =   "O"
         Height          =   255
         Index           =   4
         Left            =   1680
         TabIndex        =   15
         Top             =   1920
         Width           =   375
      End
      Begin VB.CommandButton Xbtn 
         Caption         =   "X"
         Height          =   255
         Index           =   4
         Left            =   1320
         TabIndex        =   14
         Top             =   1920
         Width           =   375
      End
      Begin VB.CommandButton Obtn 
         Caption         =   "O"
         Height          =   255
         Index           =   3
         Left            =   720
         TabIndex        =   12
         Top             =   1920
         Width           =   375
      End
      Begin VB.CommandButton Xbtn 
         Caption         =   "X"
         Height          =   255
         Index           =   3
         Left            =   360
         TabIndex        =   11
         Top             =   1920
         Width           =   375
      End
      Begin VB.CommandButton Obtn 
         Caption         =   "O"
         Height          =   255
         Index           =   2
         Left            =   2640
         TabIndex        =   9
         Top             =   960
         Width           =   375
      End
      Begin VB.CommandButton Xbtn 
         Caption         =   "X"
         Height          =   255
         Index           =   2
         Left            =   2280
         TabIndex        =   8
         Top             =   960
         Width           =   375
      End
      Begin VB.CommandButton Obtn 
         Caption         =   "O"
         Height          =   255
         Index           =   1
         Left            =   1680
         TabIndex        =   6
         Top             =   960
         Width           =   375
      End
      Begin VB.CommandButton Xbtn 
         Caption         =   "X"
         Height          =   255
         Index           =   1
         Left            =   1320
         TabIndex        =   5
         Top             =   960
         Width           =   375
      End
      Begin VB.CommandButton Obtn 
         Caption         =   "O"
         Height          =   255
         Index           =   0
         Left            =   720
         TabIndex        =   3
         Top             =   960
         Width           =   375
      End
      Begin VB.CommandButton Xbtn 
         Caption         =   "X"
         Height          =   255
         Index           =   0
         Left            =   360
         TabIndex        =   2
         Top             =   960
         Width           =   375
      End
      Begin VB.Label Status 
         Alignment       =   2  'Center
         Caption         =   "???"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   46
         Top             =   3600
         Width           =   3135
      End
      Begin VB.Line Line4 
         BorderWidth     =   2
         X1              =   2160
         X2              =   2160
         Y1              =   360
         Y2              =   3240
      End
      Begin VB.Line Line3 
         BorderWidth     =   2
         X1              =   240
         X2              =   3120
         Y1              =   2280
         Y2              =   2280
      End
      Begin VB.Label StateFld 
         Alignment       =   2  'Center
         BorderStyle     =   1  'Fixed Single
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   8
         Left            =   2280
         TabIndex        =   25
         Top             =   2400
         Width           =   735
      End
      Begin VB.Label StateFld 
         Alignment       =   2  'Center
         BorderStyle     =   1  'Fixed Single
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   7
         Left            =   1320
         TabIndex        =   22
         Top             =   2400
         Width           =   735
      End
      Begin VB.Label StateFld 
         Alignment       =   2  'Center
         BorderStyle     =   1  'Fixed Single
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   6
         Left            =   360
         TabIndex        =   19
         Top             =   2400
         Width           =   735
      End
      Begin VB.Label StateFld 
         Alignment       =   2  'Center
         BorderStyle     =   1  'Fixed Single
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   5
         Left            =   2280
         TabIndex        =   16
         Top             =   1440
         Width           =   735
      End
      Begin VB.Label StateFld 
         Alignment       =   2  'Center
         BorderStyle     =   1  'Fixed Single
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   4
         Left            =   1320
         TabIndex        =   13
         Top             =   1440
         Width           =   735
      End
      Begin VB.Label StateFld 
         Alignment       =   2  'Center
         BorderStyle     =   1  'Fixed Single
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   3
         Left            =   360
         TabIndex        =   10
         Top             =   1440
         Width           =   735
      End
      Begin VB.Label StateFld 
         Alignment       =   2  'Center
         BorderStyle     =   1  'Fixed Single
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   2
         Left            =   2280
         TabIndex        =   7
         Top             =   480
         Width           =   735
      End
      Begin VB.Label StateFld 
         Alignment       =   2  'Center
         BorderStyle     =   1  'Fixed Single
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   1
         Left            =   1320
         TabIndex        =   4
         Top             =   480
         Width           =   735
      End
      Begin VB.Label StateFld 
         Alignment       =   2  'Center
         BorderStyle     =   1  'Fixed Single
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   0
         Left            =   360
         TabIndex        =   1
         Top             =   480
         Width           =   735
      End
      Begin VB.Line Line2 
         BorderWidth     =   2
         X1              =   240
         X2              =   3120
         Y1              =   1320
         Y2              =   1320
      End
      Begin VB.Line Line1 
         BorderWidth     =   2
         X1              =   1200
         X2              =   1200
         Y1              =   360
         Y2              =   3240
      End
   End
End
Attribute VB_Name = "MainForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim fCycle As Integer
Dim fGameOver As Integer
Dim state(9) As String
Dim NextMove As String
Dim MoveNumber As Integer



Function AlgSmartAhead2(MyMove As String) As Integer
    Dim i As Integer
    Dim HerMove As String
    Dim vote(9) As Integer
    Dim vmax As Integer
    Dim maxi As Integer
    Dim move As String
    
    If MyMove = "X" Then
        HerMove = "O"
    Else
        HerMove = "X"
    End If
    
    ' look for winning moves
    For i = 0 To 8
        If state(i) = " " Then
            ' temp try the move
            state(i) = MyMove
            If WinDetect() Then
                state(i) = " "
                AlgSmartAhead2 = i
                Exit Function
            End If
            state(i) = " "
        End If
    Next i
    
    ' look for mandatory blocking moves
    For i = 0 To 8
        If state(i) = " " Then
            ' temp try the other move
            state(i) = HerMove
            If WinDetect() Then
                state(i) = " "
                AlgSmartAhead2 = i
                Exit Function
            End If
            state(i) = " "
        End If
    Next i
    
    ' take the center
    If state(4) = " " Then
        AlgSmartAhead2 = 4
        Exit Function
    End If
    
    ' analyze each square
    For i = 0 To 8
        vote(i) = 0
    Next i
    
        
        s = 0
        If state(s) = " " Then
            If AttackMove(MyMove, 0, 1, 2) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 0, 1, 2) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 0, 4, 8) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 0, 4, 8) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 0, 3, 6) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 0, 3, 6) Then vote(s) = vote(s) + 1
            End If
        End If
        s = 1
        If state(s) = " " Then
            If AttackMove(MyMove, 0, 1, 2) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 0, 1, 2) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 1, 4, 7) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 1, 4, 7) Then vote(s) = vote(s) + 1
            End If
        End If
        s = 2
        If state(s) = " " Then
            If AttackMove(MyMove, 0, 1, 2) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 0, 1, 2) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 2, 4, 6) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 2, 4, 6) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 2, 5, 8) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 2, 5, 8) Then vote(s) = vote(s) + 1
            End If
        End If
        s = 3
        If state(s) = " " Then
            If AttackMove(MyMove, 3, 4, 5) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 3, 4, 5) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 0, 3, 6) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 0, 3, 6) Then vote(s) = vote(s) + 1
            End If
        End If
        s = 4
        If state(s) = " " Then
            If AttackMove(MyMove, 0, 4, 8) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 0, 4, 8) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 2, 4, 6) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 2, 4, 6) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 1, 4, 7) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 1, 4, 7) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 3, 4, 5) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 3, 4, 5) Then vote(s) = vote(s) + 1
            End If
        End If
        s = 5
        If state(s) = " " Then
            If AttackMove(MyMove, 2, 5, 8) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 2, 5, 8) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 3, 4, 5) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 3, 4, 5) Then vote(s) = vote(s) + 1
            End If
        End If
        s = 6
        If state(s) = " " Then
            If AttackMove(MyMove, 0, 3, 6) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 0, 3, 6) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 2, 4, 6) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 2, 4, 6) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 6, 7, 8) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 6, 7, 8) Then vote(s) = vote(s) + 1
            End If
        End If
        s = 7
        If state(s) = " " Then
            If AttackMove(MyMove, 1, 4, 7) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 1, 4, 7) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 6, 7, 8) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 6, 7, 8) Then vote(s) = vote(s) + 1
            End If
        End If
        s = 8
        If state(s) = " " Then
            If AttackMove(MyMove, 2, 5, 8) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 2, 5, 8) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 0, 4, 8) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 0, 4, 8) Then vote(s) = vote(s) + 1
            End If
            If AttackMove(MyMove, 6, 7, 8) Then
                vote(s) = vote(s) + 1
            Else
                If AttackMove(HerMove, 6, 7, 8) Then vote(s) = vote(s) + 1
            End If
        End If
    
    ' find the max
    vmax = 0
    maxi = 0
    For i = 0 To 8
        If vote(i) > vmax Then
            vmax = vote(i)
            maxi = i
        End If
        'Debug.Print i & " " & vote(i)
    Next i
    
    If vmax > 0 Then
        AlgSmartAhead2 = maxi
    Else
        ' take any move
        For i = 0 To 8
            If state(i) = " " Then
                AlgSmartAhead2 = i
                Exit Function
            End If
        Next i
        
        ' alg failure; no move left!
        AlgSmartAhead2 = -1
    End If
End Function

Function AlgSmartAhead(MyMove As String) As Integer
    Dim i As Integer
    Dim HerMove As String
    Dim vote(9) As Double
    Dim vmax As Integer
    Dim maxi As Integer
    Dim move As String
    Dim incr As Double
    Dim hash As String
    
    If MyMove = "X" Then
        HerMove = "O"
    Else
        HerMove = "X"
    End If
    
    ' look for winning moves
    For i = 0 To 8
        If state(i) = " " Then
            ' temp try the move
            state(i) = MyMove
            If WinDetect() Then
                state(i) = " "
                AlgSmartAhead = i
                Exit Function
            End If
            state(i) = " "
        End If
    Next i
    
    ' look for mandatory blocking moves
    For i = 0 To 8
        If state(i) = " " Then
            ' temp try the other move
            state(i) = HerMove
            If WinDetect() Then
                state(i) = " "
                AlgSmartAhead = i
                Exit Function
            End If
            state(i) = " "
        End If
    Next i
    
    ' take the center
    If state(4) = " " Then
        AlgSmartAhead = 4
        Exit Function
    End If
    
    ' analyze each square
    For i = 0 To 8
        vote(i) = 0
    Next i
    
    For i = 0 To 1
        If i = 0 Then
            move = MyMove
            incr = 1
        Else
            move = HerMove
            incr = 1.5
        End If
        
        s = 0
        If state(s) = " " Then
            If AttackMove(move, 0, 1, 2) Then vote(s) = vote(s) + incr
            If AttackMove(move, 0, 4, 8) Then vote(s) = vote(s) + incr
            If AttackMove(move, 0, 3, 6) Then vote(s) = vote(s) + incr
        End If
        s = 1
        If state(s) = " " Then
            If AttackMove(move, 0, 1, 2) Then vote(s) = vote(s) + incr
            If AttackMove(move, 1, 4, 7) Then vote(s) = vote(s) + incr
        End If
        s = 2
        If state(s) = " " Then
            If AttackMove(move, 0, 1, 2) Then vote(s) = vote(s) + incr
            If AttackMove(move, 2, 4, 6) Then vote(s) = vote(s) + incr
            If AttackMove(move, 2, 5, 8) Then vote(s) = vote(s) + incr
        End If
        s = 3
        If state(s) = " " Then
            If AttackMove(move, 3, 4, 5) Then vote(s) = vote(s) + incr
            If AttackMove(move, 0, 3, 6) Then vote(s) = vote(s) + incr
        End If
        s = 4
        If state(s) = " " Then
            If AttackMove(move, 0, 4, 8) Then vote(s) = vote(s) + incr
            If AttackMove(move, 2, 4, 6) Then vote(s) = vote(s) + incr
            If AttackMove(move, 1, 4, 7) Then vote(s) = vote(s) + incr
            If AttackMove(move, 3, 4, 5) Then vote(s) = vote(s) + incr
        End If
        s = 5
        If state(s) = " " Then
            If AttackMove(move, 2, 5, 8) Then vote(s) = vote(s) + incr
            If AttackMove(move, 3, 4, 5) Then vote(s) = vote(s) + incr
        End If
        s = 6
        If state(s) = " " Then
            If AttackMove(move, 0, 3, 6) Then vote(s) = vote(s) + incr
            If AttackMove(move, 2, 4, 6) Then vote(s) = vote(s) + incr
            If AttackMove(move, 6, 7, 8) Then vote(s) = vote(s) + incr
        End If
        s = 7
        If state(s) = " " Then
            If AttackMove(move, 1, 4, 7) Then vote(s) = vote(s) + incr
            If AttackMove(move, 6, 7, 8) Then vote(s) = vote(s) + incr
        End If
        s = 8
        If state(s) = " " Then
            If AttackMove(move, 2, 5, 8) Then vote(s) = vote(s) + incr
            If AttackMove(move, 0, 4, 8) Then vote(s) = vote(s) + incr
            If AttackMove(move, 6, 7, 8) Then vote(s) = vote(s) + incr
        End If
    Next i
    
    ' find the max
    vmax = 0
    maxi = 0
    For i = 0 To 8
        If vote(i) > vmax Then
            vmax = vote(i)
            maxi = i
        End If
'        Debug.Print i & " " & vote(i)
    Next i
    
    If vmax > 0 Then
        AlgSmartAhead = maxi
    Else
        ' take any move
        For i = 0 To 8
            If state(i) = " " Then
                AlgSmartAhead = i
                Exit Function
            End If
        Next i
        
        ' alg failure; no move left!
        AlgSmartAhead = -1
    End If
End Function
' pick an available square randomly
Function AlgRandom(MyMove As String) As Integer
    Dim choice(9) As Integer
    Dim n As Integer
    Dim i As Integer
    
    ' list all of the available squares
    n = 0
    For i = 0 To 8
        If state(i) = " " Then
            choice(n) = i
            n = n + 1
        End If
    Next i
    
    If n = 0 Then
        AlgRandom = -1
        Exit Function
    End If
    
    If n = 1 Then
        AlgRandom = choice(0)
        Exit Function
    End If
    
    AlgRandom = choice(Int(Rnd * n))
End Function

Function AlgSequential(MyMove As String) As Integer
    ' try for the center
    If state(4) = " " Then
        AlgSequential = 4
        Exit Function
    End If
    
    ' take any open spot
    For i = 0 To 8
        If state(i) = " " Then
            AlgSequential = i
            Exit Function
        End If
    Next i
    
    ' no move
    AlgSequential = -1
End Function

Function AlgSmartAll(MyMove As String) As Integer
    Dim i As Integer
    Dim HerMove As String
    Dim vote(9) As Double
    Dim vmax As Integer
    Dim maxi As Integer
    Dim move As String
    Dim incr As Double
    
    If MyMove = "X" Then
        HerMove = "O"
    Else
        HerMove = "X"
    End If
    
    ' look for winning moves
    For i = 0 To 8
        If state(i) = " " Then
            ' temp try the move
            state(i) = MyMove
            If WinDetect() Then
                state(i) = " "
                AlgSmartAll = i
                Exit Function
            End If
            state(i) = " "
        End If
    Next i
    
    ' look for mandatory blocking moves
    For i = 0 To 8
        If state(i) = " " Then
            ' temp try the other move
            state(i) = HerMove
            If WinDetect() Then
                state(i) = " "
                AlgSmartAll = i
                Exit Function
            End If
            state(i) = " "
        End If
    Next i
    
    ' take the center
    If state(4) = " " Then
        AlgSmartAll = 4
        Exit Function
    End If
    
    ' look for the killer
    hash = ""
    For i = 0 To 8
       hash = hash + state(i)
    Next i
    If MyMove = "X" Then
        If hash = "O   X   O" Then
            AlgSmartAll = 1
            Exit Function
        End If
        If hash = "  O X O  " Then
            AlgSmartAll = 1
            Exit Function
        End If
    Else
        If hash = "X   O   X" Then
            AlgSmartAll = 1
            Exit Function
        End If
        If hash = "  X O X  " Then
            AlgSmartAll = 1
            Exit Function
        End If
    End If
    
    ' analyze each square
    For i = 0 To 8
        vote(i) = 0
    Next i
    
    For i = 0 To 1
        If i = 0 Then
            move = MyMove
            incr = 1
        Else
            move = HerMove
            incr = 1.5
        End If
        
        s = 0
        If state(s) = " " Then
            If AttackMove(move, 0, 1, 2) Then vote(s) = vote(s) + incr
            If AttackMove(move, 0, 4, 8) Then vote(s) = vote(s) + incr
            If AttackMove(move, 0, 3, 6) Then vote(s) = vote(s) + incr
        End If
        s = 1
        If state(s) = " " Then
            If AttackMove(move, 0, 1, 2) Then vote(s) = vote(s) + incr
            If AttackMove(move, 1, 4, 7) Then vote(s) = vote(s) + incr
        End If
        s = 2
        If state(s) = " " Then
            If AttackMove(move, 0, 1, 2) Then vote(s) = vote(s) + incr
            If AttackMove(move, 2, 4, 6) Then vote(s) = vote(s) + incr
            If AttackMove(move, 2, 5, 8) Then vote(s) = vote(s) + incr
        End If
        s = 3
        If state(s) = " " Then
            If AttackMove(move, 3, 4, 5) Then vote(s) = vote(s) + incr
            If AttackMove(move, 0, 3, 6) Then vote(s) = vote(s) + incr
        End If
        s = 4
        If state(s) = " " Then
            If AttackMove(move, 0, 4, 8) Then vote(s) = vote(s) + incr
            If AttackMove(move, 2, 4, 6) Then vote(s) = vote(s) + incr
            If AttackMove(move, 1, 4, 7) Then vote(s) = vote(s) + incr
            If AttackMove(move, 3, 4, 5) Then vote(s) = vote(s) + incr
        End If
        s = 5
        If state(s) = " " Then
            If AttackMove(move, 2, 5, 8) Then vote(s) = vote(s) + incr
            If AttackMove(move, 3, 4, 5) Then vote(s) = vote(s) + incr
        End If
        s = 6
        If state(s) = " " Then
            If AttackMove(move, 0, 3, 6) Then vote(s) = vote(s) + incr
            If AttackMove(move, 2, 4, 6) Then vote(s) = vote(s) + incr
            If AttackMove(move, 6, 7, 8) Then vote(s) = vote(s) + incr
        End If
        s = 7
        If state(s) = " " Then
            If AttackMove(move, 1, 4, 7) Then vote(s) = vote(s) + incr
            If AttackMove(move, 6, 7, 8) Then vote(s) = vote(s) + incr
        End If
        s = 8
        If state(s) = " " Then
            If AttackMove(move, 2, 5, 8) Then vote(s) = vote(s) + incr
            If AttackMove(move, 0, 4, 8) Then vote(s) = vote(s) + incr
            If AttackMove(move, 6, 7, 8) Then vote(s) = vote(s) + incr
        End If
    Next i
    
    ' find the max
    vmax = 0
    maxi = 0
    For i = 0 To 8
        If vote(i) > vmax Then
            vmax = vote(i)
            maxi = i
        End If
'        Debug.Print i & " " & vote(i)
    Next i
    
    If vmax > 0 Then
        AlgSmartAll = maxi
    Else
        ' take any move
        For i = 0 To 8
            If state(i) = " " Then
                AlgSmartAll = i
                Exit Function
            End If
        Next i
        
        ' alg failure; no move left!
        AlgSmartAll = -1
    End If

End Function

Function AlgSmartForceSides(MyMove As String) As Integer
    Dim i As Integer
    Dim HerMove As String
    
    If MyMove = "X" Then
        HerMove = "O"
    Else
        HerMove = "X"
    End If
    
    ' look for winning moves
    For i = 0 To 8
        If state(i) = " " Then
            ' temp try the move
            state(i) = MyMove
            If WinDetect() Then
                state(i) = " "
                AlgSmartForceSides = i
                Exit Function
            End If
            state(i) = " "
        End If
    Next i
    
    ' look for blocking moves
    For i = 0 To 8
        If state(i) = " " Then
            ' temp try the other move
            state(i) = HerMove
            If WinDetect() Then
                state(i) = " "
                AlgSmartForceSides = i
                Exit Function
            End If
            state(i) = " "
        End If
    Next i
    
    ' try for the center
    If state(4) = " " Then
        AlgSmartForceSides = 4
        Exit Function
    End If
    
    ' try to force her to a side move
    If state(4) = MyMove Then
        If state(1) = " " And state(7) = " " Then
            AlgSmartForceSides = 1
            Exit Function
        End If
        If state(3) = " " And state(5) = " " Then
            AlgSmartForceSides = 3
            Exit Function
        End If
    End If
    
    ' try to force her to a corner move
    If state(4) = MyMove Then
        If state(0) = " " And state(8) = " " Then
            AlgSmartForceSides = 0
            Exit Function
        End If
        If state(2) = " " And state(6) = " " Then
            AlgSmartForceSides = 2
            Exit Function
        End If
    End If
    
    ' take any open spot
    For i = 0 To 8
        If state(i) = " " Then
            AlgSmartForceSides = i
            Exit Function
        End If
    Next i
    
    ' no move
    AlgSmartForceSides = -1

End Function

Function AlgSmartSequential(MyMove As String) As Integer
    Dim i As Integer
    Dim HerMove As String
    
    If MyMove = "X" Then
        HerMove = "O"
    Else
        HerMove = "X"
    End If
    
    ' look for winning moves
    For i = 0 To 8
        If state(i) = " " Then
            ' temp try the move
            state(i) = MyMove
            If WinDetect() Then
                state(i) = " "
                AlgSmartSequential = i
                Exit Function
            End If
            state(i) = " "
        End If
    Next i
    
    ' look for blocking moves
    For i = 0 To 8
        If state(i) = " " Then
            ' temp try the other move
            state(i) = HerMove
            If WinDetect() Then
                state(i) = " "
                AlgSmartSequential = i
                Exit Function
            End If
            state(i) = " "
        End If
    Next i
    
    ' try for the center
    If state(4) = " " Then
        AlgSmartSequential = 4
        Exit Function
    End If
    
    ' take any open spot
    For i = 0 To 8
        If state(i) = " " Then
            AlgSmartSequential = i
            Exit Function
        End If
    Next i
    
    ' no move
    AlgSmartSequential = -1
End Function


Function AnyMoreMoves() As Integer
    Dim i As Integer
    
    For i = 0 To 8
        If state(i) = " " Then
            AnyMoreMoves = True
            Exit Function
        End If
    Next i
    
    AnyMoreMoves = False
End Function

Function AttackMove(MyMove As String, m1 As Integer, m2 As Integer, m3 As Integer)
    Dim pattern As String
    Dim look1 As String
    Dim look2 As String
    Dim look3 As String
    
    look1 = MyMove + "  "
    look2 = " " + MyMove + " "
    look3 = "  " + MyMove
    look4 = "   "
    
    pattern = state(m1) + state(m2) + state(m3)
    
    If pattern = look1 Then
        AttackMove = True
        Exit Function
    End If
    If pattern = look2 Then
        AttackMove = True
        Exit Function
    End If
    If pattern = look3 Then
        AttackMove = True
        Exit Function
    End If
    'If pattern = look4 Then
    '    AttackMove = True
    '    Exit Function
    'End If
    
    AttackMove = False
    
End Function

Function BestChoice(m1 As Integer, m2 As Integer, m3 As Integer) As Integer
    Dim n As Integer
    Dim choice(3) As Integer
    
    n = 0
    If state(m1) = " " Then
        choice(n) = m1
        n = n + 1
    End If
    If state(m2) = " " Then
        choice(n) = m2
        n = n + 1
    End If
    If state(m3) = " " Then
        choice(n) = m3
        n = n + 1
    End If
    
    If n = 0 Then
        BestChoice = -1
        Exit Function
    End If
    If n = 1 Then
        BestChoice = choice(0)
        Exit Function
    End If
    If n = 2 Then
        If choice(0) = 4 Or choice(1) = 4 Then
            BestChoice = 4
        Else
            BestChoice = choice(0)
        End If
        Exit Function
    End If
    If n = 3 Then
        If choice(0) = 4 Or choice(1) = 4 Or choice(2) = 4 Then
            BestChoice = 4
        Else
            BestChoice = choice(0)
        End If
    End If
End Function

Sub DisableXOBtns()
    Dim i As Integer
    
    For i = 0 To 8
        Xbtn(i).Enabled = False
        Obtn(i).Enabled = False
    Next i
    
    Auto1Btn.Enabled = False

End Sub

Sub EnableOBtns()
    Dim i As Integer
    
    For i = 0 To 8
        Xbtn(i).Enabled = False
        Obtn(i).Enabled = True
    Next i

End Sub
Sub EnableXBtns()
    Dim i As Integer
    
    For i = 0 To 8
        Xbtn(i).Enabled = True
        Obtn(i).Enabled = False
    Next i
End Sub

Function IsLegal(i As Integer, s As String) As Integer
    If state(i) <> " " Then
        IsLegal = False
        Exit Function
    End If
    
    IsLegal = True
End Function

Function AlgCornerBiased(MyMove As String) As Integer
    Dim i As Integer
    Dim HerMove As String
    
    If MyMove = "X" Then
        HerMove = "O"
    Else
        HerMove = "X"
    End If
    
    ' look for winning moves
    For i = 0 To 8
        If state(i) = " " Then
            ' temp try the move
            state(i) = MyMove
            If WinDetect() Then
                state(i) = " "
                AlgCornerBiased = i
                Exit Function
            End If
            state(i) = " "
        End If
    Next i
    
    ' look for blocking moves
    For i = 0 To 8
        If state(i) = " " Then
            ' temp try the other move
            state(i) = HerMove
            If WinDetect() Then
                state(i) = " "
                AlgCornerBiased = i
                Exit Function
            End If
            state(i) = " "
        End If
    Next i
    
    ' try for the center
    If state(4) = " " Then
        AlgCornerBiased = 4
        Exit Function
    End If
    
    ' try for the corners
    If state(0) = " " Then
        AlgCornerBiased = 0
        Exit Function
    End If
    If state(2) = " " Then
        AlgCornerBiased = 2
        Exit Function
    End If
    If state(6) = " " Then
        AlgCornerBiased = 6
        Exit Function
    End If
    If state(8) = " " Then
        AlgCornerBiased = 8
        Exit Function
    End If
    
    ' take any open spot
    For i = 0 To 8
        If state(i) = " " Then
            AlgCornerBiased = i
            Exit Function
        End If
    Next i
    
    ' no move
    AlgCornerBiased = -1
End Function


Sub ShowAllStates()
    Dim i As Integer
    
    For i = 0 To 8
        StateFld(i) = state(i)
    Next i
End Sub


Function AlgSmartRandom(MyMove As String) As Integer
    Dim i As Integer
    Dim HerMove As String
    
    If MyMove = "X" Then
        HerMove = "O"
    Else
        HerMove = "X"
    End If
    
    ' look for winning moves
    For i = 0 To 8
        If state(i) = " " Then
            ' temp try the move
            state(i) = MyMove
            If WinDetect() Then
                state(i) = " "
                AlgSmartRandom = i
                Exit Function
            End If
            state(i) = " "
        End If
    Next i
    
    ' look for blocking moves
    For i = 0 To 8
        If state(i) = " " Then
            ' temp try the other move
            state(i) = HerMove
            If WinDetect() Then
                state(i) = " "
                AlgSmartRandom = i
                Exit Function
            End If
            state(i) = " "
        End If
    Next i
    
    ' go random
    AlgSmartRandom = AlgRandom(MyMove)
End Function

Function WinDetect() As Integer
    ' if center position taken, check 4 ways
    If state(4) <> " " Then
        If state(3) = state(4) And state(3) = state(5) Then
            WinDetect = 2
            Exit Function
        End If
        If state(1) = state(4) And state(1) = state(7) Then
            WinDetect = 5
            Exit Function
        End If
    
        ' diagonals
        If state(0) = state(4) And state(0) = state(8) Then
            WinDetect = 7
            Exit Function
        End If
        If state(2) = state(4) And state(2) = state(6) Then
            WinDetect = 8
            Exit Function
        End If
    End If
    
    ' if upper left taken, check two ways
    If state(0) <> " " Then
        If state(0) = state(1) And state(0) = state(2) Then
            WinDetect = 1
            Exit Function
        End If
        If state(0) = state(3) And state(0) = state(6) Then
            WinDetect = 4
            Exit Function
        End If
    End If
    
    ' if lower right taken check 2
    If state(8) <> " " Then
        If state(6) = state(7) And state(6) = state(8) Then
            WinDetect = 3
            Exit Function
        End If
        If state(2) = state(5) And state(2) = state(8) Then
            WinDetect = 6
            Exit Function
        End If
    End If
    
    ' no win!
    WinDetect = 0
End Function


Private Sub Auto1Btn_Click()
    Dim MyMove As String
    Dim theMove As Integer
    Dim Alg As Integer
    
    ' whose move is it?
    MyMove = NextMove
    
    If MyMove = " " Then Exit Sub
    
    If MyMove = "X" Then
        Alg = AlgRadio(1)
        Alg = Alg + AlgRadio(2) * 2
        Alg = Alg + AlgRadio(3) * 3
        Alg = Alg + AlgRadio(4) * 4
        Alg = Alg + AlgRadio(5) * 5
        Alg = Alg + AlgRadio(6) * 6
        Alg = Alg + AlgRadio(7) * 7
        Alg = Alg + AlgRadio(8) * 8
    Else
        Alg = OAlgRadio(1)
        Alg = Alg + OAlgRadio(2) * 2
        Alg = Alg + OAlgRadio(3) * 3
        Alg = Alg + OAlgRadio(4) * 4
        Alg = Alg + OAlgRadio(5) * 5
        Alg = Alg + OAlgRadio(6) * 6
        Alg = Alg + OAlgRadio(7) * 7
        Alg = Alg + OAlgRadio(8) * 8
    End If
    
    Alg = -Alg
    
    Select Case Alg
        Case 0
            theMove = AlgSequential(MyMove)
        Case 1
            theMove = AlgRandom(MyMove)
        Case 2
            theMove = AlgSmartSequential(MyMove)
        Case 3
            theMove = AlgSmartRandom(MyMove)
        Case 4
            theMove = AlgCornerBiased(MyMove)
        Case 5
            theMove = AlgSmartAhead(MyMove)
        Case 6
            theMove = AlgSmartAhead2(MyMove)
        Case 7
            theMove = AlgSmartForceSides(MyMove)
        Case 8
            theMove = AlgSmartAll(MyMove)
    End Select
    
    
    If theMove < 0 Then Exit Sub
    
    If MyMove = "X" Then
        Xbtn_Click (theMove)
    Else
        Obtn_Click (theMove)
    End If
End Sub

Private Sub Check1_Click()

End Sub

Private Sub clearBtn_Click()
    nxFld = 0
    noFld = 0
    ncatFld = 0
End Sub

Private Sub CycleBtn_Click()
    NewGameBtn.Enabled = False
    Auto1Btn.Enabled = False
    ExitBtn.Enabled = False
    HaltBtn.Enabled = True
    CycleBtn.Enabled = False
    If animateChk.Value = 0 Then GameFrame.Visible = False
    
    fCycle = True
    While fCycle
    
        NewGameBtn_Click
        While Not fGameOver
            Auto1Btn_Click
            If animateChk.Value = 1 Then GameFrame.Refresh
        Wend
        
        If HaltXWinChk.Value And Left$(Status, 1) = "X" Then fCycle = False
        If HaltOWinChk.Value And Left$(Status, 1) = "O" Then fCycle = False
    
        DoEvents
    Wend
    
    
    NewGameBtn.Enabled = True
    Auto1Btn.Enabled = True
    ExitBtn.Enabled = True
    HaltBtn.Enabled = False
    CycleBtn.Enabled = True
    GameFrame.Visible = True

End Sub


Private Sub ExitBtn_Click()
    Unload MainForm
End Sub

Private Sub Form_Load()
    NewGameBtn_Click
End Sub


Private Sub HaltBtn_Click()
    fCycle = False
End Sub

Private Sub NewGameBtn_Click()
    Dim i As Integer
    
    For i = 0 To 8
        state(i) = " "
    Next i
    
    ShowAllStates
    
    EnableXBtns
    NextMove = "X"
    Status = "New Game. X Moves..."
    MoveNumber = 1
    
    If Not fCycle Then Auto1Btn.Enabled = True
    
    Randomize
    fGameOver = False
            
End Sub


Private Sub OAlgorithmFrm_DragDrop(Source As Control, X As Single, Y As Single)

End Sub

Private Sub Obtn_Click(Index As Integer)
    If Not IsLegal(Index, "O") Then Exit Sub
    
    state(Index) = "O"
    StateFld(Index) = "O" & MoveNumber
    MoveNumber = MoveNumber + 1
    
    If WinDetect() Then
        If Not fCycle Then DisableXOBtns
        Status = "O Wins!!!"
        noFld = noFld + 1
        fGameOver = True
    Else
        If AnyMoreMoves() Then
            If Not fCycle Then EnableXBtns
            Status = "X Moves..."
            NextMove = "X"
        Else
            If Not fCycle Then DisableXOBtns
            Status = "Cat Wins!!!"
            ncatFld = ncatFld + 1
            fGameOver = True
        End If
    End If
End Sub

Private Sub Xbtn_Click(Index As Integer)
    If Not IsLegal(Index, "X") Then Exit Sub
    
    state(Index) = "X"
    StateFld(Index) = "X" & MoveNumber
    MoveNumber = MoveNumber + 1
    
    If WinDetect() Then
        If Not fCycle Then DisableXOBtns
        Status = "X Wins!!!"
        nxFld = nxFld + 1
        fGameOver = True
    Else
        If AnyMoreMoves() Then
            If Not fCycle Then EnableOBtns
            Status = "O Moves..."
            NextMove = "O"
            If Not fCycle And autoChk Then
                Auto1Btn_Click
            End If
        Else
            If Not fCycle Then DisableXOBtns
            Status = "Cat Wins!!!"
            ncatFld = ncatFld + 1
            fGameOver = True
        End If
        
    End If
End Sub



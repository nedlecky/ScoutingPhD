VERSION 5.00
Object = "{852E65AD-72F8-11CF-840E-444553540000}#1.1#0"; "MIDIIO32.OCX"
Object = "{AFE33BE3-6DFC-101D-85F5-6EBA1EE93AF4}#1.1#0"; "HSlide32.OCX"
Object = "{BEF54A83-5A7C-101D-85F5-6EBA1EE93AF4}#1.1#0"; "Knob32.OCX"
Begin VB.Form mainFrm 
   Caption         =   "Lecky Engineering Stream Player 1.0"
   ClientHeight    =   4215
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   10005
   LinkTopic       =   "Form1"
   ScaleHeight     =   4215
   ScaleWidth      =   10005
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton fileBtn 
      Caption         =   "File"
      Height          =   375
      Left            =   5880
      TabIndex        =   18
      Top             =   2160
      Width           =   855
   End
   Begin VB.ComboBox ComboPatch 
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      ForeColor       =   &H0000FF00&
      Height          =   315
      Left            =   5370
      Style           =   2  'Dropdown List
      TabIndex        =   5
      Top             =   390
      Width           =   2295
   End
   Begin VB.CommandButton playBtn 
      Caption         =   "Scale"
      Height          =   375
      Left            =   4680
      TabIndex        =   4
      Top             =   2160
      Width           =   975
   End
   Begin MidiioLib.MIDIInput MIDIInput1 
      Left            =   1920
      Top             =   3360
      _Version        =   65537
      _ExtentX        =   847
      _ExtentY        =   847
      _StockProps     =   0
      MessageEventEnable=   -1  'True
   End
   Begin VB.ComboBox ComboMidiIn 
      Height          =   315
      Left            =   1920
      TabIndex        =   2
      Text            =   "Combo1"
      Top             =   3000
      Width           =   1815
   End
   Begin VB.ComboBox ComboMidiOut 
      Height          =   315
      Left            =   4200
      TabIndex        =   0
      Text            =   "Combo1"
      Top             =   3000
      Width           =   1815
   End
   Begin MidiioLib.MIDIOutput MIDIOutput1 
      Left            =   4200
      Top             =   3360
      _Version        =   65537
      _ExtentX        =   847
      _ExtentY        =   847
      _StockProps     =   0
      DeviceID        =   -1
      VolumeLeft      =   65535
      VolumeRight     =   65535
   End
   Begin KnobLib.Knob KnobPan 
      Height          =   600
      Left            =   8070
      TabIndex        =   6
      Top             =   180
      Width           =   855
      _Version        =   65537
      _ExtentX        =   1508
      _ExtentY        =   1058
      _StockProps     =   69
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BevelWidth      =   2
      BorderWidth     =   0
      Indicator       =   1
      IndicatorColor  =   255
      IndicatorWidth  =   0
      KnobColor       =   12632256
      KnobStyle       =   3
      Radius          =   240
      TickCaptionColor=   0
      TickColor       =   0
      TickCount       =   0
      TickGap         =   1
      TickLength      =   4
      TickWidth       =   1
      Value           =   1
      Max             =   127
      Min             =   0
      TickCaption     =   ""
   End
   Begin HslideLib.HSlider HSliderOctave 
      Height          =   315
      Left            =   3870
      TabIndex        =   7
      Top             =   450
      Width           =   1185
      _Version        =   65537
      _ExtentX        =   2090
      _ExtentY        =   556
      _StockProps     =   65
      BevelInner      =   0
      BevelOuter      =   0
      BevelWidth      =   1
      BorderWidth     =   1
      Gap             =   3
      LargeChange     =   2
      ThumbHeight     =   300
      ThumbStyle      =   1
      ThumbWidth      =   200
      TickColor       =   0
      TickCount       =   4
      TickLength      =   4
      TickMarks       =   1
      TickWidth       =   1
      TrackBevel      =   1
      TrackWidth      =   3
      Value           =   1
      Max             =   3
      Min             =   0
   End
   Begin HslideLib.HSlider HSliderVolume 
      Height          =   315
      Left            =   2070
      TabIndex        =   8
      Top             =   450
      Width           =   1275
      _Version        =   65537
      _ExtentX        =   2249
      _ExtentY        =   556
      _StockProps     =   65
      BevelInner      =   0
      BevelOuter      =   0
      BevelWidth      =   1
      BorderWidth     =   1
      Gap             =   3
      LargeChange     =   2
      ThumbHeight     =   245
      ThumbStyle      =   3
      ThumbWidth      =   320
      TickColor       =   0
      TickCount       =   5
      TickLength      =   4
      TickMarks       =   0
      TickWidth       =   1
      TrackBevel      =   1
      TrackWidth      =   3
      Value           =   1
      Max             =   127
      Min             =   0
   End
   Begin HslideLib.HSlider HSliderMIDIChannel 
      Height          =   315
      Left            =   0
      TabIndex        =   9
      Top             =   450
      Width           =   1665
      _Version        =   65537
      _ExtentX        =   2937
      _ExtentY        =   556
      _StockProps     =   65
      BevelInner      =   0
      BevelOuter      =   0
      BevelWidth      =   1
      BorderWidth     =   3
      Gap             =   3
      LargeChange     =   2
      ThumbHeight     =   245
      ThumbStyle      =   1
      ThumbWidth      =   200
      TickColor       =   0
      TickCount       =   16
      TickLength      =   4
      TickMarks       =   1
      TickWidth       =   1
      TrackBevel      =   1
      TrackWidth      =   3
      Value           =   1
      Max             =   15
      Min             =   0
   End
   Begin VB.Label LabelOctave 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H0000FF00&
      Height          =   255
      Left            =   4470
      TabIndex        =   17
      Top             =   150
      Width           =   405
   End
   Begin VB.Label Label7 
      Caption         =   "Patch"
      Height          =   255
      Left            =   5370
      TabIndex        =   16
      Top             =   150
      Width           =   645
   End
   Begin VB.Label LabelVolume 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      Caption         =   "100"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H0000FF00&
      Height          =   255
      Left            =   2730
      TabIndex        =   15
      Top             =   150
      Width           =   585
   End
   Begin VB.Label Label6 
      Caption         =   "Octave"
      Height          =   255
      Left            =   3840
      TabIndex        =   14
      Top             =   150
      Width           =   645
   End
   Begin VB.Label Label4 
      Caption         =   "Volume"
      Height          =   255
      Left            =   2070
      TabIndex        =   13
      Top             =   150
      Width           =   675
   End
   Begin VB.Label Label3 
      Caption         =   "MIDI Channel"
      Height          =   255
      Left            =   30
      TabIndex        =   12
      Top             =   150
      Width           =   1215
   End
   Begin VB.Label MidiChannelOutLabel 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      Caption         =   "1"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H0000FF00&
      Height          =   255
      Left            =   1260
      TabIndex        =   11
      Top             =   150
      Width           =   405
   End
   Begin VB.Label Label5 
      Caption         =   "L - Pan - R"
      Height          =   255
      Left            =   8040
      TabIndex        =   10
      Top             =   0
      Width           =   1005
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   "MIDI Input Source"
      Height          =   255
      Left            =   1920
      TabIndex        =   3
      Top             =   2760
      Width           =   1815
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      Caption         =   "MIDI Output Destination"
      Height          =   255
      Left            =   4200
      TabIndex        =   1
      Top             =   2760
      Width           =   1815
   End
End
Attribute VB_Name = "mainFrm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private Sub SendMIDIOut(Message As Integer, Data1 As Integer, Data2 As Integer, TimeVal As Long, Action As Integer)
   ' Put MIDI data in MIDIoutput queue
   MIDIOutput1.Message = Message
   MIDIOutput1.Data1 = Data1
   MIDIOutput1.Data2 = Data2
   MIDIOutput1.time = TimeVal
   MIDIOutput1.Action = Action
   End Sub

Private Sub fileBtn_Click()
    
    On Error GoTo noInput
    Open "d:\research\StreamPlayer\stream.dat" For Input As #1
    
    Dim cmd As String
    Dim time As Long
    Dim velocity As Integer
    Dim note As Integer
    
    MIDIOutput1.Action = MIDIOUT_RESET
    MIDIOutput1.Action = MIDIOUT_START
    On Error GoTo finished
    While (1)
        Input #1, cmd, time
        If cmd = "ON" Then
            Input #1, note, velocity
            Call SendMIDIOut(NOTE_ON + MidiChannelOut, note, velocity, time, MIDIOUT_QUEUE)
            'Debug.Print "on", time, note, velocity
        End If
        If cmd = "OFF" Then
            Input #1, note
            Call SendMIDIOut(NOTE_OFF + MidiChannelOut, note, 0, time, MIDIOUT_QUEUE)
            'Debug.Print "off", time, note
        End If
        
    Wend
        
finished:
    Close #1
    Exit Sub
noInput:
    Close #1
End Sub

Private Sub Form_Unload(Cancel As Integer)
    ' Stop the MIDI In
    MIDIInput1.Action = MIDIIN_STOP
    
    ' Close MIDI In
    MIDIInput1.Action = MIDIIN_CLOSE

    
    ' Close MIDI Out
    MIDIOutput1.Action = MIDIOUT_CLOSE

    End
End Sub

Private Sub playBtn_Click()
    Dim MIDINoteOut As Integer

    
    Dim i As Integer
    Dim x As Integer
    MIDIOutput1.Action = MIDIOUT_RESET
    MIDIOutput1.Action = MIDIOUT_START
    
    For i = 0 To 20
        Call SendMIDIOut(NOTE_ON + MidiChannelOut, MIDINoteOut + 30 + i, MidiVelocity, i * 100, MIDIOUT_QUEUE)
        Call SendMIDIOut(NOTE_OFF + MidiChannelOut, MIDINoteOut + 30 + i, MidiVelocity, (i + 10) * 100, MIDIOUT_QUEUE)
    Next i
End Sub

Sub MIDIInOpen()
    Dim wRtn As Integer
    
    If MIDIInput1.State >= MIDISTATE_OPEN Then
        ' Close midiin port
        MIDIInput1.Action = MIDIIN_CLOSE
    End If

    
    ' Get selected device id
    MIDIInput1.DeviceID = ComboMidiIn.ListIndex
    
    ' Open and display handle
    MIDIInput1.Action = MIDIIN_OPEN

    ' Start midi input
    MIDIInput1.Action = MIDIIN_START
   
End Sub
Sub MIDIOutOpen()

    If MIDIOutput1.State >= MIDISTATE_OPEN Or MIDIOutput1.DeviceID = -1 Then
        ' Close
        MIDIOutput1.Action = MIDIOUT_CLOSE
    End If
    

    ' Open selected device
    MIDIOutput1.DeviceID = ComboMidiOut.ListIndex - 1
    MIDIOutput1.Action = MIDIOUT_OPEN
End Sub


Private Sub Form_Load()
    ' General MIDI patches
    ComboPatch.AddItem "Acoustic Grand Piano"
    ComboPatch.AddItem "Bright Acoustic Piano"
    ComboPatch.AddItem "Electric Grand Piano"
    ComboPatch.AddItem "Honkytonk Piano"
    ComboPatch.AddItem "Rhodes Piano"
    ComboPatch.AddItem "Chorus Piano"
    ComboPatch.AddItem "Harpsichord"
    ComboPatch.AddItem "Clavinet"
    ComboPatch.AddItem "Celesta"
    ComboPatch.AddItem "Glockenspiel"
    ComboPatch.AddItem "Music Box"
    ComboPatch.AddItem "Vibraphone"
    ComboPatch.AddItem "Marimba"
    ComboPatch.AddItem "Xylophone"
    ComboPatch.AddItem "Tubular Bells"
    ComboPatch.AddItem "Dulcimer"
    ComboPatch.AddItem "Hammond Organ"
    ComboPatch.AddItem "Percuss. Organ"
    ComboPatch.AddItem "Rock Organ"
    ComboPatch.AddItem "Church Organ"
    ComboPatch.AddItem "Reed Organ"
    ComboPatch.AddItem "Accordion"
    ComboPatch.AddItem "Harmonica"
    ComboPatch.AddItem "Tango Accordion"
    ComboPatch.AddItem "Acoustic Guitar (nylon)"
    ComboPatch.AddItem "Acoustic Guitar (steel)"
    ComboPatch.AddItem "Electric Guitar (jazz)"
    ComboPatch.AddItem "Electric Guitar (clean)"
    ComboPatch.AddItem "Electric Guitar (muted)"
    ComboPatch.AddItem "Overdriven Guitar"
    ComboPatch.AddItem "Distortion Guitar"
    ComboPatch.AddItem "Guitar Harmonics"
    ComboPatch.AddItem "Acoustic Bass"
    ComboPatch.AddItem "Electric Bass (finger)"
    ComboPatch.AddItem "Electric Bass (pick)"
    ComboPatch.AddItem "Fretless Bass"
    ComboPatch.AddItem "Slap Bass 1"
    ComboPatch.AddItem "Slap Bass 2"
    ComboPatch.AddItem "Synth Bass 1"
    ComboPatch.AddItem "Synth Bass 2"
    ComboPatch.AddItem "Violin"
    ComboPatch.AddItem "Viola"
    ComboPatch.AddItem "Cello"
    ComboPatch.AddItem "Contra Bass"
    ComboPatch.AddItem "Tremolo Strings"
    ComboPatch.AddItem "Pizzicato Strings"
    ComboPatch.AddItem "Orchestral Harp"
    ComboPatch.AddItem "Timpani"
    ComboPatch.AddItem "String Ensemble 1"
    ComboPatch.AddItem "String Ensemble 2"
    ComboPatch.AddItem "Synth Strings 1"
    ComboPatch.AddItem "Synth Strings 2"
    ComboPatch.AddItem "Choir Aahs"
    ComboPatch.AddItem "Voice Oohs"
    ComboPatch.AddItem "Synth Voice"
    ComboPatch.AddItem "Orchestra Hit"
    ComboPatch.AddItem "Trumpet"
    ComboPatch.AddItem "Trombone"
    ComboPatch.AddItem "Tuba"
    ComboPatch.AddItem "Muted Trumpet"
    ComboPatch.AddItem "French Horn"
    ComboPatch.AddItem "Brass Section"
    ComboPatch.AddItem "Synth Brass 1"
    ComboPatch.AddItem "Synth Brass 2"
    ComboPatch.AddItem "Soprano Sax"
    ComboPatch.AddItem "Alto Sax"
    ComboPatch.AddItem "Tenor Sax"
    ComboPatch.AddItem "Baritone Sax"
    ComboPatch.AddItem "Oboe"
    ComboPatch.AddItem "English Horn"
    ComboPatch.AddItem "Bassoon"
    ComboPatch.AddItem "Clarinet"
    ComboPatch.AddItem "Piccolo"
    ComboPatch.AddItem "Flute"
    ComboPatch.AddItem "Recorder"
    ComboPatch.AddItem "Pan Flute"
    ComboPatch.AddItem "Bottle Blow"
    ComboPatch.AddItem "Shaku"
    ComboPatch.AddItem "Whistle"
    ComboPatch.AddItem "Ocarina"
    ComboPatch.AddItem "Lead 1 (square)"
    ComboPatch.AddItem "Lead 2 (saw tooth)"
    ComboPatch.AddItem "Lead 3 (calliope lead)"
    ComboPatch.AddItem "Lead 4 (chiff lead)"
    ComboPatch.AddItem "Lead 5 (charang)"
    ComboPatch.AddItem "Lead 6 (voice)"
    ComboPatch.AddItem "Lead 7 (fifths)"
    ComboPatch.AddItem "Lead 8 (bass + lead)"
    ComboPatch.AddItem "Pad 1 (new age)"
    ComboPatch.AddItem "Pad 2 (warm)"
    ComboPatch.AddItem "Pad 3 (poly synth)"
    ComboPatch.AddItem "Pad 4 (choir)"
    ComboPatch.AddItem "Pad 5 (bowed)"
    ComboPatch.AddItem "Pad 6 (metallic)"
    ComboPatch.AddItem "Pad 7 (halo)"
    ComboPatch.AddItem "Pad 8 (sweep)"
    ComboPatch.AddItem "FX 1 (rain)"
    ComboPatch.AddItem "FX 2 (sound track)"
    ComboPatch.AddItem "FX 3 (crystal)"
    ComboPatch.AddItem "FX 4 (atmo - sphere)"
    ComboPatch.AddItem "FX 5 (bright)"
    ComboPatch.AddItem "FX 6 (goblins)"
    ComboPatch.AddItem "FX 7 (echoes)"
    ComboPatch.AddItem "FX 8 (sci-fi)"
    ComboPatch.AddItem "Sitar"
    ComboPatch.AddItem "Banjo"
    ComboPatch.AddItem "Shamisen"
    ComboPatch.AddItem "Koto"
    ComboPatch.AddItem "Kalimba"
    ComboPatch.AddItem "Bagpipe"
    ComboPatch.AddItem "Fiddle"
    ComboPatch.AddItem "Shanai"
    ComboPatch.AddItem "Tinkle Bell"
    ComboPatch.AddItem "Agogo"
    ComboPatch.AddItem "Steel Drums"
    ComboPatch.AddItem "Wood block"
    ComboPatch.AddItem "Taiko Drum"
    ComboPatch.AddItem "Melodic Tom"
    ComboPatch.AddItem "Synth Drum"
    ComboPatch.AddItem "Reverse Cymbal"
    ComboPatch.AddItem "Guitar Fret Noise"
    ComboPatch.AddItem "Breath Noise"
    ComboPatch.AddItem "Seashore"
    ComboPatch.AddItem "Bird Tweet"
    ComboPatch.AddItem "Telephone Ring"
    ComboPatch.AddItem "Helicopter"
    ComboPatch.AddItem "Applause"
    ComboPatch.AddItem "Gunshot"
    ComboPatch.ListIndex = 0

    MidiChannelOut = 0
    HSliderMIDIChannel.Value = 0
    HSliderOctave.Value = 3
    HSliderVolume.Value = 100
    KnobPan.Value = 64
    
    Dim i As Integer
    '
    ' Fill output device combo box
    '
    For i = -1 To MIDIOutput1.DeviceCount - 1
        MIDIOutput1.DeviceID = i
        ComboMidiOut.AddItem MIDIOutput1.ProductName
    Next
    '
    ' Select last in list
    '
    ComboMidiOut.ListIndex = MIDIOutput1.DeviceCount
    MIDIOutput1.DeviceID = MIDIOutput1.DeviceCount - 1
    MIDIOutOpen
    
    '
    ' Fill input device combo box
    '
    For i = 0 To MIDIInput1.DeviceCount - 1
        MIDIInput1.DeviceID = i
        ComboMidiIn.AddItem MIDIInput1.ProductName
    Next
    '
    ' Select first in list
    '
    ComboMidiIn.ListIndex = 0
    MIDIInput1.DeviceID = 0
    MIDIInOpen

End Sub
Private Sub MIDIInput1_Error(ErrorCode As Integer, ErrorMessage As String)
   If (ErrorCode <> 0) And (ErrorCode <> 8) Then
      MsgBox ErrorMessage
      End If
End Sub

Private Sub MIDIInput1_Message()
    Dim InMessage As Integer
    Dim InData1 As Integer
    Dim InData2 As Integer

    '
    ' The MIDI1.VBX will receive and time stamp in-coming MIDI data very
    ' fast, but it takes VB a lot of time to fire this Message event. If
    ' you need to process MIDI data in real-time, each time this Message
    ' event fires, you should take all the pending messages.  One way to
    ' do this is by using a Do While MIDIInput2.MessageCount > 0
    ' This do while loop allows you to take all the messages that are
    ' waiting in the message queue.

    Do While MIDIInput1.MessageCount > 0
        '
        'This is in-coming MIDI data
        '
        InMessage = MIDIInput1.Message
        InData1 = MIDIInput1.Data1
        InData2 = MIDIInput1.Data2

        '
        'Now we are going to prepare the MIDI data that just came in to
        'be ready to go right back out the MIDI OUT
        '
        MIDIOutput1.Message = InMessage
        MIDIOutput1.Data1 = InData1
        MIDIOutput1.Data2 = InData2
        
        Select Case InMessage
        '
        ' NOTE_ON, NOTE_OFF, PROGRAM_CHANGE, TOTAL_MIDI_CHANNELS
        ' are all constants from the MIDCONST.BAS file.  Using constants in
        ' the MIDCONST.BAS file will allow you to not have to work with
        ' confusing codes.
        '
        ' Check to see if the in-coming MIDI Message was a NOTE_ON from the
        ' currently selected MIDI channel.
        '
        ' We can only display 64 notes on our graphic piano.  Check to see if
        ' InData1 (which is the actual MIDI note be played) can be shown on
        ' the graphic piano display.
        '
        ' Using HSliderOctave, the Octave(MidiChannelOut) is set.  This
        ' allows you to slide the octave display up and down for disaply
        ' notes that would otherwise not be able to appear on the graphic
        ' piano display.
        '
           Case NOTE_ON + MidiChannelOut
                If InData1 <= 64 + Octave(MidiChannelOut) Then
                    '
                    ' Some MIDI manufactures turn MIDI notes off by sending a MIDI NOTE ON
                    ' with a velocity = 0.  InData2 is the note velocity.  If it is greater
                    ' than 0 then it truly is a note on.  If it is, then push down the
                    ' graphic key on the piano.
                    '
                    ' If InData2 is equal to zero, then release the graphic key on the piano
                    ' because it is actually a note off.
                    '
                    If InData2 > 0 Then
                        '
                        ' Push down the graphic key on the piano
                        '
                        'frmMain.PanelWhite(InData1 - Octave(MidiChannelOut)).BevelOuter = 0
                    Else
                        ' Release the graphic key on the piano
                        '
                        'frmMain.PanelWhite(InData1 - Octave(MidiChannelOut)).BevelOuter = 2
                    End If
                End If
                '
                'Tell MIDIOutput1 to send the MIDI data
                '
                MIDIOutput1.Action = MIDIOUT_SEND

            '
            ' MIDI NOTE OFF Event received
            '
            Case NOTE_OFF + MidiChannelOut
                If InData1 <= 64 + Octave(MidiChannelOut) Then
                    '
                    ' Release the graphic key on the piano
                    '
                    'frmMain.PanelWhite(InData1 - Octave(MidiChannelOut)).BevelOuter = 2
                End If
                '
                'Tell MIDIOutput1 to send the MIDI data
                '
                MIDIOutput1.Action = MIDIOUT_SEND

            '
            ' Patch Program Change received
            '
            Case PROGRAM_CHANGE + MidiChannelOut
                '
                ' Patches (organ, piano, horn, etc.) are changed by sending
                ' a PROGRAM_CHANGE.  If we received a PROGRAM_CHANGE on the
                ' current MIDI channel from an external MIDI device, we
                ' will update the patch name on the screen and send the patch
                ' change out the MIDI Out.
                '
                 'ComboPatch.ListIndex = MIDIOutput1.Data1

            '
            'Controller Change received
            '
            Case CONTROLLER_CHANGE + MidiChannelOut
                Select Case InData1
                    Case MAIN_VOLUME
                        'HSliderVolume.Value = InData2
                    Case PAN
                        'KnobPan.Value = InData2
                End Select
            
            Case Else
                '
                'Tell MIDIOutput1 to send the MIDI data
                '
                MIDIOutput1.Action = MIDIOUT_SEND
                
        End Select

        '
        'Remove the MIDI data from the MIDI IN queue
        '
        MIDIInput1.Action = MIDIIN_REMOVE
    Loop
End Sub
Private Sub HSliderOctave_Change()
    LabelOctave.Caption = Str$(HSliderOctave.Value)
    Octave(MidiChannelOut) = (HSliderOctave.Value * 12)
End Sub

Private Sub HSliderOctave_Scroll()
    LabelOctave.Caption = Str$(HSliderOctave.Value)
    Octave(MidiChannelOut) = (HSliderOctave.Value * 12)
End Sub

Private Sub HSliderMIDIChannel_Change()
    ' Change Midi Channel to Vscroll1 value
    MidiChannelOut = HSliderMIDIChannel.Value

    ' Display new channel
    MidiChannelOutLabel.Caption = Str$(MidiChannelOut + 1)

    ' Sets the Patch & Volume for the current Midi Channel Out
    ComboPatch.ListIndex = MidiPatch(MidiChannelOut)
    HSliderVolume.Value = MidiVolume(MidiChannelOut)
    KnobPan.Value = MidiPan(MidiChannelOut)
    HSliderOctave.Value = Octave(MidiChannelOut) / 12
End Sub

Private Sub HSliderMIDIChannel_Scroll()
    ' Change Midi Channel to Vscroll1 value
    MidiChannelOut = HSliderMIDIChannel.Value

    ' Display new channel
    MidiChannelOutLabel.Caption = Str$(MidiChannelOut + 1)

    ' Sets the Patch & Volume for the current Midi Channel Out
    ComboPatch.ListIndex = MidiPatch(MidiChannelOut)
    HSliderVolume.Value = MidiVolume(MidiChannelOut)
    KnobPan.Value = MidiPan(MidiChannelOut)
    HSliderOctave.Value = Octave(MidiChannelOut) / 12

End Sub

Private Sub HSliderVolume_Change()
    MidiVelocity = HSliderVolume.Value
    MidiVolume(MidiChannelOut) = HSliderVolume.Value
    LabelVolume.Caption = Str$(MidiVelocity)
End Sub

Private Sub HSliderVolume_Scroll()
    MidiVelocity = HSliderVolume.Value
    MidiVolume(MidiChannelOut) = HSliderVolume.Value
    LabelVolume.Caption = Str$(MidiVelocity)
End Sub

Private Sub KnobPan_Change()
    MidiPan(MidiChannelOut) = KnobPan.Value

    'Pan Midi Out routine
    MIDIOutput1.Message = CONTROLLER_CHANGE + MidiChannelOut
    MIDIOutput1.Data1 = PAN
    MIDIOutput1.Data2 = MidiPan(MidiChannelOut)
    MIDIOutput1.time = 0
    MIDIOutput1.Action = MIDIOUT_SEND
End Sub

Private Sub KnobPan_Scroll()
    MidiPan(MidiChannelOut) = KnobPan.Value

    'Pan Midi Out routine
    MIDIOutput1.Message = CONTROLLER_CHANGE + MidiChannelOut
    MIDIOutput1.Data1 = PAN
    MIDIOutput1.Data2 = MidiPan(MidiChannelOut)
    MIDIOutput1.time = 0
    MIDIOutput1.Action = MIDIOUT_SEND
End Sub

Private Sub ComboPatch_Click()
    ' Sets the Patch for the current Midi Channel Out
    MidiPatch(MidiChannelOut) = ComboPatch.ListIndex

    'Patch Midi Out routine
    MIDIOutput1.Message = PROGRAM_CHANGE + MidiChannelOut
    MIDIOutput1.Data1 = MidiPatch(MidiChannelOut)
    MIDIOutput1.Data2 = 0
    MIDIOutput1.time = 0
    MIDIOutput1.Action = MIDIOUT_SEND
End Sub


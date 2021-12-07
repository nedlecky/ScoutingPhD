Attribute VB_Name = "Globals"
Option Explicit

' NoteRepeat used to stop the same key from repeating.  CapsLock detects if it is down.
Global NoteRepeat As Integer

Global Const MODAL = 1

' The Patch number array used for current patch for each midi channel
' Then Volume array used for each channels volume setting
' TrackChannel is array for the current midi channel that that Track on the mixi is set to.
Global MidiPatch(TOTAL_MIDI_CHANNELS) As Integer
Global MidiVolume(TOTAL_MIDI_CHANNELS) As Integer
Global TrackChannel(TOTAL_MIDI_CHANNELS) As Integer
Global MidiPan(TOTAL_MIDI_CHANNELS) As Integer
Global Octave(TOTAL_MIDI_CHANNELS) As Integer

' The current Midi Channel out set on Piano form
Global MidiChannelOut As Integer

' The Velocity (Volume) of notes for current midi channel
Global MidiVelocity As Integer


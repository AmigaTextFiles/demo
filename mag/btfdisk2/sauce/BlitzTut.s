;
;   Z-SOFT Ascii Text Reader Vs 1.0
;
;   19/8/96
;
;   Shaun Watters
;
;   Don't worry to much about the specifics of the following
;   code. It's main use is to show how a window is setup
;   and used.
;
;
WBStartup ; Allows your program to be run from Workbench
filename$=Par$(1) ; When run allows a filename to added
                  ; when run from CLI. The purpose of this
                  ; is to give the program an ASCII file to
                  ; display.

Dim text$(10000)  ; Array to store the text


Gosub setup

.setup:
  GadgetJam 1
  WbToScreen 1     ; Set the currently used screen as the
                   ; Workbench Screen

  ; All the text Gadgets

  TextGadget 1,0,0,0,1," PAGE UP "
  TextGadget 1,80,0,0,2,"PAGE DOWN"
  TextGadget 1,160,0,0,3," LINE UP "
  TextGadget 1,240,0,0,4,"LINE DOWN"
  TextGadget 1,550,0,0,5,"  QUIT   "

  ; Setup Our Window

  Window 1,0,0,640,256,$140C,"",1,2,1

  DefaultIDCMP $400|20 ; Sets Intuition input to report
                       ; when a window is activated and
                       ; gadget is pushed

  Use Window 1         ; Use our new Window
  WindowOutput 1       ; Sets all further prints to be output
                       ; to our window
  WColour 1,0          ; Sets the text colour
  WLocate 330,3
  Print "ZTEXT Vs 1.0 (C) 1996 ZSOFT"

  Gosub _readfile
  Gosub morewords
  Gosub main
Return

.main:
  Repeat
    ev.l=Event : ew=EventWindow ; Test if any intuition event
                                ; has occured
    If ev=$20        ; Check if a gadget has been pressed
      If ew=1        ; Check to see if performed in our window
        g=GadgetHit  ; Loads g with the number of the pressed
                     ; gadget
        Select g     ; Start a case statment based upon which
                     ; gadget was pressed
        Case 1
          lne-25
          If lne<0:lne=0:EndIf
          Gosub morewords
        Case 2
          lne+25
          If lne>ef:lne=ef:EndIf
          Gosub morewords
        Case 3
          lne-1
          If lne<0:lne=0:EndIf
          Gosub morewords
        Case 4
          lne+1
          If lne>ef:lne=ef:EndIf
          Gosub morewords
        Case 5
          quit=1
        End Select
        FlushEvents ; Clears all reported events from its buffer
      EndIf
    EndIf
    VWait
  Until quit=1
  End
Return
.morewords:
  WTitle Str$(lne)+"/"+Str$(ef)+"     "+filename$,""
  dit=0
  Use Window 1
  WindowOutput 1
  WColour 1,0
  WLocate 0,20
  For lc=lne+1 To lne+25
  NPrint text$(lc)+"                                                                                       "
  Next lc
Return
;----------------------------------------
._readfile:
If ReadFile(0,filename$)=-1
  FileInput 0
  i=1
  Repeat
    text$(i)=Edit$("",80)
    i+1
  Until Eof(0)=-1
  ef=i-25
  pno=(ef/25)
  CloseFile 0
EndIf
Return

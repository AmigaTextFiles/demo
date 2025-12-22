;*---------------------------------------------------------------------------
;  :Program.    Dual-Crew
;  :Contents.   "VectorBob" Demo (04/??/1990)
;  :Author.     Stefano "Max Headroom/TEX" Pucino
;  :Requires.   Dual-Crew Intro (Mega Cruncher v1.0, 21.264 bytes)
;  :Copyright.  Open Source (like GNU)
;  :Language.   68000 Assembler
;  :Translator. ASM-One v1.46 / Barfly v2.00
;  :To Do.
;
;  :History.
;               03.10.2001 - Version 1.0
;                NEW: Removed OS-calls
;                     Removed LED-filter control
;                     Removed write to COP1LCH
;---------------------------------------------------------------------------*

;======================================================================
; Load all includes and macros
;======================================================================

    INCDIR  INCLUDE:
    INCLUDE whdload.i
    INCLUDE whdmacros.i
    INCLUDE lvo/exec_lib.i
    INCLUDE lvo/dos_lib.i

;======================================================================
; Special BarFly options and optimisations
;======================================================================

    IFD BARFLY
        OUTPUT  "DualCrew-VectorBob.slave"              ; Name of the slave
        BOPT    O+ OG+                      ; Enable optimizing
        BOPT    ODd- ODe-                   ; Disable mul optimizing
        BOPT    w4-                         ; Disable 64k warnings
        SUPER                               ; Disable supervisor warnings
    ENDC

;======================================================================

_base   SLAVE_HEADER                        ; ws_Security + ws_ID
        dc.w    14                          ; WHDLoad version needed
        dc.w    WHDLF_NoError               ; Flags
        dc.l    $80000                      ; BaseMem Size (512 KB)
        dc.l    $0                          ; Exec Install
        dc.w    _Start-_base                ; Gameloader
        dc.w    0                           ; Current Dir
        dc.w    0                           ; Don't Cache
_keydebug
        dc.b    $5f                         ; DebugKey = HELP
_keyexit
        dc.b    $5d                         ; Exit Key = PrtScr
_expmem
        dc.l    0                           ; ExpMem (No Fast-Mem)
        dc.w    _name-_base                 ; Name of file
        dc.w    _copy-_base                 ; Copyright
        dc.w    _info-_base                 ; Additional informations

;======================================================================
; The description part
; Strings are zero terminated. 10 means Carricage Return (CR)
;======================================================================

_name
    dc.b    "VectorBob Demo",0  ; Full name of the intro
_copy
    dc.b    "1990 Dual-Crew",0                 ; Copyright information
_info                                       ; Who am I ? ;)
    dc.b    "--------Installed by:--------",10
    dc.b    "Max Headroom",10
    dc.b    "of",10
    dc.b    "The Exterminators",10
    dc.b    "-----------------------------",10

    dc.b    "Version 1.0 "                  ; Installer-version
    IFD      BARFLY
        IFND    .passchk
            DOSCMD  "WDate  >T:date"
            INCBIN  "T:date"                ; Include current date of slave
.passchk
        ENDC
    ENDC
    dc.b    0                               ; End this string
    even

;======================================================================
; The magic part. Now we start the slave ;)
;======================================================================

_Start                                      ; A0 = resident loader

; This routine simply loads the empty variable '_resload' to a1 and
; puts the resident-loader (location=A0) to it.

    lea     _resload(pc),a1                 ; Get Slave-base
    move.l  a0,(a1)                         ; Save for later use
    move.l  a0,a2                           ; A2 = resload, too

; Now we enable the Instruction-Cache but disable the Data-Cache at the
; same time. This gives us a very huge compatibility.

    move.l  #CACRF_EnableI,d0               ; Enable CPU Instruction-Cache
    move.l  d0,d1                           ; Mask
    jsr     (resload_SetCACR,a0)            ; WHD SetCache()

;======================================================================
; Clear Memory
;======================================================================

; This isn't important, so you can also leave this out. But for
; a nice and real clean memory we will "simulate" a software reset
; by clearing the memory from $10000 to $80000.

    lea.l   $10000,a0                       ; Get Start into a0
    move.l  #$6fffff,d0                     ; How many bytes to clear ?
.clearloop
    clr.l   (a0)+                           ; Clear a0 ($10000)
    dbra    d0,.clearloop                   ; Continue until d0 is -1

;======================================================================
; Load & initialize the OSEmu module
;======================================================================

; Without this we wouldn't be able to use the DOS-function LoadSeg()
; to directly load and relocate an executable for our needs.

    lea     _OSEmu(pc),a0                   ; file name
    lea     $400.w,a1                       ; A3 = OSEmu base address
    jsr     (resload_LoadFileDecrunch,a2)   ; Load and decrunch OSEmu file

; Initialize OSEmu

    move.l  a2,a0                           ; resload
    lea     _base(pc),a1                    ; slave structure
    jsr     $400.w                          ; Start it

    move.w  #0,sr                           ; switch to user mode

; Open dos.library to provide file loading function

    moveq.l #0,d0                           ; Clear d0 (=lib-version not important)
    lea     _dosname(pc),a1                 ; load dos.library

    move.l  $4.w,a6                         ; Get execbase to a6
    jsr     _LVOOpenLibrary(a6)             ; Open the library
    lea.l   _dospointer(pc),a4              ; Load dos-pointer address to a4
    move.l  d0,(a4)                         ; Put dos-pointer to a4
    move.l  d0,a6                           ; Put it also to a6

;======================================================================
; Load the intro via dos.library LoadSeg() function
;======================================================================

    lea     _exe(pc),A0                     ; Get executable-filename
    move.l  a0,d1                           ; And copy it to d0 also
    jsr     _LVOLoadSeg(A6)                 ; Load the file now.

    lsl.l   #2,d0                           ; Left-scroll result by 2
    move.l  d0,a1                           ; Copy result to a1
    addq.l  #4,a1                           ; Add 4 to it

    sub.l   a0,a0                           ; Clear a0 now
    moveq.l #0,d0                           ; No pointer on argumentline

    lea     _introstart(pc),a2              ; Get variable
    move.l  a1,(a2)                         ; Save start-address of game

;======================================================================
; The now loaded and relocated executable will be fixed here.
;======================================================================

; We will fix some routines in the intro before we start the show.
; The intro uses the Mega Cruncher v1.0 depacker. The JMP-command is
; located at $100 from the start of the exe. We will redirect it to out
; patch-routine.

    move.l  _introstart(pc),a1              ; Source-Address
    move.w  #$4ef9,$100(a1)                 ; Poke JMP to destination
    pea     (_fix,pc)                       ; Put fixes on Stack
    move.l  (a7)+,$102(a1)                  ; Write Stack to destination

; The background color is changed by the decruncher by writing the content
; of the used D3 register to $dff180. Nearly all crunchers use this method
; to show the user it's work. Anyway, the Mega Packer has a small bug. It
; will BYTE write to the $dff180 register, but the register only accepts
; WORD-writes.

    move.w  #$33c0,$5e(a1)                  ; Fix BYTE write to WORD

;======================================================================
; Start the whole show now !!!
;======================================================================

    move.l  _introstart(pc),a1              ; Source-Address
    lea.l   _arg(pc),a0                     ; Argument line
    moveq.l #1,d0                           ; One argument
    jsr     (a1)                            ; Start the decruncher
    jmp     _exitintro(pc)                  ; Now -EXIT- the intro/slave

;======================================================================
; The All-Changing patches ;)
;======================================================================

_fix

; The intro will open the Graphics-library to get the location of the
; CoProcessor. Just NOP - we don't need it anymore ;)

    move.w  #$4e71,$30000+$1d6              ; Remove OpenLibrary() Call
    move.w  #$4e71,$30000+$1d8

; This will remove the CoProcessor (COP1LCH) routine.

    move.w  #$4e71,$30000+$1dc              ; Remove write to $dff080
    move.w  #$4e71,$30000+$1de
    move.w  #$4e71,$30000+$1e0
    move.w  #$4e71,$30000+$1e2

    move.w  #$4e71,$30000+$1ea              ; Remove CloseLibrary() call
    move.w  #$4e71,$30000+$1ec

; The intro also controls the LED-filter. It switches it OFF and ON,
; without taking care of previous settings.
; We just NOP them also - WHDLoad offers an own ToolType (NoFilter) for this.

    move.w  #$4e71,$30000+$a                ; Remove LED-Filter control (OFF)
    move.w  #$4e71,$30000+$c
    move.w  #$4e71,$30000+$e
    move.w  #$4e71,$30000+$10

    move.w  #$4e71,$30000+$1f8              ; Remove LED-Filter control (ON)
    move.w  #$4e71,$30000+$1fa
    move.w  #$4e71,$30000+$1fc
    move.w  #$4e71,$30000+$11e

; Now it's time to start the Dual-Crew show ;)

    jmp     $30000                          ; Jump to the intro

;======================================================================
; Exit slave
;======================================================================

_exitintro

; We put the "OK" reason to the stack and load the resident-base to a0.
; Then we abort the whole show giving WHD the reason.

    pea     TDREASON_OK                     ; Everything went O.K.
    move.l  (_resload,pc),a0                ; Put base to a0 for use
    jmp     (resload_Abort,a0)              ; Exit the slave

;======================================================================
; Additional data and variables
;======================================================================

_OSEmu      dc.b    'OSEmu.400',0           ; Name of the OSEmu module to emulate DOS functions
_exe        dc.b    "DualCrew-VectorBob",0  ; Name of the Intro
    even
_resload    dc.l    0                       ; Address of resident loader
_dospointer dc.l    0                       ; DOS.library base pointer
_introstart dc.l    0                       ; Start-address after LoadSeg()
_arg        dc.b    $a                      ; Argument-line (CR=Empty)
_dosname    dc.b    'dos.library',0         ; DOS.library name
    even

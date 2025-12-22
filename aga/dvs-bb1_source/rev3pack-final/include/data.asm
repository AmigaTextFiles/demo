**********************************************************************
*	Data.asm
*	~~~~~~~~
*	Description : This contains all the Data and Data Structures
*		      used in the Demo/Intro etc..  		
*			
*	Code : Dennis Predovnik (SuLtAn/DVS)
*	Date : 12/3/96 
*
**********************************************************************

	section		Fast_DaTa,code

**********************************************************************
* 	Data and common variables				     *
**********************************************************************

wbview          dc.l  0
_GfxBase        dc.l  0
_IntuitionBase  dc.l  0
_DosBase	dc.l  0

_StdOut		dc.l  0	
oldres          dc.l  0
wbscreen        dc.l  0
OldDMACon	rs.w  1		        ; Old DMAcon Bits
OldINTEna	rs.w  1		        ; Old Intena Bits
INTSAVE		dc.l  0
VB		dc.l  0			; Vertical Blank Counter
systemsave	ds.l  5
_VBR		dc.l  0

wbname          dc.b  "Workbench",0
gfxname         dc.b  "graphics.library",0
intname         dc.b  "intuition.library",0
dosname		dc.b  "dos.library",0

;   OutPut Messages...

InitMsg		dc.b  " SuLtaN's Interigation Unit (SIU) Installed..",10,0
InitMsgSIZE	equ	*-InitMsg
WaitMsg		dc.b  "                Please Wait      ",10,10,0
WaitMsgSIZE	equ	*-WaitMsg
NTSCMsg		dc.b  " NTSC Unit..........Installed",10,0
NTSCMsgSIZE	equ	*-NTSCMsg
PALMsg		dc.b  " PAL Unit...........Installed",10,0
PALMsgSIZE	equ	*-PALMsg
OS2030Msg	dc.b  " OS 2.0 or Greater..Installed",10,0
OS2030MsgSIZE	equ	*-OS2030Msg
OS13Msg		dc.b  " OS 1.3 or Less.....Installed",10,0
OS13MsgSIZE	equ	*-OS13Msg
AGAMsg		dc.b  " AGA Chipset........Installed",10,10,0
AGAMsgSIZE	equ	*-AGAMsg
NoAGAMsg	dc.b  " AGA Chipset........Failed",10,10,0
NoAGAMsgSIZE	equ	*-NoAGAMsg
DVSMsg		dc.b  "      DeViOus DeZiGns 1996 ",10,0
DVSMsgSIZE	equ	*-DVSMsg
SYSTakeMsg	dc.b  "     An AGA Only Production",10,0 
SYSMsgSIZE	equ	*-SYSTakeMsg

*****************************************************************
*	Control flags						*
*****************************************************************

ntsc		dc.b	0		; 0 = pal, 1 = ntsc
AGA		dc.b	0		; 0 = ESC/OCS, 1 = AGA

*****************************************************************
*	Copper Lists						*
*****************************************************************

	section		GfX_DaTa,code_c

FIRSTCOPPER:
	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000
OPENPAL:
	incbin	"gfx/picpal.bin"
	dc.w	$010c,$0011 
	dc.w	$008e,$2c81
	dc.w	$0100,$0210 
	dc.w	$0104,$0224        
	dc.w	$0106,$0c40        
	dc.w	$0090,$2cc1 
	dc.w	$0092,$0038 
	dc.w	$0094,$00d8 
	dc.w	$0102,$0000 
	dc.w	$0108,$fff8
	dc.w	$010a,$fff8 
PICBLPT:
	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f0,$0000,$00f2,$0000 
	dc.w	$00f4,$0000,$00f6,$0000
	dc.w	$00f8,$0000,$00fa,$0000
	dc.w	$00fc,$0000,$00fe,$0000 

	dc.w	$01e4,$2100
	dc.w	$01fc,$0003      
	dc.w	$ffff,$fffe

NEWCOPPER:
	dc.w	$01fc,$0000
	dc.w	$0106,$0d80         ; Super Hires Sprites !!
	dc.w	$008e,$2c81
	dc.w	$0090,$2cc1
	dc.w	$0092,$0038
	dc.w	$0094,$00d0
	dc.w	$0108,0
	dc.w	$010a,0
	dc.w	$0102,0
CURSPR:
	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

	dc.w	$0100,%0110010000000000     ; 6 Planes.. %0101011000000000 
;	dc.w	$0104,%0000000001000000     ; Stuff sprites ! Switch Playfield priority..
MENUCOLOURTABLE:                
	dc.w	$0180,$0202,$0182,$0200,$0184,$0300,$0186,$0400
	dc.w	$0188,$0500,$018a,$0600,$018c,$0700,$018e,$0b44  
	dc.w	$0190,$0fff
	dc.w	$0192
MENUCOL:
	dc.w	$0302
	dc.w	$0194,$0fff,$0196,$0fff,$0198,$0302,$019a
	dc.w	$0302
	dc.w	$019c,$0fff,$019e,$0fff,$01a0,$0fff,$01a2
SPRCOL:	
	dc.w	$0302
MENUBLPT:
	dc.w	$00e0,$0000,$00e2,$0000     ; 1st Plane
	dc.w	$00e4,$0000,$00e6,$0000     ; 2nd Plane
	dc.w	$00e8,$0000,$00ea,$0000     ; 3rd Plane
	dc.w	$00ec,$0000,$00ee,$0000	    ; 4th Plane
	dc.w    $00f0,$0000,$00f2,$0000     ; 5th Plane
	dc.w	$00f4,$0000,$00f6,$0000     ; 6th Plane
VIEW3:
	dc.w	$fd01,$fffe		    ; New View !	
	dc.w	$0092,$003c                 ; NEW Data Fetch start!
	dc.w	$0094,$00d4                 ; NEW Data Fetch stop !
	dc.w	$0100,%1100001000000000     ; 4 Planes.. HiRes
SPLITPLANE:
	dc.w	$00e0,$0000,$00e2,$0000     ; 1st Plane
LOGOCOLOURTABLE:
	dc.w	$0180,$0202,$0182,$0302,$0184,$0302,$0186,$0fff
	dc.w	$0188,$0924,$018a,$0b35,$018c,$0302,$018e,$0d36
	dc.w	$0190,$0613,$0192,$0a25,$0194,$0e37,$0196,$0412
	dc.w	$0198,$0413,$019a,$0823,$019c,$0301,$019e,$0b36

	dc.w	$ff01,$fffe
LOGOBLPT:
	dc.w	$00e0,$0000,$00e2,$0000     ; 1st Plane
	dc.w	$00e4,$0000,$00e6,$0000     ; 2nd Plane
	dc.w	$00e8,$0000,$00ea,$0000     ; 3rd Plane
	dc.w	$00ec,$0000,$00ee,$0000	    ; 4th Plane

	dc.w	$ffff,$fffe                 ; End of list.

MENUDCOL:
	dc.w	$0192,$0fff
	dc.w	$0194,$0fff,$0196,$0fff,$0198,$0302
	dc.w	$019a,$0fba

MENUGO:
	dc.w	$0192,$0202
	dc.w	$0194,$0fff,$0196,$0fff,$0198,$0302
	dc.w	$019a,$0202

PICLOGOBK:
	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$019e,$0000

PICLOGOFK:
	dc.w	$0180,$0fff,$0182,$0fff,$0184,$0fff,$0186,$0fff
	dc.w	$0188,$0fff,$018a,$0fff,$018c,$0fff,$018e,$0fff
	dc.w	$0190,$0fff,$0192,$0fff,$0194,$0fff,$0196,$0fff
	dc.w	$0198,$0fff,$019a,$0fff,$019c,$0fff,$019e,$0fff
	dc.w	$0180,$0fff,$0182,$0fff,$0184,$0fff,$0186,$0fff
	dc.w	$0188,$0fff,$018a,$0fff,$018c,$0fff,$018e,$0fff
	dc.w	$0190,$0fff,$0192,$0fff,$0194,$0fff,$0196,$0fff
	dc.w	$0198,$0fff,$019a,$0fff,$019c,$0fff,$019e,$0fff
	dc.w	$019e,$0fff

PICLOGONK:
	incbin	"gfx/picpal.bin"

menuScreen1
	dc.l	0
menuScreen2
	dc.l	0	
dotBuf1	
	dc.l	0
dotBuf2
	dc.l	0

	section		InC_DaTa,code_c
	
*****************************************************************
*	Included GFX Binary Data				*
*****************************************************************

OPENPIC	 incbin "GFX/OpenPic.raw"
DVSLOGO1 incbin	"GFX/chipback45.raw"
DVSLOGO2 incbin	"GFX/chipback45.raw"
curR     incbin "GFX/curR.raw"
curL     incbin "GFX/curL.raw"
MAINBACK incbin	"GFX/chipback256.raw"
HEART    incbin "GFX/heart.raw"

	section		tableData,code
HEARTTABLE
	 incbin	"include/HeartTable.DAT"	
CUBETABLE
	 incbin "include/CubeTable.DAT"
		 
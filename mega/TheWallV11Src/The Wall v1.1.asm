שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ*----------------------------------------------------------------------------*
; Program:	The Wall.s
; Contents:	Slave for "The Wall" (c) 1990 Kefrens
; Author:	Legionary Of OldSk00l Crackers
; History:	2010/10/22 - v1.0
;		           - Full load from HD
;                          - Restarts Demo instead of making a Reset
;		           - Quit option (default key is 'F10')
;               2016/03/17 - v1.1
;                          - Just Reassembled to work with WHDLoad v18+
;
; Requires:	WHDLoad 18+
; Copyright:	Public Domain
; Language:	68000 Assembler
; Translator:	Asm-One v1.48
; Info:		A Nice Demo From Kefrens
*---------------------------------------------------------------------------*
		Incdir	'Dh0:OldSk00l Crackers/WHDLoad Includes/'
		Include	'whdload.i'
		Include	'whdmacros.i'
*---------------------------------------------------------------------------*
Base		SLAVE_HEADER			;ws_Security + ws_ID
		Dc.w	13			;ws_Version
		Dc.w	WHDLF_NoError|WHDLF_EmulTrap|WHDLF_ClearMem	;ws_flags
		Dc.l	1024*512		;ws_BaseMemSize
		Dc.l	0			;ws_ExecInstall
		Dc.w	Start-Base		;ws_GameLoader
		Dc.w	0			;ws_CurrentDir
		Dc.w	0			;ws_DontCache
Keydebug	Dc.b	0			;ws_keydebug
Keyexit		Dc.b	$59			;ws_keyexit = F10
Expmem		Dc.l	$0			;ws_ExpMem
		Dc.w	Name-Base		;ws_name
		Dc.w	Copy-Base		;ws_copy
		Dc.w	Info-Base		;ws_info
*---------------------------------------------------------------------------*
Name		Dc.b	'The Wall',0
Copy		Dc.b	'1990 Kefrens',0
Info		Dc.b	'Installed by Legionary/OldSk00l Crackers',10
		Dc.b	'Version 1.1 '
		Dc.b	'(2016-03-17)'
		Dc.b	0
		Even
*---------------------------------------------------------------------------*
Start		Lea	Resload(pc),a1
		Move.l	a0,(a1)

		Move.l	#11*512,d0
		Move.l	#5*512,d1
		Moveq	#1,d2
		Lea	$7e000,a0
		Move.l	a0,a3
		Move.l	Resload(pc),a2
		Jsr	Resload_DiskLoad(a2)

		Move.w	#$4e75,632(a3)
		Pea	Loader(pc)
		Move.w	#$4ef9,728(a3)
		Move.l	(a7)+,730(a3)

		Pea	Patcher(pc)
		Move.w	#$4eb9,256(a3)
		Move.l	(a7)+,258(a3)

		Jmp	(a3)

Patcher		Lea	$20000,a0
		Pea	Loader2(pc)
		Move.w	#$4ef9,5588(a0)
		Move.l	(a7)+,5590(a0)
;		Move.w	#$4e75,5486(a0)
;		Pea	Exit(pc)
;		Move.l	(a7)+,2796(a0)
		Clr.w	$7e660
		Rts

Loader		Move.w	$7e656,d0
		Move.w	$7e658,d1
		Move.l	$7e648,a0
		Bra	TrackLoader		

Loader2		Move.w	$292f0,d0
		Move.w	$292f2,d1
		Move.l	$292e2,a0

TrackLoader	Mulu.w	#11*512,d0
		Mulu.w	#11*512,d1
		Moveq	#1,d2
		Move.l	Resload(pc),a2
		Jsr	Resload_DiskLoad(a2)
		Move.w	#$8210,$dff096
		Moveq	#0,d0
		Rts
*---------------------------------------------------------------------------*
Resload		Dc.l	0		;address of resident loader
*---------------------------------------------------------------------------*
Exit		Pea	TDREASON_OK
		Bra	End

Wrongver	Pea	TDREASON_WRONGVER

End		Move.l	(Resload,Pc),-(a7)
		Add.l	#resload_Abort,(a7)
		Rts
*---------------------------------------------------------------------------*

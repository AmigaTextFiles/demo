; Demo-startup 2.4 (26.12.97) by Blueberry of Efreet
; Provides a clean context: PAL, no DMA, no Ints.
; Interrupt vectors are not restored!

Startup_68000	set	0	; Set to 1 to be 68000 compatible.
Startup_68020	set	0	; Set to 1 to require 68020.
Startup_AGA	set	0	; set to 1 to require AGA
Startup_Blitter	set	1	; Set to 1 if blitter is used.
Startup_Forbid	set	1	; Set to 1 to Forbid()/Permit().
Startup_Disable	set	0	; Set to 1 to Disable()/Enable().

; To use:
; Call KillSystem, do things, then call GreetSystem
; Can only be called ONCE!
; If the requirements are not met, KillSystem returns a negative number.
; If you have things to do in Supervisor mode, supply your
; own GetVBR routine to be called after KillSystem.
; With the default GetVBR, KillSystem just returns VBR in D0.

SU_Supervisor = -30
SU_Disable = -120
SU_Enable = -126
SU_Forbid = -132
SU_Permit = -138
SU_OpenLibrary = -552
SU_CloseLibrary = -414

SU_LoadView = -222
SU_WaitBlit = -228
SU_WaitTOF = -270
SU_OwnBlitter = -456
SU_DisownBlitter = -462

SU_AttnFlags = $128
SU_gb_ActiView = $22
SU_gb_copinit = $26

KillSystem:
	basereg	$09a,a3
	lea.l	$dff09a,a3
	move.w	#$7fff,d2
 	lea.l	SU_SysVars(pc),a2
	move.l	$4.w,a6
	if	Startup_68000!Startup_68020
	move.w	SU_AttnFlags(a6),d3
	endc
	if	Startup_68020
	lsr.w	#2,d3
	bcs.b	.ok020
	moveq.l	#-1,d0
	rts
.ok020:	endc
	if	Startup_AGA
	cmp.b	#$f8,$07d(a3)
	beq.b	.okAGA
	moveq.l	#-1,d0
	rts
.okAGA:	endc
	lea.l	SU_GfxName(pc),a1
	moveq.l	#0,d0
	jsr	SU_OpenLibrary(a6)
	move.l	d0,(a2)+
	if	Startup_Forbid
	jsr	SU_Forbid(a6)
	endc
	if	Startup_Disable
	jsr	SU_Disable(a6)
	endc
	move.l	d0,a6
	move.l	SU_gb_ActiView(a6),(a2)+
	suba.l	a1,a1
	jsr	SU_LoadView(a6)
	move.w	#$0020,$1dc(a3)	; Ensure PAL
	jsr	SU_WaitTOF(a6)
	jsr	SU_WaitTOF(a6)
	if	Startup_Blitter
	jsr	SU_OwnBlitter(a6)
	jsr	SU_WaitBlit(a6)
	endc
	move.w	$010(a3),d0
	or.w	d0,(a2)+
	move.w	$01c(a3),d0
	or.w	d0,(a2)+
	move.w	$01e(a3),d0
	or.w	d0,(a2)+
	move.w	$002(a3),d0
	or.w	d0,(a2)+
	move.w	d2,(a3)		; $09a
	move.w	d2,$096(a3)
	move.w	d2,$09c(a3)
	move.w	d2,$09e(a3)
	move.l	$4.w,a6
	if	Startup_68000
	lsr.w	#1,d3
	bcs.b	.010
	moveq.l	#0,d0
	rts
.010:	endc
	ifnd	GetVBR
	lea.l	.GetVBR(pc),a5
	else
	lea.l	GetVBR(pc),a5
	endc
	jmp	SU_Supervisor(a6)

	ifnd	GetVBR
.GetVBR:
	movec	vbr,d0
	rte
	endc

GreetSystem:
	lea.l	$dff09a,a3
	move.w	#$7fff,d2
	lea.l	SU_SysVars(pc),a2
	move.w	d2,(a3)		; $09a
	move.w	d2,$096(a3)
	move.w	d2,$09c(a3)
	move.w	d2,$09e(a3)
	move.l	(a2)+,a6	; GxfBase
	move.l	(a2)+,a1	; OldView
	move.l	SU_gb_copinit(a6),$080(a3)
	move.w	(a2)+,$09e(a3)
	move.l	(a2)+,(a3)	; $09a
	jsr	SU_LoadView(a6)
	jsr	SU_WaitTOF(a6)
	jsr	SU_WaitTOF(a6)
	if	Startup_Blitter
	jsr	SU_DisownBlitter(a6)
	endc
	move.w	(a2)+,$096(a3)
	move.l	a6,a1
	move.l	$4.w,a6
	if	Startup_Disable
	jsr	SU_Enable(a6)
	endc
	if	Startup_Forbid
	jsr	SU_Permit(a6)
	endc
	jmp	SU_CloseLibrary(a6)
	endb	a3

SU_GfxName:	dc.b	'graphics.library'
SU_SysVars:
.GxfBase:	dc.l	0
.OldView:	dc.l	0
.ADKCON:	dc.w	$8000
.INTENA:	dc.w	$8000
.INTREQ:	dc.w	$8000
.DMACON:	dc.w	$8000

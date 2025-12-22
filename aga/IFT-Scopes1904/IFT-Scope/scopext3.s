;
;########################################################################
; SCOPEXT3 - the high performance experience
; by Smack/Infect 220395
;########################################################################
; features: *sampling + playback at 36.8kHz (on normal PAL screen)
;           *hires 8-dot-wave
;########################################################################
; requires: -MC68020+
;           -OS V37+
;           -FAST RAM
; if the machine is too slow then the prog returns
;########################################################################
;

	incdir	includes:
	include	os_macros.is
	include	hardware-registers.is
CALL	MACRO
	jsr     (_LVO\1,a6)
	ENDM

	section	code,code
;---DOSLIBRARY---------------------
	move.l	4.w,a6
	move.l	(378,a6),a0	;LibList
	lea	(dosname,pc),a1
	CALL	FindName
	move.l	d0,dosbase
	move.l	d0,a6
	cmp	#37,(20,a6)	;lib_Version
	bge.b	.dosok
	moveq	#0,d0
	rts
.dosok	move.l	#titletxt,d1
	CALL	PutStr
;---32 BIT CPU---------------------
	move.l	4.w,a6
	btst	#1,(297,a6)	;ATTN_Flags(+1)
	bne.b	.CPUok
	move.l	#CPUtxt,d1
	CALLDOS	PutStr
	moveq	#0,d0
	rts
.CPUok	bsr.b	main0
	tst	slow_counter
	beq.b	.exit
	move.l	#slowtxt,d1
	CALLDOS	PutStr
.exit	moveq	#0,d0
	rts
main0	include	startup_nocheck.is	*jumps to 'main'
	include	dummysprites.is

**************************************************************
dosname:	dc.b	"dos.library",0
dosbase:	dc.l	0
		dc.b	"$VER: "
titletxt:	dc.b	"##SCOPEXT3## by Smack/Infect 220395",10,0
cputxt:		dc.b	"REQUIRES 68020+ CPU!",10,0
slowtxt:	dc.b	"SORRY, THIS MACHINE IS TOO SLOW!",10,0
**************************************************************
	even
main
	lea	cl1,a0
	bsr	dummysprites

;---INIT TIMING----------------------------------
	lea	$dff000,a5
	move	#1,(aud0per,a5)
	move	#1,(aud1per,a5)
	move	#96/2,(aud2per,a5)	;period 96 = ca.36800 Hz
	move	#1,(aud2len,a5)
	move	#64,(aud0vol,a5)
	move	#64,(aud1vol,a5)
	move	#00,(aud2vol,a5)
	move	#00,(aud3vol,a5)

;---INIT PARALLEL PORT---------------------------
	lea	($bfd000),a1
	move.b	#6,($200,a1)		*DDRA SEL and POUT output
	move.b	#0,($1301,a1)		*DDRB PRB input
	move.b	#2,(a1)			*PRA  POUT signal
	or.b	#2,($1001,a1)		*FILTER OFF!!

	move.l	(smppt0,pc),a6

	move.l	(mainvbr,pc),a0
	move.l	($70,a0),oldlevel4
	move.l	#sample_interrupt,($70,a0)
	move.l	#frame_interrupt,($6c,a0)
	move.l	#key_interrupt,($68,a0)

	move	#$7fff,(adkcon,a5)
	move.l	#cl1,(cop1lch,a5)
	move	#1,(copjmp1,a5)
	move	#$83e4,(dmacon,a5)	;+ aud2 !!!!
	move	#$c228,(intena,a5)	;audio2+vblank+level2

main_loop
	cmp.b	#$4d,keytaste	** F10 down
	beq.b	.dont
	bsr	plot_wave
.dont	clr	ready
	cmp.b	#$4f,keytaste	** F9 down
	bne.b	.ww0
.ww1	move	$dff006,$dff180
	tst	ready
	beq.b	.ww1
.ww0	tst	ready
	beq.b	.ww0
	cmp	#3,slow_counter
	bgt.b	.exit
	cmp.b	#$74,keytaste		** ESC up
	bne.b	main_loop
	clr	slow_counter
.exit
	move	#$7fff,$dff000+intena
	move.l	(mainvbr,pc),a0
	move.l	(oldlevel4,pc),($70,a0)
	rts

*********************************************************
***** A6 register forbidden to use (sample pointer) *****
*********************************************************

;-------------------------------
plot_wave
	lea	(wave_pt0,pc),a0	;double buf prev. frame
	movem.l	(a0)+,d0/d1
	exg	d0,d1
	movem.l	d0/d1,-(a0)
	lea	wpt1+2,a0
	move	d1,(4,a0)
	swap	d1
	move	d1,(a0)

	lea	fastscr+129*128-36,a5	;clear fast ram image
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	sub.l	a0,a0
	sub.l	a1,a1
	sub.l	a2,a2
	sub.l	a3,a3
	sub.l	a4,a4
	move	#128,d0
.clloop	movem.l	d1-a4,-(a5)
	movem.l	d1-a3,-(a5)
	sub	#36,a5
	dbf	d0,.clloop

	move.l	(smppt0,pc),a0		;plot to fast ram image
	lea	fastscr+64*128,a2
	move.b	(a0),d1
	ext	d1
	neg	d1
	asr	d1
	moveq	#7,d5
	moveq	#92-1,d7
.ploop	move.b	(a0)+,d0
	ext	d0
	neg	d0
	asr	d0
	move	d1,d2
	add	d0,d2
	asr	d2
	move	d2,d6
	lsl	#7,d6
	bset	d5,(a2,d6)
	move	d0,d3
	add	d2,d3
	asr	d3
	move	d3,d6
	lsl	#7,d6
	bset	d5,(a2,d6)
	move	d1,d4
	add	d2,d4
	asr	d4
	move	d4,d6
	lsl	#7,d6
	bset	d5,(a2,d6)
	add	d4,d1
	lsr	d1
	lsl	#7,d1
	bset	d5,(a2,d1)
	add	d2,d4
	lsr	d4
	lsl	#7,d4
	bset	d5,(a2,d4)
	add	d3,d2
	lsr	d2
	lsl	#7,d2
	bset	d5,(a2,d2)
	add	d0,d3
	lsr	d3
	lsl	#7,d3
	bset	d5,(a2,d3)
	move	d0,d1
	lsl	#7,d0
	bset	d5,(a2,d0)
	dbf	d5,.ploop
	addq	#1,a2
	moveq	#7,d5
	dbf	d7,.ploop

	lea	fastscr,a4		;copy to video ram
	move.l	(wave_pt0,pc),a5
	move	#128,d0
.coloop	REPT	2
	movem.l	(a4)+,d1-a3	;11
	move.l	d1,(a5)+
	move.l	d2,(a5)+
	move.l	d3,(a5)+
	move.l	d4,(a5)+
	move.l	d5,(a5)+
	move.l	d6,(a5)+
	move.l	d7,(a5)+
	move.l	a0,(a5)+
	move.l	a1,(a5)+
	move.l	a2,(a5)+
	move.l	a3,(a5)+
	ENDR
	move.l	(a4)+,(a5)+
	add	#36,a4
	dbf	d0,.coloop
	rts


************************************
sample_interrupt
	move.l	d0,-(a7)
	move.b	$bfe101,d0	*PRB CIA-A
	add.b	#$80,d0
	move	#$0780,$dff000+intreq
	move.b	d0,$dff000+aud0dat
	move.b	d0,$dff000+aud1dat
	move.b	d0,$dff000+aud2dat
	move.b	d0,(a6)+
	move.l	(a7)+,d0
	rte
************************************
frame_interrupt
	movem.l	d0-d7/a0-a5,-(a7)
	move	#$0020,$dff000+intreq
	tst	ready
	beq.b	.ok
	addq	#1,slow_counter
.ok	st	ready
	lea	(smppt0,pc),a0
	movem.l	(a0)+,d0/d1
	exg	d0,d1
	movem.l	d0/d1,-(a0)
	move.l	d1,a6
	movem.l	(a7)+,d0-d7/a0-a5
	rte
************************************
key_interrupt
	movem.l	d0-d2,-(a7)
	btst	#3,$bfed01	*ICR
	beq.b	.nokey
	move.b	$bfec01,keytaste	**get key
	moveq	#2,d2
	bsr.b	rasterwait
	bset	#6,$bfee01		**INMODE
	move.b	#0,$bfec01		**Handshake
	bclr	#6,$bfee01		**OUTMODE
.nokey	nop
	move	#8,$dff000+intreq
	movem.l	(a7)+,d0-d2
	rte
rasterwait			**input: d2 - number of lines to wait
.rwait0	move.b	$dff006,d0
.rwait1	move.b	$dff006,d1
	cmp.b	d0,d1
	beq.b	.rwait1
	dbf	d2,.rwait0
	rts
************************************

slow_counter	dc	0
oldlevel4	dc.l	0
keytaste	dc.b	0,0
wave_pt0	dc.l	scr0
wave_pt1	dc.l	scr1
ready		dc	0
smppt0		dc.l	smpbuf0
smppt1		dc.l	smpbuf1
*******************************************************
	section	buff,bss
	ds.b	1024
fastscr	ds.b	128*129
	ds.b	1024
smpbuf0	ds.b	1024*2
smpbuf1	ds.b	1024*2
*******************************************************
	section	screen,bss_c
	ds.b	1024
scr0	ds.b	92*129
scr1	ds.b	92*129
	ds.b	1024
*******************************************************
	section	chip,data_c
dummy_sprite:	dc.l	0,0,0,0

picstrt	set	100
backcol	set	$0412
cl1	ds	32
	dc	$1111,-2
	dc	bpl1mod,0,bpl2mod,-92,bplcon1,$ff
	dc	diwstrt,$1a6a,diwstop,$3ae0,ddfstrt,$28,ddfstop,$d8
	dc	color00,$0001,color01,$0eee
wpt1	dc	bpl0pth,0,bpl0ptl,0
	dc	(picstrt<<8)+5,-2,bplcon0,$9001,color00,backcol
	dc	((picstrt+63)<<8)+9,-2,color00,backcol+$0555
	dc	((picstrt+64)<<8)+9,-2,color00,backcol
	dc	((picstrt+129)<<8)+5,-2,bplcon0,1,color00,1
	dc	-1,-2

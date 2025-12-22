


;set tab size to 12 for comfort view

	include	exec/exec.i
	include	exec/exec_lib.i2

	include	intuition/intuition.i
	include	intuition/intuition_lib.i
	include	intuition/screens.i

	include	graphics/graphics_lib.i
	include	graphics/text.i
	include	graphics/rastport.i

	include	diskfont/diskfont_lib.i
	include	diskfont/diskfont.i


	include	hardware/custom.i
	include	hardware/intbits.i
INTF_AUDIO	equ	INTF_AUD0+INTF_AUD1+INTF_AUD2+INTF_AUD3
	include	hardware/dmabits.i	


	include	!main_17.i
;;;;;;;;;;;;;;
;compile mode;
;;;;;;;;;;;;;;
;0 - DEBUG (labels left)
;1 - RUN   (get full nonpackable exe)
;2 - PACK  (only code for packing)
;;;;;;;;;;;;;;
DEBUG equ 0
RUN   equ 1
PACK  equ 2
cMODE	set	RUN
;;;;;;;;;;;;;;
;;;;;	PATTERNS !!!!!
PATTERNS	EQU	34

 
frx_opt	set	1
_omicron	equ	1
;;;;;;;;;;;;;;;
;audio constants
A_sbit	equ	15	;frame: 16 or 15
A_frame	equ	1<<A_sbit	;length of frame: 65536 or 32768
A_freq	equ	17600
A_period	equ	3579545/A_freq	;17kHz


fast_mem	equ	3*1024*1024	; required fast
chip_mem	equ	512*1024	; chip (for audio)







 IFEQ (cMODE-DEBUG)

	lea	rd(pc),a0
clra
	clr.l	(a0)+
	cmp.l	#end_of_all-4,a0
	blo.s	clra

	lea	chipa,a5
	move.l	4.w,a6
 ENDC


 IFEQ (cMODE-RUN)

	lea	fasta,a1

	move.l	a1,a2
	move.l	#fast_mem/4,d0
clearbss	clr.l	(a2)+
	subq.l	#1,d0
	bne.s	clearbss	;as devpack don't repeatedly clear bss
	
	lea	CODE(pc),a0
	move.l	a1,a2
cpy	move.l	(a0)+,(a1)+
	cmp.l	#rd,a0
	blo.s	cpy
	
	move.l	4.w,a6
	jsr	_LVOCacheClearU(a6)

	lea	chipa,a5

	jsr	(a2)
	rts

 ENDC



_CUSTOM	equ	$DFF000

;TUNING
NumTx	equ	5+6	;кол-во текстур
spritx	equ	5	;first sprite texture
NumSpr	equ	12	;кол-во спрайтов

PrjConst	equ	175	;константа проектирования: s=x*PrjConst/z, etc...

minS	equ	-160	; должно быть <0
maxS	equ	+159	;   --//--    >0
minT	equ	-120	;             <0
maxT	equ	+119	;             >0
			; -> размеры экрана 320x240

maxvZ	equ	3*256	;макс. координата Z, когда ещё всё не до конца зафэйдено
			;(т.е. стены с обоими Z больше этой не рисуются)

CODE:;;;;;;;;;;;;

;registers in !main program:
;
;	a5 - chipmem
;	a6 - execbase



;fill in pointers to tables

	lea	rd(pc),a4

	move.l	a5,(rd_aucb-rd)(a4)		;ptr 2 audio buffer


	lea	rd_free(pc),a0
	lea	lengths(pc),a1
.floop
	move.l	a0,(a4)+	;write pointer

	clr.l	d0
.fgetnew
	move.w	(a1)+,d0
	beq.s	.fend
	bmi.s	.fbig
.fstep
	add.l	d0,a0
	bra.s	.floop
.fbig
	cmp.w	#$FFFF,d0
	bne.s	.fnopush
	move.l	a0,-(sp)
	bra.s	.fgetnew
.fnopush
	lsl.w	#1,d0
	lsl.l	#7,d0
	bra.s	.fstep
.fend

	;here should be coherency with lengths table
	move.l	(sp)+,a0
	lea	hordisp(pc),a2
	moveq	#spritx,d5
	swap	d5
	add.l	d5,a0
	lea	rd_ptrs(pc),a1

	moveq	#18,d0	;fill text pointers
	moveq	#64,d7
	lsl.l	#8,d7
	clr.l	d6
.txptrx
	move.b	(a2)+,d6
	move.l	a0,(a1)
	add.l	d6,(a1)+
	add.w	d7,a0
	subq.l	#1,d0
	bne.s	.txptrx	



	move.w	#$4080,d5
	lsl.l	#1,d7
	lea	spak(pc),a0
	move.l	rd_spr(pc),a1
;;;	clr.l	d0
;;;	clr.l	d1
.mkspreit
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	ext.w	d2
	ext.w	d3
	lsl.w	#5,d2
	lsl.w	#5,d3
;;;	add.w	d2,d0
;;;	add.w	d3,d1

	addq.l	#4,a1
	move.w	#$100,(a1)+
	addq.l	#2,a1
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	addq.l	#2,a1
	move.b	(a0)+,d2
	ext.w	d2
	move.w	d2,(a1)+
	move.l	#128,(a1)+
	move.l	#$0040FFFF,(a1)+

	move.l	d5,(a1)
	add.l	d7,d5
	move.b	(a0)+,(a1)
	addq.l	#4,a1

	tst.l	(a0)
	bne.s	.mkspreit

;;filling end




;;;;;;;;;;;;
;;;;;;;;;;;;open libraries, screen & its' bitmap
;;;;;;;;;;;;

	lea	iname(pc),a1
	clr.l	d0
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,-(sp)

	lea	gname(pc),a1
	clr.l	d0
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,-(sp)

	move.l	d0,a6
	lea	rd_crport(pc),a1
	jsr	_LVOInitRastPort(a6)	;init our custom temporary rastport

	move.l	4.w,a6
	lea	dfname(pc),a1
	clr.l	d0
	jsr	_LVOOpenLibrary(a6)
	tst.l	d0
	beq	nodf
	move.l	d0,-(sp)

	lea	scrtags(pc),a1
	lea	rect(pc),a0
	move.l	a0,(whererect+4-scrtags)(a1)
	move.l	8(sp),a6
	sub.l	a0,a0
	jsr	_LVOOpenScreenTagList(a6)
	tst.l	d0
	beq	noscreen
	move.l	d0,-(sp)

	lea	rd_scrbufs(pc),a5
	move.l	d0,a0
	sub.l	a1,a1
	moveq	#SB_SCREEN_BITMAP,d0
	jsr	_LVOAllocScreenBuffer(a6)
	move.l	d0,(a5)+
	beq.s	scrbuffail1
	move.l	(sp),a0
	sub.l	a1,a1
	moveq	#0,d0
	jsr	_LVOAllocScreenBuffer(a6)
	move.l	d0,(a5)+
scrbuffail1	beq	scrbuffail







;;;;;;;;;;;;opened





;;;;;;;;;;;;
;;;;;;;;;;;;generate sinus table
;;;;;;;;;;;;

	lea	sine(pc),a0		;sine tbl
	lea	(2049*2)(a0),a1

	clr.l	d0		;sin(0)
	move.l	#$6487eb,d1		;sin(2*PI/4096)  -> generate 4096 values.

.sgloop	move.l	d0,d6
	swap	d6
	lsr.w	#1,d6
	addq.w	#1,d6
	lsr.w	#1,d6

	move.w	d6,d5
	neg.w	d6

	move.w	d6,2048*2(a0)
	move.w	d6,(2048*2-2)(a1)

	move.w	d5,4096*2(a0)
	
	move.w	d5,(a0)+
	move.w	d5,-(a1)

	move.l	d1,d3		;calc next sinus
	move.l	d1,d4
	mulu.l	#$FFFFD886,d2:d3
	lsr.l	#1,d4
	add.l	d4,d3
	addx.l	d1,d2
	sub.l	d0,d2
	move.l	d1,d0
	move.l	d2,d1

	cmp.l	a0,a1
	bhs.s	.sgloop

;;;;;;;;;;;;generated

	
;call music synth code
;-------------------------------------------------
;-------------------------------------------------
;-------------call synth code---------------------
;-------------------------------------------------
;-------------------------------------------------
 IFNE	_omicron
	lea	sine(pc),a4		; sine for envelopes etc
	move.l	rd_aucb(pc),a0
	add.l	#32768,a0		; target buf
	lea	muza+PATTERNS(pc),a2	; notes
	bsr.w	omicron
 ENDC

;-------------------------------------------------







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Render text to memory image from defined disk font
;
; WARNING: 020+
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FONTHEIGHT	equ	50

	lea	printext(pc),a3
	lea	rd_ptrs(pc),a5

; a3 - pointer to text (format: <color.b>,"text text",0, etc)
; a5 - pointer to an array of memory blocks

;_RenderText
	lea	font(pc),a0
	lea	fontname(pc),a1
	move.l	a1,(a0)
	move.l	4(sp),a6		;diskfont.library
	jsr	_LVOOpenDiskFont(a6)
	tst.l	d0

	beq.b	.nofont

	move.l	d0,a1
	moveq	#0,d0
	moveq	#0,d1
.loop
	move.l	(a5)+,a4
	move.b	(a3)+,d4
	move.b	(a3)+,d0
.loo2	
	move.l	tf_CharData(a1),a2
	sub.b	tf_LoChar(a1),d0
	moveq	#FONTHEIGHT,d3
	move.l	tf_CharSpace(a1),a0
	move.l	a4,d5
	
	add.w	0(a0,d0.l*2),a4
	
	move.l	tf_CharKern(a1),a0
	exg	a4,d5
	
	add.w	0(a0,d0.l*2),a4
	
	move.l	tf_CharLoc(a1),a0
	move.w	0(a0,d0.l*4),d1
	move.w	2(a0,d0.l*4),d0
	beq.s	.skipp		;fix for zero symbol width!!!!! <by lvd>
.chdy	
	bfextu	(a2){d1:d0},d2
	move.l	a4,a0
	ror.l	d0,d2
.more
	add.l	d2,d2
	bcc.b	.no_set
	move.b	d4,(a0)
	tst.l	d2
.no_set
	addq.l	#1,a0
	bne.b	.more
	add.w	tf_Modulo(a1),a2

	add.w	#256,a4
	subq.w	#1,d3
	bne.b	.chdy
.skipp	
	move.l	d5,a4
	move.b	(a3)+,d0
	bne.b	.loo2

	tst.b	(a3)
	bne.b	.loop

	move.l	8(sp),a6		;graphics.library
	jsr	_LVOCloseFont(a6)
.nofont

;;;;;;;;;;;;font rendering end



;;;;;;;;;;;;do different things
	lea	rd(pc),a6

	bsr	Gen_shit

	bsr	Eng_genblk

	bsr	Eng_mkmove

	bsr	Pal_makepal ;a1 - ptr to palette


	lea	Proggy(pc),a0
	move.l	a0,(rd_MTprog-rd)(a6)





;;;;;;;;;;;;;;;;
;set interrupts & so on...

;!!!!!!! warning: we don't touch VBLANK bit in intena - else some strange problems arise

	move.l	a6,-(sp)

	move.l	(8+4)(sp),a6	;graphics.library
	move.l	4(sp),a0
	add.w	#sc_ViewPort,a0
	jsr	_LVOLoadRGB32(a6)	;load palette (a1 prepared by Pal_makepal)


	move.l	4.w,a6
	lea	Get_VBR(pc),a5
	jsr	_LVOSupervisor(a6)	;get vbr

	move.l	(sp)+,a6

	add.w	#$6C,a0	;VBR+$6C - vblank interrupt
			;VBR+$70 - audio interrupt

	lea	_CUSTOM,a1

	move.w	intenar(a1),-(sp)
	and.w	#(INTF_AUD0),(sp)
	or.w	#(INTF_SETCLR),(sp)
	move.w	dmaconr(a1),-(sp)
	and.w	#(DMAF_AUDIO+DMAF_SPRITE),(sp)
	or.w	#(DMAF_SETCLR),(sp)


	move.w	#(DMAF_AUDIO),dmacon(a1)		;disable audio dma
	move.w	#(INTF_AUDIO),intena(a1)		;disable audio ints
	move.w	#(INTF_AUDIO),intreq(a1)		;clear intflags

	move.l	(a0),-(sp)	;save vblank vector

	move.l	(a0),(rd_revblank-rd)(a6);!!!!!!!!!!!!!!!!!!!!!
				 ;replace vblank vector - done carefully
				 ;without disabling interrups

	lea	INT_vblank(pc),a2
	move.l	a2,(a0)+
	move.l	(a0),-(sp)
	lea	INT_audio(pc),a2
	move.l	a2,(a0)+
	move.l	a0,-(sp)

	lea	(aud0+ac_len)(a1),a2
	moveq	#4,d0
.setauregs
	move.w	#A_frame/2,(a2)+
	move.w	#A_period,(a2)+
	move.w	#64,(a2)+
	add.w	#ac_SIZEOF-6,a2
	subq.l	#1,d0
	bne.s	.setauregs

	lea	muza(pc),a0
	move.l	a0,(rd_auprog-rd)(a6)
	bsr	AuPlay

	move.w	#(DMAF_SETCLR+DMAF_AUDIO),dmacon(a1)
	move.w	#(INTF_SETCLR+INTF_AUD0),intena(a1)

	;vblank interrupt should be normally enabled

;;;;;;;;;;;;int stuff done





;;;;;;;;;;;;main loop start here

PlayLoop
;;;;;;;;;;;;;;
	lea	rd(pc),a6

	bsr	Eng_Intp
	bsr	Eng_render


;;;;;;;;;;;;noise

	moveq	#0,d7
	move.b	(rd_MT_noise-rd)(a6),d7
	beq.s	.nonoise


	move.l	(rd_vbuf-rd)(a6),a0
	move.w	(rd_gtime-rd)(a6),d0
.puk
	rol.l	d0,d0
	add.l	d7,d0
	move.l	d0,d1
	divul.l	#(maxS-minS+1)*(maxT-minT+1),d2:d1
	divu.w	#(maxS-minS+1),d1
	swap	d1
	tst.w	d1
	seq	d3
	or.b	d3,d1
	bsr	NoiseSrach
	subq.l	#1,d7
	bne.s	.puk
.nonoise
	tst.b	(rd_MT_nsml-rd)(a6)
	beq.s	.nonsml

	moveq	#31,d2
	and.w	(rd_gtime-rd)(a6),d2
	mulu.w	#(maxS-minS+1),d2
	moveq	#8,d7
.rew
	move.w	#320,d1
	bsr	NoiseSrach
	add.l	#10240,d2
	subq.l	#1,d7
	bne.s	.rew
.nonsml





;;;;;;;;;;;;doublebuffering & c2p

	move.l	(rd_shtrbuf-rd)(a6),a0
	movem.l	(rd_vbuf-rd)(a6),a1/a3
	move.l	a3,a2

	clr.l	d0
.trans
	move.w	(a1)+,d0
	move.b	(a0,d0.l),(a3)+
	cmp.l	a2,a1
	blo.s	.trans






	

	lea	(rd_scrbufs-rd)(a6),a5
	move.l	(a5)+,a0
	move.l	(a5)+,a1
	move.l	a0,-(a5)
	move.l	a1,-(a5)	;swap ScreenBuffers

	move.l	sb_BitMap(a1),(rd_crport+rp_BitMap-rd)(a6)	;copy bmap to rport

	move.l	6*4(sp),a6		;GfxBase
	clr.l	d0
	clr.l	d1
	move.l	#(maxS-minS),d2
	move.l	#(maxT-minT),d3
	move.l	#(maxS-minS+1),d4
	lea	rd_crport(pc),a0	;temp rport
	jsr	_LVOWriteChunkyPixels(a6)

	move.l	7*4(sp),a6		;IntuiBase
	move.l	4*4(sp),a0		;screen
	move.l	rd_scrbufs(pc),a1	;screenbuffer
	jsr	_LVOChangeScreenBuffer(a6)



	tst.w	rd_gtime(pc)
	bpl	PlayLoop

;;;;;;;;;;;;mainloop ends



;;;;;;;;;;;;get things back

	lea	_CUSTOM,a1

	move.w	#(INTF_AUDIO),intena(a1)
	move.w	#(INTF_AUDIO),intreq(a1)
	move.w	#(DMAF_AUDIO),dmacon(a1)

	move.l	(sp)+,a0
	move.l	(sp)+,-(a0)
	move.l	(sp)+,-(a0)

	move.w	(sp)+,dmacon(a1)
	move.w	(sp)+,intena(a1)



;;;;;;;;;;;;return resources

scrbuffail
	move.l	12(sp),a6		;intuition base
	lea	rd_scrbufs(pc),a5
	move.l	(sp),a0		;screen ptr
	move.l	(a5)+,a1
	jsr	_LVOFreeScreenBuffer(a6)
	move.l	(sp),a0
	move.l	(a5)+,a1
	jsr	_LVOFreeScreenBuffer(a6)

	move.l	(sp)+,a0
	jsr	_LVOCloseScreen(a6)
noscreen


	move.l	4.w,a6
	move.l	(sp)+,a1
	jsr	_LVOCloseLibrary(a6)
nodf
	move.l	(sp)+,a1
	jsr	_LVOCloseLibrary(a6)
	move.l	(sp)+,a1
	jsr	_LVOCloseLibrary(a6)	

	clr.l	d0
	rts	;end task!


NoiseSrach
	lea	([a6,(rd_vbuf-rd).w],d2.l*2),a1
.srach
	rol.l	d0,d0
	add.w	d1,d0
	move.w	d0,(a1)+
	subq.w	#1,d1
	bne.s	.srach

	rts



Get_VBR	movec	VBR,a0
	rte
















;;;;;;;;;;;;interrupt routines

INT_vblank	movem.l	d0-d7/a0-a6,-(sp)

	lea	_CUSTOM,a1
;;;; 	move.w	#(DMAF_SPRITE),dmacon(a1)	;no mouse pointer
	lea	rd(pc),a6

	lea	(rd_gtime-rd)(a6),a5

	btst	#6,$bfe001
	bne.s	.cwrk
.stop
	or.w	#$8000,(a5)
.cwrk
	tst.w	(a5)
	bmi	.no

	btst	#2,potinp(a1)
	beq	.no

	addq.w	#1,(a5)


.chkevent
	move.w	([(rd_MTprog-rd).w,a6]),d0
	moveq	#$0F,d1
	and.w	d0,d1
	lsr.w	#4,d0
	lsl.w	#3,d0
	cmp.w	(a5),d0
	bhi.s	.noevent
	addq.l	#2,(rd_MTprog-rd)(a6)

	cmp.b	#8,d1	;gap
	bne.s	.noev1
	addq.l	#4,(rd_mvpptr-rd)(a6)
	bra.s	.chkevent
.noev1
	cmp.b	#9,d1	;fade
	bne.s	.noev2
	st	(rd_MT_fade-rd)(a6)	
	bra.s	.chkevent
.noev2
	cmp.b	#10,d1	;noise on
	bne.s	.noev3
	addq.b	#1,(rd_MT_noise-rd)(a6)
	bra.s	.chkevent
.noev3
	cmp.b	#11,d1	;noise off
	bne.s	.noev4
	clr.w	(rd_MT_noise-rd)(a6)
	bra.s	.chkevent
.noev4
	cmp.b	#12,d1	;small noise
	bne.s	.noev5
	st	(rd_MT_nsml-rd)(a6)
	bra.s	.chkevent
.noev5

	cmp.b	#15,d1
	beq.s	.stop

	bfexts	d1{29:3},d1
	bpl.s	.setspeed
	lsl.l	#1,d1
.setspeed
	move.l	d1,(rd_MT_tstp-rd)(a6)

	bra.s	.chkevent



.noevent
	move.l	(rd_MT_tstp-rd)(a6),d0
	add.l	d0,(rd_MT_t-3-rd)(a6)
	add.l	d0,(rd_MT_t-3-rd)(a6)

	tst.b	(rd_MT_fade-rd)(a6)
	beq.s	.nofade

	btst	#0,(rd_gtime+1-rd)(a6)
	bne.s	.nofade
	move.l	(rd_bzt-rd)(a6),a0
.loop
	tst.b	(a0)
	beq.s	.nofade
	subq.b	#1,(a0)+
	bra.s	.loop
.nofade
	tst.b	(rd_MT_noise-rd)(a6)
	beq.s	.nonoise
	addq.b	#1,(rd_MT_noise-rd)(a6)
.nonoise


.no

	movem.l	(sp)+,d0-d7/a0-a6

	jmp	([rd_revblank.w,pc])	;"system-friendly" vblank :-)))





;;;;;;;;;;;;audio playing

INT_audio	movem.l	d0-d7/a0-a6,-(sp)
	lea	_CUSTOM,a1

	lea	rd(pc),a6

	btst	#INTB_AUD0,(intreqr+1)(a1)
	beq.s	.noaud0

	bsr.s	AuPlay

	move.w	#INTF_AUD0,intreq(a1)
.noaud0
	movem.l	(sp)+,d0-d7/a0-a6
	rte


AuPlay:
	move.l	(rd_auprog-rd)(a6),a0
.rld
	move.w	(a0)+,d0
	bne.s	.norst
	lea	muza(pc),a0
	bra.s	.rld
.norst
	move.l	a0,(rd_auprog-rd)(a6)

	lea	(aud0+ac_ptr)(a1),a0
	moveq	#4,d2
.newptr
	moveq	#$0F,d1
	and.w	d0,d1
	ror.w	#4,d0
	swap	d1
 IFEQ (A_sbit-15)
	lsr.l	#1,d1
 ENDC
	add.l	(rd_aucb-rd)(a6),d1
	move.l	d1,(a0)
	add.w	#ac_SIZEOF,a0
	subq.l	#1,d2
	bne.s	.newptr

	rts












;texture 'generating' ;)

Gen_shit:
	;генерим текстуры
	move.l	rd_tx(pc),a0
	
	clr.l	d7

	lea	(a0),a1

.rndfill	
	rol.l	d0,d0
	add.l	d7,d0
	move.b	d0,(a1)+
	
	addq.w	#1,d7
	bne.s	.rndfill	



	move.w	#$0100,d3

	clr.l	d0
	clr.l	d1

	moveq	#4,d5
.filter

	moveq	#4,d6
.blur
	sub.w	d3,d7
	move.b	(a0,d7.l),d0
	
	subq.b	#1,d7
	add.w	d3,d7
	move.b	(a0,d7.l),d1
	add.w	d1,d0
	
	add.w	d3,d7
	addq.b	#1,d7
	move.b	(a0,d7.l),d1
	add.w	d1,d0
	
	addq.b	#1,d7
	sub.w	d3,d7
	move.b	(a0,d7.l),d1
	add.w	d1,d0
	
	subq.b	#1,d7
	lsr.w	#2,d0
	move.b	d0,(a0,d7.l)
	
	addq.w	#1,d7
	bne.s	.blur

	subq.l	#1,d6
	bne.s	.blur


	lea	(a0),a1
.modify
	move.b	(a1),d0

	lsl.b	#2,d0
	slt	d1
	eor.b	d1,d0
	add.b	#$40,d0

	move.b	d0,(a1)+
	
	addq.w	#1,d7
	bne.s	.modify


	subq.l	#1,d5
	bne.s	.filter

	moveq	#23,d2
	moveq	#45,d3
	bsr.s	.deriv

	moveq	#1,d2
	moveq	#2,d3
	bsr.s	.deriv


	clr.l	d0
	moveq	#3,d6
.topal
	move.b	(a0),d2
	lsr.b	#2,d2
	add.b	d0,d2
	move.b	d2,(a0)+
	subq.w	#1,d7
	bne.s	.topal
	add.b	#$40,d0
	subq.l	#1,d6
	bne.s	.topal



	rts



.deriv
	lsl.w	#8,d2
.derl
	move.b	(a0,d7.l),d0
	add.w	d2,d7
	add.b	d3,d7
	move.b	(a0,d7.l),d1
	sub.w	d2,d7
	sub.b	d3,d7
	
	sub.b	d1,d0
	add.b	#$80,d0
	move.b	d0,(a1)+
	
	addq.w	#1,d7
	bne.s	.derl

	rts




;///////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;///////////////////////////////////////////////
;\\\\\\\\\\\\\\\


;palette creating (with fade)

Pal_makepal:; a6 должен указывать на rd !
	
	;генерит цвета, шейдтейбл и палитру

	move.l	(rd_bzt-rd)(a6),a0
	
	move.l	#(127*65536/maxvZ),d0
	moveq	#$7F,d1
	swap	d1
	
	move.w	#maxvZ,d7
.setbzt
	swap	d1
	move.b	d1,(a0)+
	swap	d1
	sub.l	d0,d1
	subq.w	#1,d7
	bne.s	.setbzt


	move.l	(rd_shtrbuf-rd)(a6),a0	;2060720 байт



	;generate shadetable

	lea	collt(pc),a3

	moveq	#3,d7	;RBG counter
.rgb
	lea	(a0),a1
	moveq	#4,d6	;color fields counter (8 fields, 32 colors each)
.field
	moveq	#63,d5	;counter inside field (for interpolating)
.interp
	lea	(a1),a2
	clr.l	d4	;shade counter
.shade
	clr.l	d0
	clr.l	d1
	move.w	(a3),d0		;interpolation inside color field
	move.b	d0,d1
	lsr.l	#8,d0
	move.l	d5,d2
	move.l	d5,d3
	eor.b	#$3F,d2
	mulu.w	d0,d2
	mulu.w	d1,d3	
	add.l	d2,d3
	lsr.l	#6,d3

	move.l	d4,d0		;shading
	lsl.b	#1,d0
	tst.b	d4
	bmi.s	.towhite
.toblack	clr.b	d2
	bra.s	.toend
.towhite	move.b	d3,d2
	not.b	d3		;d3=$ff-d3 {col=col+($ff-col)*coeff}
.toend	mulu.w	d0,d3
	lsr.w	#8,d3
	add.b	d3,d2		;d2.b - shaded color component

	move.b	d2,(a2,d7.l)	;writing color component

	add.w	#$400,a2
	addq.b	#1,d4
	bne.s	.shade

	addq.l	#4,a1
	dbf	d5,.interp

	addq.l	#2,a3
	subq.l	#1,d6
	bne.s	.field

	subq.l	#1,d7
	bne.s	.rgb

	sub.w	#$3FC,a2






	;a0 - shadetable
	;a2 - octree
	
	
;;	;очищаем место под octree
;;	
;;	lea	(a2),a1
;;	
;;	move.l	#37449*(ot_SIZE/4),d0
;;.clrot	clr.l	(a1)+
;;	subq.l	#1,d0
;;	bne.s	.clrot


	; заносим все элементы shadetable'а в octree	

	lea	(a0),a3

	lea	ot_SIZE(a2),a1	;a1 - свободное место в octree

.fillot
	move.l	(a3)+,d5

	lea	(a2),a4	; начали добавлять цвет


	moveq	#5,d7	; глубина дерева - 5 (только старшие 5 бит)
.bitindex
	bsr	.extract

	lea	ot_child0(a4,d2.l*4),a5	;есть ли ссылка на следующий уровень
	tst.l	(a5)
	bne.s	.ischild

	move.l	a1,(a5)	;нет ссылки
	add.w	#ot_SIZE,a1
.ischild
	move.l	(a5),a4	;есть ссылка

	subq.l	#1,d7
	bne.s	.bitindex


	;a4 - указатель на 'лист'
	
	ror.l	#5,d5	;восстановили d0

 IFND frx_opt

	addq.l	#1,(a4)	;увеличили счётчик
;;;;;;;;;;;	clr.l	d7	;добавляем компоненты
	moveq	#(3-1),d1
.addcomps
	move.b	d5,d7
	ror.l	#8,d5
	add.l	d7,ot_R(a4,d1.l*4)
	dbf	d1,.addcomps	

 ELSE
;;; fyrex on 28 oct 2k2

	addq.l	#1,(a4)+
	addq.l	#(ot_B-4),a4
	move.b	d5,d7
	add.l	d7,(a4)
	lsr.l	#8,d5
	move.b	d5,d7
	add.l	d7,-(a4)
	lsr.l	#8,d5
	move.b	d5,d7
	add.l	d7,-(a4)
;;; end of fyrex

 ENDC
	cmp.l	a2,a3
	blo.s	.fillot



	;сокращаем octree
	; пока кол-во листов >256
	;  среди всех конечных узлов (которые указывают только на листы)
	;  ищем узлы с минимальной суммой ot_count'ов их листов - и сокращаем их
	;  (делаем листом, суммируя ot_count'ы и ot_(R|G|B) их листов)


	;a0 - shadetable
	;a2 - octree
	;a1 - свободное место (после octree)

.cutleaves
	lea	(a2),a3

	clr.l	d0	;счётчик листов
	moveq	#-1,d1	;минимальный ot_count
.findmin
	tst.l	(a3)
	bmi.s	.nxtnode	;<0 - недействительный лист/узел
	bne.s	.leaf	;!=0 - лист (считаем их)


	clr.l	d3	;считаем сумму ot_count'ов
	moveq	#7,d2
.cntsum	move.l	ot_child0(a3,d2.l*4),a5
	tst.l	a5
	beq.s	.nochild
	tst.l	(a5)	;если указатеть был на узел (не на лист) - выход
	beq.s	.nxtnode
	add.l	(a5),d3
.nochild	dbf	d2,.cntsum


	cmp.l	d1,d3
	bhs.s	.nxtnode
	
	move.l	d3,d1
	lea	(a3),a4	;как минимум 1 лист есть всегда - a4 запишется

	bra.s	.nxtnode

.leaf	addq.w	#1,d0

.nxtnode	add.w	#ot_SIZE,a3
	cmp.l	a1,a3
	blo.s	.findmin

	cmp.w	#256,d0	;если листов <=256 - конец работы
	bls.s	.endcut


	;a4 - узел с минимальной суммой листов - сокращаем его

	clr.l	d2	;R
	clr.l	d3	;G
	clr.l	d4	;B
	moveq	#7,d5
	moveq	#-1,d6

.cutleaf	move.l	ot_child0(a4,d5.l*4),a5
	tst.l	a5
	beq.s	.noleaf

	move.l	d6,(a5)+	;сделали лист недействительным (<0)

	add.l	(a5)+,d2	;прибавили компоненты
	add.l	(a5)+,d3
	add.l	(a5),d4


.noleaf	dbf	d5,.cutleaf

	movem.l	d1-d4,(a4)	;записали в текущий узел (теперь лист)

	bra.s	.cutleaves
.endcut


	;d0 - кол-во листов после сокращения (может быть <256)

	lea	(a1),a5	;куда пишем палитру ( $xx.RR.GG.BB )
;;;;;;;	move.l	a1,(rd_palbuf-rd)(a6)
	lea	(a2),a3


	moveq	#1,d5
	ror.l	#8,d5
	move.l	d5,(a5)+
.palf
	tst.l	(a3)
	ble.s	.nxtpal

	movem.l	(a3),d1-d4

	divu.w	d1,d2
	divu.w	d1,d3
	divu.w	d1,d4

	move.b	d5,(ot_R+3)(a3)
	addq.b	#1,d5

	move.b	d2,(a5)
	addq.l	#4,a5
	move.b	d3,(a5)
	addq.l	#4,a5
	move.b	d4,(a5)
	addq.l	#4,a5

.nxtpal	add.w	#ot_SIZE,a3
	cmp.l	a1,a3
	blo.s	.palf




 	clr.l	d7
	lea	(a0),a3
.trans
	move.l	(a3)+,d5
	lea	(a2),a5	;входной адрес в octree
.nxtbi
	bsr.s	.extract

	move.l	ot_child0(a5,d2.l*4),a5

	tst.l	(a5)
	beq.s	.nxtbi

	move.b	(ot_R+3)(a5),(a0)+

	cmp.l	a2,a3
	blo.s	.trans

	rts	;a1 - ptr to palette


.extract
	move.l	d5,d1
	clr.l	d2

 IFND frx_opt

	moveq	#3,d6
.extrbits
	lsr.l	#8,d1
	roxl.l	#1,d2
	subq.l	#1,d6
	bne.s	.extrbits
	rol.l	#1,d5

 ELSE

;;; fyrex on 28 oct 2k2

	lsr.l	#8,d1
	addx.l	d2,d2	
	lsr.l	#8,d1
	addx.l	d2,d2	
	lsr.l	#8,d1
	addx.l	d2,d2	
	add.l	d5,d5

;;; end of fyrex

 ENDC

	rts






;///////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;///////////////////////////////////////////////
;\\\\\\\\\\\\\\\

;;;;;;;;;;;;main 3d engine renderer

Eng_render:	;a6 должен указывать на rd !


;; move.l (rd_vbuf-rd)(a6),a0
;; move.l #(maxS-minS+1)*(maxT-minT+1)/2,d0
;;.metka
;; clr.l (a0)+
;; subq.l #1,d0
;; bne.s .metka




	movem.w	(rd_wallhiY-rd)(a6),d0-d1	;высчитываем rd_(hi|lo)Y из wallY и viewY
	sub.w	(rd_viewY-rd)(a6),d0
	sub.w	(rd_viewY-rd)(a6),d1
	movem.w	d0-d1,(rd_hiY-rd)(a6)

;Расчёт опорной точки текстур стен

;txbase=[16.16]loY/(loY-hiY)

	movem.w	(rd_hiY-rd)(a6),d0/d2	;d0.l - hiY, d2.l - loY
	
	sub.l	d2,d0	;d0 - hiY-loY
	lsl.l	#8,d2
	neg.l	d0
	lsl.l	#8,d2
	divs.l	d0,d2
	lsl.l	#8,d2
	
	move.l	d2,(rd_txbase-rd)(a6)



	move.w	(rd_viewang-rd)(a6),d0	;генерим матрицу поворота
	and.w	#4095,d0		;4096 значений (ко)синуса
	lea	(pc,sine.w,d0.w*2),a0
	move.w	(a0),d1
	move.w	1024*2(a0),d0
	move.w	d1,d2
	move.w	d0,d3
	neg.w	d2		;d0 +cos, d1 +sin, d2 -sin, d3 +cos
	movem.w	d0-d3,(rd_rotmx-rd)(a6)


;floor/ceiling drawing

;	Uo,Vo считаются по формуле: (Uo,Vo)[16.16]=(1/T)*Rotate(0,PrjConst*Y)
;	dU,dV:                      (dU,dV)[16.16]=(1/T)*Rotate(Y,0)
;
;                       ( cos  sin )
; где Rotate(U,V)=(U,V)*(          ) {т.к. координаты в текстуре поворачиваются в другую сторону}
;                       (-sin  cos )

	move.w	#minT,d7
	move.l	(rd_vbuf-rd)(a6),a1	;куда текстурировать

	clr.l	d0
	move.b	(rd_txdn-rd)(a6),d0
	swap	d0
	lea	([(rd_tx-rd).w,a6],d0.l),a2	;откуда брать текcтуру

.fuvtb
	move.w	(rd_loY-rd)(a6),d6	;пол
	tst.w	d7
	blt.s	.nonzero
	bne.s	.ldnew		;чтобы не делить на 0

	move.b	(rd_txupdlt-rd)(a6),d0
	ext.w	d0
	lsl.l	#8,d0
	lsl.l	#8,d0
	add.l	d0,a2

	bra	.efuv
.ldnew
	move.w	(rd_hiY-rd)(a6),d6	;переключение на потолок
.nonzero
	movem.w	(rd_rotmx-rd)(a6),d0-d3	;d0  cos,  d1  sin
				;d2  -sin, d3  cos
	
	move.w	d6,d4
	ext.l	d7
	muls.w	#PrjConst,d4	;d4.l = PrjConst*Y
	
	muls.l	d4,d2	;d2 = T*U'= -PrjConst*Y*sin
	muls.l	d4,d3	;d3 = T*V'=  PrjConst*Y*cos

	divs.l	d7,d2	; U'
	divs.l	d7,d3	; V'

	lsl.l	#2,d2	;
	lsl.l	#2,d3	; к виду 16.16

	add.l	(rd_viewX-rd)(a6),d2
	add.l	(rd_viewZ-rd)(a6),d3

	muls.w	d6,d0	;d0 = T*dU= Y*cos
	muls.w	d6,d1	;d1 = T*dV= Y*sin

	lsl.l	#2,d0	;
	lsl.l	#2,d1	; к виду 16.16

	divs.l	d7,d0	;dU
	divs.l	d7,d1	;dV

	divs.l	d7,d4	;d4.l - Z-координата

	cmp.l	#maxvZ,d4
	bgt.s	.efuv

	moveq	#minS/2,d5
	add.l	d5,d5
	move.l	d1,d6
	muls.l	d5,d6
	muls.l	d0,d5
	add.l	d6,d3
	add.l	d5,d2

	move.w	([(rd_bzt-rd).w,a6],d4.w),d4

	lsl.l	#8,d1
	lsl.l	#8,d3
	move.l	d1,a3

	;d2,d3 -  U, V [16.16]
	;d0,a3 - dU,dV [16.16]
	;a2 - адрес текстуры
	;a1 - адрес в буфере экрана
	;d4.w - яркость (high byte)

	moveq	#16,d5
	move.w	#(maxS-minS+1),d1

.inner
	move.l	d3,d6
	lsr.l	d5,d6

	rol.l	d5,d2
	add.l	a3,d3

	move.b	d2,d6
	rol.l	d5,d2

	move.b	(a2,d6.l),d4
	add.l	d0,d2

	move.w	d4,(a1)+
	subq.w	#1,d1

	bne.s	.inner
	bra.s	.ifuv
.efuv
	moveq	#($ffffff00+(maxS-minS+1)/2),d1
.clrloop
	clr.l	(a1)+
	subq.b	#1,d1
	bne.s	.clrloop
.ifuv
	addq.w	#1,d7
	cmp.w	#maxT,d7
	ble	.fuvtb






	movem.w	(rd_viewX-rd)(a6),d0-d2	;d0 - X, d2 - Z

	move.l	(rd_blkptr-rd)(a6),a1	;ищем стартовый блок
	move.l	a1,a0
.sbfloop
	tst.b	bi_dummy(a1)	;если не нашли стартблок - выход
	bne.s	.sbfcont
	rts
.sbfcont
	movem.w	bi_crX(a1),d3/d5
	move.w	#$100,d4
	move.w	d4,d6
	add.w	d3,d4
	add.w	d5,d6	;d3,d4 - для X, d5,d6 - для Z
	
	cmp.w	d3,d0
	blt.s	.sbfnext
	cmp.w	d4,d0
	bge.s	.sbfnext
	cmp.w	d5,d2
	blt.s	.sbfnext
	cmp.w	d6,d2
	blt.s	.sbfdone
.sbfnext
	add.w	#bi_SIZE,a1
	bra.s	.sbfloop
.sbfdone	;a1 - указатель на начальный блок



	;очищаем флаг bi_flgdone
	;вращаем координаты в bi_(lb|rb|etc.)

.clerot	clr.b	bi_flgdone(a0)	;bi_flgdone.b

	lea	bi_lbX(a0),a2

	move.l	bi_crX(a0),d0	;загрузка X и Z координат
	bsr	Eng_rotmv		;повернуть и передвинуть в соотв. с полож. камеры
	move.l	d1,(a2)+		;посчитали левый задний угол
	
	moveq	#1,d7
	ror.l	#8,d7		;d7=$0100 0000
	add.l	d7,d0
	bsr	Eng_rotmv
	move.l	d1,(a2)+		;правый задний
	
	add.w	#256,d0
	bsr	Eng_rotmv
	move.l	d1,(a2)+		;правый передний
	
	sub.l	d7,d0
	bsr	Eng_rotmv
	move.l	d1,(a2)		;левый передний

	add.w	#bi_SIZE,a0
	tst.b	bi_dummy(a0)
	bne.s	.clerot





;raycaster for walls

	;рейкастим лучи

	move.l	(rd_clbuf-rd)(a6),a2
	lea	(rd_curS-rd)(a6),a4
	move.w	#minS,(a4)


	;a1 - начальный блок, a0 - текущий, a2 - место в ClmBuf'е

Eng_raycast
	move.l	a1,a0
Eng_trace
	move.l	(rd_dunno-rd)(a6),a5	;dunno-буфер
	st.b	bi_flgdone(a0)	;прошлись лучом по блоку - он видим

	cmp.l	a0,a1
	bne	.norw


	;близко к невидимой стенке?
	movem.w	(rd_viewX-rd)(a6),d2-d4	;d2 - X, d4 - Z

near	equ	8
	moveq	#near,d7

	sub.w	bi_crZ(a1),d4	;к нижней стене?
	cmp.w	d7,d4
	bgt.s	.nodw
	tst.l	bi_pbw(a1)
	beq.s	.nodw

	bsr	Eng_trcrw
	bsr	Eng_trcuw
	bsr	Eng_trclw
	move.l	bi_pbw(a0),a0
	st.b	bi_flgdone(a0)
	bsr	Eng_trclw
	bsr	Eng_trcdw
	bsr	Eng_trcrw
	bra.s	.illegal2

.nodw
	not.b	d4		;к верхней стене?
	cmp.w	d7,d4
	bgt.s	.nouw
	tst.l	bi_plf(a1)
	beq.s	.nouw

	bsr	Eng_trclw
	bsr	Eng_trcdw
	bsr	Eng_trcrw
	move.l	bi_pfw(a0),a0
	st.b	bi_flgdone(a0)	;прошлись лучом по блоку - он видим
	bra.s	.tcont

.nouw
	sub.w	bi_crX(a1),d2	;к левой стенке?
	cmp.w	d7,d2
	bgt.s	.nolw
	tst.l	bi_plf(a1)
	beq.s	.nolw

	bsr	Eng_trcdw
	bsr	Eng_trcrw
	bsr	Eng_trcuw
	move.l	bi_plf(a0),a0
	st.b	bi_flgdone(a0)	;прошлись лучом по блоку - он видим
	bsr	Eng_trcuw
	bsr	Eng_trclw
	bsr	Eng_trcdw
.illegal2
	bra.s	.illegal

.nolw
	not.b	d2		;к правой стенке?
	cmp.w	d7,d2
	bgt.s	.norw
	tst.l	bi_prt(a1)
	beq.s	.norw

	bsr	Eng_trcuw
	bsr	Eng_trclw
	bsr	Eng_trcdw
	move.l	bi_prt(a0),a0
	st.b	bi_flgdone(a0)	;прошлись лучом по блоку - он видим
	bsr	Eng_trcdw
	bsr	Eng_trcrw
	bsr	Eng_trcuw
.illegal1
	bra.s	.illegal
.norw

	bsr	Eng_trcdw
.tcont
	bsr	Eng_trcrw
	bsr	Eng_trcuw
	bsr	Eng_trclw

.illegal
;	ILLEGAL	;!!!!!!
;	rts

;	откат
Eng_dunno	
	
	cmp.l	(rd_dunno-rd)(a6),a5
	bls.s	Eng_endunno

	sub.w	#56,a5
	movem.l	(a5),d0-d7/a0/a3

	tst.l	a3
	bne.s	Eng_dunno

thresh	equ	60

	tst.l	d6
	bgt.s	.cmp1
	cmp.w	#-thresh,d6
	blt.s	Eng_dunno
	clr.l	d6
.jump
	subq.l	#4,sp
	bra	Eng_gotwall
.cmp1
	cmp.w	#($100+thresh),d6
	bge.s	Eng_dunno
	clr.l	d6
	st.b	d6
	bra.s	.jump

	bra.s	Eng_dunno
Eng_endunno
Eng_endtrc
	add.w	#cl_SIZE,a2
	addq.w	#1,(a4)
	cmp.w	#maxS,(a4)
	ble	Eng_raycast






;sort columns & sprites

	;сортируем спрайты/колонки
	clr.l	(rd_ssrt-rd)(a6)


	move.l	(rd_clbuf-rd)(a6),a2	;добавляем колонки
	move.w	#(maxS-minS+1),d7
.addcols
	move.b	#2,cl_dummy(a2)
	tst.w	cl_Z(a2)
	ble.s	.skadcl

	bsr.s	.addsrt		;adds (a2) to rd_ssrt
.skadcl
	add.w	#cl_SIZE,a2
	subq.w	#1,d7
	bne.s	.addcols


	move.l	(rd_blkptr-rd)(a6),a3	;добавляем спрайты
.selblk
	tst.b	bi_flgdone(a3)
	beq.s	.nxtblk

	move.l	(rd_spr-rd)(a6),a2

	movem.w	bi_crX(a3),d6-d7	;d6 - bi_crX, d7 - bi_crZ
.selspr
	tst.b	sp_dummy(a2)
	beq.s	.selend
	
	movem.w	sp_Xo(a2),d0-d2	;d0 - sp_Xo, d2 - sp_Zo

	move.w	#$100,d4		;делаем координы для проверки (bi_cr+$100)
	move.w	d4,d5
	add.w	d6,d4
	add.w	d7,d5
	
	cmp.w	d6,d0		;попал ли спрайт в кубик (в bi_)
	blt.s	.selnxt
	cmp.w	d4,d0
	bge.s	.selnxt
	cmp.w	d7,d2
	blt.s	.selnxt
	cmp.w	d5,d2
	bge.s	.selnxt
	
	swap	d0
	move.w	d2,d0
	bsr	Eng_rotmv		;провернуть координаты спрайта (d2-d5 - портятся)

	tst.w	d1		;если Z<=0 - спрайт невидим
	ble.s	.selnxt
	
	move.l	d1,sp_Xr(a2)

	bsr.s	.addsrt

.selnxt	add.w	#sp_SIZE,a2
	bra.s	.selspr


.addsrt	;добавляет элемент a2 в отсортированый список (rd_ssrt)
	;использует a0,a1,d0

	lea	(rd_ssrt-rd)(a6),a1	;вставляем (a2) в отсортированный список
	move.w	sp_Zr(a2),d0
.looknxt
	move.l	a1,a0

	move.l	(a0),a1

	tst.l	a1		;если ноль - вставить в конец списка
	beq.s	.insert
	
	cmp.w	sp_Zr(a1),d0	;иначе - проверить Z-координату
	blt.s	.looknxt
.insert
	move.l	a1,(a2)
	move.l	a2,(a0)

	rts

.selend
.nxtblk
	add.w	#bi_SIZE,a3
	tst.b	bi_dummy(a3)
	bne.s	.selblk











;draw sprites/columns in back-to-front order (sorted)

	;рисуем колонки/спрайты

	lea	(rd_ssrt-rd)(a6),a2
	bra	.drawend
.draw
	cmp.b	#2,cl_dummy(a2)
	bne.s	.spreit

	movem.w	cl_Thi(a2),d0-d1
	movem.w	minT_(pc),d2-d3

	cmp.l	d2,d1
	bge.s	.cTloOK
	move.l	d2,d1
.cTloOK	
	cmp.w	d3,d0
	ble.s	.cThiOK
	move.w	d3,d0
.cThiOK	
	sub.w	d1,d0	;d0 - высота для цикла по точкам
	ble.s	.drawend1

	move.w	cl_S(a2),d4
	lea	([(rd_vbuf-rd).w,a6],d4.w*2,(-minS*2).w),a3

	move.w	d1,d4
	sub.w	d2,d4
	mulu.w	#(2*(maxS-minS+1)),d4
	add.l	d4,a3	;a3 - начало текстурирования в буфере

	move.l	cl_txstep(a2),d2	;d2 - dU
	muls.l	d2,d1
	add.l	(rd_txbase-rd)(a6),d1	;d1 - U

	clr.l	d3
	move.w	cl_tx(a2),d3
	move.b	cl_V(a2),d3
	lsl.l	#8,d3
	lea	([a6,(rd_tx-rd).w],d3.l),a4	;получили позицию в буфере текстур

	move.w	cl_Z(a2),d3
	move.w	([(rd_bzt-rd).w,a6],d3.w),d3	;яркость

	move.l	d1,d4	;U
	move.l	d2,d5	;dU

	clr.w	d4
	swap	d4
	swap	d5

.innerloop	
	add.w	d2,d1
	move.b	(a4,d4.l),d3

	addx.w	d5,d4

	move.w	d3,(a3)
	add.w	#(2*(maxS-minS+1)),a3

	subq.w	#1,d0
	bne.s	.innerloop
.drawend1
	bra	.drawend




.spreit
	movem.w	sp_Xr(a2),d0-d1	;d0 - Xr, d1.l - Zr
	movem.w	sp_Yo(a2),d2-d6	;d2 - Yo, d4 - Sx, d5 - Sy, d6 - dcr
	move.w	#PrjConst,d3
	sub.w	(rd_viewY-rd)(a6),d2
	
	muls.w	d3,d0
	muls.w	d3,d2
	
	divs.w	d1,d0
.drall1
	bvs.s	.drawend1
	divs.w	d1,d2	;d0,d2 - cS,cT
	bvs.s	.drawend1

	movem.w	d0/d2,(rd_scS-rd)(a6)
	
	mulu.w	d3,d6	;масштабируем d3 в соответствии с d6 (0..65535)
	swap	d6

	muls.w	d6,d4
	muls.w	d6,d5

	divs.w	d1,d4
	bvs.s	.drawend1
	divs.w	d1,d5	;d4,d5 - deltaS,deltaT
	bvs.s	.drawend1

;считаем шаг в текстуре по формуле txstep[16.16]=Z/(PrjConst*dcr)

	lsl.l	#8,d1
	ext.l	d6
	lsl.l	#8,d1
	divs.l	d6,d1	;d1 - шаг в текстуре
	move.l	d1,(rd_stxs-rd)(a6)

	move.w	d0,d1
	move.w	d2,d3

	sub.w	d4,d0	;d0 - slfS
;;;	bvs.s	.drawend1
	sub.w	d5,d2	;d2 - sloT
;;;	bvs.s	.drawend1
	add.w	d4,d1	;d1 - srtS
;;;	bvs.s	.drawend1
	add.w	d5,d3	;d3 - shiT
;;;	bvs.s	.drawend1

	movem.w	minS_(pc),d4-d7	;d4 minS, d5 maxS+1, d6 minT, d7 maxT+1

	cmp.w	d4,d0		;клиппируем
	bge.s	.slfS_OK
	move.w	d4,d0
.slfS_OK
	cmp.w	d5,d1
	ble.s	.srtS_OK
	move.w	d5,d1
.srtS_OK
	cmp.w	d6,d2
	bge.s	.sloT_OK
	move.w	d6,d2
.sloT_OK
	cmp.w	d7,d3
	ble.s	.shiT_OK
	move.w	d7,d3
.shiT_OK

	sub.w	d0,d1
.drspr_1	ble.s	.drawend1
	sub.w	d2,d3
	ble.s	.drspr_1

	;d0 - начальный S
	;d1 - счётчик S
	;d2 - начальный T
	;d3 - счётчик T
	movem.w	d0-d3,(rd_sSstrt-rd)(a6)

.drsol
	lea	(rd_stxs-rd)(a6),a3
	move.l	(a3)+,d0		;d0 - шаг текстуры
	movem.w	(a3)+,d1-d5		;d1 - cS, d2 - cT
				;d3 - Sstrt, d4 - Scnt, d5 - Tstrt
				;(a3) - Tcnt

	move.l	d3,d6	;
	move.w	d5,d7	;для расчёта экранного адреса
	
	sub.l	d1,d3	;считаем начальные координаты в текстуре
	sub.l	d2,d5
	muls.l	d0,d3	;d3 - U
	muls.l	d0,d5	;d5 - V

	lsr.l	#8,d5
	clr.b	d5
	move.l	sp_txnum(a2),d1
	lsr.l	#8,d1
	add.w	d5,d1
	lea	([a6,(rd_tx-rd).w],d1.l),a4	;адрес в текстуре

	sub.w	#minT,d7
	mulu.w	#(maxS-minS+1),d7
	add.l	d6,d7
	lea	([a6,(rd_vbuf-rd).w],d7.l*2,(2*(-minS)).w),a1	;экранный адрес
	
	move.w	d0,d5
	move.w	d3,d6

	swap	d3
	clr.l	d1
	swap	d0
	move.b	d3,d1

	tst.b	sp_type(a2)		;проверка типа спрайта
	bne.s	.spr_norm

.drsil
	add.w	d5,d6
	move.b	(a4,d1.l),d3

	addx.b	d0,d1
	
	move.b	(a1),d2
	add.b	d3,d2
	scs	d3
	or.b	d3,d2
	move.b	d2,(a1)
	addq.l	#2,a1
	
	subq.w	#1,d4
	bne.s	.drsil

	bra.s	.spr_end

.spr_norm
	move.w	sp_Zr(a2),d2
	move.w	([a6,(rd_bzt-rd).w],d2.w),d2	;получили яркость из таблицы

.drsul
	add.w	d5,d6
	move.b	(a4,d1.l),d2

	beq.s	.nomove
	move.w	d2,(a1)
.nomove
	addx.b	d0,d1

	addq.l	#2,a1
	subq.w	#1,d4
	bne.s	.drsul

.spr_end
	addq.w	#1,-2(a3)
	subq.w	#1,(a3)
	bne	.drsol

.drawend
	move.l	(a2),a2
	tst.l	a2
	bne	.draw




	rts






;--------------------------------------------------------------

;rotate proc

Eng_rotmv:	;d0(x.16|z.16) поворачивает и смещает в d1; d0 не изменяется, d2-d5 портятся

	movem.w	(rd_rotmx-rd)(a6),d2-d5	;загрузить матрицу поворота
				;d2 = cos, d3 = sin  | X
				;d4 = -sin,d5 = cos  | Z
	move.l	d0,d1
	sub.w	(rd_viewZ-rd)(a6),d1
	swap	d1
	sub.w	(rd_viewX-rd)(a6),d1	d1.w = X, (d1>>16).w = Z

	muls.w	d1,d2	;d2 = Xcos
	muls.w	d1,d4	;d4 = -Xsin
	
	swap	d1
	
	muls.w	d1,d5	;d5 = Zcos
	muls.w	d3,d1	;d1 = Zsin

	add.l	d5,d4	;d4 = Z'=-Xsin+Zcos
	add.l	d2,d1	;d2 = X'=Xcos+Zsin
	
	lsl.l	#2,d4
	lsl.l	#2,d1
	
	swap	d4
	move.w	d4,d1
	
	rts



;procs for raycaster

;--------------------------------------------------------------
	;для сокращения
Eng_trcdw
	movem.w	bi_lbX(a0),d0-d3	;d0 Xo, d1 Zo, d2 Xe, d3 Ze
	move.l	bi_pbw(a0),a3
	move.b	bi_txbw(a0),d7
	bra.s	Eng_blktrc
Eng_trcrw
	movem.w	bi_rbX(a0),d0-d3
	move.l	bi_prt(a0),a3
	move.b	bi_txrt(a0),d7
	bra.s	Eng_blktrc
Eng_trcuw
	movem.w	bi_rfX(a0),d0-d3
	move.l	bi_pfw(a0),a3
	move.b	bi_txfw(a0),d7
	bra.s	Eng_blktrc
Eng_trclw	
	movem.w	bi_lfX(a0),d0-d1
	movem.w	bi_lbX(a0),d2-d3
	move.l	bi_plf(a0),a3
	move.b	bi_txlf(a0),d7
;;;;;;;;;;;	bra.s	Eng_blktrc

Eng_blktrc:	;пересекает ли луч стену

	;регистры на входе:
	;
	;a0 - указатель на текущий блок
	;a1 - указатель на начальный блок
	;a2 - текущая позиция в ClmBuf'e
	;a3 - указатель на соседний блок, соответствующий стене d0-d3
	;a4 - указатель на текущую координату S
	;a5 - указатель на буфер отката в спорных случаях
	;
	;d0.w, d1.w, d2.w, d3.w - соответственно Xo, Zo, Xe, Ze стены (расширены до лонга!)

	;rd_curS - определяет луч

	;результат: добавляет колонку в ClmBuf или возвращается



	;проверка ориентации стены и луча:
	; луч: PrjConst * X = S * Z
	; проверка ориентации: PrjConst * dX - S * dZ <= 0 (блок - против часовой стрелки)
	
	sub.l	d0,d2	;d2 - dX
	sub.l	d1,d3	;d3 - dZ
	move.w	d2,d4
	move.w	d3,d5
	
	muls.w	#PrjConst,d4	;PrjConst * dX
	muls.w	(a4),d5		;S * dZ
	
	sub.l	d5,d4	;d4 = PrjConst * dX - S * dZ

	blt.s	.orientok
.rts
	rts
.orientok

	;расчёт точки пересечения стены с лучом
	; (X Z) = (Xo Zo) + V * (dX dZ)
	;  V = (S * Zo - PrjConst * Xo) / (PrjConst * dX - S * dZ)

	;уже посчитано: d4 = PrjConst * Dx - S * dZ

	move.w	d0,d5		;Xo
	move.w	d1,d6		;Zo
	muls.w	#PrjConst,d5	;PrjConst * Xo
	muls.w	(a4),d6		;S * Zo
	sub.l	d5,d6		;d6 = S * Zo - PrjConst * Xo

	move.l	d6,d5
	muls.l	d3,d5		;dZ * (S * Zo - PrjConst * Xo)
	divs.l	d4,d5		;dZ * V
	add.l	d1,d5		;!!d5 = Z!!

	blt.s	.rts	;если точка пересечения находится сзади - нафиг :)

	cmp.l	#maxvZ,d5	;обрезка слишком длинного луча
	ble.s	.cont
	st	cl_Z(a2)
	rts
.cont
	lsl.l	#8,d6
	divs.l	d4,d6	;V (от 0 до 256 включительно)

	bmi.s	.dunno	; >=0
	
	cmp.l	#256,d6
	blt.s	.texok
.dunno

	movem.l	d0-d7/a0/a3,(a5)
	add.w	#56,a5
	rts


.texok
	;находимся здесь - луч попадает на стену

	tst.l	a3	;стена ли?

	beq.s	Eng_gotwall	;если попали в стенку

	move.l	a3,a0	;переход на соседний блок

	addq.l	#4,sp
	bra	Eng_trace


Eng_gotwall
	;сделать запись в ClmBuf
	;d0-d3 = Xo/Zo/dX/dZ
	;d4 = PrjConst * Dx - S * dZ
	;d5 = Z
	;d6 = V
	;d7 - txnum
	;
	;a2 - текущая позиция в ClmBuf'e
	;
	;в cl_ уже заполнено: cl_Z, cl_S, cl_tx	

	move.b	d7,cl_tx(a2)
	move.b	d6,cl_V(a2)
	move.w	d5,cl_Z(a2)
	move.w	(a4),cl_S(a2)

	;надо посчитать Thi/Tlo и txstep
	;формулы:
	; T=Y*(PrjConst*dX-S*dZ)/(Zo*dX-Xo*dZ)
	; txstep = $100/(Thi-Tlo)

	move.w	d0,d6
	muls.w	d3,d6	;Xo*dZ
	move.w	d1,d5
	muls.w	d2,d5	;Zo*dX
	sub.l	d6,d5	;d5 = Zo*dX-Xo*dZ

	movem.w	(rd_hiY-rd)(a6),d6-d7	;d6 - hiY, d7 - loY
	muls.l	d4,d6
	muls.l	d4,d7
	divs.l	d5,d6	;d6 - Thi
	divs.l	d5,d7	;d7 - Tlo (неклиппированные)

	movem.w	d6-d7,cl_Thi(a2)

	move.l	d6,d5
	sub.l	d7,d5	;Thi-Tlo - для расчёта txstep

	moveq	#1,d4
	ror.l	#8,d4	;d4=$0100 0000
	divu.l	d5,d4

	move.l	d4,cl_txstep(a2)
Eng_fullqu
	addq.l	#4,sp
	bra	Eng_endtrc








;--------------------------------------------------------------

Eng_Intp:	;interpolate routine

	;interpolates between Y1 & Y2
	;uses formula: Y=At^3+Bt^2+Ct+D, t=0..1
	; A=(-Y0+3*Y1-3*Y2+Y3)/2
	; B=(2*Y0-5*Y1+4*Y2-Y3)/2
	; C=(-Y0+Y2)/2
	; D=Y1

	;needs correct a6 (points to rd)

	clr.l	d7
	movem.w	(rd_MTpos-rd)(a6),d5-d6		;noninterruptable movem
	lsr.l	#8,d6
	move.b	d6,d7
	lea	(rd_viewX-rd)(a6),a2		;store coords

	move.l	([a6,(rd_mvpptr-rd).w]),a0
	lea	(a0,d5.l*8),a0		;current position in Move table


	moveq	#4,d6		;coords loop
.crds
	lea	intp_coeffs(pc),a1	;coeffs
	clr.l	d3		;overall sum (for Y)

	moveq	#4,d4		;A-D calc loop
.abcd
	clr.l	d2		;sum for coeff

	moveq	#(4-1),d5		;Y0-Y3 fetching loop
.fetch
	move.b	(a1)+,d0
	ext.w	d0
	muls.w	(a0,d5.l*8),d0
	add.l	d0,d2

	subq.l	#1,d5
	bpl.s	.fetch

	muls.l	d7,d3	;iterated calculation of given formula:
	lsl.l	#8,d2	;Y=((At+B)t+C)t+D
	asr.l	#8,d3
	add.l	d2,d3

	subq.l	#1,d4
	bne.s	.abcd

	lsl.l	#7,d3
	addq.l	#2,a0
	move.l	d3,(a2)+
	
	subq.l	#1,d6
	bne.s	.crds


	rts



;--------------------------------------------------------------


Eng_mkmove:	;генерит Move table из пакованной программы

	lea	(rd_mvs-rd)(a6),a2
	move.l	a2,(rd_mvpptr-rd)(a6)

	lea	pkmove(pc),a0	;packed movetable
	move.l	(rd_mvtbl-rd)(a6),a1	;куда генерить

	move.w	(a0)+,d0	;fetch num of trajectories
	movem.w	(a0)+,d3-d6	;fetch startposition
.traj
	move.w	(a0)+,d1	;fetch num of points in trajectory
	move.l	a1,(a2)+
	movem.w	d3-d6,(a1)
	addq.l	#8,a1
.loop2
	move.b	(a0)+,d2
	ext.w	d2
	lsl.w	#4,d2
	add.w	-8(a1),d2
	move.w	d2,(a1)+
	subq.w	#1,d1
	bne.s	.loop2

	subq.w	#1,d0
	bne.s	.traj

	rts


;----------------------------------------------------------

Eng_genblk:	;строит лабиринт по битовой программе

;bit program: 01  - turn left & step
;             10  - just step in previous direction
;             11  - turn right & step
;             000 - push position
;             001 - pop position

egb_walltx	equ	0
egb_uptx	equ	1
egb_dntx	equ	2

	clr.l	d7	;bit pointer

	clr.l	d5	;X coord (in blocks, not real coords)
	clr.l	d6	;Z coord

	clr.l	d4	;direction: 0-fw,2-bw,3-lf,1-rt

	move.w	#(egb_dntx*256+((egb_uptx-egb_dntx)&255)),(rd_txdn-rd)(a6)

	move.l	(rd_blkptr-rd)(a6),a0	;куда генерить

	subq.l	#6,sp
	st.b	(sp)	;stopflag: make redundant pop to stop :)

.genloop
	move.l	#(egb_walltx*$01010101),bi_txfw(a0)
	st	bi_dummy(a0)
	move.b	d5,bi_crX(a0)	;blocks -> real coords
	move.b	d6,bi_crZ(a0)
	add.w	#bi_SIZE,a0
.readnext
	bfextu	Blk_Prog(pc){d7:3},d0
	lsr.l	#1,d0
	beq.s	.pushpop

	addq.l	#2,d7

	subq.w	#2,d0
	add.w	d0,d4
	and.w	#$0003,d4

	add.b	egb_steptbl(pc,d4.w*4),d5
	add.b	(egb_steptbl+1)(pc,d4.w*4),d6

	bra.s	.genloop
.pushpop
	bcs.s	.pop

	movem.w	d4-d6,-(sp)
.addq3
	addq.l	#3,d7
	bra.s	.readnext
.pop
	movem.w	(sp)+,d4-d6
	tst.w	d4
	bpl.s	.addq3

	;link blocks

	move.l	(rd_blkptr-rd)(a6),a0
.outer
	move.l	(rd_blkptr-rd)(a6),a1
.inner
	move.b	bi_crX(a0),d0
	sub.b	bi_crX(a1),d0
	lsl.w	#8,d0
	move.b	bi_crZ(a0),d0
	sub.b	bi_crZ(a1),d0

	lea	egb_steptbl(pc),a2
.wherelnk
	move.w	(a2)+,d1
	beq.s	.endwlnk
	move.w	(a2)+,d2
	cmp.w	d0,d1
	bne.s	.wherelnk
	move.l	a1,(a0,d2.w)
.endwlnk
	add.w	#bi_SIZE,a1
	tst.b	bi_dummy(a1)
	bne.s	.inner
	
	add.w	#bi_SIZE,a0
	tst.b	bi_dummy(a0)
	bne.s	.outer

	rts



egb_steptbl	dc.w	$0001,bi_pbw
	dc.w	$0100,bi_plf
	dc.w	$00FF,bi_pfw
	dc.w	$FF00,bi_prt
	dc.w	0



;; muz generator code
	include "!amicron.s"
muza
	incbin	"muza1.bin"		; custom muz module
 
;		Y3 Y2 Y1 Y0
;		 |  |  |  |
intp_coeffs	dc.b	+1,-3,+3,-1	;<-A
	dc.b	-1,+4,-5,+2	;<-B
	dc.b	+0,+1,+0,-1	;<-C
	dc.b	+0,+0,+2,+0	;<-D
			; together

minS_	dc.w	minS	;для movem'ов
maxS_1	dc.w	(maxS+1)	;
minT_	dc.w	minT	;
maxT_1	dc.w	(maxT+1)	; вместе


rd_wallhiY	dc.w	+123	;координаты пола/потолка
rd_wallloY	dc.w	-132	; вместе






;///////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;///////////////////////////////////////////////
;\\\\\\\\\\\\\\\
;--------------------------------------------------------------

scrtags
	dc.l	SA_Width,(maxS-minS+1)
	dc.l	SA_Height,(maxT-minT+1)
	dc.l	SA_Depth,8
	dc.l	SA_Type,CUSTOMSCREEN
	dc.l	SA_Quiet,1
	dc.l	SA_ShowTitle,0
	dc.l	SA_DisplayID,DEFAULT_MONITOR_ID
	dc.l	SA_Exclusive,1

whererect				;
	dc.l	SA_DClip,0		; together
	dc.l	TAG_DONE

rect	dc.w	0,8,maxS-minS,maxT-minT+8


font	dc.l	0
	dc.w	FONTHEIGHT
	dc.b	1,1







	;ДВИЖЕНИЯ КАМЕРЫ
pkmove	
	dc.w	6	;кол-во траекторий
	dc.w	0128,0128,0000,1024	;начальные координаты

	dc.w	4*mv1_len
	           ;XXXX ZZZZ YYYY Angl
	;!!!! все смещения умножаются на 16 !!!!
mv1_beg;		 XXX  ZZZ  YYY  Ang
	dc.b	+000,+000,+000,+000	;!!начальная!позиция!!
	dc.b	-016,+000,+000,+000
	dc.b	-012,-004,+000,+032
	dc.b	-004,-012,+000,+032
	dc.b	+000,-016,+000,+000
	dc.b	-004,-012,+000,-032
	dc.b	-012,-004,+000,-032
	dc.b	-016,+000,+000,+000
	dc.b	-020,+004,+000,+016
	dc.b	+004,-016,+000,+048
	dc.b	-004,-006,+002,+008
	dc.b	0,0,0,0	;конечные координаты
mv1_end
mv1_len	equ	(mv1_end-mv1_beg)/4

	dc.w	4*mv2_len
mv2_beg
	dc.b	0,0,0,0
	dc.b	-016,+000,+000,+000
	dc.b	-016,+000,+000,+000
	dc.b	-012,+004,+000,-032
	dc.b	-004,+012,+000,-032
	dc.b	+000,+016,+000,+000
	dc.b	+004,+020,+000,+016
	dc.b	-020,-004,+000,+048
	dc.b	-016,+000,+000,+000
	dc.b	-020,+004,+000,+016
	dc.b	+004,-016,+000,+048
	dc.b	+002,-006,-005,-008
	dc.b	0,0,0,0
mv2_end
mv2_len	equ	(mv2_end-mv2_beg)/4


	dc.w	4*mv3_len
mv3_beg
	dc.b	0,0,0,0
	dc.b	-016,+000,+000,+000
	dc.b	-012,-004,+000,+032
	dc.b	-004,-012,+000,+032
	dc.b	+004,-012,+000,+032
	dc.b	+012,-004,+000,+032
	dc.b	+016,+000,+000,-016
	dc.b	+012,-004,+000,-032
	dc.b	+000,-012,+000,-016
	dc.b	+009,-017,-002,+8
	dc.b	0,0,0,0

mv3_end
mv3_len	equ	(mv3_end-mv3_beg)/4

	dc.w	4*mv4_len
mv4_beg
	dc.b	0,0,0,0
	dc.b	-016,+000,+000,+000
	dc.b	-016,+000,+000,+000
	dc.b	-012,+004,+000,-032
	dc.b	-004,+012,+000,-032
	dc.b	+000,+016,+000,+000
	dc.b	+000,+016,+000,-032
	dc.b	+000,+016,+000,-032
	dc.b	0,0,0,0
	dc.b	+016,+000,+003,+000
	dc.b	+015,+001,+003,+000
	dc.b	0,0,0,0
	dc.b	0,0,0,0

mv4_end
mv4_len	equ	(mv4_end-mv4_beg)/4


	dc.w	4*mv5_len
mv5_beg
	dc.b	0,0,0,0
	dc.b	+016,+000,+000,+000
	dc.b	+016,+000,+000,+000
	dc.b	+016,+000,+000,+000
	dc.b	-012,+004,+000,-032
	dc.b	-004,+012,+000,-032
	dc.b	+000,+016,+000,+000
	dc.b	+000,+014,-004,+000
	dc.b	+002,+000,-003,+000
	dc.b	0,0,0,0
	dc.b	0,0,0,0

mv5_end
mv5_len	equ	(mv5_end-mv5_beg)/4


	dc.w	4*mv6_len
mv6_beg
	dc.b	0,0,0,0
	dc.b	+016,+000,+000,-064
	dc.b	+016,+000,+000,-064
	dc.b	+016,+000,+000,+000
	dc.b	+016,+000,+000,+000
	dc.b	+000,+000,+000,-064
	dc.b	+000,-004,+000,+000
	dc.b	+000,-008,+000,+000
	dc.b	+000,-012,+000,+000
	dc.b	+000,-016,+000,+000
	dc.b	+000,-020,+000,+000
	dc.b	+000,-024,+000,+000
	dc.b	+000,-024,+000,+000
	dc.b	+000,-024,+000,+000
	dc.b	+000,-024,+000,+000
	dc.b	0,0,0,0

mv6_end
mv6_len	equ	(mv6_end-mv6_beg)/4







mv_nomore
mv_overall	equ	mv_nomore-pkmove




	;ПРОГРАММА СОБЫТИЙ
Proggy:
	;time - in 8/50 secs (every 8th vblank)

	;speed: 1,2,3 - positive, 7,6,5,4 - negative doubled (7<>-2, 6<>-4, etc)


;	COMMAND	time[,operand]

	SPEED	0,2

	SPEED	(mv1_len-2)*32/4,4
	NOISESML	(mv1_len-2)*32/4

	NOISEOFF	(mv1_len-2)*32/4+(mv1_len-2)*32/16
	GAP	(mv1_len-2)*32/4+(mv1_len-2)*32/16
	SPEED	(mv1_len-2)*32/4+(mv1_len-2)*32/16,2

	SPEED	(mv1_len-2)*32/4+(mv1_len-2)*32/16+(mv2_len-2)*32/4,4
	NOISESML	(mv1_len-2)*32/4+(mv1_len-2)*32/16+(mv2_len-2)*32/4

	NOISEOFF	(mv1_len-2)*32/4+(mv1_len-2)*32/16+(mv2_len-2)*32/4+(mv2_len-2)*32/16
	GAP	(mv1_len-2)*32/4+(mv1_len-2)*32/16+(mv2_len-2)*32/4+(mv2_len-2)*32/16
	SPEED	(mv1_len-2)*32/4+(mv1_len-2)*32/16+(mv2_len-2)*32/4+(mv2_len-2)*32/16,2

mv12 equ (mv1_len-2)*32/4+(mv1_len-2)*32/16+(mv2_len-2)*32/4+(mv2_len-2)*32/16

	SPEED	mv12+(mv3_len-2)*32/4,4
	NOISESML	mv12+(mv3_len-2)*32/4

	NOISEOFF	mv12+(mv3_len-2)*32/4+(mv3_len-2)*32/16
	GAP	mv12+(mv3_len-2)*32/4+(mv3_len-2)*32/16
	SPEED	mv12+(mv3_len-2)*32/4+(mv3_len-2)*32/16,2
	
mv123 equ mv12+(mv3_len-2)*32/4+(mv3_len-2)*32/16

	SPEED	mv123+(mv4_len-2)*32/4,4
	NOISESML	mv123+(mv4_len-2)*32/4

	NOISEOFF	mv123+(mv4_len-2)*32/4+(mv4_len-2)*32/16
	GAP	mv123+(mv4_len-2)*32/4+(mv4_len-2)*32/16
	SPEED	mv123+(mv4_len-2)*32/4+(mv4_len-2)*32/16,2

mv1234 equ mv123+(mv4_len-2)*32/4+(mv4_len-2)*32/16

	SPEED	mv1234+(mv5_len-2)*32/4,4
	NOISESML	mv1234+(mv5_len-2)*32/4

	NOISEOFF	mv1234+(mv5_len-2)*32/4+(mv5_len-2)*32/16
	GAP	mv1234+(mv5_len-2)*32/4+(mv5_len-2)*32/16
	SPEED	mv1234+(mv5_len-2)*32/4+(mv5_len-2)*32/16,2

mv12345 equ mv1234+(mv5_len-2)*32/4+(mv5_len-2)*32/16

	NOISEON	mv12345+6*32/4
	FADE	mv12345+7*32/4

	ENDE	mv12345+13*32/4




spak	;СПРАЙТ-ИНФО
	; dX,dZ - умножаются на 32 !!!!!!!!!!!!!!!!!!!!!!!!!
	;            dX   dZ   Y   Type (0-bright,1-solid)

	dc.b	-038,-031,+065,1	;drink
	dc.b	-044,+018,-040,1	;eat
	dc.b	+014,-030,+010,1	;fucк
	dc.b	-001,+037,+115,1	;urinate
	dc.b	+020,+031,-110,1	;defecate

	dc.b	+037,-004,+000,1	;be ape!

	dc.b	+036,-036,+000,0	;kod
	dc.b	+036,-044,+000,0	;mus
	dc.b	+036,-052,+000,0	;mhm

	dc.l	0	;END!



collt	;4 color fields with 64 colors each
;		 begin
;		 |
;		 | end
;		 | |
;	dc.w	$0000,$00FF,$0000,$00FF;<--B
;	dc.w	$FF00,$00FF,$0000,$0000;<--G
;	dc.w	$0000,$00FF,$00FF,$0000;<--R
;		 \__/
;		  |
;		  colorfield (interpolated from begin to end)
;
	dc.b	000,255,255,060,060,000,000,255
	dc.b	000,180,080,197,197,000,000,255
	dc.b	255,050,200,255,255,255,000,255


lengths
	dc.w	sp_SIZE*(NumSpr+1)

	dc.w	bi_SIZE*(NumBlk+1)

	dc.w	$8000+(65536/256)

	dc.w	(8+6)*4*6

	dc.w	ClmBuf_len


	dc.w	$8000+(VideoBuf_len+255)/256


	dc.w	$8000+(VideoBuf_len/2+255)/256

	dc.w	$FFFF
	dc.w	$8000+NumTx*256

	dc.w	8058+$8000

;;	dc.w	mv_overall*3

	dc.w	0









NumBlk	equ	56	;кол-во блоков
Blk_Prog	;bitprogram for generating blocklist

	STARTBIT

	PUSH
	LEFT
	GO
	PUSH
	GO
	RIGHT
	GO	
	GO
	PUSH
	GO
	PUSH
	GO
	LEFT
	POP
	RIGHT
	GO
	POP
	LEFT
	GO
	GO
	LEFT
	POP
	LEFT
	GO
	PUSH
	GO
	PUSH
	GO
	LEFT
	POP
	RIGHT
	GO
	GO
	PUSH
	GO
	RIGHT
	POP
	LEFT
	POP
	LEFT
	GO
	GO
	RIGHT
	GO
	POP
	RIGHT
	GO
	PUSH
	GO
	GO
	PUSH
	LEFT
	RIGHT
	LEFT
	POP
	RIGHT
	GO
	GO
	GO
	GO
	GO
	GO
	GO
	POP
	LEFT
	GO
	GO
	

	POP	;for stopping

	STOPBIT


hordisp	dc.b	64,64,64,64,64,64,64,64,64,64
	dc.b	120,100,0,60,0,75,0,75

printext	dc.b	192+25,'driNk!',0
	dc.b	192+25,' ',0

	dc.b	192+20,'eAt!',0
	dc.b	192+20,' ',0

	dc.b	192+10,'fUCk!',0
	dc.b	192+10,' ',0

	dc.b	192+15,'uRiNaTe!',0
	dc.b	192+15,' ',0

	dc.b	192+10,'deFeCAtE!',0
	dc.b	192+10,' ',0

	dc.b	192+05,'be',0
	dc.b	192+05,'ApE!',0

	dc.b	255,'kod:',0
	dc.b	255,'vader fyrex',0

	dc.b	255,'muz:',0
	dc.b	255,'djinn',0
	
	dc.b	255,'mayhem',0
	dc.b	255,'CAFe02',0

	dc.b	0


fontname	dc.b	"CGTriumvirate.font",0

iname	dc.b	'intuition.library',0
gname	dc.b	'graphics.library',0
dfname	dc.b	'diskfont.library',0

	dc.b	'end!'
	cnop	0,4
DATA:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ^ y
; |     3D-система координат (ось z вдаль)
; |
; |   ^ z
; |  /
; | /
; |/
; *---------> x

;      |
;      | экранная система координат (начало - в центре экрана)
;      |
; -----*-----> s
;      |
;      |
;      | t
;      v




rd	;render data


;////////////
rd_spr	dc.l	0;Sprites	;указатель на таблицу спрайтов

rd_blkptr	dc.l	0;BlInfo	;указатель на blockinf'у

rd_bzt	dc.l	0;BZTab	;указатель на таблицу Z-яркость

rd_dunno	dc.l	0;DunnoBuf

rd_clbuf	dc.l	0;ClmBuf


rd_vbuf	dc.l	0;VideoBuf	;указатель на буфер экрана
			;
			;
rd_hbuf	dc.l	0;HalfBuf	;
			; вместе

rd_tx	dc.l	0;TexBuf	;указатель на текстуры


rd_shtrbuf	dc.l	0;ColGen	;указатель на буфер для генерации палитры

rd_mvtbl	dc.l	0;Move	;pointer to Move table

;;;;;;

rd_viewX	dc.w	0;357	;координаты камеры (должны соответствовать rd_startb)
rd_viewXf	dc.w	0	;дробная часть
			;
rd_viewZ	dc.w	0;128	;
rd_viewZf	dc.w	0	;
			;
rd_viewY	dc.w	0	;
rd_viewYf	dc.w	0	;
			;
rd_viewang	dc.w	0;123	;угол поворота камеры (0..4095) ВЛЕВО (коорд. крутим ВПРАВО)
rd_viewanf	dc.w	0	;дробная его часть
			; together

;;;;;;

rd_rotmx	dc.w	0	;+cos *x-+-> x' (получатся конечные координаты)
	dc.w	0	;+sin *z-/
rd_rotmy	dc.w	0	;-sin *x-\
	dc.w	0	;+cos *z-+-> z'
			; вместе

rd_hiY	dc.w	0	;
rd_loY	dc.w	0	; вместе

rd_txbase	dc.l	0	;опорная точка текстур стен [16.16]


rd_curS	dc.w	0	;текущая координата S

rd_txdn	dc.b	0	;номер нижней текстуры
rd_txupdlt	dc.b	0	;разница номера верхней и нижней
			; вместе

rd_ssrt	dc.l	0	;указатель на первый элемент для сортировки

rd_stxs	dc.l	0	;шаг текстуры
rd_scS	dc.w	0	;координаты центра спрайта
rd_scT	dc.w	0	;
rd_sSstrt	dc.w	0	;координаты и счётчики отрисовки спрайта
rd_sScnt	dc.w	0	;
rd_sTstrt	dc.w	0	;
rd_sTcnt	dc.w	0	; вместе


rd_dbufdsp	dc.w	0	;смещение в битмапе экрана для даблбуфферинга

rd_gtime	dc.w	0	;время в вбланках

rd_MTpos	dc.w	0	;position in Move table (>=0)
rd_MT_t	dc.b	0	;t (0..255) for interpolating
			; together
rd_MT_tstp	dc.l	0	;timestep

rd_MT_fade	dc.b	0	;fading enabled

rd_MT_noise	dc.b	0	;noise enabled
rd_MT_nsml	dc.b	0	; вместе

rd_MTprog	dc.l	0	;указатель на событийную программу

rd_revblank	dc.l	0	;возврат из вбланка


rd_scrbufs			;
rd_scrbuf0	dc.l	0	;
rd_scrbuf1	dc.l	0	; together

rd_mvpptr	dc.l	0
rd_mvs	ds.l	6



rd_aucb	dc.l	0	;chip buffer

rd_auprog	dc.l	0	;points to audioprogram

rd_ptrs	ds.l	18

rd_crport	ds.b	rp_SIZEOF	;rastport for WCP




;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; arrays & gentables
;;;;;;;;;;;;;;; \/\/\/\/\/\/\/\/\/

;;sine	ds.w	4096+1024+2	;sine table up to 5*PI/2
;;rd_free:	;first free mem byte (where to make tables/buffers/etc.)

sine:
rd_free	equ	sine+2*(4096+1024+2)



;Sprites	ds.b	sp_SIZE*(NumSpr+1)	;sp_

;BlInfo	ds.b	bi_SIZE*(NumBlk+1)	;bi_

;BZTab	ds.b	65536	;связь Z-яркость

;DunnoBuf	ds.b	(8+6)*4*6

ClmBuf_len	equ	cl_SIZE*(maxS-minS+1)
;ClmBuf	ds.b	ClmBuf_len

VideoBuf_len equ	2*(maxS-minS+1)*(maxT-minT+1)
;VideoBuf	ds.w	(maxS-minS+1)*(maxT-minT+1)	;буфер экрана - 2 байта на точку
					;
;HalfBuf	ds.b	(maxS-minS+1)*(maxT-minT+1)	;
					; вместе

;TexBuf	ds.b	65536*NumTx	;буфер текстур (256x256)


;ColGen	ds.b	2062776	;для генерации палитры

;Move	ds.b	mv_overall*3	;таблица движения

	even




 IFEQ (cMODE-DEBUG)
	ds.b	fast_mem
end_of_all


	section	datac,bss_c
chipa:
	ds.b	chip_mem
 ENDC


 IFEQ (cMODE-RUN)

	section	fasta,bss
fasta:	
	ds.b	fast_mem
	
	section	chipa,bss_c
chipa:	
	ds.b	chip_mem
 ENDC

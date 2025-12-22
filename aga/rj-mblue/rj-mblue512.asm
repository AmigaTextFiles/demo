
Code_Start:

Init:	

*First of all let me say that this code is very slow,
*and so you have to see it on fast machine (ie. 040/060)
*There is another problem related to cpu speed,
*in fact i change camera parameters on vertical blank
*this mean that if you haven't a fast machine you'll see tunnel
*deform along frame calculation (from top to bottom of the screen)
*So, slower machine equal to worse screen results.
*Btw, on my a4000 (040/25) the 'trick' is almost non-noticeble.

*Coded by nAo/rAMjAM in August 1998
	
	Lea	Base,a0

*here lies a dumb palette generator :D

	move.l	a0,a1
	moveq	#-1,d7			;just 256 color :-)
	moveq	#0,d0
.pal	move.l	d0,(a1)+
	add.l	#$00010102,d0		;spread black to blue 
	subq.b	#1,d7
	bcc.s	.pal
	bsr.w	SetPalette		;loads palette


steps	equ	2048			;sin/cos table steps
factor	equ	steps*10000/2/31415	;fixed point factor

	move.l	a1,a2			;saves sin table pointer
	move.l	#factor,d5		;this piece of code
	move.w	#steps,d0		;generates a sin/cos table
	lsr.w	#3,d7			;using an infinitesimal
	mulu.w	d5,d0			;rotation matrix 
	moveq	#0,d2			;u can find all the math stuff..
					;on http://come.to/amiga
.scloop	move.l	d2,d3			;look at azure's doc with my final
	divs.l	d5,d3			;error correction chapter
	move.w	d3,(a1)+		;btw, this isn't the shortest
	sub.l	d3,d0			;way i know to generate a sin table
	move.l	d0,d1			;but afaik probably 
	divs.l	d5,d1			;it's the shortest way
	move.w	d1,(a1)+		;to make a sin/cos table
	add.l	d1,d2
	dbra	d7,.scloop



* This is V.R.T.G ************************************
* Very Random Textures Generator :-D *****************

	
	move.l	a1,a0			;saves pointer
	moveq	#4,d0
.random	ror.l	d0,d0			;tanx to Azure for this..
	addq.l	#7,d0			;smart (and chip) rnd generator
	move.b	d0,(a0)+
*	clr.b	(a0)+	
	dbra	d7,.random

	moveq	#6-1,d4			;filter passes
	
.start	moveq	#6-1,d6			;blur passes
	move.l	a1,a0
.loopf	move.b	(a0),d0
	lsl.b	#2,d0
	bge.s	.ok
	not.b	d0
.ok	move.b	d0,(a0)+		;this routine
	dbra	d7,.loopf		;perform a texture
.loopbb	move.l	a1,a0			;generator
	move.l	a1,a5			;using some rnd value
	move.l	#256,d0			;and some blur
	move.l	d0,d1			;and non-linear filters
	neg.w	d1			
.loopb	moveq	#0,d2			;final resuslt it's
	move.b	-1(a0),d2		;completely emphyric
	add.b	(a5,d0.l),d2		;just work on
	moveq	#0,d3			;non-linear filter
	move.b	1(a0),d3		;and blur/filter passes to achieve
	add.b	(a5,d1.l),d3		;better results.
	add.w	d2,d3
	lsr.w	#2,d3			;pay attention 
	move.b	d3,(a0)+		;to work on effective
	addq.w	#1,d0			;256x256 closed texture space
	addq.w	#1,d1			;to eliminate
	dbra	d7,.loopb		;tiling problems
	dbra	d6,.loopbb
	dbra	d4,.start

	move.l	a1,a5			*saves texture pointer
	move.l	a0,a1			*saves grid pointer
	lea	(33*33*8)(a1),a4	*saves temp pointer
	move.l	a4,a0		
	lea	(32*4)(a0),a0		*chunky pointer
	rts				;this rts can removed
					;but who care? :)

VBlank:	; Called every vblank after Init has finished.

	addq.w	#1,param4(a4)		;here..
	move.w	param4(a4),d0		;just...
	movem.w	(a2,d0.w*4),d0/d1	;some...
	asr.w	#1,d0			;lissajeous..
	asr.w	#2,d1			;trick..
	move.w	d0,param1(a4)		;to move..
	move.w	d1,param2(a4)		;and rotate camera
	move.w	(a2,d1.w*4,2048*2*4+384),d0
	lsl.w	#3,d0
	move.w	d0,param3(a4)
	rts


Main:	; Called once when Init has finished.
	; Registers are as left by Init.
	; If it terminates, the demo will exit.


* A5 --> Texture Pointer
* A4 --> TempData Pointer
* A2 --> Sin/Cos Pointer
* A1 --> Grid Pointer
* A0 --> Chunky Pointer


param1		equ	0
param2		equ	2
param3		equ	4
param4		equ	6	



Main2	bsr.b	Tracer			;call ray tracer
	bsr.w	Lattice			;call lattice expander
	bsr.w	Update256x256		
	bra.b	Main2		

	rts

*very simple ray tracer

Tracer	movem.l	d0-a6,-(sp)
	moveq	#32/2,d7
	moveq	#-32/2,d1
.y	moveq	#-32/2,d0
.x	moveq	#26,d2		;focal lenght

	move.w	param1(a4),d3	;rotates ray on X axis
	and.w	#$7ff,d3
	movem.w	(a2,d3.w*4),d3/d4
	move.l	d3,d5
	move.l	d4,d6
	muls.w	d2,d3		;z*sin
	muls.w	d1,d4		;y*cos
	muls.w	d1,d5		;y*sin
	muls.w	d2,d6		;z*cos
	add.l	d5,d6		;Z
	sub.l	d3,d4		;Y

	move.l	d4,-(sp)

	move.w	param2(a4),d3	;rotate ray on Y axis
	and.w	#$7ff,d3
	movem.w	(a2,d3.w*4),d3/d5
	move.l	d3,d4
	move.l	d5,d2
	muls.w	d0,d3		;x*sin
	muls.l	d6,d4		;z*sin
	muls.w	d0,d2		;x*cos
	muls.l	d6,d5		;z*cos
	moveq	#11,d6
	asr.l	d6,d4
	asr.l	d6,d5
	add.l	d2,d4		;X
	sub.l	d3,d5		;Z
	move.l	(sp)+,d6
	move.l	d5,-(sp)

	move.l	d6,d5
	move.l	d4,d6
	asr.l	#6,d5
	asr.l	#6,d4
	muls.w	d5,d5
	muls.w	d4,d4
	add.l	d4,d5
	addq.l	#1,d5

	moveq	#1,d3		;thank goes to 
	ror.l	#2,d3		;Graham for this
        moveq   #32,d2		;fast and short sqrter
.l2n
        move.l  d3,d4
        rol.l   d2,d4
        add.w   d3,d3
        cmp.l   d4,d5
        bcs.b   .no
        addq.w  #1,d3
        sub.l   d4,d5
.no
        subq.w  #2,d2
        bgt.b   .l2n
 
.ok	move.l	(sp)+,d4	;i know that this isn't the academic
	asl.l	#5,d4		;way to make tunnels, but that's the
	asl.l	#5,d6		;only way i found that eliminates
	divs.w	d3,d6		;arctan calculation and short both
	divs.w	d3,d4		;(my atan routine is 100 bytes long....)
	add.w	param3(a4),d4	;Z axis camera traslation
	move.w	d4,(a1)+	;just write (u,v)
	move.w	d6,(a1)+

	addq.l	#1,d0		;next column
	cmp.w	d7,d0
	ble.w	.x
	addq.l	#1,d1		;next row
	cmp.w	d7,d1
	ble.w	.y
	movem.l	(sp)+,d0-a6
	rts



*A5-> texture pointer*
*A1-> 33x33 (u,v) grid pointer*
*A0-> chunky buffer*

;I know that actually this routine it's slow
;but this is a short code compo, that isn't? :)

Lattice	movem.l	d0-a6,-(sp)
	moveq	#32-1,d7		;y loop counter
	moveq	#10,d5
	moveq	#0,d0
.scanli	swap	d7
	move.w	#32-1,d7		;x loop counter
	
.square	move.l	a0,a6
	move.l	(33*4)(a1),a4		;(u4,v4)
	move.l	(a1)+,d1		;(u1,v1)
	move.l	(33*4)(a1),a3		;(u3,v3)
	move.l	(a1),d2			;(u2,v2)
	sub.l	d1,a4			;(u4-u1,v4-v1)
	sub.l	d2,a3			;(u3-u2,v3-v2)
	lsl.l	#3,d1
	lsl.l	#3,d2
	moveq	#8-1,d6

.Yspan	move.l	d1,d3			;(uL,vL)
	move.l	d2,d4			;(uR,vR)
	swap	d6
	sub.l	d3,d4			;(uR-uL,vR-vL)
	addq.w	#8,d6
	asr.l	#3,d4
	lsl.w	#3,d4
	asr.w	#3,d4

.Xspan	move.w	d3,d0			;need explanations
	rol.l	#8,d3			;this loop? :)
	move.b	d3,d0			
	ror.l	#8,d3
	move.b	(a5,d0.l),(a6)+		;just do it :-)
	add.l	d4,d3			;(u+du,v+dv)
	subq.w	#1,d6
	bne.s	.Xspan

	lea	256-8(a6),a6		;next span
	add.l	a4,d1			;(uL+duL,vL+dvL)
	add.l	a3,d2			;(ur+duR,vR+dvR)
	swap	d6			
	dbra	d6,.Yspan

	addq.l	#8,a0			;next nice little square
	dbra	d7,.square
	addq.l	#4,a1
	lea	(256*7)(a0),a0
	swap	d7
	dbra	d7,.scanli
	movem.l	(sp)+,d0-a6
	rts
	
	

		printt	"Length of your code"
Code_End:	printv	Code_End-Code_Start

;; ******************** BSS area ********************

	section	BSS_Area,bss

; declare BSS vars here. and only here


Base		
Palette		ds.l	256
Sin		ds.l	2048*4
Texture		ds.b	256*256
Grid		ds.l	33*33*2
TempData	ds.l	32
Chunky		ds.b	256*256
safe		ds.b	256*256
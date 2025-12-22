; Startup for the #amycoders 384 bytes demo compo by Blueberry/Efreet.

; QuickFixed by Harry "Piru" Sintonen 15th July 1998:
;
;  1) Didn't require KS V39 -> Crash on pre-V39 (at least pre-V37).
;  2) Didn't restore original task priority.
;  3) TAG_END was missing from ProcessParams taglist.
;  4) Improved interleaved test a bit.
;  5) It wasn't possible to compile intro with Devpac because use
;     of basereg and global\.local references.
;  6) Fixed loads of "Warning: trailing comma at end of DC directive"
;

	incdir	code:compos/512BytesCompo/
	include	systemdefs.i
	

call	macro
	jsr	_LVO\1(a6)
	endm
	
	section	code,code

Startup:
	move.l	$4.w,a6
	lea.l	IntName(pc),a1
	moveq.l	#39,d0
	call	OpenLibrary
	move.l	d0,IntBase
	beq.w	.noint
	lea.l	GfxName(pc),a1
	moveq.l	#39,d0
	call	OpenLibrary
	move.l	d0,GfxBase
	beq.w	.nogfx
	lea.l	DosName(pc),a1
	moveq.l	#39,d0
	call	OpenLibrary
	move.l	d0,DosBase
	beq.w	.nodos

	; Open screen.
	move.l	IntBase(pc),a6
	suba.l	a0,a0
	lea.l	ScreenParams(pc),a1
	call	OpenScreenTagList
	move.l	d0,_Screen
	beq.b	.noscr
	; Ensure that the screen is interleaved.
	move.l	d0,a0
	move.l	sc_RastPort+rp_BitMap(a0),a1
	move.l	bm_Planes+4(a1),d1
	sub.l	bm_Planes(a1),d1
	lsl.l	#3,d1			; HS: *DEPTH
	cmp.w	bm_BytesPerRow(a1),d1
	bne.b	.notil			; HS: fix
	; Put BitMap1 into _Screen->ViewPort.RasInfo
	move.l	sc_ViewPort+vp_RasInfo(a0),a1
	move.l	#BitMap1,ri_BitMap(a1)

	; Set own priority to 0.
	move.l	$4.w,a6
	suba.l	a1,a1
	call	FindTask
	move.l	d0,a1
	moveq.l	#0,d0
	move.l	a1,-(sp)		; HS: store thistask
	call	SetTaskPri
	move.l	d0,-(sp)		; HS: store old pri!

	; Create VBlank process.
	move.l	DosBase(pc),a6
	move.l	#ProcessParams,d1
	call	CreateNewProc
	move.l	d0,Process
	beq.b	.nopro

	bsr.w	DoTheJob

.nopro:
	move.l	$4.w,a6			; HS: restore pri
	move.l	(sp)+,d0
	move.l	(sp)+,a1
	call	SetTaskPri

.notil:	move.l	IntBase(pc),a6
	move.l	_Screen(pc),a0
	call	CloseScreen
.noscr:	move.l	$4.w,a6
	move.l	DosBase(pc),a1
	call	CloseLibrary
.nodos:	move.l	GfxBase(pc),a1
	call	CloseLibrary
.nogfx:	move.l	IntBase(pc),a1
	call	CloseLibrary
.noint:	moveq.l	#0,d0
	rts

ScreenParams:
	dc.l	SA_Left,0		; HS: not really needed.
	dc.l	SA_Top,0		; HS: not really needed.
	dc.l	SA_Width,320
	dc.l	SA_Height,256
	dc.l	SA_Depth,8
	dc.l	SA_ShowTitle,0
	dc.l	SA_BitMap,BitMap1
	dc.l	SA_Quiet,1
	dc.l	SA_Type,CUSTOMSCREEN
	dc.l	SA_DisplayID,PAL_MONITOR_ID
	dc.l	SA_Interleaved,1	; HS: not really needed.
	dc.l	TAG_END

ProcessParams:
	dc.l	NP_Entry,VBlankProcess
	dc.l	NP_Name,ProcessName
	dc.l	NP_Priority,1
	dc.l	TAG_END			; HS: WAS MISSING!

BitMap1:
	dc.w	8*40,256,8,0
	dc.l	Planes1+0*40,Planes1+1*40,Planes1+2*40,Planes1+3*40
	dc.l	Planes1+4*40,Planes1+5*40,Planes1+6*40,Planes1+7*40

BitMap2:
	dc.w	8*40,256,8,0
	dc.l	Planes2+0*40,Planes2+1*40,Planes2+2*40,Planes2+3*40
	dc.l	Planes2+4*40,Planes2+5*40,Planes2+6*40,Planes2+7*40

IntBase:	dc.l	0
GfxBase:	dc.l	0
DosBase:	dc.l	0
_Screen:	dc.l	0
OldBitMap:	dc.l	0
Process:	dc.l	0
OldStack:	dc.l	0
ProcessState:	dc.w	0
C2P1x1State:	dc.w	0
C2P2x1State:	dc.w	0
C2PEdgeState:	dc.w	0

IntName:	dc.b	'intuition.library',0
GfxName:	dc.b	'graphics.library',0
DosName:	dc.b	'dos.library',0
ProcessName:	dc.b	'VBlank process',0
		even

;; ******************** Calling shell ********************

DoTheJob:
	move.l	a7,OldStack
	move.w	#$000f,$dff096
	bsr.w	Init
	movem.l	d0-a6,Registers
	move.w	#1,ProcessState
.wait1:	cmp.w	#2,ProcessState	; Wait for VBlank process to begin.
	bne.b	.wait1
	bsr.w	Main

Exit:
	move.w	#$000f,$dff096
	move.l	OldStack(pc),a7
	move.w	#3,ProcessState
.wait2:	cmp.w	#4,ProcessState	; Wait for VBlank process to end.
	bne.b	.wait2
	rts

VBlankProcess:
.loop1:	move.l	GfxBase(pc),a6
	call	WaitTOF
	tst.w	ProcessState(pc)
	beq.b	.loop1
	move.w	#2,ProcessState
	movem.l	Registers,d0-a6
.loop2:	bsr.w	VBlank
	movem.l	d0-d1/a0-a1/a6,-(a7)
	move.l	GfxBase(pc),a6
	call	WaitTOF
	movem.l	(a7)+,d0-d1/a0-a1/a6
	cmp.w	#3,ProcessState
	bne.b	.loop2
	move.w	#4,ProcessState
	rts

;; ******************** Internal routines ********************

TestMouse:
	; Exit if LMB pressed.
	btst.b	#6,$bfe001
	beq.b	Exit
	rts

GetScreen:
	move.l	_Screen(pc),a3
	move.l	sc_ViewPort+vp_RasInfo(a3),a3
	move.l	#BitMap1,a2
	add.l	#BitMap2,a2
	sub.l	ri_BitMap(a3),a2	; Other BitMap.
	move.l	bm_Planes(a2),a1
	; A1 = PlanePtr of Undisplayed BitMap
	; A2 = Undisplayed BitMap
	; A3 = _Screen->Viewport.RasInfo
	rts

DoubleBuffer:
	bsr.w	GetScreen
	move.l	a2,ri_BitMap(a3)	; Do the switch.
	move.l	GfxBase(pc),a6
	move.l	_Screen(pc),a0
	lea.l	sc_ViewPort(a0),a0
	jmp	(_LVOScrollVPort,a6)	; And display it.

ClearEdges:
	tst.w	C2PEdgeState
	beq.b	.ok
	bsr.w	GetScreen
	move.w	#256*8-1,d7
.loop:	clr.l	(a1)+
	lea.l	40-8(a1),a1
	clr.l	(a1)+
	dbf	d7,.loop
	clr.w	C2PEdgeState
.ok:	rts

	; *** Adjust this include path! ***
	include	C2P1x1x8.S
	include	C2P2x1x8.S

;; ******************** Callable routines ********************

Update128x128:
	; Update the screen in 2x2 resolution
	; using the supplied 128x128 linear chunky buffer.
	; The sides will get color 0.
	; Callable from Init and Main.
	; Input: A0 = Chunky buffer
	bsr.w	TestMouse
	movem.l	d0-a6,-(a7)
	bsr.w	ClearEdges
	tst.w	C2P2x1State(pc)
	blt.b	.ok
	move.w	#128,d0
	move.w	#128,d1
	moveq.l	#40,d2
	move.w	#8+15*40,d3
	bsr.w	C2P2x1x8_SetSizes
	move.w	#-1,C2P2x1State
	move.l	8*4(a7),a0
.ok:	bsr.w	GetScreen
	addq.l	#4,a1
	bsr.w	C2P2x1x8
	move.l	8*4(a7),a0
	bsr.w	GetScreen
	lea.l	8*40+4(a1),a1
	bsr.w	C2P2x1x8
	bsr.w	DoubleBuffer
	movem.l	(a7)+,d0-a6
	rts

Update160x128:
	; Update the screen in 2x2 resolution
	; using the supplied 160x128 linear chunky buffer.
	; Callable from Init and Main.
	; Input: A0 = Chunky buffer
	bsr.w	TestMouse
	movem.l	d0-a6,-(a7)
	move.w	#-1,C2PEdgeState
	tst.w	C2P2x1State(pc)
	bgt.b	.ok
	move.w	#160,d0
	move.w	#128,d1
	moveq.l	#40,d2
	move.w	#15*40,d3
	bsr.w	C2P2x1x8_SetSizes
	move.w	#1,C2P2x1State
	move.l	8*4(a7),a0
.ok:	bsr.w	GetScreen
	bsr.w	C2P2x1x8
	move.l	8*4(a7),a0
	bsr.w	GetScreen
	lea.l	8*40(a1),a1
	bsr.w	C2P2x1x8
	bsr.w	DoubleBuffer
	movem.l	(a7)+,d0-a6
	rts

Update256x256:
	; Update the screen in 1x1 resolution
	; using the supplied 256x256 linear chunky buffer.
	; The sides will get color 0.
	; Callable from Init and Main.
	; Input: A0 = Chunky buffer
	bsr.w	TestMouse
	movem.l	d0-a6,-(a7)
	bsr.w	ClearEdges
	tst.w	C2P1x1State(pc)
	blt.b	.ok
	move.w	#256,d0
	move.w	#256,d1
	moveq.l	#40,d2
	move.w	#8+7*40,d3
	bsr.w	C2P1x1x8_SetSizes
	move.w	#-1,C2P1x1State
	move.l	8*4(a7),a0
.ok:	bsr.w	GetScreen
	addq.l	#4,a1
	lea.l	TempBuffer,a2
	bsr.w	C2P1x1x8
	bsr.w	DoubleBuffer
	movem.l	(a7)+,d0-a6
	rts

Update320x256:
	; Update the screen in 1x1 resolution
	; using the supplied 320x256 linear chunky buffer.
	; Callable from Init and Main.
	; Input: A0 = Chunky buffer
	bsr.w	TestMouse
	movem.l	d0-a6,-(a7)
	move.w	#-1,C2PEdgeState
	tst.w	C2P1x1State(pc)
	bgt.b	.ok
	move.w	#320,d0
	move.w	#256,d1
	moveq.l	#40,d2
	move.w	#7*40,d3
	bsr.w	C2P1x1x8_SetSizes
	move.w	#1,C2P1x1State
	move.l	8*4(a7),a0
.ok:	bsr.w	GetScreen
	lea.l	TempBuffer,a2
	bsr.w	C2P1x1x8
	bsr.w	DoubleBuffer
	movem.l	(a7)+,d0-a6
	rts

CacheClear:
	; Clear caches so written SMC will be valid.
	; Callable from Init, VBlank and Main.
	movem.l	d0-d1/a0-a1/a6,-(a7)
	move.l	$4.w,a6
	call	CacheClearU
	movem.l	(a7)+,d0-d1/a0-a1/a6
	rts

SetPalette:
	; Set the screen palette to the one supplied.
	; Format is 256 longwords in $xxrrggbb.
	; The upper byte of each longword is ignored.
	; Callable from Init, VBlank and Main.
	; Input: A0 = Palette
	movem.l	d0-d2/a0-a2/a6,-(a7)
	lea.l	.data(pc),a1
	lea.l	4(a1),a2
	;move.w	#256-1,d2
	move.w	#256,d2			; little bug
.loop:	move.w	(a0)+,d0
	move.b	d0,(a2)
	addq.l	#4,a2
	move.b	(a0)+,d0
	move.b	d0,(a2)
	addq.l	#4,a2
	move.b	(a0)+,d0
	move.b	d0,(a2)
	addq.l	#4,a2
	subq.b	#1,d2		
	bne.b	.loop		

	move.l	GfxBase(pc),a6
	move.l	_Screen(pc),a0
	lea.l	sc_ViewPort(a0),a0
	call	LoadRGB32
	movem.l	(a7)+,d0-d2/a0-a2/a6
	rts
.data:
	dc.w	256,0
	dcb.l	256*3
	dc.w	0
	
;; ********************************************************
;; ******************** Your code here ********************
;; ********************************************************




*************************************************
* "Jump around" 512b Intro by SNIPER 02.09.1998 *
* That's my contibutition to the IRC 512b compo *
*   It's not really optimized,but it works ;)   *	
*             Hope you like it.                 *
*                                               *
* Greetings to:                                 *
*            LIGHTSTORM INC.,NUANCE,LIGHTFORCE  *
*            MATRIX,ETHIC,SECTOR7,DARKSIDE      *
*            #AMYCODERS          		*                                 
*                                               *
* Contact me at: ehrich@fh-brandenburg.de       *
*************************************************

Code_Start:

dmacon      	equ   $096
aud0        	equ   $0A0
aud1        	equ   $0B0
aud2        	equ   $0C0
aud3        	equ   $0D0

* AudChannel
ac_ptr     	equ   $00   ; ptr to start of waveform data
ac_len      	equ   $04   ; length of waveform in words
ac_per      	equ   $06   ; sample period
ac_vol      	equ   $08   ; volume
ac_dat      	equ   $0A   ; sample pair
ac_SIZEOF   	equ   $10

chunkyx		equ	160
chunkyy		equ	128
chunkysize	equ	chunkyx*chunkyy
sinsize		equ	1024		
amplitude	equ	255

		
; maincode here
Main:	

	lea	buf,a6			; bss base register

	; set palette two ranges 128 colors
	move.l	a6,a0
	move.l	a0,a1
	lea	(128*4,a1),a2
	moveq	#127,d7
	moveq	#0,d0
.plp	move.l	d0,(a1)+		; range 1	
	move.l	d0,d1
	lsr.b	#1,d1
	move.l	d1,(a2)+		; range 2
	add	#$102,d0
	subq.l	#1,d7
	bpl.s	.plp
	move.l	d7,-(a2)		; color 255 = white
	bsr.w	SetPalette		; setting palette
					; palettebuffer will be overwritten later
	; precalc sintab .. 
	; base code from another coder (i've forgotten his name)
	lea	(sintab-buf,a6),a0
	move.l	a0,a1
	moveq	#0,d0				
	move.l	#($06487E*amplitude)/sinsize,d1	
	move.l	#(($277A78/sinsize)<<16)/sinsize,d2
	lsr	#5,d7
.sinlp	move.l	d0,(a0)
	addq	#2,a0
	move.l	d2,d3
	muls.l	d0,d4:d3
	sub.l	d4,d1
	add.l	d1,d0
	dbra	d7,.sinlp

	; a1 = sintab
	; precalc a simple sin/cos phongmap
	;lea	(tex1-buf,a6),a0	; texture1
        move.l	a6,a0
	lsr    	#8,d7
.ylp    move    #255,d6
.xlp    move  	(a1,d6.w*4),d0
        add   	(a1,d7.w*4),d0
        lsr	#2,d0
	subq	#1,d0			; set colorange 0...126
	bpl.s	.ok			; because 127/255 is the ball color
	clr	d0	
.ok	move.b  d0,(a0)+
        dbra    d6,.xlp
        dbra    d7,.ylp

	; a1 = sintab
	; precalc and play music
        lea     drum,a0			; precalc a nice drum	
        move.l	a0,a2
        ;move    #1024*2-1,d7		; sample len
	lsr	#5,d7
	lea	(a0,d7.w),a3		; sample2
        moveq   #0,d1			; sine start
        move    #16<<8,d2		; sine adder FK
        move    d2,d3			; down				
.dlp    and     #1023,d1		; sine mask
        move    (a1,d1.w*2),d0		; get sine
	swap	d0
        divs    d3,d0			; get down
	moveq	#127,d6			; cut if over byte size			
	cmp     d6,d0
	blt.s   .low
        move    d6,d0
.low  	neg	d6
	cmp     d6,d0
	bgt.s   .grtr
	move    d6,d0
.grtr   move.b  d0,(a0)+		; save it
	asr	#2,d0
	move.b	d0,(a3)+
        move    d2,d4			
        lsr     #8,d4           
        add     d4,d1
        subq    #2,d2			; freq delta		
        addq    #1,d3			; down delta
        dbra    d7,.dlp			

	lea	$dff000+aud0,a5		; get custombase + audio0
	moveq	#2-1,d7			; channels
.audlp	move.l  a2,(a5)+		; ac_ptr
        move    #1024*3,(a5)+		; ac_len
        move    #400,(a5)+		; ac_per	
	st	(a5)+			; ac_vol : i hope it works on every machine
	addq	#ac_SIZEOF-9,a5		; to next aud
	dbra	d7,.audlp		; next audio channel
	
	move	#$8203,(dmacon-aud2,a5) ; audio dma on




	; mainloop starts here
mainloop

	; rotation zoomer
	; a6 = texture	
        lea     (sintab-buf,a6),a2
        move  	rot(pc),d0
        and     #$7fe,d0
        move	(a2,d0.w),d0
        lsl	#2,d0
        and     #$7fe,d0
        add	d0,a2	
        move    (a2),d5
        move    (256*2,a2),d4
        move    d5,d1
	lsl	#2,d1
	moveq  	#-256/2,d2
	sub	d2,d1
	sub	d2,d1
        muls    d1,d4
        muls    d1,d5
        asr.l   #8,d4
        asr.l   #8,d5

        lea  	(chunky-buf,a6),a1
        move.l	a1,a0

	move    d2,d0
	muls    d5,d0

	move    d2,d6
        muls    d4,d6
        add     d0,d6
        move    d6,a3

	move    d2,d6
        muls    d5,d6

	move    d2,d0
        muls    d4,d0
        add     d0,d6
        move    d6,a4

        add   	#(128*256)+128,a3
        add   	#(128*256)+128,a4

        moveq   #0,d2               
        move	#chunkyy-chunkyy/4,d7

.ylp	move	a3,d6
	move	a4,d0
	add	d5,a3
	sub	d4,a4

	; sorry for the lame innerloop ,but it's the shortest way ;(
        move	#chunkyx-1,d1    
.xlp	move    d6,d2
        ror     #8,d0
        move.b  d0,d2
        rol     #8,d0
        move.b  (a6,d2.l),(a1)+
        add     d5,d0
        add     d4,d6
        dbra    d1,.xlp
        dbra    d7,.ylp




	; jumping ball
	lea	(chunkyx*36+chunkyx/2,a0),a1	; signed chunky position
	lea	(sintab-buf,a6),a2
	lea	(256*2,a2),a3

	move	rot(pc),d5
	and	#1023,d5
	move	(a2,d5.w*2),d5
	asr	#3,d5
	add	d5,a1

	move	scal(pc),d5
	asr	#8,d5
	and	#511,d5
	move	(a2,d5.w*2),d5
	move	d5,d0
	asr	#2,d0
	muls	#chunkyx,d0
	add.l	d0,a1
	add	#256+96,d5
	bne.s	.sok1
	move	#96,d5
.sok1	
	lsr	#6,d7
.cilp	move	(a2,d7.w*2),d0
	ext.l	d0
	lsl.l	#5,d0
	divs	d5,d0
	muls	#chunkyx,d0
	move	(a3,d7.w*2),d1
	asr	#4,d1
	add	d1,d0
	st	(a1,d0.w)
	dbra	d7,.cilp



	; just a little mirror (shit, it's forbidden to use the copper ;) )
	; a0 = chunky
	lea	(chunkysize-(chunkyx*(chunkyy/4)),a0),a1
	move.l	a1,a2
	move	#chunkyy/4-1,d7
.mylp	move	#chunkyx-1,d6
.mxlp	move.b	(a2)+,(a1)
	add.b	#128,(a1)+
	dbra	d6,.mxlp
	sub	#chunkyx*3,a2
	dbra	d7,.mylp



	; chunkytoplanar & displaybitmap
	; a0 = chunky

	ifeq	chunkyx-320
	bsr.w	Update320x256		
	else
	ifeq	chunkyx-256
	bsr.w	Update256x256		
	else
	ifeq	chunkyx-160
	bsr.w	Update160x128		
	else
	ifeq	chunkyx-128
	bsr.w	Update128x128		
	endc
	endc
	endc

	bra.w	mainloop		




; init some .. or nothing :)
Init:	

; vertical blank interrupt	
VBlank:	
	lea	rot(pc),a0
	add	#2,(a0)+
	add	#1895,(a0)+
	rts

; variables

rot	dc.w	256
scal	dc.w	128<<8
	
;	uncomment this when you are using ASM-One

		printt	"Length of your code"
Code_End:	printv	Code_End-Code_Start

;; ******************** BSS area ********************

	section Samples,bss_c

drum	ds.w	1024*4

	section	BSS_Area,bss

chunky	ds.b	chunkysize	
sintab	ds.l	sinsize
buf:	; base ptr
tex1	ds.b	256*256




;; ******************** Internal BSS area ********************

	section	TempBuffer,bss

TempBuffer:	ds.b	320*256/2
Registers:	ds.l	15

	section	Planes,bss_c

Planes1:	ds.l	320*256/32*8
Planes2:	ds.l	320*256/32*8

;; ******************** Screen setup ********************

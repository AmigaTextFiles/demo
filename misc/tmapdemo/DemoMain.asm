; $$TABS=8
;
; GameDemo - texture mapping and Gouraud shading Demo by Chris Green
;
; This code is both AA specific and (in some parts) V39 specific.
;
; NOTE: This code is in no way optimized. I only spent about 1 week on
; it total.
;

	include	'exec/types.i'			; get structure definition macros, etc.
	include	'exec/memory.i'			; get memory type flags
	include	'exec/interrupts.i'		; get interrupt structure

 	include	'intuition/intuition.i'		; get window defs' etc.
	include	'intuition/screens.i'		; get screen attributes, etc.
	include	'graphics/displayinfo.i'	; get display-id definitions
	include	'graphics/view.i'		; display modes
	include	'hardware/custom.i'		; get register offsets
	include	'devices/timer.i'		; get timer.device stuff

	include	'demo.i'			; master include file for this program.

	xref	_LVOOpenLibrary,_LVOCloseLibrary,_LVOOpenDevice,_LVOCloseDevice
	xref	_LVOOpenScreenTagList,_LVOCloseScreen,_LVODelay
	xref	_LVOAllocMem,_LVOUCopperListInit,_LVORemakeDisplay,_LVOFreeMem
	xref	_LVOScreenToFront,_LVOAddIntServer,_LVORemIntServer
	xref	_LVOSignal,_LVOAllocSignal,_LVOWait,_LVORemTask
	xref	_LVOObtainSemaphore,_LVOReleaseSemaphore
	xref	_LVOScrollVPort,_LVOForbid,_LVOPermit,_LVOLoadRGB32
	xref	_LVOSetSignal,_LVOAllocBitMap,_LVOFreeBitMap
	xref	_LVOSetAPen,_LVOMove,_LVODraw,_LVOInitRastPort,_LVOSetRast
	xref	_LVOReadEClock,_LVOGetBitMapAttr

	xref	_AbsExecBase			; it's 4, but let's use the symbol anyway.
	xref	_custom
	xref	_CreateTask
	xref	ReadRaw
	xref	init_fakefb,fill_fakefb,fakefb_to_screen,fill_fakefb_gradient
	xref	YLRFill,UnClippedPolygon,vertex,current_color
	xref	DoMovement,PlayerHeading,PlayerX,PlayerY,PlayerZ,PlayerSpeed
	xref	stick_click
	xref	render_3d

main::
	ONTIMER	0
	geta6				; in this program, a6 is used for most variable references,
					; to save space and speed.

	move.l	a7,InitialSP(a6)
	move.l	_AbsExecBase,_SysBase(a6)	; let's use a local copy so that it might be in fast ram

	openlib	intuiname(pc),_IntuitionBase
	openlib	gfxname(pc),_GfxBase
	openlib	dosname(pc),_DosBase

; now, we must allocate a bitmap for the main scrolling area.
	move.l	_GfxBase(a6),a6
	move.l	#CANVAS_WIDTH,d0
	move.l	#CANVAS_HEIGHT,d1
	move.l	#SCREEN_DEPTH,d2
	move.l	#BMF_DISPLAYABLE|BMF_CLEAR|BMF_INTERLEAVED,d3
	sub.l	a0,a0
	jsr	_LVOAllocBitMap(a6)
	geta6
	move.l	d0,bm_tag+4
	move.l	d0,canvas_bitmap(a6)
	beq	quiet_error
; now, initialize a rastport for drawing into the canvas bitmap
	move.l	a6,a5				; keep varbase temporarily in a5
	move.l	_GfxBase(a6),a6
	move.l	d0,a0		; a0=bitmap
	move.l	#BMA_FLAGS,d1	; get bitmap flags
	jsr	_LVOGetBitMapAttr(a6)	; test interleaved state
	btst	#BMB_INTERLEAVED,d0	; is interleaved?
	beq	quiet_error	; bomb out if not interleaved

	lea	canvas_rport(a5),a1
	jsr	_LVOInitRastPort(a6)
	move.l	canvas_bitmap(a5),canvas_rport+rp_BitMap(a5)
	
; all libraries are open, now let's open our demo screen.
	sub.l	a0,a0			; no NewScreen structure, just tags
	lea	screentaglist(pc),a1	; screen attributes
	move.l	_IntuitionBase(a5),a6
	jsr	_LVOOpenScreenTagList(a6)
	geta6
	move.l	d0,DemoScreen(a6)
	beq	quiet_error
	
; now, we must allocate a UCopList structure for our user copper list

;	move.l	#ucl_SIZEOF,d0
;	move.l	#MEMF_PUBLIC|MEMF_CLEAR,d1	; as per autodoc for CINIT
;	move.l	_SysBase(a6),a6
;	jsr	_LVOAllocMem(a6)
;	geta6
;	move.l	d0,UserCopList(a6)
;	beq	quiet_error
	
;	move.l	d0,a0
;	move.l	d0,a2				; save value
;	move.l	#30,d0				; room for 30 copper instructions
;	move.l	_GfxBase(a6),a6
;	jsr	_LVOUCopperListInit(a6)

;	CWAIT	a2,#0,#0			; wait for first line
;	CMOVE	a2,#intreq,#$8010		; cause an interrupt
;	CEND	a2
;	geta6

; now, let's install the user copperlist into our screen's viewport.

	move.l	DemoScreen(a6),a0
;	move.l	a2,sc_ViewPort+vp_UCopIns(a0)

	move.l	DemoScreen(a6),a0
	lea	sc_ViewPort(a0),a1
	move.l	a1,canvas_viewport(a6)

	lea	timername(pc),a0		; device name
	moveq	#0,d0				; unit #
	lea	TimerIO(a6),a1			; iorequest
	moveq	#0,d1				; flags
	move.l	$4,a6
	jsr	_LVOOpenDevice(a6)
	geta6
	tst.l	d0				; error?
	bne	quiet_error



	move.l	canvas_viewport(a6),a0
	lea	mytab(pc),a1
	move.l	_GfxBase(a6),a6
	jsr	_LVOLoadRGB32(a6)
	geta6


; now, let's create the copper-triggered task
;	pea	$1000			; stack size
;	pea	realtime_task(pc)	; code ptr
;	pea	25			; priority
;	pea	mytaskname(pc)		; name
;	jsr	_CreateTask		; call amiga.lib entry point
;	lea	4*4(a7),a7		; pop stacked args
;	move.l	d0,thetask(a6)
;	move.l	d0,CopperIntr+IS_DATA(a6)



; now, let's set up the copper interrupt handler.
;	move.w	#$8010,_custom+intena		; enable copper ints
;	move.b	#10,LN_PRI+CopperIntr(a6)	; pick a nice priority
;	move.l	#myintr_handler,IS_CODE+CopperIntr(a6)
;	lea	CopperIntr(a6),a1
;	move.l	_SysBase(a6),a6
;	moveq	#4,d0				; interrupt number
;	jsr	_LVOAddIntServer(a6)
;	geta6
;	st	server_added(a6)		; flag for whether server was added
	bsr	init_fakefb

main_loop:	
	moveq	#0,d0
	bsr	fill_fakefb
	move.l	d7,-(a7)
	bsr	DoMovement
	bsr	render_3d
	bsr	get_elapsed_time
	move.w	d0,frfract(a6)
	ifne	DO_DIAGNOSTICS
	ONTIMER	2
	move.w	frfract(a6),d0
	beq.s	no_frate
	move.l	#$8000*10,d1
	divu	d0,d1
	moveq	#0,d0
	move.w	d1,d0
	dstring	'Frame rate=%04ld',DUNGEON_WINDOW_RIGHT+10,DUNGEON_WINDOW_Y+20,d0
no_frate:
	ifne	0
	moveq	#0,d0
	move.w	PlayerHeading(a6),d0
	dstring	'Head=%04lx',DUNGEON_WINDOW_RIGHT+5,DUNGEON_WINDOW_Y+30,d0
	moveq	#0,d0
	move.w	PlayerSpeed(a6),d0
	dstring	'v=%04lx',DUNGEON_WINDOW_RIGHT+5,DUNGEON_WINDOW_Y+40,d0
	dstring	'X=%7ld',DUNGEON_WINDOW_RIGHT+5,DUNGEON_WINDOW_Y+50,PlayerX(a6)
	dstring	'Y=%7ld',DUNGEON_WINDOW_RIGHT+5,DUNGEON_WINDOW_Y+60,PlayerY(a6)
	dstring	'Z=%7ld',DUNGEON_WINDOW_RIGHT+5,DUNGEON_WINDOW_Y+70,PlayerZ(a6)
	endc
	OFFTIMER	2
	endc
	ONTIMER	1
	bsr	fakefb_to_screen
	OFFTIMER	1
	move.l	(a7)+,d7
	tst.b	stick_click(a6)
	beq	main_loop
	
quit_demo:
	bsr	cleanup_resources		; close everything
	moveq	#0,d0				; return code
	rts					; and return to shell

temp_ylr:
	dc.w	0,0,1,-1

myintr_handler:
	move.l	canvas_viewport,a6
	move.w	vp_Modes(a6),d0
	and.w	#V_VP_HIDE,d0
	bne.s	no_signal
	move.l	$4.w,a6
	move.l	CycleTaskSignal,d0
	beq.s	no_signal
	jsr	_LVOSignal(a6)
no_signal:
	moveq	#0,d0			; let others run
	rts


realtime_task:
; entry point for beam-triggered display task.
	geta6
	move.l	_SysBase(a6),a6
	moveq	#-1,d0
	jsr	_LVOAllocSignal(a6)
	geta6
	moveq	#1,d1
	lsl.l	d0,d1
	move.l	d1,d0
	move.l	d0,CycleTaskSignal(a6)
	move.l	d0,d7
	move.l	a6,a5
CycleTaskLoop:
	move.l	_SysBase(a5),a6
	move.l	d7,d1
	moveq	#0,d0
	jsr	_LVOSetSignal(a6)
	move.l	d7,d0
	jsr	_LVOWait(a6)
	ifd	SCROLL_TEST
	move.l	DemoScreen(a5),a0
	lea	sc_ViewPort(a0),a0
	st	not_safe(a5)		; tell the main task that
	move.l	vp_RasInfo(a0),a1

	addq.w	#1,ri_RyOffset(a1)
	cmp.w	#200,ri_RyOffset(a1)
	bls.s	1$
	clr.w	ri_RyOffset(a1)
1$:
	addq.w	#1,ri_RxOffset(a1)
	cmp.w	#320,ri_RxOffset(a1)
	bls.s	2$
	clr.w	ri_RxOffset(a1)
2$:	move.l	_GfxBase(a5),a6		; it is not safe to RemTask me.
	jsr	_LVOScrollVPort(a6)
	move.w	#$f0f,$dff180
	sf	not_safe(a5)
	endc
	bra	CycleTaskLoop

mytab:
	include	'palette.i'		; use default palette

quiet_error::
; entr: none. exit: doesn't. trashes: all
; this routine exits from the program, cleaning up any resources, but with no error
; message. This is because some library may have failed to open.
	geta6				; this routine can be entered without a6 pointing at variable base.
	bsr	cleanup_resources	; close libraries
	move.l	InitialSP(a6),a7
	moveq	#30,d0			; return code
	rts

cleanup_resources:
; close all screens, libraries, free memory, etc.
	OFFTIMER	0
	tst.l	TimerIO+IO_DEVICE(a6)	; timer open ?
	beq.s	no_timer
	lea	TimerIO(a6),a1
	move.l	$4,a6
	jsr	_LVOCloseDevice(a6)
	geta6
no_timer:
	tst.b	server_added(a6)
	beq.s	no_server
	lea	CopperIntr(a6),a1
	moveq	#4,d0			; copper intr
	move.l	_SysBase(a6),a6
	jsr	_LVORemIntServer(a6)
	geta6
	clr.b	server_added(a6)
no_server:
	move.l	thetask(a6),a1
	cmp.w	#0,a1
	beq.s	notask
	move.l	_SysBase(a6),a6
busy_loop:
	jsr	_LVOForbid(a6)
	tst.b	not_safe
	beq.s	is_safe
	jsr	_LVOPermit(a6)
	bra.s	busy_loop
is_safe:
	jsr	_LVORemTask(a6)
	jsr	_LVOPermit(a6)
	geta6
notask:
	move.l	DemoScreen(a6),d0
	beq.s	screen_not_open
	move.l	d0,a0
	move.l	_IntuitionBase(a6),a6
	jsr	_LVOCloseScreen(a6)
	geta6
	clr.l	DemoScreen(a6)
screen_not_open:
	move.l	canvas_bitmap(a6),a0
	move.l	_GfxBase(a6),a6
	jsr	_LVOFreeBitMap(a6)	; FreeBitMap(NULL) is ok
	geta6
	closelib	_IntuitionBase
	closelib	_GfxBase
	closelib	_DosBase
	rts


get_elapsed_time::
; return d0=elapsed time in int.frac format
; trashes: a0/a1/d1-d4
	lea	NewEClock(a6),a0
	move.l	TimerIO+IO_DEVICE(a6),a6	; get library pointer
	jsr	_LVOReadEClock(a6)		; now, NewEClock=64 bit value
	geta6
	movem.l	LastEClock(a6),d1/d2/d3/d4	; d1/d2=old d3/d4=new
	movem.l	d3/d4,LastEClock(a6)
	tst.b	first_timer(a6)
	beq.s	second_time
	clr.b	first_timer(a6)
	moveq	#0,d0
	rts
second_time:
	sub.l	d2,d4
	subx.l	d1,d3				; d3 now=elapsed time
	add.l	d0,d0
	clr.w	d0
	swap	d0			; d0=#ticks in (1/32768s)
	divu.l	d0,d3:d4
	move.l	d4,d0
	rts


screentaglist:
; list of attributes for the screen that we want to open
	dc.l	SA_Width,SCREEN_WIDTH,SA_Height,SCREEN_HEIGHT,SA_Depth,SCREEN_DEPTH
	dc.l	SA_Quiet,-1				; prevent gadgets, titlebar from appearing.
	dc.l	SA_DisplayID,0				; default (can be promoted)
bm_tag::
	dc.l	SA_BitMap,0
	dc.l	TAG_END



dosname:
	dc.b	'dos.library',0
intuiname:
	dc.b	'intuition.library',0
gfxname:
	dc.b	'graphics.library',0

mytaskname:
	dc.b	'Demo Color Cycle Task',0

timername:
	dc.b	'timer.device',0

	section	__MERGED,DATA

InitialSP::	dc.l	0		; initial stack pointer so that we can return to the
					; shell from any stack depth
_SysBase::	dc.l	0		; my copy of ExecBase
_IntuitionBase::
		dc.l	0		; Intuition library base ptr
_GfxBase::	dc.l	0		; graphics library ptr
_DosBase::	dc.l	0		; dos library ptr

DemoScreen::	dc.l	0		; pointer to our screen

UserCopList::	dc.l	0		; pointer to our allocated user copper list

thetask::	dc.l	0
CycleTaskSignal::
		dc.l	0

canvas_bitmap::	dc.l	0		; bitmap for scrolling canvas
canvas_viewport::
		dc.l	0		; viewport of canvas screen

CopperIntr::	ds.b	IS_SIZE		; interrupt structure for my copper interrupt

frfract::	dc.w	0		; elapsed time 32767=1 sec
TimerIO::	ds.b	IOTV_SIZE

; the following two must stay together
LastEClock::	dc.l	0,0		
NewEClock::	dc.l	0,0
; the preceeding two must stay together

canvas_rport::	ds.b	rp_SIZEOF	; rastport for writing into canvas bitmap
server_added::	dc.b	0
not_safe::	dc.b	0
first_timer::	dc.b	-1		; set if get_elapsed_time hasn't been called yet
ctdn::	dc.b	0

	end

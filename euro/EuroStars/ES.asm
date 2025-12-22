*\  :ts=8 bk=0
*
* ES.asm:	A neato star program based on some Euro code (from the group
*		"Absence" I believe).
*
*		This code came from Portal under the name STARTOY.LZH and
*		was uploaded by Greg Cunningham (author of BaudBandit).
*		The program was disassembled using ReSource 4.16 (from The
*		Puzzle Factory), and modified from there by me.
*
*		Improvements:
*		o No longer Disable()s the world whle running.
*		o Tossed out hard-coded custom copper list; now uses an
*		  Intuition screen.  (Drag it!  Amaze your friends!)
*		o Uses Intuition Window to collect mouse click.
*		o Now *closes* GfxBase.
*		o Clipping improved.
*		o Replaced 800-entry sinetable with 1024-entry table.
*		o Angles and spins now forced to even values.
*		o New, more traditional perspective formula.
*		o Reasonably commented.
*		o Busy-wait for bottom-of-frame replaced with copper
*		  interrupt.
*		o New amazing stupendous incredible argument parser.
*		o Code speed improved slightly (!)
*		o Has an ARexx port!!!!!
*
* Some dedicated EuroHacker				91??.??
* Leo L. Schwab			(415) 903-9321		9109.12
*  New argument parsing					9205.09
*  New 1024-entry sinetable				9205.09
*  Functional ARexx					9205.10
*  BOF copper interrupt					9205.11
*/

****************************************************************************
* Documentation.
*
******* ES ******************************************
*
*   NAME
*	ES -- EuroStars
*
*   SYNOPSIS
*	ES [MRS][XYZ] <value> [<value> ... ]
*	ES B
*	ES Q	(ARexx only)
*
*   DESCRIPTION
*	ES is a starfield program based on European code that has been
*	massively cleaned up and featurized.  As a result, it doesn't run
*	quite as smoothly on vanilla 68000-based systems, but it's less
*	likely to trash your system.
*
*	ES may be run from the command line or from the Workbench.  When
*	you're finished looking, click the left mouse button anywhere on the
*	starfield to exit.
*
*	ES lets you specify how the stars move and rotate.  This is done
*	from the command line or from the ARexx port.  For both, the
*	argument syntax is the same.
*
*   ARGUMENTS
*	The M, R, and S operators specify star movement, rotation, and spin
*	respectively.  Movement specifies how many world units the stars are
*	translated each frame.  Rotation specifies a static/initial rotation
*	angle.  Spin specifies the change in rotation for each frame.  The
*	X, Y, and Z specifiers indicate which axes the operators are to
*	apply.  Rotation angles are specified in "EuroHackerGrads."  There
*	are 2048 EHG to a full 360 degree circle.
*
*	The MRS operators must appear before the the XYZ specifiers, and
*	there may be no spaces between them.  Only one MRS operator may
*	appear before a given set of XYZ specifiers.  Following the MRSXYZ
*	command are the actual values to be used.
*
*	It's much easier to understand if you look at the examples.
*
*	In addition to the above, there are two additional arguments that
*	may be used:
*
*	B:	Operate as background server.
*		Ordinarily, ES will exit when you click on its screen.
*		However, if you want to do extensive ARexx operations
*		without user interference, this option may be specified,
*		causing ES to ignore all subsequent mouse events on its
*		screen.  Once backgrounded, ES cannot be un-backgrounded.
*		The only way to terminate a backgrounded ES is with the
*		following command:
*
*	Q:	Quit.
*		When sent as an ARexx command, ES will exit immediately.
*		This option on the CLI command line is meaningless; if
*		present, the entire command line is ignored.
*
*   AREXX
*	ES features an ARexx port.  The name of the port is EUROSTARS.
*	Commands sent to this port are exactly the same as those on the
*	command line.  Malformed commands are returned with RC set to
*	RC_ERROR (10).
*
*	Commands are cumulative; that is, a move command (for example)
*	remains in effect until reset by another move command for the same
*	axis.  Thus, an MX command followed later by an SX command does not
*	cancel the MX command.
*
*   EXAMPLES
*	ES mx 4
*		Move stars 4 units along X axis each frame.
*	ES sxyz 2 -4 6
*		For each frame, spin the X axis 2 EHG, the Y axis -4 EHG,
*		and the Z axis 6 EHG.
*	ES rx 512
*		Rotate X axis 512 EHG and keep it there.
*	ES rx -512 sx 2
*		Start X axis rotated at -512 EHG and add 2 EHG to it each
*		frame.
*	ES mxz 10 0 sxyz 2 2 2
*		Move 10 units along X, zero units along Z, and spin all axes
*		by two EHG each frame.
*	ES mxz sxyz 10 0 2 2 2
*		Identical to the above.
*	ES sxmxsymzsz 2 10 2 0 2
*		Again, identical to the above.
*
*	As you can see, the syntax is very flexible.
*
*   NOTES
*	Despite its nomenclature, the 'B' option does not fork ES into the
*	background; you must use the 'Run' command.
*
*	The coordinate system is right-handed, X axis horizontal, Y axis
*	vertical, Z axis perpendicular to the screen.  Positive rotations
*	are clockwise, and are in Z,Y,X order.
*
*	The default startup values are:
*	MX 0  MY 0  MZ 4   RX 0  RY 0  RZ 0   SX 0  SY 0  SZ 0
*
*   BUGS
*	Slow on a 68000.  Short of Disable()ing the system or reducing the
*	number of stars, this is unavoidable.
*
*	Malformed commands generate a diagnostic string to the CLI.  These
*	strings are not available to ARexx programs.  Sigh...
*
*   AUTHOR
*	Leo L. Schwab  --  New Technologies Group, Inc.
*	BIX:		ewhac
*	Portal:		ewhac
*	InterNet:	ewhac@ntg.com   ..or..   ewhac@well.sf.ca.us
*
****************************************************************************
* Includes.
*
		include	'exec/types.i'
		include	'exec/memory.i'
		include	'graphics/gfxbase.i'
		include	'hardware/intbits.i'
		include	'intuition/intuition.i'
		include	'libraries/dosextens.i'
		include	'rexx/storage.i'
		include	'rexx/errors.i'


****************************************************************************
* A couple of simple macros.
*
xlib	MACRO
		XREF	_LVO\1
	ENDM

jsrlib	MACRO
		jsr	_LVO\1(a6)
	ENDM


****************************************************************************
* External references.
*
		xlib	AllocMem
		xlib	FreeMem
		xlib	AllocSignal
		xlib	FreeSignal
		xlib	AddIntServer
		xlib	RemIntServer
		xlib	OpenLibrary
		xlib	CloseLibrary
		xlib	Forbid
		xlib	Permit
		xlib	WaitPort
		xlib	PutMsg
		xlib	GetMsg
		xlib	ReplyMsg
		xlib	AddPort
		xlib	RemPort
		xlib	FindTask
		xlib	Signal
		xlib	Wait
		xlib	OpenScreen
		xlib	OpenWindow
		xlib	CloseScreen
		xlib	CloseWindow
		xlib	SetPointer
		xlib	MakeScreen
		xlib	GetScreenData
		xlib	RethinkDisplay
		xlib	QueryOverscan
		xlib	LoadRGB4
		xlib	FreeCopList
		xlib	UCopperListInit
		xlib	CWait
		xlib	CMove
		xlib	CBump
		xlib	Output
		xlib	Write
		xlib	CreateProc
		xlib	Lock

		xref	_intreq


****************************************************************************
* Public symbols (primarily for debugging).
*
		xdef	Transform
		xdef	NextStar
		xdef	StarSeg
		xdef	MoveStars
		xdef	DrawStars
		xdef	SinCos
		xdef	ParseArgs


****************************************************************************
* Symbol Definitions
*
MINBOX		equ	-450
MAXBOX		equ	450
BOXRANGE	equ	MAXBOX-MINBOX+1

MAGIC		equ	$10000		; 256 << 8
ZPULL		equ	780

SCRWIDE		equ	352
SCRHIGH		equ	230

SPRBUFSIZ	equ	12


****************************************************************************
* And now for the code!
*
		section	EuroStars,code

CreatedSix
	;------	Test CLI vs. Workbench
		bsr	ClearBSS	; Initialize uninitialized data

		moveq	#0,d7		; No error
		move.l	a0,a2		; Save CLI command line data
		move.l	d0,d2

		move.l	(4).w,a6
		sub.l	a1,a1		; Find ourselves
		jsrlib	FindTask
		move.l	d0,mpsigtask
		move.l	d0,a0
		tst.l	pr_CLI(a0)	; Are we a CLI?
		beq.s	WBench		; No, don't parse command line.

	;------	CLI startup.  Parse arguments.
		move.l	a2,a0		; Restore CLI command data
		move.l	d2,d0
		clr.b	0(a0,d0.l)	; Force NULL at end of command line
		bsr	ParseArgs
		move.l	d0,d7		; Save error string (it's easier
		bra.s	OpenDOS		;  this way.  Trust me.)

	;------	Workbench startup.  Get startup message.
WBench		lea	pr_MsgPort(a0),a2
		move.l	a2,a0
		jsrlib	WaitPort
		move.l	a2,a0
		jsrlib	GetMsg
		move.l	d0,WBStartMsg

	;------	Open DOS.
OpenDOS		move.l	(4).w,a6
		lea	DOSName(pc),a1
		moveq	#0,d0
		jsrlib	OpenLibrary
		move.l	d0,DOSBase
		beq	err_dos

	;------	Now then, did the parser return an error?
		move.l	d7,d0
		ble.s	1$		; (Ignore 'QUIT')
		bsr	PrintCLIStr	; Print the error
		bra	err_mem		; Exit (closing DOS)
1$
	;------	Allocate memory for blank sprite.
		moveq	#SPRBUFSIZ,d0
		move.l	#MEMF_CHIP!MEMF_CLEAR,d1
		jsrlib	AllocMem
		move.l	d0,sprdat
		beq	err_mem

	;------	Allocate signal for message port.
		moveq	#-1,d0
		jsrlib	AllocSignal
		move.b	d0,mpsigbit
		bmi	err_signal

	;------	Open Graphics
		lea	GfxName(pc),a1
		moveq	#0,d0
		jsrlib	OpenLibrary
		move.l	d0,GBase
		beq	err_gfx

	;------	Open Intuition
		lea	IntuiName(pc),a1
		moveq	#0,d0
		jsrlib	OpenLibrary
		move.l	d0,IBase
		beq	err_intui

	;------	Open screen
		move.l	d0,a6
		lea	scr_def(pc),a0
		jsrlib	OpenScreen
		move.l	d0,scrptr
		beq	err_scr
		move.l	d0,a2

	;------	Open window on screen
		lea	windef(pc),a0
		jsrlib	OpenWindow
		move.l	d0,winptr
		beq	err_win

	;------	Set invisible pointer.
		move.l	d0,a0
		move.l	sprdat(pc),a1
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		jsrlib	SetPointer

	;------	Set local bitplane pointers.
		move.l	sc_BitMap+bm_Planes+0(a2),Plane1ptr
		move.l	sc_BitMap+bm_Planes+4(a2),Plane2ptr

	;------	Shove Screen's ViewPort into a nice-ish overscan position.
	;------	We have to do this differently based on OS revision.
		lea	XBuff,a3
		cmp.w	#37,LIB_VERSION(a6)	; What version?
		blt.s	OScan1_3

	;------	Do 2.0 centering.  A3 is used as Rectangle structure pointer.
		move.l	a3,a1
		moveq	#OSCAN_TEXT,d0
		sub.l	a0,a0		; Zero is LORES_KEY
		jsrlib	QueryOverscan

		move.w	#SCRWIDE,d0	; Compute difference in sizes
		sub.w	ra_MaxX(a3),d0	;  between standard screen and ours.
		add.w	ra_MinX(a3),d0
		move.w	#SCRHIGH,d1	; SCRHIGH - (MaxY - MinY)
		sub.w	ra_MaxY(a3),d1
		add.w	ra_MinY(a3),d1
		asr.w	#1,d0
		asr.w	#1,d1
		sub.w	d0,sc_ViewPort+vp_DxOffset(a2)	; Shift screen
		sub.w	d1,sc_ViewPort+vp_DyOffset(a2)
		bra.s	AddBOF

	;------	Do 1.3 centering.  A3 is used as screen buffer pointer.
OScan1_3	move.l	a3,a0		; Screen buffer
		move.l	#sc_SIZEOF,d0	; bufsiz
		moveq	#WBENCHSCREEN,d1	; Screen type
		sub.l	a1,a1		; NULL
		jsrlib	GetScreenData	; Tell me about the Workbench screen

		move.w	#SCRWIDE,d0	; Skate screen acto WBench size
		move.w	sc_ViewPort+vp_DWidth(a3),d1
		btst.b	#7,sc_ViewPort+vp_Modes(a3)	; Check HIRES bit
		beq.s	2$		; HIRES?
		asr.w	#1,d1		; Yes, divide width by two
2$
		sub.w	d1,d0
		asr.w	#1,d0		; Divide difference by two
		sub.w	d0,sc_ViewPort+vp_DxOffset(a2)	; Shift screen

		move.w	#SCRHIGH,d0
		move.w	sc_ViewPort+vp_DHeight(a3),d1
		btst.b	#2,sc_ViewPort+vp_Modes+1(a3)	; Check LACE bit
		beq.s	3$		; LACE?
		asr.w	#1,d1		; Yes, divide height by two
3$
		sub.w	d1,d0
		asr.w	#1,d0
		sub.w	d0,sc_ViewPort+vp_DyOffset(a2)	; Shift screen

	;------	Add Bottom-of-frame copper interrupt.
AddBOF		lea	MyCopList,a3
		move.l	a3,sc_ViewPort+vp_UCopIns(a2)	; vp->UCopIns = cl;
		move.l	a3,a0		; CINIT (cl, 4);
		moveq	#4,d0
		move.l	GBase(pc),a6
		jsrlib	UCopperListInit

		move.l	a3,a1		; CWAIT (cl, SCRHIGH, 0);
		move.l	#SCRHIGH,d0
		moveq	#0,d1
		jsrlib	CWait
		move.l	a3,a1
		jsrlib	CBump

		move.l	a3,a1		; CMOVE (cl, intreq,
		move.l	#_intreq,d0	;	 INTF_SETCLR | INTF_COPER);
		move.l	#INTF_SETCLR!INTF_COPER,d1
		jsrlib	CMove
		move.l	a3,a1
		jsrlib	CBump

		move.l	a3,a1		; CEND (cl);
		move.l	#10000,d0
		move.l	#255,d1
		jsrlib	CWait
		move.l	a3,a1		; Not sure this is necessary, but the
		jsrlib	CBump		;  gfxmacros.h macro does it...

	;------	Recompose display.
		move.l	a2,a0		; Screen still in A2
		move.l	IBase(pc),a6
		jsrlib	MakeScreen
		jsrlib	RethinkDisplay

	;------	Load colors.
		lea	sc_ViewPort(a2),a0
		lea	colors(pc),a1
		moveq	#4,d0
		move.l	GBase(pc),a6
		jsrlib	LoadRGB4

	;------	Create sub-process to actually render stars.
		move.l	mpsigtask(pc),a0
		moveq	#0,d2
		move.b	LN_PRI(a0),d2	; Priority
		subq.l	#1,d2		; (Nudge *BELOW* creator)
		lea	StarSeg(pc),a0
		move.l	a0,d3		; SegList pointer
		lsr.l	#2,d3		; (Convert to BPTR)
		lea	ESName(pc),a0
		move.l	a0,d1		; Process name
		move.l	#4096,d4	; Stack size
		move.l	DOSBase(pc),a6
		jsrlib	CreateProc
		tst.l	d0
		beq	err_proc

	;------	Launch subprocess with startup message.
		move.l	d0,a0
		lea	startmsg(pc),a1
		move.l	(4).w,a6
		jsrlib	PutMsg

	;------	Publish message port.
		lea	mport(pc),a1
		jsrlib	AddPort


	;------	Wait for ARexx and Intuition events.
		bsr	HandleEvents


	;------	Remove port and flush all pending messages.
		jsrlib	Forbid		; STOP!
		lea	mport(pc),a2
		move.l	a2,a1
		jsrlib	RemPort		; Pull port from list
		moveq	#RC_FATAL,d2

flushloop	move.l	a2,a0
		jsrlib	GetMsg		; Get message, if any
		tst.l	d0
		beq.s	1$		; No message, leave loop
		move.l	d0,a1
		move.l	d2,rm_Result1(a1)	; Die die die
		clr.l	rm_Result2(a1)
		jsrlib	ReplyMsg	; Reply failed message
		bra.s	flushloop
1$
		jsrlib	Permit		; Okay, go ahead.

	;------	Send kill signal to stars process.
		moveq	#0,d0
		bset	#SIGBREAKB_CTRL_C,d0
		move.l	StarTask(pc),a1		; RACE!!  Might not be set!
		jsrlib	Signal

	;------	Wait for startup message to return.
		lea	mport(pc),a0
		jsrlib	WaitPort


	;------	Cleanup and exit.
err_proc	move.l	GBase(pc),a6	; Delete UCopList by hand
		move.l	scrptr(pc),a0	;  (required for 1.3)
		lea	sc_ViewPort+vp_UCopIns(a0),a0
		move.l	(a0),a1
		clr.l	(a0)		; Keep system from freeing it, too
		move.l	ucl_FirstCopList(a1),a0
		jsrlib	FreeCopList

		move.l	IBase(pc),a6	; Close window
		move.l	winptr(pc),a0
		jsrlib	CloseWindow
err_win		move.l	scrptr(pc),a0
		jsrlib	CloseScreen
err_scr		move.l	a6,a1
		move.l	(4).w,a6
		jsrlib	CloseLibrary	; Close Intuition
err_intui	move.l	GBase(pc),a1
		jsrlib	CloseLibrary	; Close Graphics
err_gfx		moveq	#0,d0
		move.b	mpsigbit(pc),d0
		jsrlib	FreeSignal	; Free msgport signal
err_signal	move.l	sprdat(pc),a1
		moveq	#SPRBUFSIZ,d0
		jsrlib	FreeMem
err_mem		move.l	DOSBase(pc),a1
		jsrlib	CloseLibrary
err_dos
		move.l	WBStartMsg(pc),d0	; Reply Workbench startup
		beq.s	xit			;  if present.

		move.l	d0,a1
		jsrlib	ReplyMsg
		clr.l	d0

xit		rts


****************************************************************************
* ARexx message and window event processing loop.
*
HandleEvents
	;------	Compute signal flag for window port.
		moveq	#0,d2
		move.l	winptr(pc),a0
		move.l	wd_UserPort(a0),a0
		move.b	MP_SIGBIT(a0),d0
		bset.l	d0,d2

	;------	Compute signal flag for ARexx port.
		move.b	mpsigbit(pc),d0
		bset.l	d0,d2

	;------	Wait for something to happen.
eventloop	move.l	d2,d0
		jsrlib	Wait

	;------	Check for ARexx messages.
		moveq	#RC_ERROR,d3

0$		lea	mport(pc),a0
		jsrlib	GetMsg
		tst.l	d0		; Message present?
		beq.s	9$		; No, fall off

		move.l	d0,a2
		move.l	ARG0(a2),a0	; Get argument string
		bsr	ParseArgs	; Parse it
		move.l	d0,d7		; Was there an error?
		ble.s	1$		; No

		move.l	d3,rm_Result1(a2)	; Yes, store error
		bra.s	2$

1$		clr.l	rm_Result1(a2)
2$		clr.l	rm_Result2(a2)	; Result2 always NULL
		move.l	a2,a1
		jsrlib	ReplyMsg	; Send message back
		bra.s	0$		; Next message, please
9$
	;------	Was that parser return a REXX request for death?
		tst.l	d7
		bmi.s	Rexxit		; Why, yes it was!

	;------	Check for window events.
		move.l	winptr(pc),a0
		move.l	wd_UserPort(a0),a0
		jsrlib	GetMsg		; Check port
		tst.l	d0		; Something there?
		beq.s	eventloop	; No, go to sleep
		move.l	d0,a1		; Yup, reply it
		jsrlib	ReplyMsg

	;------	Window event arrived.  If we are a background server, ignore
	;------	the event.  Elsewise, return.
		move.w	BackServ(pc),d0	; Just to set flags
		bne.s	eventloop

Rexxit		rts			; User wants us dead, dammit.


****************************************************************************
* Welcome to the actual stars code.
*
		cnop	0,4

StarSeg		dc.l	0		; Phony NextSeg pointer

	;------	Entry point.
		move.l	(4).w,a6
		sub.l	a1,a1
		jsrlib	FindTask		; Get pointer to this task.
		move.l	d0,StarTask		; Store
		move.l	d0,a0
		lea	pr_MsgPort(a0),a2	; Get pointer to MsgPort

	;------	Wait for startup message.
		move.l	a2,a0
		jsrlib	WaitPort
		move.l	a2,a0
		jsrlib	GetMsg
		move.l	d0,StarMsg

	;------	Compute sigmask.
		moveq	#0,d0
		bset.l	#SIGBREAKB_CTRL_C,d0
		bset.l	#SIGBREAKB_CTRL_F,d0	; BOF will happen here.
		move.l	d0,StarSigMask

	;------	Install interrupt server.
		moveq	#INTB_COPER,d0
		lea	BOFintrnode(pc),a1
		jsrlib	AddIntServer

	;------	Main star loop.
mainloop	bsr	AddSpins
		bsr	Transform
		bsr.s	MoveStars

		move.l	StarSigMask(pc),d0
		jsrlib	Wait		; Wait for BOF or kill signal
		move.l	d0,StarSigs

		bsr	EraseStars	; Do this in any case
		bsr	DrawStars

		move.l	StarSigs(pc),d0
		btst.l	#SIGBREAKB_CTRL_C,d0
		beq.s	mainloop

	;------	Got kill signal from above.  Remove interrupt server,
	;------	reply startup and exit.
		jsrlib	Forbid		; HA!  MINE!
		moveq	#INTB_COPER,d0
		lea	BOFintrnode(pc),a1
		jsrlib	RemIntServer

		move.l	StarMsg(pc),a1
		jmp	_LVOReplyMsg(a6)	; Poof!  Bye...



****************************************************************************
* Move the stars
*
MoveStars	lea	XCoords(pc),a0
		lea	YCoords(pc),a1
		lea	ZCoords(pc),a2
		move.w	delta_x(pc),d0
		move.w	delta_y(pc),d1
		move.w	delta_z(pc),d2
		move.w	#BOXRANGE,d4
		move.w	NumStars(pc),d7

0$		move.w	(a0),d3
		add.w	d0,d3		; Add move delta
		cmp.w	#MAXBOX,d3	; Too big?
		bgt.s	1$
		cmp.w	#MINBOX,d3	; Too small?
		bge.s	2$
		add.w	d4,d3		; Wrap up
		bra.s	2$
1$		sub.w	d4,d3		; Wrap down
2$		move.w	d3,(a0)+

		move.w	(a1),d3
		add.w	d1,d3
		cmp.w	#MAXBOX,d3
		bgt.s	11$
		cmp.w	#MINBOX,d3
		bge.s	22$
		add.w	d4,d3
		bra.s	22$
11$		sub.w	d4,d3
22$		move.w	d3,(a1)+

		move.w	(a2),d3
		add.w	d2,d3
		cmp.w	#MAXBOX,d3
		bgt.s	111$
		cmp.w	#MINBOX,d3
		bge.s	222$
		add.w	d4,d3
		bra.s	222$
111$		sub.w	d4,d3
222$		move.w	d3,(a2)+

		dbra	d7,0$

		rts


****************************************************************************
* Star rendering routines.
*
EraseStars	moveq	#0,d0
		move.l	Plane1ptr(pc),a1
		move.l	Plane2ptr(pc),a2
		lea	PlaneOffsets,a4
		move.w	NumStars(pc),d7
1$		move.w	(a4)+,d1
		move.w	d0,0(a1,d1.w)	; Blast entire word.
		move.w	d0,0(a2,d1.w)
		dbra	d7,1$

		rts


DrawStars	lea	XBuff,a0
		lea	YBuff,a1
		lea	PlaneOffsets,a3
		lea	ZBuff,a5
		move.l	Plane1ptr(pc),a2
		move.l	Plane2ptr(pc),a4
		move.w	NumStars(pc),d7
		move.w	#SCRHIGH-1,d4
		move.w	#SCRWIDE-1,d5
		move.w	#$8000,d6
NextDraw	move.w	(a1)+,d0	; Load and check Y value
		bmi.s	clipped
		cmp.w	d4,d0
		bgt.s	clipped

		move.w	(a0),d1		; Load and check X value
		bmi.s	clipped
		cmp.w	d5,d1
		bgt.s	clipped

		move.w	d1,d2
		and.b	#15,d1
		and.w	#$FFF0,d2
		lsr.w	#3,d2
		move.w	d6,d3
		ror.w	d1,d3
		mulu	#SCRWIDE/8,d0	; BytesPerRow
		add.w	d0,d2
		move.w	d2,(a3)+
		cmp.w	#-176,(a5)	; Z closer than this?
		ble.s	1$		; No, draw just plane 1 (dim)

		or.w	d3,0(a4,d2.w)	; This plane definitely gets written
		cmp.w	#130,(a5)	; Very close?
		ble.s	2$		; No
1$		or.w	d3,0(a2,d2.w)	;    Yes; draw brightest value
2$		addq.w	#2,a5
		addq.w	#2,a0	; No, you can't get rid of this easily...
		dbra	d7,NextDraw

		rts

clipped		clr.w	(a3)+
		addq.w	#2,a5
		addq.w	#2,a0
		dbra	d7,NextDraw

		rts


****************************************************************************
* The Biggie!
* Transform all points, rotating about Z, Y, and X axes (in that order).
* Those of you looking for a general matrix multiply here won't find it.
* These are simple two dimensional rotations applied one at a time.
* The sine/cosine table uses 8.8 fixed point notation.  The numbers in the
* coordinates array are straight integers.
*
Transform	lea	CurrentSinCos(pc),a4
		move.w	theta_x(pc),d0
		bsr	SinCos
		move.w	d0,(a4)
		move.w	d1,2(a4)
		move.w	theta_y(pc),d0
		bsr	SinCos
		move.w	d0,4(a4)
		move.w	d1,6(a4)
		move.w	theta_z(pc),d0
		bsr	SinCos
		move.w	d0,8(a4)
		move.w	d1,10(a4)
		lea	XCoords(pc),a0
		lea	YCoords(pc),a1
		lea	ZCoords(pc),a2
		lea	XBuff,a3
		move.w	NumStars(pc),d4
		move.l	#MAGIC,d2	; 256 as an 8.8 fixed point num.
		move.w	#ZPULL,d3	; "Pull out"

	;------	Perform rotations.
NextStar	move.w	(a0),d5		; X
		muls	10(a4),d5	;   * cos(z)
		move.w	(a1),d1		; Y
		muls	8(a4),d1	;   * sin(z)
		sub.l	d1,d5		; == X cos(z) - Y sin(z) == X'    D5
		lsr.l	#8,d5
		move.w	(a0)+,d6	; X
		muls	8(a4),d6	;   * sin(z)
		move.w	(a1)+,d1	; Y
		muls	10(a4),d1	;   * cos(z)
		add.l	d1,d6		; == X sin(z) + Y cos(z) == Y'    D6
		lsr.l	#8,d6	; Rotation about Z axis complete.

		move.w	(a2),d7		; Z
		muls	6(a4),d7	;   * cos(y)
		move.w	4(a4),d1	; sin(y)
		muls	d5,d1		;	 * X'
		sub.l	d1,d7		; == Z cos(y) - X' sin(y) == Z'   D7
		lsr.l	#8,d7
		move.w	(a2)+,d1	; Z
		muls	4(a4),d1	;   * sin(y)
		muls	6(a4),d5	; X' * cos(y)
		add.l	d1,d5		; == X' cos(y) + Z sin(y) == X''  D5
		lsr.l	#8,d5	; Rotation about Y axis complete.

		move.w	d6,d0		; Y'
		muls	2(a4),d6	;    * cos(x)
		move.w	d7,d1		; Z'
		muls	(a4),d1		;    * sin(z)
		sub.l	d1,d6		; == Y' cos(x) - Z' sin(x) == Y'' D6
		lsr.l	#8,d6
		muls	(a4),d0		; Y' * sin(x)
		muls	2(a4),d7	; Z' * cos(x)
		add.l	d0,d7		; == Y' sin(x) + Z' cos(x) == Z'' D7
		lsr.l	#8,d7	; Rotation about X axis complete.

* Before I got to this, the perspective formula was:
*
*	 1000 - Z
*	----------
*	  780 - Z
*
* I ran this through a spreadsheet (Thanks, Mike!) and found that, yes, it
* does yield a hyperbolic curve (which is correct).  However, it was so
* alien that I decided to re-work it into a more traditional form found in
* most of my graphics books.  The scalar is now:
*
*	    MAGIC
*	-------------
*	- (Z - ZPULL)
*
* This is closer to what you'll find in the graphics books.  The subtraction
* from Z is to "pull" the stars away from the camera (which is at Z == 0) so
* that they'll be visible.  The negation effectively flips the Z axis, which
* makes the calculation easier (trust me).  MAGIC and ZPULL are currently
* set to 256 and 780 respectively.  The 256 is a number I pulled out of
* Thin Air.  (So's the 780, for that matter...)  Feel free to play with them
* to see what happens.
*
		move.w	d7,$258(a3)	; ZBuff store (for pixel brightness)

		move.l	d2,d0		; 256 (pre-formatted)
		move.w	d3,d1		; 780
		sub.w	d7,d1		;     - Z
		ble.s	BehindCamera
		divs	d1,d0		; == 256 / -(Z - 780)
		bvs.s	BehindCamera	; Shunt wild division

		move.w	d6,d1		; Y
		muls	d0,d1		;    * 256 / -(Z - 780)
		lsr.l	#8,d1
		add.w	#115,d1		; + center_screen_y
		move.w	d1,$12C(a3)	; YBuff store

		move.w	d5,d1		; X
		muls	d0,d1		;    * 256 / -(Z - 780)
		lsr.l	#8,d1
		add.w	#176,d1		; + center_screen_x
		move.w	d1,(a3)+	; XBuff store
		dbra	d4,NextStar

		rts

	;------	Whoops!  Behind the camera.  Force an invisible point.
BehindCamera	moveq	#-1,d1
		move.w	d1,$12C(a3)	; YBuff store
		move.w	d1,(a3)+	; XBuff store
		dbra	d4,NextStar

		rts


****************************************************************************
* Sine/Cosine calculator.  Nothing amazing here, just a table lookup.
* D0: Angle (360 deg. == 1600)
* D0 is used directly as offset into sine table; MUST be even, lest Bad
* Things happen.
*
* Returns sine in D0, cosine in D1.
*
SinCos		lea	SineTable(pc),a5
		move.w	d0,d2
		move.w	0(a5,d0.w),d0	; Fetch sine
		cmp.w	#2048-512,d2
		ble.s	1$
		sub.w	#2048-512,d2
		bra.s	2$

1$		add.w	#512,d2
2$		move.w	0(a5,d2.w),d1	; Fetch cosine
		rts


****************************************************************************
* Add spins to current rotation angles.  Clip to 360° circle.
*
AddSpins	move.w	#2048-1,d1	; 360° == 2048 EHG
		lea	theta_x(pc),a0
		lea	spin_x(pc),a1

		move.w	(a0),d0		; Get angle
		add.w	(a1)+,d0	; Add spin
		and.w	d1,d0		; Clip to 360°
		move.w	d0,(a0)+	; Store it back

		move.w	(a0),d0
		add.w	(a1)+,d0
		and.w	d1,d0
		move.w	d0,(a0)+

		move.w	(a0),d0
		add.w	(a1),d0
		and.w	d1,d0
		move.w	d0,(a0)

		rts



****************************************************************************
* New ParseArgs.  More flexible!  Less filling!
* Added 9202.20		Finished 9205.09
*
*	A0:  Argument string.
*
*	As the options are parsed, the destination address of the value is
*	pushed on a queue.  As values are acquired, the address is pulled,
*	and the value stored there.  Imbalances are checked and reported.
*
* SYNOPSIS
*	[MRS][XYZ] <value> [ <value> ... ]
*
*	Only one M, R, or S qualifier may accompany XYZ specifiers.  They
*	may be specified in any order, and the values need not immediately
*	follow them.
*
* OPTIONS
*	M: Move; specify translation
*	R: Rotate; specify initial rotation
*	S: Spin; specify spin velocities
*

ParseArgs	movem.l	d2/d7/a2-a5,-(sp)
		sub.l	a3,a3		; Mode (NULL)
		move.l	sp,a4		; Stacksave
		move.l	sp,a5		; Pop pointer

	;------	Copy active variables to workspace.
		lea	delta_x(pc),a1
		lea	wrk_delta(pc),a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.w	(a1),(a2)

	;------	Main parsing loop.
getchar		moveq	#0,d0
		move.b	(a0)+,d0	; getchar()
		beq	EndOfString
		cmp.b	#'a',d0		; Lower case?
		blo.s	0$
		sub.b	#'a'-'A',d0	; Convert to upper case
0$
	;------	Test for whitespace.
		cmp.b	#' ',d0
		beq.s	whitespace
		cmp.b	#9,d0		; TAB
		beq.s	whitespace
		cmp.b	#10,d0		; Newline
		beq.s	whitespace

	;------	Test for numeric.
		cmp.b	#'-',d0		; Leading minus
		beq.s	numeric
		cmp.b	#'0',d0
		blo.s	3$
		cmp.b	#'9',d0
		bls.s	numeric
3$
	;------	Test for [B]ackground command.
		cmp.b	#'B',d0
		bne.s	1$
		move.w	d0,BackServ	; All it has to be is non-zero
		bra	UnWindOK	; Ignore rest of string
1$
	;------	Test for [Q]uit command.
		cmp.b	#'Q',d0
		bne.s	2$
		moveq	#-1,d0		; Tell upstairs we need to quit
		bra	UnWind		; Ignore rest of string
2$
	;------	Test for '?' help.
		moveq	#ERR_HELP,d7
		cmp.b	#'?',d0
		beq	ParseError

	;------	Test for 'XYZ'.
		cmp.b	#'X',d0
		blo.s	4$
		cmp.b	#'Z',d0
		bls.s	GotXYZ
4$
	;------	Test for 'MRS'; set mode if present.
		cmp.b	#'M',d0
		bne.s	11$
		lea	wrk_delta(pc),a3	; Set mode
		bra.s	getchar
11$
		cmp.b	#'R',d0
		bne.s	22$
		lea	wrk_theta(pc),a3	; Set mode
		bra.s	getchar
22$
		cmp.b	#'S',d0
		bne	33$
		lea	wrk_spin(pc),a3		; Set mode
		bra	getchar
33$
	;------	Dunno what this is; error.
		moveq	#ERR_SYNTAX,d7
		bra	ParseError


	;------	Process whitespace.
whitespace	sub.l	a3,a3		; NULL out mode
		bra	getchar


	;------	Process numerics.
numeric		subq.w	#1,a0		; ungetchar()
		bsr.s	GatherNum	; Parsed value returned in D0

		moveq	#ERR_EXTRAVAL,d7
		cmpa.l	sp,a5		; Are there values yet to be poked?
		beq	ParseError	; Nope, too many values.
		move.l	-(a5),a1	; Get address to poke
		move.w	d0,(a1)		; Write value.

		bra	getchar


	;------	Process presence of 'XYZ'.
GotXYZ		moveq	#ERR_NOMODE,d7
		move.l	a3,d1		; Mode set?
		beq	ParseError	; No, user forgot MRS qualifier

		sub.b	#'X',d0		; Compute index
		add.w	d0,d0		; Compute word offset
		add.l	a3,d0		; Add "mode" to get final address
		move.l	d0,-(sp)	; Push address
		bra	getchar


	;------	End of string; perform sanity checks and return.
EndOfString	moveq	#ERR_MISSINGVAL,d7
		cmpa.l	sp,a5		; Is stack empty?
		bne.s	ParseError

	;------	Force angles and rotations to even values.
		moveq	#-2,d0		; 0xFFFE
		bclr	#16,d0		; Low bit in both word halves clear
		lea	wrk_theta(pc),a0
		and.l	d0,(a0)+	; Zot, zot, zot...
		and.l	d0,(a0)+
		and.l	d0,(a0)+

	;------	Copy new values to active variables.
		lea	wrk_delta(pc),a0
		lea	delta_x(pc),a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0),(a1)

UnWindOK	moveq	#0,d0		; No error
UnWind		move.l	a4,sp		; Restore stack pointer
		movem.l	(sp)+,d2/d7/a2-a5
		rts			; Back to you, Brian...


****************
* Gather decimal number.
*
GatherNum	moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2		; negative flag

	;------	Gather chars.  Test for whitespace first.
numloop		move.b	(a0)+,d1
		beq.s	11$		; NULL; EOL
		cmp.b	#' ',d1
		beq.s	11$
		cmp.b	#9,d1		; TAB
		beq.s	11$
		cmp.b	#10,d1		; Newline
		beq.s	11$

	;------	Check for unary minus.
		cmp.b	#'-',d1
		beq.s	22$

	;------	Check for numeric.
		moveq	#ERR_BADVAL,d7
		cmp.b	#'0',d1
		blo.s	ParseError
		cmp.b	#'9',d1
		bhi.s	ParseError

	;------	Accumulate numeric digit.  Overflow not tested.
		mulu	#10,d0
		sub.b	#'0',d1
		add.w	d1,d0
		bra.s	numloop

	;------	Flip sense of minus sign.  We don't check for multiple
	;------	instances.
22$		not.b	d2
		bra.s	numloop

	;------	Whitespace encountered; return to parser for storage.
11$		tst.b	d2		; This number negative?
		beq.s	110$
		neg.w	d0		; Yep, turn it over.
110$
		rts


****************
* Short routine to report parsing errors
*
ParseError	move.l	ErrStrs(pc,d7.w),d0	; Pointer to error string.
		bra.s	UnWind


ErrStrs		dc.l	SyntaxErr,BadVal,ModeMissing,MissingVal
		dc.l	ExtraVal,HelpStr

ERR_SYNTAX	EQU	0
ERR_BADVAL	EQU	4
ERR_NOMODE	EQU	8
ERR_MISSINGVAL	EQU	12
ERR_EXTRAVAL	EQU	16
ERR_HELP	EQU	20


****************************************************************************
* Print string to CLI.  Pointer to string in D0.
*
PrintCLIStr	movem.l	d2/d3/a2/a6,-(sp)
		move.l	d0,a2		; Save string pointer.
		move.l	DOSBase(pc),a6
		jsrlib	Output		; Somewhere to print?
		move.l	d0,d1
		beq.s	99$		; No, forget it

		move.l	a2,d2		; Compute string length
0$		tst.b	(a2)+
		bne.s	0$
		suba.l	d2,a2
		move.l	a2,d3
		subq.l	#1,d3
		jsrlib	Write		; Write string
99$
		movem.l	(sp)+,d2/d3/a2/a6
		rts


****************************************************************************
* Bottom-of-frame interrupt routine.
*
BOFintr		moveq	#0,d0
		bset.l	#SIGBREAKB_CTRL_F,d0	; F stands for Frame
		move.l	(4).w,a6
		jsrlib	Signal			; Task ptr already in A1

		moveq	#0,d0
		rts


****************************************************************************
* Something I added to make things more reliable.
*
ClearBSS	move.l	#EndBSS,d2
		lea	StartBSS,a2
		sub.l	a2,d2
		subq.w	#1,d2
1$		clr.b	(a2)+
		dbra	d2,1$

		rts


****************************************************************************
* Data!  (Yes, Captain?)
*
NumStars	dc.w	68

delta_x		dc.w	0	; Star movement
delta_y		dc.w	0
delta_z		dc.w	4
theta_x		dc.w	0	; Initial/current rotation angles
theta_y		dc.w	0
theta_z		dc.w	0
spin_x		dc.w	0	; Spin velocities
spin_y		dc.w	0
spin_z		dc.w	0

wrk_delta	dc.w	0,0,0	; Working areas for the parser
wrk_theta	dc.w	0,0,0
wrk_spin	dc.w	0,0,0

CurrentSinCos	dc.w	0	; theta_x
		dc.w	0
		dc.w	0	; theta_y
		dc.w	0
		dc.w	0	; theta_z
		dc.w	0
IBase		dc.l	0
GBase		dc.l	0
DOSBase		dc.l	0
winptr		dc.l	0
Plane1ptr	dc.l	0
Plane2ptr	dc.l	0
sprdat		dc.l	0
WBStartMsg	dc.l	0
StarMsg		dc.l	0
StarSigMask	dc.l	0
StarSigs	dc.l	0
BackServ	dc.w	0

XCoords		dc.w	$FF37,$FED2,$6A,$FFF7,$C8,$CD,$FFF9,$132,$FF35
		dc.w	$FF9A,$FF7F,$16B,$EC,$FFF7,$186,$FF5A,$FF0D,$177
		dc.w	$FEAF,$6F,$FF5F,$FF22,$150,$2B,$FED5,$FEE3,$90,$AA
		dc.w	$FEBE,$13A,$12D,$FFA4,$FF49,$FEEE,$41,$164,$FF09
		dc.w	$8A,$FFE3,$D2,$FEBE,$13A,$12D,$FFA4,$FF49,$FEEE,$41
		dc.w	$164,$FF09,$8A,$FF46,$FF85,$154,$FF19,$60,$FF5C,$9B
		dc.w	$FFA8,$FF18,$158,$AE,$FF2F,$FE72,$21,$8C,$FE8B,$CF
		dc.w	$48,$FF7A,$137,$C8,$FED4
YCoords		dc.w	$FF5F,$FF22,$150,$2B,$FED5,$FEE3,$90,$AA,$FEBE,$13A
		dc.w	$12D,$FFA4,$FF49,$FEEE,$41,$164,$FF09,$8A,$FFE3,$D2
		dc.w	$FF37,$FED2,$6A,$FFF7,$C8,$CD,$FFF9,$132,$FF35
		dc.w	$FF9A,$FF7F,$16B,$EC,$FFF7,$186,$FF5A,$FF0D,$177
		dc.w	$FEAF,$6F,$177,$FEAF,$6F,$FF5F,$FF22,$150,$2B,$FED5
		dc.w	$FEE3,$90,$164,$FF09,$8A,$FFE3,$FF52,$FF2F,$18E,$21
		dc.w	$FF74,$FE8B,$CF,$FFB8,$86,$FEC9,$D2,$FF22,$94,$14D
		dc.w	$FE9B,$F4,$C8,$12C
ZCoords		dc.w	$FF52,$FF2F,$FE72,$21,$8C,$175,$FF31,$FFB8,$FF7A
		dc.w	$137,11,$153,$FF22,$94,$14D,$FE9B,$F4,$FEEC,$9B
		dc.w	$FF46,$FF85,$154,$FF19,$60,$FF5C,$9B,$FFA8,$FF18
		dc.w	$158,$FF61,$FE8F,$F8,$FEE7,$8C,$FF85,$48,$FEAC
		dc.w	$FF17,$6A,$13B,$FF01,$FF3A,$FFF9,7,$BE,$12B,$FED1
		dc.w	$FE94,$FC,$FF91,$CD,$FFF9,$132,$FF35,$FF9A,$FF7F
		dc.w	$16B,$EC,$FFF7,$186,$FED2,$6A,$FFF7,$C8,$CD,$FFF9
		dc.w	$132,$FF35,$FF9A,$FF7F,$96,$FF06


SineTable	dc.w	0,2,3,5,6,8,9,11
		dc.w	13,14,16,17,19,20,22,24
		dc.w	25,27,28,30,31,33,34,36
		dc.w	38,39,41,42,44,45,47,48
		dc.w	50,51,53,55,56,58,59,61
		dc.w	62,64,65,67,68,70,71,73
		dc.w	74,76,77,79,80,82,83,85
		dc.w	86,88,89,91,92,94,95,97
		dc.w	98,99,101,102,104,105,107,108
		dc.w	109,111,112,114,115,117,118,119
		dc.w	121,122,123,125,126,128,129,130
		dc.w	132,133,134,136,137,138,140,141
		dc.w	142,144,145,146,147,149,150,151
		dc.w	152,154,155,156,157,159,160,161
		dc.w	162,164,165,166,167,168,170,171
		dc.w	172,173,174,175,177,178,179,180
		dc.w	181,182,183,184,185,186,188,189
		dc.w	190,191,192,193,194,195,196,197
		dc.w	198,199,200,201,202,203,204,205
		dc.w	206,207,207,208,209,210,211,212
		dc.w	213,214,215,215,216,217,218,219
		dc.w	220,220,221,222,223,224,224,225
		dc.w	226,227,227,228,229,229,230,231
		dc.w	231,232,233,233,234,235,235,236
		dc.w	237,237,238,238,239,239,240,241
		dc.w	241,242,242,243,243,244,244,245
		dc.w	245,245,246,246,247,247,248,248
		dc.w	248,249,249,249,250,250,250,251
		dc.w	251,251,252,252,252,252,253,253
		dc.w	253,253,254,254,254,254,254,255
		dc.w	255,255,255,255,255,255,256,256
		dc.w	256,256,256,256,256,256,256,256
		dc.w	256,256,256,256,256,256,256,256
		dc.w	256,256,256,255,255,255,255,255
		dc.w	255,255,254,254,254,254,254,253
		dc.w	253,253,253,252,252,252,252,251
		dc.w	251,251,250,250,250,249,249,249
		dc.w	248,248,248,247,247,246,246,245
		dc.w	245,245,244,244,243,243,242,242
		dc.w	241,241,240,239,239,238,238,237
		dc.w	237,236,235,235,234,233,233,232
		dc.w	231,231,230,229,229,228,227,227
		dc.w	226,225,224,224,223,222,221,220
		dc.w	220,219,218,217,216,215,215,214
		dc.w	213,212,211,210,209,208,207,207
		dc.w	206,205,204,203,202,201,200,199
		dc.w	198,197,196,195,194,193,192,191
		dc.w	190,189,188,186,185,184,183,182
		dc.w	181,180,179,178,177,175,174,173
		dc.w	172,171,170,168,167,166,165,164
		dc.w	162,161,160,159,157,156,155,154
		dc.w	152,151,150,149,147,146,145,144
		dc.w	142,141,140,138,137,136,134,133
		dc.w	132,130,129,128,126,125,123,122
		dc.w	121,119,118,117,115,114,112,111
		dc.w	109,108,107,105,104,102,101,99
		dc.w	98,97,95,94,92,91,89,88
		dc.w	86,85,83,82,80,79,77,76
		dc.w	74,73,71,70,68,67,65,64
		dc.w	62,61,59,58,56,55,53,51
		dc.w	50,48,47,45,44,42,41,39
		dc.w	38,36,34,33,31,30,28,27
		dc.w	25,24,22,20,19,17,16,14
		dc.w	13,11,9,8,6,5,3,2
		dc.w	0,-2,-3,-5,-6,-8,-9,-11
		dc.w	-13,-14,-16,-17,-19,-20,-22,-24
		dc.w	-25,-27,-28,-30,-31,-33,-34,-36
		dc.w	-38,-39,-41,-42,-44,-45,-47,-48
		dc.w	-50,-51,-53,-55,-56,-58,-59,-61
		dc.w	-62,-64,-65,-67,-68,-70,-71,-73
		dc.w	-74,-76,-77,-79,-80,-82,-83,-85
		dc.w	-86,-88,-89,-91,-92,-94,-95,-97
		dc.w	-98,-99,-101,-102,-104,-105,-107,-108
		dc.w	-109,-111,-112,-114,-115,-117,-118,-119
		dc.w	-121,-122,-123,-125,-126,-128,-129,-130
		dc.w	-132,-133,-134,-136,-137,-138,-140,-141
		dc.w	-142,-144,-145,-146,-147,-149,-150,-151
		dc.w	-152,-154,-155,-156,-157,-159,-160,-161
		dc.w	-162,-164,-165,-166,-167,-168,-170,-171
		dc.w	-172,-173,-174,-175,-177,-178,-179,-180
		dc.w	-181,-182,-183,-184,-185,-186,-188,-189
		dc.w	-190,-191,-192,-193,-194,-195,-196,-197
		dc.w	-198,-199,-200,-201,-202,-203,-204,-205
		dc.w	-206,-207,-207,-208,-209,-210,-211,-212
		dc.w	-213,-214,-215,-215,-216,-217,-218,-219
		dc.w	-220,-220,-221,-222,-223,-224,-224,-225
		dc.w	-226,-227,-227,-228,-229,-229,-230,-231
		dc.w	-231,-232,-233,-233,-234,-235,-235,-236
		dc.w	-237,-237,-238,-238,-239,-239,-240,-241
		dc.w	-241,-242,-242,-243,-243,-244,-244,-245
		dc.w	-245,-245,-246,-246,-247,-247,-248,-248
		dc.w	-248,-249,-249,-249,-250,-250,-250,-251
		dc.w	-251,-251,-252,-252,-252,-252,-253,-253
		dc.w	-253,-253,-254,-254,-254,-254,-254,-255
		dc.w	-255,-255,-255,-255,-255,-255,-256,-256
		dc.w	-256,-256,-256,-256,-256,-256,-256,-256
		dc.w	-256,-256,-256,-256,-256,-256,-256,-256
		dc.w	-256,-256,-256,-255,-255,-255,-255,-255
		dc.w	-255,-255,-254,-254,-254,-254,-254,-253
		dc.w	-253,-253,-253,-252,-252,-252,-252,-251
		dc.w	-251,-251,-250,-250,-250,-249,-249,-249
		dc.w	-248,-248,-248,-247,-247,-246,-246,-245
		dc.w	-245,-245,-244,-244,-243,-243,-242,-242
		dc.w	-241,-241,-240,-239,-239,-238,-238,-237
		dc.w	-237,-236,-235,-235,-234,-233,-233,-232
		dc.w	-231,-231,-230,-229,-229,-228,-227,-227
		dc.w	-226,-225,-224,-224,-223,-222,-221,-220
		dc.w	-220,-219,-218,-217,-216,-215,-215,-214
		dc.w	-213,-212,-211,-210,-209,-208,-207,-207
		dc.w	-206,-205,-204,-203,-202,-201,-200,-199
		dc.w	-198,-197,-196,-195,-194,-193,-192,-191
		dc.w	-190,-189,-188,-186,-185,-184,-183,-182
		dc.w	-181,-180,-179,-178,-177,-175,-174,-173
		dc.w	-172,-171,-170,-168,-167,-166,-165,-164
		dc.w	-162,-161,-160,-159,-157,-156,-155,-154
		dc.w	-152,-151,-150,-149,-147,-146,-145,-144
		dc.w	-142,-141,-140,-138,-137,-136,-134,-133
		dc.w	-132,-130,-129,-128,-126,-125,-123,-122
		dc.w	-121,-119,-118,-117,-115,-114,-112,-111
		dc.w	-109,-108,-107,-105,-104,-102,-101,-99
		dc.w	-98,-97,-95,-94,-92,-91,-89,-88
		dc.w	-86,-85,-83,-82,-80,-79,-77,-76
		dc.w	-74,-73,-71,-70,-68,-67,-65,-64
		dc.w	-62,-61,-59,-58,-56,-55,-53,-51
		dc.w	-50,-48,-47,-45,-44,-42,-41,-39
		dc.w	-38,-36,-34,-33,-31,-30,-28,-27
		dc.w	-25,-24,-22,-20,-19,-17,-16,-14
		dc.w	-13,-11,-9,-8,-6,-5,-3,-2


colors		dc.w	0,$336,$669,$CCF

GfxName		dc.b	'graphics.library',0
IntuiName	dc.b	'intuition.library',0
DOSName		dc.b	'dos.library',0
ESName		dc.b	'EuroStars',0
ESPortName	dc.b	'EUROSTARS',0	; ARexx wants uppercase.  Sigh...


****************
* Error strings
*
SyntaxErr	dc.b	"Syntax error.",10,0
BadVal		dc.b	"Bad value.",10,0
ModeMissing	dc.b	"Must specify M, R, or S before XYZ.",10,0
MissingVal	dc.b	"Expecting more values.",10,0
ExtraVal	dc.b	"Unexpected extra value.",10,0
		dc.b	"$VER: "
HelpStr		dc.b	"ES 1.0 (12.5.92) -- EuroStars",10
		dc.b	"Written by Leo L. Schwab.",10,10
		dc.b	"Usage:",10
		dc.b	9,"ES [MRS][XYZ] <value> [<value> ... ]",10
		dc.b	9,"ES B",9,"; Run as background server",10
		dc.b	9,"ES Q",9,"; Quit (ARexx only)",10,10
		dc.b	"ARexx port name is EUROSTARS.",10,0


****************
* Static structure definitions.
*
		cnop	0,4

	;------	NewScreen
scr_def		dc.w	0,0
		dc.w	352,230
		dc.w	2
		dc.b	0,1
		dc.w	0
		dc.w	CUSTOMSCREEN!SCREENQUIET
		dc.l	0
		dc.l	ESName
		dc.l	0
		dc.l	0

	;------	NewWindow
windef		dc.w	0,0
		dc.w	352,230
		dc.b	-1,-1
		dc.l	MOUSEBUTTONS
		dc.l	SMART_REFRESH!BACKDROP!BORDERLESS!ACTIVATE
		dc.l	0
		dc.l	0
		dc.l	0
scrptr		dc.l	0
		dc.l	0
		dc.w	0,0,0,0
		dc.w	CUSTOMSCREEN

	;------	MessagePort
mport		dc.l	0,0		; LN_SUCC, LN_PRED
		dc.b	NT_MSGPORT	; LN_TYPE
		dc.b	0		; LN_PRI
		dc.l	ESPortName	; LN_NAME
		dc.b	PA_SIGNAL	; MP_FLAGS
mpsigbit	dc.b	-1		; MP_SIGBIT
mpsigtask	dc.l	0		; MP_SIGTASK
		ds.b	LH_SIZE		; MP_MSGLIST,LH_SIZE

	;------	Startup Message
startmsg	dc.l	0,0		; LN_SUCC, LN_PRED
		dc.b	NT_MESSAGE	; LN_TYPE
		dc.b	0		; LN_PRI
		dc.l	ESName		; LN_NAME
		dc.l	mport		; MN_REPLYPORT
		dc.w	MN_SIZE		; MN_LENGTH

	;------	Interrupt structure
BOFintrnode	dc.l	0,0		; LN_SUCC, LN_PRED
		dc.b	NT_INTERRUPT	; LN_TYPE
		dc.b	0		; LN_PRI
		dc.l	ESName		; LN_NAME
StarTask	dc.l	0		; IS_DATA
		dc.l	BOFintr		; IS_CODE


****************************************************************************
* Uninitialized data
*
		SECTION EuroStars,BSS
StartBSS:

MyCopList	ds.b	ucl_SIZEOF
XBuff		ds.w	150
YBuff		ds.w	150
ZBuff		ds.w	150
PlaneOffsets	ds.w	150

EndBSS:
		END

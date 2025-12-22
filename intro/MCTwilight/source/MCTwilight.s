;***************************************************************************
; SINE SCROLL LO-RES Coded by SLAINE of Outlanders
;*************************************************************************** 
;
; Shitty Starfield, Tracker incorporation, and Speed Variable
; All Additionals Coded by MC.
;
; Sit on it CAB !!!
;
;***************************************************************************
; Force All Code And Graphics To Chip Memory.
;***************************************************************************
	SECTION Demo,code_c		; Code & Gfx To Chip Mem

;***************************************************************************
; Disable All Mutitasking.
;***************************************************************************
	move.l	ExecBase,a6		; Exebase.
	jsr	Forbid(a6)		; Forbid() Turn Off Multitasking.

	bsr	Initialise		; Setup

;***************************************************************************
; Store WBCopper & Install NewCopper.
;***************************************************************************
	move.l	ExecBase,a0		; Execbase.
	move.l	$9c(a0),a1		; Find WBCopper Addr.
	move.l	$32(a1),WBcopper	; Store WBcopper.
	move.l	#MYcopper,$32(a1)	; Install New Copper Addr.

;***************************************************************************
; Enable Level 3 Interupt.  Store Old & Insert New Interupt Address.
;***************************************************************************
	move.w #$8010,intena		; Enable Lev3 Copper Interupt.
	move.l $6c.w,OldLev3		; Store Old Interrupt Address.
	move.l #NewLev3,$6c.w		; Install New Interrupt Address.

;***************************************************************************
; Branch To TestMouse While Interupt Does Its Job At 50 Frames A Second.
;***************************************************************************
	bra	TestMouse		; Branch

;***************************************************************************
; The Heart Of The Demo! The Interupt Routine.(Simple Yet Effective).
;***************************************************************************
NewLev3:movem.l d0-d7/a0-a6,-(a7)	; Store Registers
	and.w	#$10,intreqr		; Check If Copper Interupt.
	beq.s	XLev3			; If Not Exit.
	move.w	#$10,intreq		; Clear Request Bit.

;***************************************************************************
; Interupt Routine Goes In Here.
;******************************************************Õ********************

	bsr	ClearScreen
	bsr	GetChar		; Get, Print Char
	bsr	ScrollText	; Scroll Chars
	bsr	CalcSine
	bsr	ShowText	; Show Scroll
	bsr	SwapPointers
	bsr	StarMain

	bsr 	mt_music
;***************************************************************************
; Restore Registers And Exit Interupt.(Jump To Old Lev 3).
;***************************************************************************
XLev3:	movem.l	(a7)+,d0-d7/a0-a6	; Restore Registers.
	dc.w	$4ef9			; Jump To Old Lev 3.
OldLev3:dc.l	0			; Store For Old Lev 3.

;***************************************************************************
; Meanwhile The Mouse Is Waiting For Something to Happen.
;***************************************************************************
TestMouse:
	btst	#6,$bfe001		; Check for left mouse button.
	bne.s	TestMouse		; Loop until pressed.

;***************************************************************************
; Mouse Button Pressed! So Put Old Lev 3 Back & Disable Copper Interupt.
;***************************************************************************
	move.l	OldLev3,$6c.w		; Install Old Interrupt.
	move.w	#$10,intena		; Disable Copper Int.

;***************************************************************************
; Switch off Audio DMA & Clear Audio Data Channels. Turn Filter On.
;***************************************************************************
	bsr	mt_end
	bclr	#1,$bfe001	


;***************************************************************************
; Install WorkBench Copper Address.
;***************************************************************************
	move.l	ExecBase,a0
	move.l	$9c(a0),a1		; Fast And Dirty
	move.l	WBcopper,$32(a1)

;***************************************************************************
; Turn Multitasking Back On And Clear D0 Before Exit To Dos.
;***************************************************************************
	move.w	#$8020,dmacon		; Turn On sprite DMA

	move.l	ExecBase,a6		; ExecBase.
	jsr	Permit(a6)		; Permit() - Turn on multitasking.
	moveq	#0,d0
	rts				; Return to AmigaDOS

;***************************************************************************
; Init BPlanes, DMA & MYcopper 
;***************************************************************************
Initialise:

        bsr 	mt_init
        bset	#1,$bfe001

	move.w	#$8780,dmacon		; Copper & Blitter DMA on
	move.w	#$0020,dmacon		; Turn off sprite DMA
	lea	spr0data,a0
	moveq	#7,d0
ClrSpr:	clr.l	(a0)
	addq.l	#8,a0
	dbf	d0,ClrSpr

	lea	Screen1,a0		; Plane 1 Addr.
	move.l	a0,d0
	lea	CopBP1ptr,a1		; Copper Pointer.
	move.w	d0,6(a1)		; Hi Word.
	swap	d0
	move.w	d0,2(a1)		; Lo Word.

	swap	d0
	move.l	a0,d0
	lea	CopBP2ptr,a1		; Copper Pointer.
	move.w	d0,6(a1)		; Hi Word.
	swap	d0
	move.w	d0,2(a1)		; Lo Word.

;	bsr	mt_init
;	bset	#1,$bfe001

	rts

;***************************************************************************
; Demo Routines Start Here!. Call These From The Interupt.
;***************************************************************************
*** GET AND PRINT TEXT ***
GetChar:
	tst.b	Pause_ctr	; Check Pause Counter
	beq.s	NoPause		; Branch If Zero
	subq.b	#1,Pause_ctr	; Sub 1 If Not Zero
	rts
PauseSet:
	move.b	#255,Pause_ctr	; Set Pause Counter
	addq.l	#1,Text_ptr	; Skip Pause Byte In Text
	move.b	#1,Scroll_flg	; Set For No Scroll
	rts
NoPrint:
	subq.b	#1,Print_ctr	; Sub 1 From Print Counter
	rts
NoPause:
	tst.b	Print_ctr	; Time To Print?
	bne.s	NoPrint		; Branch If Not Zero
	move.b	#speedvar1,Print_ctr	; Update For Next Run
	move.b	#0,Scroll_flg	; Set For Scroll
	move.l	Text_ptr,a0	; Get Text Position
	tst.b	(a0)		; Test For Pause
	beq.s	PauseSet	; Branch If Null Byte
	cmp.b	#$ff,(a0)	; Text End?
	bne.s	NotTextEnd	; No
	lea	Text,a0		; Yes, Get Table Start
NotTextEnd:
	move.b	(a0)+,d0	; Get Char
	move.l	a0,Text_ptr	; Update Pointer

	sub.b	#32,d0		; Get Char No.
	lsl.w	#5,d0		; Multiply By No. Lines Per Char
	lea	Font,a0		; Get Font
	lea	(a0,d0),a0	; Get Correct Character
	lea	Buffer+40,a1	; Get Print Buffer
	moveq	#15,d0		; No. Lines To Print -1.
Print_lp:
	move.w	(a0)+,(a1)	; Print 1 Line
	add.l	#42,a1		; Next Print Line
	dbf	d0,Print_lp	; Loop Till All Lines Printed
	rts

*** BUFFER SCROLL ***
ScrollText:
	tst.b	Scroll_flg		; Do A Scroll?
	beq.s	Scroll			; If Zero Scroll
	rts				; If Not Zero Exit
Scroll:	btst	#14,dmaconr		; Test Busy Bit
	bne.s	Scroll
	lea	Buffer,a0		; Source
	lea	Buffer-2,a1		; Destination
	move.l	a0,bltapth		; CH.A Source
	move.l	a1,bltdpth		; CH.D Dest
	move.l	#$0fffffff,bltafwm	; No Masking
	clr.l	bltamod			; No Modulo



;MC's SPEED MOD.

	move.w #%0000100100000000!$f0,d0
	moveq #speed,d1
	neg.w d1
	moveq #12,d2
	lsl.w d2,d1			;Work out speed (shift!)
	or.w d1,d0
	move.w d0,bltcon0		;D=A Minterm

;END SPEED


;	move.l	#$e9f00000,bltcon0	; Barrel Shift & Minterm (D=A)
	move.w	#17*64+21,bltsize	; Size And Blit
	rts

*** SINE SCROLL ***	
ShowText:
	lea	Ys1,a0
	lea	Buffer,a1		; Source
	move.l	Scr_ptr,a2		; Dest
;	add.l	#38,a2
; These Only Have To Be Set Once
	move.w	#40,bltamod		; Skip Line In Buffer
	move.w	#38,bltbmod		; Skip Line In Screen
	move.w	#38,bltdmod		; Same
	move.l	#$dfc0000,bltcon0	; Set Minterm D=A+B
	move.w	#$ffff,bltafwm

	moveq	#19,d2			; Screen Width In Words -1.
Sine_lp1:
	move.w	#%1100000000000000,d1		; Mask In D1
	moveq	#7,d3			; No. Bytes Per Char -1
Sine_lp2:
	btst	#14,dmaconr		; Test Busy Bit
	bne.s	Sine_lp2

	move.w	(a0)+,d0
	mulu	#40,d0

	lea	(a2,d0),a3		; Dest + Sine Val

	move.l	a1,bltapth		; CH.A Source
	move.l	a3,bltbpth		; Ch.B Dest+Mask
	move.l	a3,bltdpth		; Ch.D Dest
	move.w	d1,bltalwm		; Mask Value
	move.w	#16*64+1,bltsize

	ror.w	#2,d1			; Move Mask
	dbf	d3,Sine_lp2
	addq.l	#2,a1
	addq.l	#2,a2
	dbf	d2,Sine_lp1
	rts

;*** CLEAR SCREEN ***
ClearScreen:
	btst	#14,dmaconr		; Test Busy Bit
	bne.s	ClearScreen
	move.l	Scr_ptr,a0
	move.l	a0,bltdpth
	move.l	#$ffffffff,bltafwm
	clr.w	bltdmod
	move.l	#$1000000,bltcon0
	move.w	#116*64+20,bltsize

	lea	8040(a0),a0
	movem.l	d0-7/a0-6,-(a7)
	movem.l	Blank,d0-7/a1-6
	rept	61
	movem.l	d0-7/a1-6,-(a0)
	endr
	movem.l	(a7)+,d0-7/a0-6
	rts

Blank:	dcb.l	14
Store:	dcb.l	0

SwapPointers:
	tst.b	AddSub_flg
	bne.s	AddPointers
	lea	Screen1,a0
	move.l	a0,Scr_ptr
	lea	Screen1,a0
	move.l	a0,d0
	Lea	CopBP1ptr,a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	Lea	CopBP2ptr,a0
	swap d0
	add.l	#40,d0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	eor.b	#1,AddSub_flg
	rts
AddPointers:
	lea	Screen1,a0
	move.l	a0,Scr_ptr
	lea	Screen1,a0
	move.l	a0,d0
	Lea	CopBP1ptr,a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	Lea	CopBP2ptr,a0
	swap d0
	add.l	#40,d0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	eor.b	#1,AddSub_flg
	rts

;*** CALC NEXT SINE POSITION ***
CalcSine:
	Lea	Sintable(pc),a0
	lea	Ys1,a4

	Move	Y_pt1,d0
	Add	Y_vel1,d0
	And	#510,d0
	Move	d0,Y_pt1
	Move	Y_pt2,d1
	Add	Y_vel2,d1
	And	#510,d1
	Move	d1,Y_pt2
	Move.w	#159,d7	; No Bobs -1 to Calc Pos On
CalcLoop:
	Move	(a0,d0),d5
	Move	(a0,d1),d6
	Asr	d5
	Asr	d6
	Add	d5,d6
	Muls	#(200-Length),d6
	Swap	d6
	Add	#(100-Length/2),d6
	Move	d6,(a4)+

	Add	Y_add1,d0
	And	#$1fe,d0
	Add	Y_add2,d1
	And	#$1fe,d1
	dbf	d7,CalcLoop
	Rts


*** GET STAR POSITIONS FAR A RANDOM START ***
	LEA	XYD_tab,A0		; Get X, Y, D Table
	MOVEQ	#NoStars-1,D1		; Number Of Stars
Set_lp:	BSR	RandXY			; Get X
	MOVE.W	D0,(A0)+		; Store X
	BSR	RandXY			; Get Y
	MOVE.W	D0,(A0)+		; Store Y
	BSR	RandXY			; Get D = Divisor
	AND.W	#$1FF,D0
	MOVE.W	D0,(A0)+		; Store D
	DBF	D1,Set_lp

	rts



; A BIT of Cuting & Pasting and Hey Presto...
; A starfield is born !!!



*** STAR ROUTINE ***
;	A0 = X, Y, D UNCONVERTED POSITION TABLE. ( 3 WORDS )
;	A1 = LAST CONVERTED X+Y, OFFSET POSIITON.( 2 WORDS )
;	A2 = BITPLANE 1
;	A3 = BITPLANE 2
;	D3 = NUMBER OF STARS -1
StarMain:
	LEA	XYD_tab,A0	; Get UnConverted Table
	LEA	LastXY,A1	; Get PreConverted Last Position
	LEA	Screen1,A2	; Get BP1
	LEA	Screen2,A3	; Get BP2
	MOVEQ	#NoStars-1,D3	; No. Stars -1
Calc_lp:MOVE.W	(A0)+,D4	; Get X
	MOVE.W	(A0)+,D5	; Get Y
	MOVE.W	(A0),D6		; Get Divisor
	SUBQ.W	#StarSpd,(A0)+	; Sub For Star Speed
	TST.W	D6
	BLE	GetNewXY	; Less-Equal To Zero
	EXT.L	D4		; Extended
	EXT.L	D5
	DIVS	D6,D4		; Divide
	DIVS	D6,D5
	ADD.W	#160,D4		; Add Centre X
	ADD.W	#128,D5		; Add Centre Y
	TST.W	D4
	BLT	GetNewXY	; Less Than Zero
	TST.W	D5
	BLT	GetNewXY
	CMP.W	#319,D4		; Check Max X
	BGT.S	GetNewXY	; If Greater Than Compare
	CMP.W	#255,D5		; Check Max Y
	BGT.S	GetNewXY
	MULU	#$28,D5		; Mulu Y By Scr Width In Bytes
	MOVE.W	D4,D7		; Store X
	LSR.W	#3,D4		; Find X In Bytes (Divide By 8)
	ADD.W	D4,D5		; Add X To Y
	NOT.B	D7		; Inverse Stored X For Bit Offset
	MOVE.W	(A1),D0		; Get Last X+Y
	MOVE.W	D5,(A1)+	; Store New X+Y
	MOVE.W	(A1),D1		; Get Last Offset
	MOVE.W	D7,(A1)+	; Store New Offset
	BCLR	D1,(A2,D0)	; Clear Last Position
	BCLR	D1,(A3,D0)	; Clear
;	CMP.W	#400,D6		; Check Pos For Colour Change
;	BGT.S	SetBP1		; If Greater Set BPlane 1
;	CMP.W	#250,D6
;	BGT.S	SetBP2		; If Greater Set BPlane 2
	BSET	D7,(A2,D5)	; If Less Or Equal Set Both Planes
	BSET	D7,(A3,D5)	; BP2
Loop_end:
	DBF	D3,Calc_lp	; Loop Till All Done

	MOVE.W	(A1)+,D0	; Placed For Last Star Clear
	MOVE.W	(A1),D1
	BCLR	D1,(A2,D0)	; BP1
	BCLR	D1,(A3,D0)	; BP2
	RTS

RandXY:	MOVE.W	$DFF006,D0	; Get Fairly Random Value From VHposr
VHstr:	MULU	#$0,D0		; Mutiply By Last Random Number
	NOT.W	D0		; Inverse
	MOVE.W	D0,VHstr+2	; Naughty But Nice!.
	RTS

GetNewXY:
	BSR.S	RandXY
	MOVE.W	D0,-6(A0)	; X
	BSR.S	RandXY
	MOVE.W	D0,-4(A0)	; Y
	BSR.S	RandXY
	MOVE.W	#$300,-2(A0)	; D
	BRA.S	Loop_end

SetBP1:	BSET	D7,(A2,D5)	; BP1
	BRA	Loop_end
SetBP2:	BSET	D7,(A3,D5)	; BP2
	BRA	Loop_end






;**************************************************
;*    ----- Protracker V2.3A Playroutine -----    *
;**************************************************

; VBlank Version 2:
; Call mt_init to initialize the routine, then call mt_music on
; each vertical blank (50 Hz). To end the song and turn off all
; voices, call mt_end.

; This playroutine is not very fast, optimized or well commented,
; but all the new commands in PT2.3A should work.
; If it's not good enough, you'll have to change it yourself.
; We'll try to write a faster routine soon...

; Changes from V1.0C playroutine:
; - Vibrato depth changed to be compatible with Noisetracker 2.0.
;   You'll have to double all vib. depths on old PT modules.
; - Funk Repeat changed to Invert Loop.
; - Period set back earlier when stopping an effect.

DMAWait = 300 ; Set this as low as possible without losing low notes.

n_note		EQU	0  ; W
n_cmd		EQU	2  ; W
n_cmdlo		EQU	3  ; B
n_start		EQU	4  ; L
n_length	EQU	8  ; W
n_loopstart	EQU	10 ; L
n_replen	EQU	14 ; W
n_period	EQU	16 ; W
n_finetune	EQU	18 ; B
n_volume	EQU	19 ; B
n_dmabit	EQU	20 ; W
n_toneportdirec	EQU	22 ; B
n_toneportspeed	EQU	23 ; B
n_wantedperiod	EQU	24 ; W
n_vibratocmd	EQU	26 ; B
n_vibratopos	EQU	27 ; B
n_tremolocmd	EQU	28 ; B
n_tremolopos	EQU	29 ; B
n_wavecontrol	EQU	30 ; B
n_glissfunk	EQU	31 ; B
n_sampleoffset	EQU	32 ; B
n_pattpos	EQU	33 ; B
n_loopcount	EQU	34 ; B
n_funkoffset	EQU	35 ; B
n_wavestart	EQU	36 ; L
n_reallength	EQU	40 ; W

mt_init	LEA	mt_data,A0
	MOVE.L	A0,mt_SongDataPtr
	MOVE.L	A0,A1
	LEA	952(A1),A1
	MOVEQ	#127,D0
	MOVEQ	#0,D1
mtloop	MOVE.L	D1,D2
	SUBQ.W	#1,D0
mtloop2	MOVE.B	(A1)+,D1
	CMP.B	D2,D1
	BGT.S	mtloop
	DBRA	D0,mtloop2
	ADDQ.B	#1,D2
			
	LEA	mt_SampleStarts(PC),A1
	ASL.L	#8,D2
	ASL.L	#2,D2
	ADD.L	#1084,D2
	ADD.L	A0,D2
	MOVE.L	D2,A2
	MOVEQ	#30,D0
mtloop3	CLR.L	(A2)
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	42(A0),D1
	ASL.L	#1,D1
	ADD.L	D1,A2
	ADD.L	#30,A0
	DBRA	D0,mtloop3

	OR.B	#2,$BFE001
	MOVE.B	#6,mt_speed
	CLR.B	mt_counter
	CLR.B	mt_SongPos
	CLR.W	mt_PatternPos
mt_end	CLR.W	$DFF0A8
	CLR.W	$DFF0B8
	CLR.W	$DFF0C8
	CLR.W	$DFF0D8
	MOVE.W	#$F,$DFF096
	RTS

mt_music
	MOVEM.L	D0-D4/A0-A6,-(SP)
	ADDQ.B	#1,mt_counter
	MOVE.B	mt_counter(PC),D0
	CMP.B	mt_speed(PC),D0
	BLO.S	mt_NoNewNote
	CLR.B	mt_counter
	TST.B	mt_PattDelTime2
	BEQ.S	mt_GetNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_dskip

mt_NoNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_NoNewPosYet

mt_NoNewAllChannels
	LEA	$DFF0A0,A5
	LEA	mt_chan1temp(PC),A6
	BSR	mt_CheckEfx
	LEA	$DFF0B0,A5
	LEA	mt_chan2temp(PC),A6
	BSR	mt_CheckEfx
	LEA	$DFF0C0,A5
	LEA	mt_chan3temp(PC),A6
	BSR	mt_CheckEfx
	LEA	$DFF0D0,A5
	LEA	mt_chan4temp(PC),A6
	BRA	mt_CheckEfx

mt_GetNewNote
	MOVE.L	mt_SongDataPtr(PC),A0
	LEA	12(A0),A3
	LEA	952(A0),A2	;pattpo
	LEA	1084(A0),A0	;patterndata
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	mt_SongPos(PC),D0
	MOVE.B	(A2,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.W	mt_PatternPos(PC),D1
	CLR.W	mt_DMACONtemp

	LEA	$DFF0A0,A5
	LEA	mt_chan1temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	$DFF0B0,A5
	LEA	mt_chan2temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	$DFF0C0,A5
	LEA	mt_chan3temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	$DFF0D0,A5
	LEA	mt_chan4temp(PC),A6
	BSR.S	mt_PlayVoice
	BRA	mt_SetDMA

mt_PlayVoice
	TST.L	(A6)
	BNE.S	mt_plvskip
	BSR	mt_PerNop
mt_plvskip
	MOVE.L	(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	n_cmd(A6),D2
	AND.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ	mt_SetRegs
	MOVEQ	#0,D3
	LEA	mt_SampleStarts(PC),A1
	MOVE	D2,D4
	SUBQ.L	#1,D2
	ASL.L	#2,D2
	MULU	#30,D4
	MOVE.L	(A1,D2.L),n_start(A6)
	MOVE.W	(A3,D4.L),n_length(A6)
	MOVE.W	(A3,D4.L),n_reallength(A6)
	MOVE.B	2(A3,D4.L),n_finetune(A6)
	MOVE.B	3(A3,D4.L),n_volume(A6)
	MOVE.W	4(A3,D4.L),D3 ; Get repeat
	TST.W	D3
	BEQ.S	mt_NoLoop
	MOVE.L	n_start(A6),D2	; Get start
	ASL.W	#1,D3
	ADD.L	D3,D2		; Add repeat
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	4(A3,D4.L),D0	; Get repeat
	ADD.W	6(A3,D4.L),D0	; Add replen
	MOVE.W	D0,n_length(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)	; Set volume
	BRA.S	mt_SetRegs

mt_NoLoop
	MOVE.L	n_start(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)	; Set volume
mt_SetRegs
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ	mt_CheckMoreEfx	; If no note
	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0E50,D0
	BEQ.S	mt_DoSetFineTune
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0	; TonePortamento
	BEQ.S	mt_ChkTonePorta
	CMP.B	#5,D0
	BEQ.S	mt_ChkTonePorta
	CMP.B	#9,D0	; Sample Offset
	BNE.S	mt_SetPeriod
	BSR	mt_CheckMoreEfx
	BRA.S	mt_SetPeriod

mt_DoSetFineTune
	BSR	mt_SetFineTune
	BRA.S	mt_SetPeriod

mt_ChkTonePorta
	BSR	mt_SetTonePorta
	BRA	mt_CheckMoreEfx

mt_SetPeriod
	MOVEM.L	D0-D1/A0-A1,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	mt_PeriodTable(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#36,D7
mt_ftuloop
	CMP.W	(A1,D0.W),D1
	BHS.S	mt_ftufound
	ADDQ.L	#2,D0
	DBRA	D7,mt_ftuloop
mt_ftufound
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	ADD.L	D1,A1
	MOVE.W	(A1,D0.W),n_period(A6)
	MOVEM.L	(SP)+,D0-D1/A0-A1

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 ; Notedelay
	BEQ	mt_CheckMoreEfx

	MOVE.W	n_dmabit(A6),$DFF096
	BTST	#2,n_wavecontrol(A6)
	BNE.S	mt_vibnoc
	CLR.B	n_vibratopos(A6)
mt_vibnoc
	BTST	#6,n_wavecontrol(A6)
	BNE.S	mt_trenoc
	CLR.B	n_tremolopos(A6)
mt_trenoc
	MOVE.L	n_start(A6),(A5)	; Set start
	MOVE.W	n_length(A6),4(A5)	; Set length
	MOVE.W	n_period(A6),D0
	MOVE.W	D0,6(A5)		; Set period
	MOVE.W	n_dmabit(A6),D0
	OR.W	D0,mt_DMACONtemp
	BRA	mt_CheckMoreEfx
 
mt_SetDMA
	MOVE.W	#300,D0
mt_WaitDMA
	DBRA	D0,mt_WaitDMA
	MOVE.W	mt_DMACONtemp(PC),D0
	OR.W	#$8000,D0
	MOVE.W	D0,$DFF096
	MOVE.W	#300,D0
mt_WaitDMA2
	DBRA	D0,mt_WaitDMA2

	LEA	$DFF000,A5
	LEA	mt_chan4temp(PC),A6
	MOVE.L	n_loopstart(A6),$D0(A5)
	MOVE.W	n_replen(A6),$D4(A5)
	LEA	mt_chan3temp(PC),A6
	MOVE.L	n_loopstart(A6),$C0(A5)
	MOVE.W	n_replen(A6),$C4(A5)
	LEA	mt_chan2temp(PC),A6
	MOVE.L	n_loopstart(A6),$B0(A5)
	MOVE.W	n_replen(A6),$B4(A5)
	LEA	mt_chan1temp(PC),A6
	MOVE.L	n_loopstart(A6),$A0(A5)
	MOVE.W	n_replen(A6),$A4(A5)

mt_dskip
	ADD.W	#16,mt_PatternPos
	MOVE.B	mt_PattDelTime,D0
	BEQ.S	mt_dskc
	MOVE.B	D0,mt_PattDelTime2
	CLR.B	mt_PattDelTime
mt_dskc	TST.B	mt_PattDelTime2
	BEQ.S	mt_dska
	SUBQ.B	#1,mt_PattDelTime2
	BEQ.S	mt_dska
	SUB.W	#16,mt_PatternPos
mt_dska	TST.B	mt_PBreakFlag
	BEQ.S	mt_nnpysk
	SF	mt_PBreakFlag
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	CLR.B	mt_PBreakPos
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
mt_nnpysk
	CMP.W	#1024,mt_PatternPos
	BLO.S	mt_NoNewPosYet
mt_NextPosition	
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
	CLR.B	mt_PBreakPos
	CLR.B	mt_PosJumpFlag
	ADDQ.B	#1,mt_SongPos
	AND.B	#$7F,mt_SongPos
	MOVE.B	mt_SongPos(PC),D1
	MOVE.L	mt_SongDataPtr(PC),A0
	CMP.B	950(A0),D1
	BLO.S	mt_NoNewPosYet
	CLR.B	mt_SongPos
mt_NoNewPosYet	
	TST.B	mt_PosJumpFlag
	BNE.S	mt_NextPosition
	MOVEM.L	(SP)+,D0-D4/A0-A6
	RTS

mt_CheckEfx
	BSR	mt_UpdateFunk
	MOVE.W	n_cmd(A6),D0
	AND.W	#$0FFF,D0
	BEQ.S	mt_PerNop
	MOVE.B	n_cmd(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_Arpeggio
	CMP.B	#1,D0
	BEQ	mt_PortaUp
	CMP.B	#2,D0
	BEQ	mt_PortaDown
	CMP.B	#3,D0
	BEQ	mt_TonePortamento
	CMP.B	#4,D0
	BEQ	mt_Vibrato
	CMP.B	#5,D0
	BEQ	mt_TonePlusVolSlide
	CMP.B	#6,D0
	BEQ	mt_VibratoPlusVolSlide
	CMP.B	#$E,D0
	BEQ	mt_E_Commands
SetBack	MOVE.W	n_period(A6),6(A5)
	CMP.B	#7,D0
	BEQ	mt_Tremolo
	CMP.B	#$A,D0
	BEQ	mt_VolumeSlide
mt_Return2
	RTS

mt_PerNop
	MOVE.W	n_period(A6),6(A5)
	RTS

mt_Arpeggio
	MOVEQ	#0,D0
	MOVE.B	mt_counter(PC),D0
	DIVS	#3,D0
	SWAP	D0
	CMP.W	#0,D0
	BEQ.S	mt_Arpeggio2
	CMP.W	#2,D0
	BEQ.S	mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#15,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio2
	MOVE.W	n_period(A6),D2
	BRA.S	mt_Arpeggio4

mt_Arpeggio3
	ASL.W	#1,D0
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE.W	n_period(A6),D1
	MOVEQ	#36,D7
mt_arploop
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0),D1
	BHS.S	mt_Arpeggio4
	ADDQ.L	#2,A0
	DBRA	D7,mt_arploop
	RTS

mt_Arpeggio4
	MOVE.W	D2,6(A5)
	RTS

mt_FinePortaUp
	TST.B	mt_counter
	BNE.S	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaUp
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	SUB.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#113,D0
	BPL.S	mt_PortaUskip
	AND.W	#$F000,n_period(A6)
	OR.W	#113,n_period(A6)
mt_PortaUskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS	
 
mt_FinePortaDown
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaDown
	CLR.W	D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	ADD.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI.S	mt_PortaDskip
	AND.W	#$F000,n_period(A6)
	OR.W	#856,n_period(A6)
mt_PortaDskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS

mt_SetTonePorta
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#36*2,D0 ;37?
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_StpLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_StpFound
	ADDQ.W	#2,D0
	CMP.W	#36*2,D0 ;37?
	BLO.S	mt_StpLoop
	MOVEQ	#35*2,D0
mt_StpFound
	MOVE.B	n_finetune(A6),D2
	AND.B	#8,D2
	BEQ.S	mt_StpGoss
	TST.W	D0
	BEQ.S	mt_StpGoss
	SUBQ.W	#2,D0
mt_StpGoss
	MOVE.W	(A0,D0.W),D2
	MOVE.L	(SP)+,A0
	MOVE.W	D2,n_wantedperiod(A6)
	MOVE.W	n_period(A6),D0
	CLR.B	n_toneportdirec(A6)
	CMP.W	D0,D2
	BEQ.S	mt_ClearTonePorta
	BGE	mt_Return2
	MOVE.B	#1,n_toneportdirec(A6)
	RTS

mt_ClearTonePorta
	CLR.W	n_wantedperiod(A6)
	RTS

mt_TonePortamento
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_TonePortNoChange
	MOVE.B	D0,n_toneportspeed(A6)
	CLR.B	n_cmdlo(A6)
mt_TonePortNoChange
	TST.W	n_wantedperiod(A6)
	BEQ	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_toneportspeed(A6),D0
	TST.B	n_toneportdirec(A6)
	BNE.S	mt_TonePortaUp
mt_TonePortaDown
	ADD.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BGT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)
	BRA.S	mt_TonePortaSetPer

mt_TonePortaUp
	SUB.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BLT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)

mt_TonePortaSetPer
	MOVE.W	n_period(A6),D2
	MOVE.B	n_glissfunk(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_GlissSkip
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#36*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_GlissLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_GlissFound
	ADDQ.W	#2,D0
	CMP.W	#36*2,D0
	BLO.S	mt_GlissLoop
	MOVEQ	#35*2,D0
mt_GlissFound
	MOVE.W	(A0,D0.W),D2
mt_GlissSkip
	MOVE.W	D2,6(A5) ; Set period
	RTS

mt_Vibrato
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Vibrato2
	MOVE.B	n_vibratocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_vibskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_vibskip2
	MOVE.B	D2,n_vibratocmd(A6)
mt_Vibrato2
	MOVE.B	n_vibratopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	AND.B	#$03,D2
	BEQ.S	mt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_vib_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_vib_set
mt_vib_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_sine
	MOVE.B	0(A4,D0.W),D2
mt_vib_set
	MOVE.B	n_vibratocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#7,D2
	MOVE.W	n_period(A6),D0
	TST.B	n_vibratopos(A6)
	BMI.S	mt_VibratoNeg
	ADD.W	D2,D0
	BRA.S	mt_Vibrato3
mt_VibratoNeg
	SUB.W	D2,D0
mt_Vibrato3
	MOVE.W	D0,6(A5)
	MOVE.B	n_vibratocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_vibratopos(A6)
	RTS

mt_TonePlusVolSlide
	BSR	mt_TonePortNoChange
	BRA	mt_VolumeSlide

mt_VibratoPlusVolSlide
	BSR.S	mt_Vibrato2
	BRA	mt_VolumeSlide

mt_Tremolo
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Tremolo2
	MOVE.B	n_tremolocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_treskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_treskip2
	MOVE.B	D2,n_tremolocmd(A6)
mt_Tremolo2
	MOVE.B	n_tremolopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.S	mt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_tre_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_tre_set
mt_tre_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_sine
	MOVE.B	0(A4,D0.W),D2
mt_tre_set
	MOVE.B	n_tremolocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	TST.B	n_tremolopos(A6)
	BMI.S	mt_TremoloNeg
	ADD.W	D2,D0
	BRA.S	mt_Tremolo3
mt_TremoloNeg
	SUB.W	D2,D0
mt_Tremolo3
	BPL.S	mt_TremoloSkip
	CLR.W	D0
mt_TremoloSkip
	CMP.W	#$40,D0
	BLS.S	mt_TremoloOk
	MOVE.W	#$40,D0
mt_TremoloOk
	MOVE.W	D0,8(A5)
	MOVE.B	n_tremolocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_tremolopos(A6)
	RTS

mt_SampleOffset
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_sononew
	MOVE.B	D0,n_sampleoffset(A6)
mt_sononew
	MOVE.B	n_sampleoffset(A6),D0
	LSL.W	#7,D0
	CMP.W	n_length(A6),D0
	BGE.S	mt_sofskip
	SUB.W	D0,n_length(A6)
	LSL.W	#1,D0
	ADD.L	D0,n_start(A6)
	RTS
mt_sofskip
	MOVE.W	#$0001,n_length(A6)
	RTS

mt_VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	mt_VolSlideDown
mt_VolSlideUp
	ADD.B	D0,n_volume(A6)
	CMP.B	#$40,n_volume(A6)
	BMI.S	mt_vsuskip
	MOVE.B	#$40,n_volume(A6)
mt_vsuskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

mt_VolSlideDown
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
mt_VolSlideDown2
	SUB.B	D0,n_volume(A6)
	BPL.S	mt_vsdskip
	CLR.B	n_volume(A6)
mt_vsdskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

mt_PositionJump
	MOVE.B	n_cmdlo(A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,mt_SongPos
mt_pj2	CLR.B	mt_PBreakPos
	ST 	mt_PosJumpFlag
	RTS

mt_VolumeChange
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	CMP.B	#$40,D0
	BLS.S	mt_VolumeOk
	MOVEQ	#$40,D0
mt_VolumeOk
	MOVE.B	D0,n_volume(A6)
	MOVE.W	D0,8(A5)
	RTS

mt_PatternBreak
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU	#10,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.S	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS

mt_SetSpeed
	MOVE.B	3(A6),D0
	BEQ	mt_Return2
	CLR.B	mt_counter
	MOVE.B	D0,mt_speed
	RTS

mt_CheckMoreEfx
	BSR	mt_UpdateFunk
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#$9,D0
	BEQ	mt_SampleOffset
	CMP.B	#$B,D0
	BEQ	mt_PositionJump
	CMP.B	#$D,D0
	BEQ.S	mt_PatternBreak
	CMP.B	#$E,D0
	BEQ.S	mt_E_Commands
	CMP.B	#$F,D0
	BEQ.S	mt_SetSpeed
	CMP.B	#$C,D0
	BEQ	mt_VolumeChange
	BRA	mt_PerNop

mt_E_Commands
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	LSR.B	#4,D0
	BEQ.S	mt_FilterOnOff
	CMP.B	#1,D0
	BEQ	mt_FinePortaUp
	CMP.B	#2,D0
	BEQ	mt_FinePortaDown
	CMP.B	#3,D0
	BEQ.S	mt_SetGlissControl
	CMP.B	#4,D0
	BEQ	mt_SetVibratoControl
	CMP.B	#5,D0
	BEQ	mt_SetFineTune
	CMP.B	#6,D0
	BEQ	mt_JumpLoop
	CMP.B	#7,D0
	BEQ	mt_SetTremoloControl
	CMP.B	#9,D0
	BEQ	mt_RetrigNote
	CMP.B	#$A,D0
	BEQ	mt_VolumeFineUp
	CMP.B	#$B,D0
	BEQ	mt_VolumeFineDown
	CMP.B	#$C,D0
	BEQ	mt_NoteCut
	CMP.B	#$D,D0
	BEQ	mt_NoteDelay
	CMP.B	#$E,D0
	BEQ	mt_PatternDelay
	CMP.B	#$F,D0
	BEQ	mt_FunkIt
	RTS

mt_FilterOnOff
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#1,D0
	ASL.B	#1,D0
	AND.B	#$FD,$BFE001
	OR.B	D0,$BFE001
	RTS	

mt_SetGlissControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	RTS

mt_SetVibratoControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_SetFineTune
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	RTS

mt_JumpLoop
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_SetLoop
	TST.B	n_loopcount(A6)
	BEQ.S	mt_jumpcnt
	SUBQ.B	#1,n_loopcount(A6)
	BEQ	mt_Return2
mt_jmploop	MOVE.B	n_pattpos(A6),mt_PBreakPos
	ST	mt_PBreakFlag
	RTS

mt_jumpcnt
	MOVE.B	D0,n_loopcount(A6)
	BRA.S	mt_jmploop

mt_SetLoop
	MOVE.W	mt_PatternPos(PC),D0
	LSR.W	#4,D0
	MOVE.B	D0,n_pattpos(A6)
	RTS

mt_SetTremoloControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_RetrigNote
	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
	BNE.S	mt_rtnskp
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	BNE.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
mt_rtnskp
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	mt_rtnend
mt_DoRetrig
	MOVE.W	n_dmabit(A6),$DFF096	; Channel DMA off
	MOVE.L	n_start(A6),(A5)	; Set sampledata pointer
	MOVE.W	n_length(A6),4(A5)	; Set length
	MOVE.W	#300,D0
mt_rtnloop1
	DBRA	D0,mt_rtnloop1
	MOVE.W	n_dmabit(A6),D0
	BSET	#15,D0
	MOVE.W	D0,$DFF096
	MOVE.W	#300,D0
mt_rtnloop2
	DBRA	D0,mt_rtnloop2
	MOVE.L	n_loopstart(A6),(A5)
	MOVE.L	n_replen(A6),4(A5)
mt_rtnend
	MOVE.L	(SP)+,D1
	RTS

mt_VolumeFineUp
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA	mt_VolSlideUp

mt_VolumeFineDown
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA	mt_VolSlideDown2

mt_NoteCut
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter(PC),D0
	BNE	mt_Return2
	CLR.B	n_volume(A6)
	MOVE.W	#0,8(A5)
	RTS

mt_NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter,D0
	BNE	mt_Return2
	MOVE.W	(A6),D0
	BEQ	mt_Return2
	MOVE.L	D1,-(SP)
	BRA	mt_DoRetrig

mt_PatternDelay
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	TST.B	mt_PattDelTime2
	BNE	mt_Return2
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelTime
	RTS

mt_FunkIt
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	TST.B	D0
	BEQ	mt_Return2
mt_UpdateFunk
	MOVEM.L	A0/D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_glissfunk(A6),D0
	LSR.B	#4,D0
	BEQ.S	mt_funkend
	LEA	mt_FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,n_funkoffset(A6)
	BTST	#7,n_funkoffset(A6)
	BEQ.S	mt_funkend
	CLR.B	n_funkoffset(A6)

	MOVE.L	n_loopstart(A6),D0
	MOVEQ	#0,D1
	MOVE.W	n_replen(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	n_wavestart(A6),A0
	ADDQ.L	#1,A0
	CMP.L	D0,A0
	BLO.S	mt_funkok
	MOVE.L	n_loopstart(A6),A0
mt_funkok
	MOVE.L	A0,n_wavestart(A6)
	MOVEQ	#-1,D0
	SUB.B	(A0),D0
	MOVE.B	D0,(A0)
mt_funkend
	MOVEM.L	(SP)+,A0/D1
	RTS


mt_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_PeriodTable
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

mt_chan1temp	dc.l	0,0,0,0,0,$00010000,0,  0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,0,$00020000,0,  0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,0,$00040000,0,  0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,0,$00080000,0,  0,0,0,0

mt_SampleStarts	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_SongDataPtr	dc.l 0

mt_speed	dc.b 6
mt_counter	dc.b 0
mt_SongPos	dc.b 0
mt_PBreakPos	dc.b 0
mt_PosJumpFlag	dc.b 0
mt_PBreakFlag	dc.b 0
mt_LowMask	dc.b 0
mt_PattDelTime	dc.b 0
mt_PattDelTime2	dc.b 0,0

mt_PatternPos	dc.w 0
mt_DMACONtemp	dc.w 0



;*****************************************************************************
; This Is The Start Of The Co-Processor List!.
;*****************************************************************************
MYcopper:
 dc.w diwstrt,$2c81	; Screen Start.	(Top Left).
 dc.w diwstop,$f4c1	; End.PAL	(Bottom Right).$2cc1 For Pal.

 dc.w ddfstrt,$38	; DataFetch Start.(Left).
 dc.w ddfstop,$d0	; End.		  (Right).

 dc.w bplcon0,$2200	; No. BPlanes. Activate DPF

 dc.w bplcon1,$00

 dc.w bpl1mod,0		; Bitplane Modulo.
 dc.w bpl2mod,0		; Modulo Enabling 2 BPlanes In One Blit

; The Picture
CopBP1ptr: dc.w bpl1pth,0	; Bitplane 1 Pointers.(Col2)
	   dc.w bpl1ptl,0
CopBP2ptr: dc.w bpl2pth,0	; Bitplane 2 Pointers.(Col4)
	   dc.w bpl2ptl,0

; Colours
 dc.w col0,$000
 dc.w col1,$666
 dc.w col2,$fff
 dc.w col3,$aaa



 dc.w $f409,$fffe

 dc.w $09c,$8010	; Request Interrupt

 dc.w $ffff,$fffe ; End copper.(Impossible Wait).


;*****************************************************************************
; Various Data Tables, Text, SineTables, Colour etc.
;*****************************************************************************
NoStars		=	64		; Number Of Stars
StarSpd		=	8		; Star Speed

XYD_tab:	dcb.w	NoStars*3,0	; 3 Words X,Y,Div
LastXY:		dcb.w	NoStars*2,0	; 2 Words X+Y, Bit Offset

StarBP1:	dcb.b	10240,0		; Star Planes
StarBP2:	dcb.b	10240,0


Text:
		;********************
	DC.B    "                                                                             "
;	DC.B	"                                        "
        DC.B    "                                  S P O O K Y  ! !                  "
	DC.B	"      HELLO BOYZ AND GALS ........."
	DC.B	"           WELCOME TO A LITTLE INTRO DONE BY..........     " 
        DC.B    "      *** MC ***   ",0
	DC.B	"                I REPEAT...   "
	DC.B	"      --- MC ---   ",0
	DC.B	"                  THIS INTRO WAS DONE JUST TO PLAY MY NEW MODULE CALLED    "
	DC.B	" THE            TWILIGHT ZONE  ",0
	DC.B	"           -MC DRONE MIX- ",0
	DC.B	"               IT WAS SLAPPED TOGETHER IN A COUPLE OF HOURS SO ITS NOT EXACTLY A CLASSIC BUT ITS WORTH A LAUGH OR TWO !!!!     "
	DC.B	"       ABOUT THIS INTRO -----   THE SCROLLER WAS GIVEN TO ME BY  SLAINE  AND I DID THE USELESS STARFIELD....       YES I KNOW ITS SLOW"
	DC.B	" AND EXTREMELY JERKY BUT PLEASE BEAR IN MIND THAT I KNOW  * BOTT *  ALL ABOUT CODING DEMOS BUT WHO CARES ?? ---           AND BESIDES...    I'M NAT THAT TYPE-A-GUY ANYWAY....   ( SPIT )  "
	DC.B	"       AT LEAST ITS BETTER THAN MAKING A DEMO USING D-PAINT  ( CAB!! )                  EH-HEM         YEP...              "
	DC.B	"      ANYWAY, THE SOURCE HAS BEEN INCLUDED IF YOU FEEL THE URGE TO USE IT AS AN INTRO OR EVEN AS THE MAIN PART OF YOUR NEW TRACKMO !!!   ( JUDGING BY THE CURRENT STANDARDS !! )              "
	DC.B	"            AND NOW FOR THE REALLY ENTHRALLING ,   EDGE-OF-THE-SEAT ,  NAIL-BITING   GREETS.....           "
	DC.B	"YO'S GO OUT TO:   ---            "
	DC.B	"        BC        "
	DC.B	"       SHAZ       "
	DC.B	"       FEEF    ( ANY LUCK WITH THE PRO'S ??? )             "
	DC.B	"       BOYZEE     "
	DC.B	"       NADS       "
	DC.B	"       IMMY       "
	DC.B	"       ASS     ( RARELY RARE RARENESSES -- H )       "
	DC.B	"        CAB       "
	DC.B	"      THE RAY     "
	DC.B	"       MAROOF     "
	DC.B	"        RAZ       "
	DC.B	"       BLAKEY     "
	DC.B	"       SADBOD     "
	DC.B	"       BROWNY     "
	DC.B	"       HOGGY      "
	DC.B	"         LX       "
	DC.B	"      JON SMITH - CCT01      "
	DC.B	"        GOODGEY           "
	DC.B	"       BRITISH AIRWAYS       "
	DC.B	"       THE GAS BOARD         "
	DC.B	"         "
	DC.B	"     AND ALL OF MY TENANTS CURRENTLY LIVING IT UP BECOZ I HAVE BEEN TOO LAZY TO COME ROUND FOR THIS TERMS RENT !!!!!!      "
	DC.B	"    ( BUT DON'T WORRY,    I NEED A HARD DRIVE SO EXPECT THE RENT TO RISE VERY SOON ........ )            "
	DC.B	"                MESSAGE TO "   
	DC.B    "         C.A.B      ",0
	DC.B	"                 I STILL HATE YOU.                     "
	DC.B	"  I HOPE YOU HAVE A GOOD TIME IN LONDON WORKING FOR THE GAS BOARD... "
	DC.B	" ( NUDGE NUDGE, WINK WINK, SAY NO MORE ! )   "
	DC.B	"                       "
	DC.B	" OK,  I'VE RUN OUT OFF THINGS TO SAY ,   SO I'LL LEAVE YOU TO ENJOY/HATE THE MOD...    "
	DC.B	"                         "
	DC.B	"  LOOK OUT FOR OTHER  MODS/INTROS/SOURCES   FROM THE PURVEYOR OF UTTERLY USELESS PRODUCTIONS...             "
	DC.B	"    -- MC --    ",0
	DC.B	"                                   "
	DC.B	"LATERS............................................................................................                      " 
	DC.B	"                                 "



	DC.B	$FF
Text_ptr:	dc.l	Text
Print_ctr:	dc.b	0
Pause_ctr:	dc.b	0
Scroll_flg:	dc.b	0
Font:	incbin	MCTwilight:Bin/Font.bin

;**********************************
; SINE VARIABLES
Length	= 16

; SINE POINTERS

Y_vel1:	dc.w	8	; Y Bob Velocity
Y_vel2:	dc.w	16	; Y Sine Velocity

Y_add1:	dc.w	2	; Y Sine Distance
Y_add2:	dc.w	2	; Y Bob Distance



; speed variable 
; speed can be (1,2,4,8)
; BUT set the speedvar1 variable according to the chosen speed
; ie speed=1 -- speedvar1=24
;    speed=2 -- speedvar1=12
;    speed=4 -- speedvar1=3
;    speed=8 -- speedvar1=1


speed		equ     4
speedvar1	equ     4




; Store For Sine Tables

Y_pt1:	Dc.w 0
Y_pt2:	Dc.w 0

Ya:	Dc.l Ys1
Ys1:	Dcb.w 160,0

Sintable:	incbin	MCTwilight:Bin/Sin.bin


;**********************************
Screen1:	dcb.w	10240,0		; Display
Screen2:	dcb.w	10240,0		; Display
Buffer:		dcb.w	42*21,0		; Scroll Buffer
Scr_ptr:	dc.l	Screen1
AddSub_flg	dc.b	0

;*****************************************************************************
; Store For WorkBench Copper, Library Base Addresses etc.
;*****************************************************************************
	even
WBcopper: 	dc.l 	0	; Store WBench Copper Addr.


mt_data:
;		incbin	st-00:modules/mod.twilight-mc_drone	; Enter Path And Module Name Here.


;*****************************************************************************
;EQUATES for LIBRARY & HARDWARE REGISTERS
;*****************************************************************************

ExecBase	EQU	4	; The One And Only.

Forbid		EQU	-132	; Forbid Multitask
Permit		EQU	-138	; Permit Multitask

Disable		EQU	-120
Enable		EQU	-126

OpenLib		EQU 	-552	; Offset for OpenLibrary.
CloseLib	EQU	-414	; Offset for CloseLibrary.

WBskip		EQU	38	; Offset For WB Copper.

;*** VARIOUS ***
bltddat		EQU	$DFF000
dmaconr		EQU	$DFF002
vposr		EQU	$DFF004
vhposr		EQU	$DFF006
dskdatr		EQU	$DFF008
joy0dat		EQU	$DFF00A
joy1dat		EQU	$DFF00C
clxdat		EQU	$DFF00E

adkconr		EQU	$DFF010
pot0dat		EQU	$DFF012
pot1dat		EQU	$DFF014
potinp		EQU	$DFF016
serdatr		EQU	$DFF018
dskbytr		EQU	$DFF01A
intenar		EQU	$DFF01C
intreqr		EQU	$DFF01E

dskpt		EQU	$DFF020
dsklen		EQU	$DFF024
dskdat		EQU	$DFF026
refptr		EQU	$DFF028
vposw		EQU	$DFF02A
vhposw		EQU	$DFF02C
copcon		EQU	$DFF02E
serdat		EQU	$DFF030
serper		EQU	$DFF032
potgo		EQU	$DFF034
joytest		EQU	$DFF036
strequ		EQU	$DFF038
strvbl		EQU	$DFF03A
strhor		EQU	$DFF03C
strlong		EQU	$DFF03E

;*** BLITTER ***
bltcon0		EQU	$DFF040
bltcon1		EQU	$DFF042
bltafwm		EQU	$DFF044
bltalwm		EQU	$DFF046
bltcpth		EQU	$DFF048
bltcptl 	EQU	$DFF04A
bltbpth		EQU	$DFF04C
bltbptl 	EQU	$DFF04E
bltapth		EQU	$DFF050
bltaptl 	EQU	$DFF052
bltdpth		EQU	$DFF054
bltdptl 	EQU	$DFF056
bltsize		EQU	$DFF058

bltcmod		EQU	$DFF060
bltbmod		EQU	$DFF062
bltamod		EQU	$DFF064
bltdmod		EQU	$DFF066

bltcdat		EQU	$DFF070
bltbdat		EQU	$DFF072
bltadat		EQU	$DFF074

dsksync		EQU	$DFF07E

;*** COPPER ADDRESS & STROBE ***
cop1lc		EQU	$DFF080
cop2lc		EQU	$DFF084
copjmp1		EQU	$DFF088
copjmp2		EQU	$DFF08A
copins		EQU	$DFF08C


;*** BITPLANE START & DATA FETCH ***
diwstrt		EQU	$08E
diwstop		EQU	$090
ddfstrt		EQU	$092
ddfstop		EQU	$094

;*** DMA & INTERRUPT CONTROL ***
dmacon		EQU	$DFF096
clxcon		EQU	$DFF098
intena		EQU	$DFF09A
intreq		EQU	$DFF09C

;*** AUDIO ****
adkcon		EQU	$DFF09E
aud0lch		EQU	$DFF0A0
aud0lcl		EQU	$DFF0A2
aud0len 	EQU	$DFF0A4
aud0per 	EQU	$DFF0A6
aud0vol		EQU	$DFF0A8
aud0dat		EQU	$DFF0AA

aud1lch		EQU	$DFF0B0
aud1lcl		EQU	$DFF0B2
aud1len 	EQU	$DFF0B4
aud1per 	EQU	$DFF0B6
aud1vol		EQU	$DFF0B8
aud1dat		EQU	$DFF0BA

aud2lch		EQU	$DFF0C0
aud2lcl		EQU	$DFF0C2
aud2len 	EQU	$DFF0C4
aud2per 	EQU	$DFF0C6
aud2vol		EQU	$DFF0C8
aud2dat		EQU	$DFF0CA

aud3lch		EQU	$DFF0D0
aud3lcl		EQU	$DFF0D2
aud3len 	EQU	$DFF0D4
aud3per 	EQU	$DFF0D6
aud3vol		EQU	$DFF0D8
aud3dat		EQU	$DFF0DA

;*** COPPER BITPLANE LOCATION ***
bpl1pth		EQU	$0E0
bpl1ptl		EQU	$0E2
bpl2pth		EQU	$0E4
bpl2ptl		EQU	$0E6
bpl3pth		EQU	$0E8
bpl3ptl		EQU	$0EA
bpl4pth		EQU	$0EC
bpl4ptl		EQU	$0EE
bpl5pth		EQU	$0F0
bpl5ptl		EQU	$0F2
bpl6pth		EQU	$0F4
bpl6ptl		EQU	$0F6

;*** COPPER BITPLANE CONTROL ***
bplcon0		EQU	$100
bplcon1		EQU	$102
bplcon2		EQU	$104
bplcon3		EQU	$106

;*** COPPER BITPLANE MODULO ***
bpl1mod		EQU	$108
bpl2mod		EQU	$10A

bpldat		EQU	$DFF110

;*** COPPER SPRITE LOCATION ***
spr0pth		EQU	$120
spr0ptl 	EQU	$122
spr1pth 	EQU	$124
spr1ptl 	EQU	$126
spr2pth		EQU	$128
spr2ptl 	EQU	$12A
spr3pth 	EQU	$12C
spr3ptl 	EQU	$12E
spr4pth		EQU	$130
spr4ptl 	EQU	$132
spr5pth 	EQU	$134
spr5ptl 	EQU	$136
spr6pth		EQU	$138
spr6ptl 	EQU	$13A
spr7pth 	EQU	$13C
spr7ptl 	EQU	$13E

;*** SPRITE POSITION ***
spr0pos		EQU	$DFF140
spr1pos		EQU	$DFF148
spr2pos 	EQU	$DFF150
spr3pos 	EQU	$DFF158
spr4pos 	EQU	$DFF160
spr5pos 	EQU	$DFF168
spr6pos 	EQU	$DFF170
spr7pos 	EQU	$DFF178

spr0ctl		EQU	$DFF142
spr1ctl		EQU	$DFF14A
spr2ctl 	EQU	$DFF152
spr3ctl 	EQU	$DFF15A
spr4ctl 	EQU	$DFF162
spr5ctl 	EQU	$DFF16A
spr6ctl 	EQU	$DFF172
spr7ctl 	EQU	$DFF17A

;** SPRITE DATA ***
spr0data 	EQU	$DFF144
spr1data 	EQU	$DFF14c
spr2data 	EQU	$DFF154
spr3data 	EQU	$DFF15c
spr4data 	EQU	$DFF164
spr5data 	EQU	$DFF16c
spr6data 	EQU	$DFF174
spr7data 	EQU	$DFF17c


spr0datb 	EQU	$DFF146
spr1datb 	EQU	$DFF14e
spr2datb 	EQU	$DFF156
spr3datb 	EQU	$DFF15e
spr4datb 	EQU	$DFF166
spr5datb 	EQU	$DFF16e
spr6datb 	EQU	$DFF176
spr7datb 	EQU	$DFF17e

;*** SPRITE COLOURS ***
sp0col1		EQU	$1a2
sp0col2		EQU	$1a4
sp0col3		EQU	$1a6
sp2col1		EQU	$1aa
sp2col2		EQU	$1ac
sp2col3		EQU	$1ae
sp4col1		EQU	$1b2
sp4col2		EQU	$1b4
sp4col3		EQU	$1b6
sp6col1		EQU	$1ba
sp6col2		EQU	$1bc
sp6col3		EQU	$1be

;*** BITPLANE COLOURS ***
col0		EQU	$180
col1 		EQU	$182
col2		EQU	$184
col3    	EQU	$186
col4    	EQU	$188
col5    	EQU	$18a
col6    	EQU	$18c
col7    	EQU	$18e
col8    	EQU	$190
col9		EQU	$192
col10   	EQU	$194
col11   	EQU	$196
col12   	EQU	$198
col13   	EQU	$19a
col14   	EQU	$19c
col15   	EQU	$19e
col16   	EQU	$1a0	
col17   	EQU	$1a2
col18   	EQU	$1a4
col19   	EQU	$1a6
col20   	EQU	$1a8
col21   	EQU	$1aa
col22   	EQU	$1ac
col23   	EQU	$1ae
col24   	EQU	$1b0
col25   	EQU	$1b2
col26   	EQU	$1b4
col27   	EQU	$1b6
col28   	EQU	$1b8
col29   	EQU	$1ba
col30   	EQU	$1bc
col31   	EQU	$1be

; End Of Equates


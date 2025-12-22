*********************************************************************
*	Init.asm
*	~~~~~~~~
*	Description : This is my initialization code for use with Demos,
*		      Intro's etc.. This works on mode promotion and
*                     other "weird" screenmodes, proberly the best 
*                     startup so far.. Kill all INTS/DMA etc !!  		
*		      This also contains Free/Restore stuff also !!
*			
*	Code : Dennis Predovnik (Sultan/DVS)
*	Date : 10/1/95 
*
*********************************************************************

        section Init_cOdE,code          

**********************************************************************
*	Setup for System Takeover				     *
**********************************************************************

init:
	move.l	#InitMsg,d2
	move.l	#InitMsgSIZE,d3
	jsr	printMsg		; Write  Message to User !!

	move.l	#WaitMsg,d2
	move.l	#WaitMsgSIZE,d3
	jsr	printMsg

        move.l  4.w,a6
        sub.l   a1,a1                   ; Zero - Find current task
        jsr     _LVOFindTask(a6)
        move.l  d0,a1
        moveq   #127,d0                 ; Task priority to very high...
        jsr     _LVOSetTaskPri(a6)
        move.l  4.w,a6                  ; Get ExecBase
        lea     intname,a1	        ;
        moveq   #39,d0                  ; Kickstart 3.0 or higher
        jsr     _LVOOpenLibrary(a6)
        move.l  d0,_IntuitionBase       ; Store intuitionbase
                                        ; Note: If this fails then 
                                        ; Kickstart is <V39.
        move.l  4.w,a6                  ; Get ExecBase
        lea     gfxname,a1              ; Graphics name
        moveq   #33,d0                  ; Kickstart 1.2 or higher
        jsr     _LVOOpenLibrary(a6)
        tst.l   d0
        beq     exit                    ; Failed to open? Then quit
        move.l  d0,_GfxBase
        move.l  d0,a6
        move.l  gb_ActiView(a6),wbview  ; Store current view address

**********************************************************************
*	Check system I'm on.. PAL/NTSC/AGA/ECS/OCS		     *
**********************************************************************

        move.l  _GfxBase,a6
	lea	$dff002,a5	        ; Custom chip base + 2

	cmpi.l	#37,LIB_VERSION(a6)	; 2.04 or better?
	bge.b	OS20			; Yup

	move.l	#OS13Msg,d2
	move.l	#OS13MsgSIZE,d3
	jsr	printMsg
	cmpi.b	#50,VBlankFrequency(a6)	; Is vblank rate pal?
	beq.b	PAL_DISPLAY		; Yup.

	move.l  #NTSCMsg,d2
	move.l	#NTSCMsgSIZE,d3
	jsr	printMsg
	move.b	#1,ntsc			; Set NTSC flag.
	bra.b	CheckAGA

OS20:
	move.l	#OS2030Msg,d2
	move.l	#OS2030MsgSIZE,d3
	jsr	printMsg

	move.l	_GfxBase,a0		; Graphics base
	btst.b	#PALn,gb_DisplayFlags(a0)
	beq.b	PAL_DISPLAY		; PAL display mode?

	move.l	#NTSCMsg,d2
	move.l	#NTSCMsgSIZE,d3
	jsr	printMsg

	move.b	#1,ntsc			; Set NTSC flag.
	bra	CheckAGA

PAL_DISPLAY:
	move.l	#PALMsg,d2
	move.l	#PALMsgSIZE,d3
	jsr	printMsg

CheckAGA:
	move.l	_GfxBase,a0
	btst.b	#GFXB_AA_ALICE,gb_ChipRevBits0(a0)
	beq.b	NOT_AGA			; Nope.
	move.b	#1,AGA			; Set the AGA flag.

	move.l	#AGAMsg,d2
	move.l	#AGAMsgSIZE,d3
	jsr	printMsg

	bra	bangCop

NOT_AGA:
	move.l	#NoAGAMsg,d2
	move.l	#NoAGAMsgSIZE,d3
	jsr	printMsg
	jsr	errorCleanUp    	; Yep, Let's blow this joint !
	FREEALL	
	add.l	#4,sp                   ; Clear off Address !
	rts

**********************************************************************
*	Insert Copper						     *
**********************************************************************

bangCop:
	move.l	#DVSMsg,d2
	move.l	#DVSMsgSIZE,d3	
	jsr	printMsg                ; Tell User System Takeover 
	move.l	#SYSTakeMsg,d2		; Imminent..
	move.l	#SYSMsgSIZE,d3
	jsr	printMsg

        jsr	_GetVBR	
	move.l	d0,_VBR

        move.l  _GfxBase,a6
	sub.l   a1,a1                   ; Clear a1
        jsr     _LVOLoadView(a6)        ; Flush View to nothing
        jsr     _LVOWaitTOF(a6)         ; Wait once
        jsr     _LVOWaitTOF(a6)         ; Wait again.

        lea	$dff000,a5
	lea	systemsave,a4
	move	#$8000,d7
	move.l  $26(a6),(a4)
	move.l  $32(a6),4(a4)
	move    $1c(a5),d0
	move	2(a5),d1
	or	d7,d0
	and	#$3ff,d1
	or	d7,d1
	move	d0,$8(a4)
	move	d1,$a(a4)
;	move	#$7fff,$9a(a5)
;	move	#$20,$96(a5)
	move.w  #DMAF_SETCLR!DMAF_SPRITE,dmacon(a5)

        move.l  #FIRSTCOPPER,$dff080.L  ; Bang it straight in.
	move.w	#$0,$dff088
	move.w	#$20,$dff1dc
	move.w	#$0,$dff106

	rts				; End !!!

**********************************************************************
*	End Music, Free Memory, Restore Display etc..		     *
**********************************************************************

cleanUp:
	lea	$dff000,a5	                ; Custom chip base
	lea	systemsave,a4
	move	8(a4),$9a(a5)
        move	10(a4),$96(a5)
        move.l	(a4),$80(a5)
        move.l	4(a4),$84(a5)

errorCleanUp:
	move.l  wbview,a1
        move.l  _GfxBase,a6
        jsr     _LVOLoadView(a6)	        ; Fix view
        jsr     _LVOWaitTOF(a6)
        jsr     _LVOWaitTOF(a6)             	; Wait for LoadView()
        move.l  gb_copinit(a6),$dff080.L    	; Kick it into life
        move.l  _IntuitionBase,a6
        jsr     _LVORethinkDisplay(a6)     	; and rethink....
        move.l  _GfxBase,a1
        move.l  4.w,a6
        jsr     _LVOCloseLibrary(a6)        	; Close graphics.library
        move.l  _IntuitionBase,d0
        beq.s   exit                        	; If not open, don't close!
        move.l  d0,a1
        jsr     _LVOCloseLibrary(a6)

exit:
	moveq   #0,d0                       	; Clear d0 for exit
        rts                                 	; back to workbench/cli

error:
        rts

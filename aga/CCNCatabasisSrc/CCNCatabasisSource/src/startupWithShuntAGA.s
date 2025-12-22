
; - - - - - - - startup / exit - - - - 


	; force devpac GenAm assembler options
	; case sensitive, no debug section, output linkable .o
	opt c+   ;?
	opt d-
	opt ALINK
mc68020
MDEBUG	equ	1
DOKEYBOARD	equ	1


	include exec/execbase.i
	include exec/exec_lib.i
	include exec/memory.i
	include exec/tasks.i
	include exec/interrupts.i

	include intuition/intuition.i
	include intuition/intuition_lib.i

	include graphics/graphics_lib.i
	include graphics/gfxbase.i
;	include graphics/view.i

	include dos/dos.i
	include dos/dostags.i
	include libraries/dosextens.i

	include hardware/custom.i

	include dos/dos_lib.i2

	; - - -for keyboard
	ifne DOKEYBOARD
	include  exec/io.i
	include  exec/nodes.i
	include  devices/input.i
	include  devices/inputevent.i
	endc


	; just for testing dfi:
	; - - macros and defines here
TAKEOVER	equ	1
	STRUCTURE MainDt,0    
		; - - private
	;useless	ULONG	md_sysirq
	;useless	ULONG	md_vbr
		UWORD	md_intena
		UWORD	md_dmacon
		UWORD	md_intreq
		UWORD	md_adkcon
		ULONG	md_view
		STRUCT	md_sirq,IS_SIZE
		ULONG	md_irqdat	; can be anything
		UWORD	md_irqOn
	LABEL MainDt_SIZEOF

CALL	MACRO
	jsr _LVO\1(a6)
	ENDM
	; after init, jump to this:
	XREF	_dmain

	ifne MDEBUG
	XDEF	_debugv
	endc	

	; this is for sasc exit()
	XDEF	__XCEXIT
	; pointers to databases:
	XDEF	_exitErrNo	
	XDEF	_IntuitionBase
	XDEF	_GfxBase
	XDEF	_DosBase
	XDEF	_DOSBase
	XDEF	_mdata
	XDEF	_time
	XDEF	_irqcode
	XDEF	_ntsc	;1b
	XDEF	_midY
	XDEF	_doEnd
	; functions	to close/ reopen intuition
	XDEF	_wbView
	XDEF	_shunt
	; - - - - loaded code section in fast or chip
	; - - - - Real Code entry is here.
	section code,code

	; if launch from Workbench, got to answer
	; the OS message, or crash at exit.
	; it doesn't happen when launched from DOS/CLI

	; - - - - get intuition, graphics, dos libs
	movea.l	4.w,a6	; get exec base
	lea	intname(pc),a1
	lea	_IntuitionBase(pc),a4   ;start of _xxxbase
	moveq	#0,d0
	CALL	OpenLibrary
	move.l	d0,(a4)+

	lea	gfxname(pc),a1
	moveq	#0,d0
	CALL	OpenLibrary
	move.l	d0,(a4)+

	lea	dosname(pc),a1
	moveq	#0,d0
	CALL	OpenLibrary
	move.l	d0,(a4)+

	; - - - - - -
	sub.l	a1,a1
	CALL	FindTask
	move.l	d0,a4

	moveq	#0,d0	; default: no message to answer 
	tst.l	pr_CLI(a4)
	bne.s	.fromCli
.fromWorkbench
	lea	pr_MsgPort(a4),a0
	CALL    WaitPort		;wait for a message
	lea	pr_MsgPort(a4),a0
	CALL	GetMsg			;then get it
	move.l	d0,-(sp)
	; - - also need this:
	; note: would need to get current dir from wb msg
	; for dos/open
	; and set it to dos/setcurrentdir
	; but using progdir: did the trick.
    ;d0
    bra	.endwb
.fromCli
	move.l	d0,-(sp)
.endwb


	; - - - test for AGA (A1200/A4000/CD32)
	move.w	$dff000+vposr,d0
 	and.w	#$7f00,d0	;chip version bitmask
;	 move.w d0,_debugv+10	 ; emu 1200: A300

	cmp.w	#$2300,d0	; AGA pal, tested A1200,A4000
	beq.b	.agaPal
	cmp.w	#$3300,d0 ; should be AGA NTSC...
	beq.b	.agaNtsc
		move.w	#1,_exitErrNo
		bra		noAllocError		
.agaNtsc
	st	_ntsc
	move.b	#100,_midY+1
.agaPal

	bsr	initKeyboard
	
	
	; - - - clean alloc
	move.l	4.w,a6
	move.l	#MainDt_SIZEOF,d0
	;optimized move.l #MEMF_CLEAR,d1 ; MEMF_CLEAR is 1<<16
	moveq   #1,d1
	swap 	d1
	CALL    AllocMem
	move.l	d0,_mdata	
	tst.l   d0 
	beq		MainDataAllocError

;	 move.w	 #3*50-1,d7
;.lpt
;	 move.l	 _GfxBase,a6
;	 CALL	 WaitTOF
;	 dbf d7,.lpt
   
	move.l	sp,_StartupEndStack
	bsr	    _dmain
    

	; - - - - - -  exit - - - -
__XCEXIT:	;SASC c exit() label
	move.l	_StartupEndStack(pc),sp

	bsr	closeKeyboard

    ; - - - close startup data
    move.l	4.w,a6 ; exec
	move.l	_mdata(pc),a1
	move.l	#MainDt_SIZEOF,d0
	CALL	FreeMem

MainDataAllocError
noAllocError:
;	 ifne MDEBUG
;		 move.l	 _DosBase,a6
;		 move.l	 #_debugl,d1
;		 move.l	 #_debugv,d2
;		 CALL	 VPrintf
;	 endc
	; - - - if any error to tell...
	move.w	_exitErrNo(pc),d7
	beq.b	.noErrEnd
	subq	#1,d7 ; table offset
	; test if WB mode or DOS mode
	move.l	(sp),d0
	beq.b	.dosErr			
	;wb error, use intui
	move.l	_IntuitionBase,a6
	lea		StringRequester,a1
	lea	errNoTable,a5
	move.l	(a5,d7.w*4),12(a1)
	sub.l	a0,a0
	sub.l	a2,a2
	sub.l	a3,a3
	CALL	EasyRequestArgs
	bra.b	.noErrEnd	
.dosErr	
		move.l	_DosBase,a6
		lea	errNoTable,a5
		move.l	(a5,d7.w*4),d1
		clr.l	d2
		CALL	VPrintf
.noErrEnd	
	
	; - - - - close libs
	move.l	4.w,a6 ; exec
	moveq	#3-1,d7
	lea		_IntuitionBase(pc),a2
.freelibloop
	move.l	(a2)+,a1
	CALL	CloseLibrary    
	dbf		d7,.freelibloop

	; - - - answer possible Workbench message
	move.l	(sp)+,d0
	beq.s	.noMsgReply
	move.l	d0,a1   ; got to do that if app thrown from WB.
	CALL	ReplyMsg
.noMsgReply

	; quit app, return code 0   in d0
	moveq   #0,d0 ; official DOS return code
	rts
_shunt:
	; - - - - system shutdown part

;	 bsr initKeyboard


	; moved in func to to be able to 
	; finish condition test in main
	
	; a6 exec 
	move.l	4.w,a6	
	CALL    Forbid

	move.l	_mdata(pc),a4
	
	move.w	#$8000,d0
	move.l	#$dff000,a5
	move.w	intenar(a5),d1
	move.w	dmaconr(a5),d2    
	move.w	intreqr(a5),d3
	move.w	adkconr(a5),d4
	or.w	d0,d1
	or.w	d0,d2
	or.w	d0,d3
	or.w	d0,d4
	move.w	d1,md_intena(a4)
	move.w	d2,md_dmacon(a4)
	move.w	d3,md_intreq(a4)
	move.w	d4,md_adkcon(a4)

	; - - - - - - - dmacon	
;	 move.w	 #$7fff,dmacon(a5) ;Disable DMAs
;oldglitychy move.w  #%1000001111000000,dmacon(a5)

	move.w  #$83ff,dmacon(a5)
	;Master,Copper,Blitter,Bitplanes DISK


;	 move.w	  #%1000001111010000,dmacon(a5) ;

	;move.w	#$83ff,dmacon(a5)
	;dmacon:
	; b15:blitter set	
	; b11/12:XX  b13: BlitterZero b14:blitterbuzy
	; b8:bitplanes b9: enable all b10: blitter DMA priority
	; b4: disk b5:sprite b6: blitter b7:copro DMA
	; b0->b3 audio

	; - - - - - intena
;	 move.w	 #%0111111111111111,intena(a5)		 ;Disable IRQs
;	 move.w	 #%1110000000000000,intena(a5)
	;		    ED  	         master lev6
	;		                 2   diskblock finished
	
; intena:;
;b11serialport b12:disksync b13:external b14:Master
;b4:copro? b5:VERTB b6:blitterfinished b7-b10 audio finished
;b0 serial b1diskblockfinished b2:reserv b3: IO ports
;was	move.w	#$e000,intena(a5)		;Master and lev6	
	
	; - - - set irq
    ; exec: a6

    lea		md_sirq(a4),a1
	lea		md_irqdat(a4),a2
	move.w	#$027f,LN_TYPE(a1) ; LN_TYPE,LN_PRI 2,127
	move.l	a2,IS_DATA(a1)
	move.l	#irqcode,IS_CODE(a1)

	; the Paula interrupt bit number (0 through 14).
	moveq.l #5,d0   ;VERTB
	CALL	AddIntServer	; return nothing
	move.w	#1,md_irqOn(a4) 


	move.l	_GfxBase(pc),a6
	CALL	WaitBlit
	move.l	gb_ActiView(a6),md_view(a4)

	sub.l	a1,a1
	CALL	LoadView
	CALL	WaitTOF
	CALL	WaitTOF

	; - - dark available next frame:
	move.l #bplm,d0
	move.w	d0,bplp+6
	swap	d0
	move.w	d0,bplp+2
	lea copperboot,a0
	move.l	a0,cop1lc+$dff000
	
	rts
_wbView:
	ifne    TAKEOVER



	; - - - remove irq
	move.l	4.w,a6
	move.l	_mdata(pc),a4

	tst.w   md_irqOn(a4)
	beq		.noremint
	lea		md_sirq(a4),a1
	moveq.l #5,d0   ; paula interupt bit:VERTB
	CALL	RemIntServer
.noremint
	; note: stops after the waitTOF


;	 move.w	 #$00f0,d0
;	 bsr    setColSc

	move.l	#$dff000,a5	
	move.l	_mdata(pc),a4

	; - - - recover state before forbid...
	move.w	md_intena(a4),intena(a5)
	move.w	md_dmacon(a4),dmacon(a5)
	move.w	md_intreq(a4),intreq(a5)
	move.w	md_adkcon(a4),adkcon(a5)

; - - - screen back must happens before own screen meme close
	move.l	_GfxBase(pc),a6
	; get wb's copper pointer in gfxbase
	; re-put it in hardware.
	move.l	38(A6),cop1lc(a5)
	move.l  md_view(a4),a1
	CALL    LoadView
	CALL    WaitTOF
	CALL    WaitTOF
    
	movea.l	4.w,a6
	CALL    Permit




	; end takeover restore
	endc

	rts
; - - - - - - - - 
; useless because we use addintserver
;vbr_exception:
;	 ; movec vbr,Xn is a priv. instr.  You must be supervisor to execute!
;	 movec   vbr,d0
;	 ; many assemblers don't know the VBR, if yours doesn't, then use this
;	 ; line instead.
;	 ;   dc.w    $4e7a $0801 ;vic:équivalent movec
;	 rte             ; back to user state code
; - - - - - - - -
	even
irqcode:
	; executed each 50 hz on pal	
	movem.l	d2-d7/a2-a4,-(sp)
	tst.b	_ntsc(pc)
	beq	.pal
		addq.l	#5,_time ;ntsc 300=1sec	
	bra	.nopal
.pal
		addq.l	#6,_time	; pal 300=1sec
.nopal

	move.l	_irqcode,a0
	tst.l	a0
	beq		.noc
		jsr	(a0)	
.noc	
	

;    Servers are called with the following register conventions:
;        D0 - scratch
;        D1 - scratch
;        A0 - scratch
;        A1 - server is_Data pointer (scratch)
;        A5 - jump vector register (scratch)
;        A6 - scratch
;        all other registers must be preserved

	movem.l (sp)+,d2-d7/a2-a4
	moveq	#0,d0 ; set z for chain or it is bad
	rts
; - - - - - -- --
	ifne    DOKEYBOARD
	XDEF    initKeyboard
initKeyboard:
	move.l   4.w,a6
	CALL     CreateMsgPort
	move.l 	d0,a5    ; a5 = MsgPort
	move.l	d0,kbdport

	move.l   d0,a0
	move.l   #IOSTD_SIZE,d0
	CALL     CreateIORequest
	move.l   d0,a4     ; a4 = IOStdReq
	move.l	   d0,kbdioReq

	lea      inputdevice(pc),a0
	moveq    #0,d0
	move.l   a4,a1
	clr.l    d1
	CALL	 OpenDevice

	; set up our input handler
;	 sub.l    a1,a1
;	 CALL	  FindTask

	lea	kbdh(pc),a3	   
;	 move.l   d0,IS_DATA(a3)
	move.l	a3,IS_DATA(a3) ; must be filled
	move.l   #handlercode,IS_CODE(a3)
	move.b   #127,LN_PRI(a3)
	move.l   #handlername,LN_NAME(a3)

	; add it to the chain of handlers
	move.l   a3,IO_DATA(a4)
	move.w   #IND_ADDHANDLER,IO_COMMAND(a4)
	move.l   a4,a1
	CALL	 DoIO
	rts
	XDEF    closeKeyboard
closeKeyboard:
	; remove the handler and clean up

	lea		kbdh(pc),a3
	move.l  kbdioReq(pc),a4
	move.l   4.w,a6

	move.l   a3,IO_DATA(a4)
	move.w   #IND_REMHANDLER,IO_COMMAND(a4)
	move.l   a4,a1
	CALL	 DoIO

	move.l   a4,a1
	CALL	 CloseDevice
	move.l   a4,a0
	CALL	 DeleteIORequest
	move.l	kbdport,a0
	CALL	 DeleteMsgPort

	rts
; the input handler receives a linked list of events in A0
; and must return the new list in D0. register A1 will
; contain the IS_DATA field of the Interrupt structure
handlercode:
	move.l   a0,d0

	 ; check if we have pressed the escape key
.check
; - - - - -keyboard events - - -
	move.b  ie_Class(a0),d7
	cmp.b    #IECLASS_RAWKEY,d7
	bne      .notkbd
; ie_code: for up, or $80.
; esc:$45 space:$40 ret:$44 a:$10 z:$11
; ctrl:$63 alt1:$64 alt2:$65
;arrow up:$4c down:$4d left: $4f right:$4e

;	 move.w  ie_Code(a0),_debugv+10
	cmp.w    #$c5,ie_Code(a0) ;esc up
	bne      .noend
		move.b	#1,_doEnd
.noend

	; null this event so they keypress isn't seen by the system
	move.b   #IECLASS_NULL,ie_Class(a0)

	; signal ABORT to our task. (A1 already points to our task)
	;movem.l  d0/a6, -(sp)
	;	 move.l   4, a6
	;	 move.l   #SIGF_ABORT, d0
	;	 call     Signal
	;movem.l  (sp)+, d0/a6
	;rts

	; check the next event in this list
.notkbd
	cmp.b	#IECLASS_RAWMOUSE,d7
	bne	.notmouse
    move.b   #IECLASS_NULL,ie_Class(a0)

.notmouse
	
	move.l    ie_NextEvent(a0),a0
	move.l    a0,d1
	bne       .check
	; here d0 must be list !!!
	rts
; - - -  - - - - -
kbdioReq:	dc.l	0
kbdport:	dc.l	0
kbdh:	 dcb.b   IS_SIZE,0
handlername  dc.b      "d",0
inputdevice  dc.b      "input.device",0
	even
	endc ; end DOKEYBOARD
; - - - - - - - -
_mdata	dc.l	0
_time:	dc.l	0
_irqcode:	dc.l	0
_exitErrNo	dc.w	0
_StartupEndStack:   dc.l    0

; the library bases can be accessed by any linked code
_IntuitionBase:	dc.l    0
_GfxBase:		dc.l    0
_DOSBase:
_DosBase:		dc.l    0

StringRequester	dc.l	20
				dc.l	0
				dc.l	Reqt
				dc.l	noAgal
				dc.l	Reqok
errNoTable:	dc.l	noAgal,noMeml,noDatl    
_midY:	dc.w   128	  ;100 or 128
_doEnd:	dc.b    0
_ntsc:	dc.b	0
; - - -let names together:
intname: INTNAME
gfxname: GRAFNAME
dosname: DOSNAME
noAgal: dc.b	10,'need AGA Machine',10,10,0
noMeml: dc.b	10,'no Mem!',10,10,0
noDatl: dc.b	10,'no .dat file!',10,10,0
Reqt			dc.b 'Error',0
Reqok			dc.b 'Ok',0
    ; insert other strings here
	ifne MDEBUG
_debugl:	dc.b 10,'value:%ld %ld %ld %ld',10
			dc.b 'chip:%ld fast:%ld',10,10,0
		even
_debugv:	dc.l	0,0,0,0,0,1
	XDEF    setColSc
setColSc:
	;d0 color
	move.w	d0,coppercolor+2
	lea	copperboot,a0
	move.l	a0,cop1lc+$dff000
	move.l	_GfxBase,a6
	CALL	WaitTOF
	CALL	WaitTOF
	rts

	endc
    even

	section    copro,data_c
	cnop	0,8
bplm:	dcb.b	40,$00 ; works
copperboot:
	dc.w	fmode,0 ; must first ?
	dc.w    diwstrt,$2c81
	dc.w    diwstop,$2cc1
	dc.w    ddfstrt,$0038
	dc.w    ddfstop,$00d0
	dc.w	bplcon0,$1200 ; 1 plane
	dc.w	bplcon1,0
	dc.w	bplcon3,0
	dc.w	bplcon4,$0011
	dc.w	bpl1mod,-40
	dc.w	bpl2mod,-40
coppercolor:
	dc.w	$0180,$0000
bplp:
	dc.w    bplpt,0,bplpt+2,0

	dc.w    sprpt,0,sprpt+2,0
	dc.w    sprpt+4,0,sprpt+6,0
	dc.w    sprpt+8,0,sprpt+10,0
	dc.w    sprpt+12,0,sprpt+14,0
	dc.w    sprpt+16,0,sprpt+18,0
	dc.w    sprpt+20,0,sprpt+22,0
	dc.w    sprpt+24,0,sprpt+26,0
	dc.w    sprpt+28,0,sprpt+30,0	 
	dc.w	$ffff,$fffe
	dc.w	$ffff,$fffe

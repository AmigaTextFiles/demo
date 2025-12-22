*****************************************************************
*	IORoutines.asm                                              
*	~~~~~~~~~~~~~~                                              
*	Description : This file contains all the I/O Routines 
*		      in this intro/pack/demo..	 
*			
*	Code : Dennis Predovnik (SuLtAn/DVS)
*	Date : 13/3/96 
*
*****************************************************************

	section		IORoutines,code

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*		checkSelection					*
*								*
* Description : Function checks the user's input and acts	*
*               accordingly...                                  *
*								*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

checkSelection:
	moveq	#0,d0
	jsr	GET			     ; Scan Keyz !
	cmpi.w	#13,d0
	bne	chkDown
	bra	loadThaMod
	rts
chkDown:
	cmpi.w	#31,d0
	bne	chkUp
	cmpi.w	#4,exeVar                    ; Passed Down Limit ?
	bgt	chkUp
	addq.w	#1,exeVar                    ; Down Key pressed
	jsr	moveCursor
	rts
chkUp:	
	cmpi.w	#30,d0
	bne     chkMouse 
	tst	exeVar
	ble     chkMouse
	subq.w	#1,exeVar   
	jsr	moveCursor
chkMouse:
	rts

moveCursor:
        move.w	exeVar,d1
	move.l	#curL,a0
	move.l	#CURL_X,d2        
	jsr	updateCursor
	moveq	#0,d1
        move	exeVar,d1
	move.l	#curR,a0
	move.l	#CURR_X,d2        
	jsr	updateCursor
	rts

loadThaMod:
	cmpi.w	#0,exeVar
	bne	chk1
;	jsr	musicOut
	jsr	PT_End
	jsr	PT_DMAWait
	lea.l	Mod0,a0
	jsr	PT_Init	
;	jsr	musicIn	
	rts
chk1:
	cmpi.w	#1,exeVar
	bne	chk2	
;	jsr	musicOut
	jsr	PT_End
	jsr	PT_DMAWait
	lea.l	Mod1,a0
	jsr	PT_Init	
;	jsr	musicIn
	rts
chk2:
	cmpi.w	#2,exeVar
	bne	chk3	
;	jsr	musicOut
	jsr	PT_End
	jsr	PT_DMAWait
	lea.l	Mod2,a0
	jsr	PT_Init	
;	jsr	musicIn
	rts
chk3:
	cmpi.w	#3,exeVar
	bne	chk4	
;	jsr	musicOut
	jsr	PT_End
	jsr	PT_DMAWait
	lea.l	Mod3,a0
	jsr	PT_Init	
;	jsr	musicIn
	rts
chk4:
	cmpi.w	#4,exeVar
	bne	chk5	
;	jsr	musicOut
	jsr	PT_End
	jsr	PT_DMAWait
	lea.l	Mod4,a0
	jsr	PT_Init	
;	jsr	musicIn
	rts
chk5:
	cmpi.w	#5,exeVar
	bne	endMod	
;	jsr	musicOut
	jsr	PT_End
	jsr	PT_DMAWait
	lea.l	Mod5,a0
	jsr	PT_Init	
;	jsr	musicIn
endMod:
	rts


musicOut:
	move.l	#63,d0
	move.l	#63,d1
musicOutLoop:	
	WaitVBL
	WaitVBL
	movem.l	d0/d1,-(sp)
	jsr	PT_SetMasterVol
	movem.l	(sp)+,d0/d1
	subq	#1,d0
	dbra	d1,musicOutLoop
	rts

musicIn:
	moveq	#0,d0
	moveq	#0,d1
musicInLoop:	
	WaitVBL
	WaitVBL
	movem.l	d0/d1,-(sp)
	jsr	PT_SetMasterVol
	movem.l	(sp)+,d0/d1
	addq	#1,d0
	addq	#1,d1
	cmpi	#63,d0
	blt	musicInLoop
	rts

; I cant remember where I got this routine , but its useful !!
; jsr GET
; and d0 holds the ascii value of the key you pressed! useful
; it does shifted keys, normal keys, fkeys etc..

GET:
GETT:	MOVE.L $DFF004,D0	; APPROPRIATE WAIT...
	AND.L #$F00,D0
	BNE.S GETT
        MOVE.B OLDVCH(PC),d0
	MOVE.B $BFEC01,D0
	NOT.W D0
	ROR.B #1,D0
	ANDI.W #$FF,D0
	BTST #7,D0
	BNE.S RELEASE
	CMP.B OLDVCH(PC),D0
	BNE.S RELEASE
	ADDI.B #1,RPCNT
	TST.B RFLAG
	BEQ.S RPNEW
	CMPI.B #10,RPCNT	; BETWEEN REP CHARS...
	BEQ.S NEWCH
NULLCH:	MOVE.B #$6F,D0
	BRA.S SHTST
RPNEW:	CMPI.B #250,RPCNT	; INITIAL WAIT
	BNE.S NULLCH
	MOVE.B #1,RFLAG
	CLR.B RPCNT
	BRA.S SHTST
RELEASE:CLR.B RFLAG
NEWCH:	CLR.B RPCNT
	MOVE.B D0,OLDVCH
SHTST:	CMPI.B #$60,D0
	BEQ.S ASHIF
	CMPI.B #$61,D0
	BEQ.S ASHIF
	CMPI.B #$E0,D0
	BEQ.S KSHIF
	CMPI.B #$E1,D0
	BEQ.S KSHIF
GCHTAB:	BTST #7,D0
	BEQ.S GCHB
	MOVE.B #$6F,D0
GCHB:	LEA UKTAB(PC),A0
	TST.B SHIFLAG
	BEQ.S GCHA
	LEA SKTAB(PC),A0
GCHA:	ANDI.W #$7F,D0
	MOVE.B (A0,D0.W),D0
	TST.B SHIFLAG
	BNE.S GCHEX
	CMPI.B #"a",D0
	BLT.S GCHEX
	CMPI.B #"z",D0
	BGT.S GCHEX
	SUBI.B #32,D0
GCHEX:	MOVE.B D0,CHV
	RTS
ASHIF:	MOVE.B #1,SHIFLAG
	BRA.S GCHTAB
KSHIF:	CLR.B SHIFLAG
	BRA.S GCHTAB

********** USA1 KEYMAPS **********
* NOTE: F1-F10 ARE 128-137
* HELP=138, RT=28, LFT=29, UP=30, DN=31
* ESC=27, BKsp[<-]=8 TAB=9, SHTAB=12
* ENT=13, SHENT=10
* DEL=127
********** USA1 KEYMAPS **********

OLDVCH:	 DC.B $C4
CHV:	 DC.B 0
RPCNT:	 DC.B 0
RFLAG:	 DC.B 0
SHIFLAG: DC.B 0

UKTAB:	DC.B "`1234567890-=\",0,"0"
	DC.B "qwertyuiop[]",0,"123"
	DC.B "asdfghjkl;'",0,0,"456"
	DC.B 0,"zxcvbnm,./",0,".789"
	DC.B 32,8,9,13,13,27,127,0,0,0,"-",0,30,31,28,29
	DC.B 128,129,130,131,132,133,134,135,136,137,"()/*+",138
	DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

SKTAB:	DC.B "~!@#$%^&*()_+|",0,"0"
	DC.B "QWERTYUIOP{}",0,"123"
	DC.B "ASDFGHJKL:",34,0,0,"456"
	DC.B 0,"ZXCVBNM<>?",0,".789"
	DC.B 32,8,12,10,10,27,127,0,0,0,"-",0,30,31,28,29
	DC.B 128,129,130,131,132,133,134,135,136,137,"()/*+",138
	DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

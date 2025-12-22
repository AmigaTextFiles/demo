
***************************************************************
*****							*******
*******		Project: Banana Dance (chip tune disk) *******
*******						       ********
*******		Code   : Grace                         ********
*******         GFx    : Ramon                         ********
******          Music  : Crush                          *******
*****                                                    ******
***************************************************************



		Incdir	Asm-Includes:

		include	hardware/custom.i
		include	hardware/dmabits.i
		include	hardware/intbits.i

		include	dos/dosextens.i
		include	lvo.i


MEMORYBLOCK	equ	640*400
TASKPRI		equ	0


		section	startup,code


************************************************
*************	icon startup     ***************
************************************************

Startup:	bra	open
		move.l	$4.w,a6
		sub.l	a1,a1			
		jsr	_LVOFindTask(a6)
		move.l	d0,sys_task
		move.l	d0,a3
		tst.l	pr_CLI(a3)
		bne.s   .ycli
		lea	pr_MsgPort(a3),a0
		jsr	_LVOWaitPort(a6)
		lea	pr_MsgPort(a3),a0
		jsr	_LVOGetMsg(a6)
		move.l	d0,sys_msg

.ycli:		move.l	sys_task,a1		; set task priority
		moveq	#TASKPRI,d0
		jsr	_LVOSetTaskPri(a6)
		move.w	d0,sys_taskpri


************************************************
*************	open dos.library ***************
************************************************

open:		move.l	$4.w,a6
		lea	dosname,a1
		moveq	#0,d0
		jsr	_LVOOpenLibrary(a6)
		move.l	d0,dosbase
		beq.w	End


************************************************
*************	AllocMem(),genuegend Speicher? *
************************************************

		move.l	$4.w,a6
		move.l	#MEMORYBLOCK,d0
		move.l	#$10002,d1
		jsr	_LVOAllocMem(a6)
		move.l	d0,memadr
		beq.w	No_Mem
		
************************************************
*************	Wieviel Speicher vorhanden?    *
************************************************

		move.l	$4.w,a6
		move.l	#$4,d1
		jsr	_LVOAvailMem(a6)
		move.l	d0,d4
		lea	FastCount+28,a0
		jsr	Convert
		
		move.l	$4.w,a6
		move.l	#$2,d1
		jsr	_LVOAvailMem(a6)
		move.l	d0,d4
		lea	ChipCount+28,a0
		jsr	Convert
		

************************************************
*************	AGA Amiga oder nicht?    *******
************************************************

		lea	$dff000,a5
		move.w	$7c(a5),d0
		cmpi.b	#$f8,d0
		bne.w	No_Aga
		move.l	$4.w,a6
		moveq	#39,d0
		move.l	#gfxname,a1
		jsr	_LVOOpenLibrary(a6)
		move.l	d0,gfxbase
		beq.w	No_Aga
		
************************************************
************	Loesche Cache Speicher *********
************************************************

		move.l	$4.w,a6
		cmp.w	#37,$14(a6)
		bcs.s	CpuCheck
		jsr	_LVOCacheClearU(a6)
		
************************************************
***********	Check CPU	****************
************************************************

CpuCheck:	move.l	$4.w,a6
		move.w	$128(a6),d0
		
		btst	#7,d0
		beq.s	Mc040
		move.l	#$68060,Cpu
		bra.b	Mc04x
		
Mc040:		btst	#3,d0
		beq.b	Mc030
		move.l	#$68040,Cpu
		bra.b	Mc04x
		
Mc030:		btst	#2,d0
		beq.s	Mc020
		move.l	#$68030,Cpu
		bra.b	Mc04x
		
Mc020:		btst	#1,d0
		beq.b	Mc010
		move.l	#$68020,Cpu
		bra.b	Mc04x
		
Mc010:		btst	#0,d0
		beq.b	Mc04x
		move.l	#$68010,Cpu
		
Mc04x:		btst	#6,d0
		beq.s 	TestFPU
		move.l	#$68040,Cpu
		move.l	#$68882,Fpu
		bra.b	PutOut
		
TestFPU:	btst	#5,d0
		beq.b	Mc68882
		move.l	#$68882,Fpu
		bra.b	PutOut
		
Mc68882:	btst	#4,d0
		beq.b	PutOut
		move.l	#$68881,Fpu
		
		
PutOut:		bsr.w	GetCli
		move.l	#InfoMsg,d2
		move.l	#InfoMsgE-InfoMsg,d3
		move.l	Cli,a1
		jsr	_LVOWrite(a6)
		move.l	Cpu,d0
		lea	Processor+26,a0
		bsr	MakeDigit
		bsr.w	GetCli
		move.l	#Processor,d2
		moveq	#49,d3
		move.l	Cli,a1
		jsr	_LVOWrite(a6)
		cmp.l	#0,Fpu
		beq.b	NoFpu
		move.l	Fpu,d0
		lea	MathProc+26,a0
		bsr	MakeDigit
		bsr.w	GetCli
		move.l	#MathProc,d2
		moveq	#49,d3
		move.l	Cli,a1
		jsr	_LVOWrite(a6)
		bra.b	ChipRam
NoFpu:		bsr.w	GetCli
		move.l	#NoMathProc,d2
		moveq	#49,d3
		move.l	Cli,a1
		jsr	_LVOWrite(a6)   
		

ChipRam:	bsr.w	GetCli
		move.l	#ChipCount,d2
		moveq	#49,d3
		move.l	Cli,a1
		jsr	_LVOWrite(a6)
		bsr.w	GetCli
		move.l	#FastCount,d2
		moveq	#49,d3
		move.l	Cli,a1
		jsr	_LVOWrite(a6)
		bsr.w	GetCli
		move.l	#CredizMsg,d2
		move.l	#CredizMsgE-CredizMsg,d3
		move.l	Cli,a1
		jsr	_LVOWrite(a6)


;-------------------------------------------------------------------

;	Jump to Main-Routine here

		jsr	Presents
		jsr	Title
		jsr	Menu
		
;-------------------------------------------------------------------


Close_GfxLib:	move.l	$4.w,a6
		move.l	gfxbase,a1
		jsr	_LVOCloseLibrary(a6)
                
Free_Mem:	move.l	$4.w,a6
		move.l	memadr,a1
		move.l	#MEMORYBLOCK,d0
		jsr	_LVOFreeMem(a6)

Close_DosLib:	move.l	$4.w,a6
		move.l	dosbase,a1
		jsr	_LVOCloseLibrary(a6)
           
End:		move.l	sys_task,a1		
		move.w	sys_taskpri,d0
		jsr	_LVOSetTaskPri(a6)

		tst.l	sys_msg			
		beq.s	.nmsg
		jsr	_LVOForbid(a6)
		move.l	sys_msg,a1
		jsr	_LVOReplyMsg(a6)
.nmsg		moveq	#0,d0
		rts 


**************************************************************************
**************  Konvertiere Hexadezimalzahlen zu Dezimalzahlen  **********
**************************************************************************

Convert:	move.l	d0,d1
		andi.l	#$ffff0000,d1
		swap	d1
                
nextdigit:	divu	#10,d1
		move.w	d1,d2
		ext.l	d2
		andi.l	#$ffff0000,d1
		andi.l	#$0000ffff,d0
		add.l	d1,d0
		divu	#10,d0
		swap	d0
		addi.b	#48,d0
		move.b	d0,-(a0)
		swap	d0         
		andi.l	#$0000ffff,d0
		move.l	d2,d1
		add.l	d0,d2
		bne.b	nextdigit
		rts
                                        
MakeDigit:	moveq	#4,d1
		moveq	#0,d2
.loop:		move.b	d0,d2
		and.b	#$0f,d2
		add.b	#48,d2
		move.b	d2,-(a0)
		ror.l	#4,d0
		dbra	d1,.loop
		rts                   		


GetCli:		move.l	dosbase,a6
		jsr	_LVOOutput(a6)
		move.l	d0,Cli
		move.l	Cli,d1
		rts

**************************************************************************
*************   Die alten WorkBenchWerte speichern   *********************
**************************************************************************


TakeOSdisplay:	move.l	gfxbase,a6
		move.l	$22(a6),a0
		move.l	a0,system_view
		move.l	$26(a6),system_copper
		suba.l	a1,a1
		jsr	_LVOLoadView(a6)        ;GRAPHICS LoadView (NULL)
		jsr	_LVOWaitTOF(a6)         ;GRAPHICS WaitTOF
		jsr	_LVOWaitTOF(a6)         ;GRAPHICS WaitTOF
		rts                                        

RestoreOSdisplay:
		move.l	gfxbase,a6
		move.l	system_copper,$dff080
		move.w	#$8020,$dff096
		move.l	system_view,a1
		jsr	_LVOLoadView(a6)        ;GRAPHICS LoadView (fix OLD view)
		rts              

***************************************************************************
**************  Alten Interrupt speichern und neuen anlegen        ********
***************************************************************************

GetVBInt:	suba.l	a0,a0
		movea.l	$4,a6
		move.w	$128(a6),d0
		and.w	#$0001,d0
		beq.w	VBInit
        
		move.l	$4.w,a6
		lea	VB(pc),a5
		jsr	_LVOSupervisor(a6)
                                       
VBInit:		lea	$dff000,a5
		move.w	$1c(a5),dmacon_old
		ori.w	#$8000,dmacon_old
		move.w	$2(a5),intena_old
		ori.w	#$c000,intena_old
		move.w	#$3fdf,$9a(a5)
		move.w	#$0020,$96(a5)
		move.l	$6c.w,old_vb
		move.l	#First_VB,$6c.w
		rts
                                                                        
VB:		movec	vbr,a0
		move.l	a0,vb_last
		rte             		


First_VB:	movem.l	d0-d7/a0-a6,-(sp)
		jsr     tp_play

		cmp.w	#0,EnableMaus
		beq.s	.conti

		jsr 	CheckMausPos

.conti		cmp.w	#0,bananaplay
		beq.s	.conti2
		jsr	BandAnim

.conti2		move.w	#$0020,$dff09c
		movem.l (sp)+,d0-d7/a0-a6
		rte
		
RestoreVBInt:	lea	$dff000,a5
		move.w	#$7fff,$9a(a5)
		move.l	old_vb,$6c.w
		move.w	dmacon_old,$9a(a5)
		move.w	intena_old,$96(a5)
		rts 		
		
****************************************************************************
***********     Kein Speicher vorhanden => TextAusGabe    ******************
****************************************************************************

No_Mem:		bsr.w	GetCli
		move.l	#ErrorMsg,d2
		move.l	#ErrorMsgE-ErrorMsg,d3
		jsr	_LVOWrite(a6)
		bra.w	Close_DosLib     

****************************************************************************
***********     Kein AGA Amiga => TextAusGabe       ************************
****************************************************************************

No_Aga:		bsr.w	GetCli
		move.l	#NoAgaMsg,d2
		move.l	#NoAgaMsgE-NoAgaMsg,d3
		jsr	_LVOWrite(a6)
		bra.w	Free_Mem
                                

***************************************************************************
************    Pointers                   ********************************
***************************************************************************

		section	startupdata,data
		
copper_view:	dc.l	0
dosbase:	dc.l	0
crmbase:	dc.l	0
memadr:		dc.l	0
gfxbase:	dc.l	0
Cpu:		dc.l	0
Fpu:		dc.l	0
Cli:		dc.l	0
system_view:	dc.l	0
system_copper:	dc.l	0
sys_task:	dc.l	0
sys_msg:	dc.l	0
sys_taskpri:	dc.l	0
old_vb:		dc.l	0
vb_last:	dc.l	0
dmacon_old:	dc.w	0
intena_old:	dc.w	0

gfxname:	dc.b	'graphics.library',0
dosname:	dc.b	'dos.library',0

NoAgaMsg:	dc.b	'You do not have the AGA chipset.',10
NoAgaMsgE:	dc.b	0
ErrorMsg:	dc.b	'Something went wrong.',10
		dc.b	'Not enough chipmem available.',10,10
ErrorMsgE:	dc.b	0
InfoMsg:	dc.b	'(o)------------------------------------------(o)',10
		dc.b	' |   H a r d w a r e - I n f o r m a t i o n  | ',10
		dc.b	' |                                            | ',10
		dc.b	' |                                            | ',10
InfoMsgE:	dc.b	0


Processor:	dc.b	' |             CPU:                           | ',10
MathProc:	dc.b	' |             FPU:                           | ',10
ChipCount:	dc.b	' |             Chip:          Bytes free.     | ',10
FastCount:	dc.b	' |             Fast:          Bytes free.     | ',10
NoMathProc:	dc.b	' |             FPU:  none                     | ',10
CredizMsg:	dc.b	' |                                            | ',10
		dc.b	' |                                            | ',10
		dc.b	' |             Code  : GrAcE/Crux Design      | ',10
		dc.b	' |             Gfx   : Ramon                  | ',10
		dc.b	' |             Music : Crush                  | ',10
		dc.b	' |                                            | ',10
		dc.b	' |                                            | ',10
		dc.b	' |                                            | ',10
		dc.b	' |             finished on 3.October 1997     | ',10
		dc.b	'(o)------------------------------------------(o)',10,10
		dc.b	'Decrunching.....                                ',10,10
CredizMsgE:	dc.b	0        


		cnop	0,8



;----------------------------------------------------------------------------

		Incdir	dh0:tmp/dance/


;----------------------------------------------------------------------------

; 		Present-Routine

;----------------------------------------------------------------------------


MEMSIZE		equ	320*256

;----------------------------------------------------------------------------

;--------------------------------------------------------------------------------



		section	Main,code


Presents:	bsr	Waiting2
		lea	$dff000,a5
		jsr	TakeOSdisplay


		lea	$dff000,a5
		move.l	#CopperList,$80(a5)
		clr.w	$88(a5)		
		
		move.l	memadr,d0
		lea	Planes,a0
		move.l	#MEMSIZE/8,d1		
		moveq	#3-1,d7			;3 Planes
		bsr	SetPlanes

		bsr	Waiting2

;----------------------------------------------------------------------------

		move.l	#PresentsGFX,SourceAdr
		move.l	memadr,a0
		add.l	#320*80/8,a0
		move.l	a0,DestAdr
		move.w	#0,SourceMod
		move.w	#0,DestMod
		move.w	#3-1,BlitterLoops	; 3 planes
		move.w	#80*64+20,BlitterHeight
		move.l	#320*80/8,PicHeight
		move.l	#320*256/8,DestHeight
		bsr	StartBlitter
		
		move.l	#CopColor+2,CopperColorAdr
		move.l	#PresentsCols,ColorTable
		move.w	#8-1,ColorAnzahl	;8 Colors
		bsr	Fade_in

		bsr	Waiting2


;----------------------------------------------------------------------------
		
		move.l	#GraceGFX,SourceAdr
		move.l	memadr,DestAdr
		move.w	#0,SourceMod
		move.w	#22,DestMod
		move.w	#3-1,BlitterLoops	; 3 planes
		move.w	#35*64+9,BlitterHeight
		move.l	#144*35/8,PicHeight
		move.l	#320*256/8,DestHeight
		bsr	StartBlitter
		
		move.l	#TopColor+2,CopperColorAdr
		move.l	#CreditsCols,ColorTable
		move.w	#8-1,ColorAnzahl	;8 Colors
		bsr	Fade_in

		bsr	Waiting2

		move.l	#TopColor+2,CopperColorAdr
		move.w	#8-1,ColorAnzahl	;8 Colors
		bsr	Fade_out

		bsr	Waiting


;----------------------------------------------------------------------------


		move.l	#RamonGFX,SourceAdr
		move.l	memadr,d0
		add.l	#320*210/8+22,d0
		move.l	d0,DestAdr
		move.w	#0,SourceMod
		move.w	#22,DestMod
		move.w	#3-1,BlitterLoops	; 3 planes
		move.w	#35*64+9,BlitterHeight
		move.l	#144*35/8,PicHeight
		move.l	#320*256/8,DestHeight
		bsr	StartBlitter
		
		move.l	#BelowColor+2,CopperColorAdr
		move.l	#CreditsCols,ColorTable
		move.w	#8-1,ColorAnzahl	;8 Colors
		bsr	Fade_in

		bsr	Waiting2

		move.l	#BelowColor+2,CopperColorAdr
		move.w	#8-1,ColorAnzahl	;8 Colors
		bsr	Fade_out

		bsr	Waiting


;----------------------------------------------------------------------------

		move.l	#ClearMap,SourceAdr
		move.l	memadr,DestAdr
		move.w	#0,SourceMod
		move.w	#22,DestMod
		move.w	#3-1,BlitterLoops	; 3 planes
		move.w	#35*64+9,BlitterHeight
		move.l	#144*35/8,PicHeight
		move.l	#320*256/8,DestHeight
		bsr	StartBlitter

;----------------------------------------------------------------------------

		move.l	#CrushGFX,SourceAdr
		move.l	memadr,d0
		add.l	#22,d0
		move.l	d0,DestAdr
		move.w	#0,SourceMod
		move.w	#22,DestMod
		move.w	#3-1,BlitterLoops	; 3 planes
		move.w	#35*64+9,BlitterHeight
		move.l	#144*35/8,PicHeight
		move.l	#320*256/8,DestHeight
		bsr	StartBlitter
		
		move.l	#TopColor+2,CopperColorAdr
		move.l	#CreditsCols,ColorTable
		move.w	#8-1,ColorAnzahl	;8 Colors
		bsr	Fade_in

		bsr	Waiting2

		move.l	#TopColor+2,CopperColorAdr
		move.w	#8-1,ColorAnzahl	;8 Colors
		bsr	Fade_out

		bsr	Waiting

;----------------------------------------------------------------------------


		move.l	#CopColor+2,CopperColorAdr
		move.w	#8-1,ColorAnzahl	;8 Colors
		bsr	Fade_out

		rts




;----------------------------------------------------------------------------

; 		Title-Routine

;----------------------------------------------------------------------------



Title:		move.l	memadr,d0
		lea	Planes,a0
		move.l	#MEMSIZE/8,d1		
		moveq	#5-1,d7			
		bsr	SetPlanes

		move.l	#$01005200,DMACON

		move.l	#TitleGFX,SourceAdr
		move.l	memadr,a0
		add.l	#320*50/8,a0
		move.l	a0,DestAdr
		move.w	#0,SourceMod
		move.w	#0,DestMod
		move.w	#5-1,BlitterLoops	
		move.w	#150*64+20,BlitterHeight
		move.l	#320*150/8,PicHeight
		move.l	#320*256/8,DestHeight
		bsr	StartBlitter

		move.l	#CopColor+2,CopperColorAdr
		move.l	#TitleCols,ColorTable
		move.w	#32-1,ColorAnzahl	
		bsr	Fade_in


		jsr	GetVBInt    		; start interrupt server

		move.l	#Tune_1,tp_data	
		jsr	tp_init

		move.w	#0,tp_volume
		bsr	SlideVolOn

;----------------------------------------------------------------------------

		move.l	#ClearMap,SourceAdr
		move.l	memadr,d0
		add.l   #320*210/8+22,d0
		move.l	d0,DestAdr
		move.w	#0,SourceMod
		move.w	#22,DestMod
		move.w	#3-1,BlitterLoops	; 3 planes
		move.w	#35*64+9,BlitterHeight
		move.l	#144*35/8,PicHeight
		move.l	#320*256/8,DestHeight
		bsr	StartBlitter

;----------------------------------------------------------------------------


		move.l	#BananaGFX,SourceAdr
		move.l	memadr,a0
		add.l	#320*208/8+18,a0
		move.l	a0,DestAdr
		move.w	#0,SourceMod
		move.w	#34,DestMod
		move.w	#5-1,BlitterLoops	
		move.w	#45*64+3,BlitterHeight
		move.l	#48*45/8,PicHeight
		move.l	#320*256/8,DestHeight
		bsr	StartBlitter

		move.l	#BelowColor+2,CopperColorAdr
		move.l	#BananaCols,ColorTable
		move.w	#32-1,ColorAnzahl	
		bsr	Fade_in


		bsr	Waiting2
		bsr	Waiting2
		bsr	Waiting2


		move.l	#BelowColor+2,CopperColorAdr
		move.w	#32-1,ColorAnzahl	
		bsr	Fade_out

		
		move.l	#CopColor+2,CopperColorAdr
		move.w	#32-1,ColorAnzahl	
		bsr	Fade_out


		rts




;----------------------------------------------------------------------------

; 		Menu-Routine

;----------------------------------------------------------------------------


Menu:		move.l	#$01800223,TopColor
		move.l	#ClearMap,SourceAdr
		move.l	memadr,d0
		add.l   #22,d0
		move.l	d0,DestAdr
		move.w	#0,SourceMod
		move.w	#22,DestMod
		move.w	#3-1,BlitterLoops	
		move.w	#35*64+9,BlitterHeight
		move.l	#144*35/8,PicHeight
		move.l	#320*256/8,DestHeight
		bsr	StartBlitter


		move.w	#4,AnimCount_1
		move.w	#6,AnimCount_2
		bsr	BandAnimInit
		move.w	#1,bananaplay

		move.l	#BelowColor+2,CopperColorAdr
		move.l	#BandCols,ColorTable
		move.w	#32-1,ColorAnzahl	
		bsr	Fade_in_Menu


		move.l	#MenuGFX,SourceAdr
		move.l	memadr,a0
		add.l	#320*40/8,a0
		move.l	a0,DestAdr
		move.w	#0,SourceMod
		move.w	#0,DestMod
		move.w	#5-1,BlitterLoops	
		move.w	#165*64+20,BlitterHeight
		move.l	#320*165/8,PicHeight
		move.l	#320*256/8,DestHeight
		bsr	StartBlitter

		move.l	#CopColor+2,CopperColorAdr
		move.l	#MenuCols,ColorTable
		move.w	#32-1,ColorAnzahl	
		bsr	Fade_in_Menu


;------------------------------------------------------------------

		move.l	#$00968020,SpriteDMA
		move.w	#$797f,$dff036
		bsr	SetSprite
		move.w	#1,Flag
		move.w	#1,EnableMaus
		
;------------------------------------------------------------------



MenuLoop:	btst	#6,$bfe001
		beq.w	CheckTune
		btst	#2,$dff016
		bne.s	MenuLoop


;------------------------------------------------------------------
		bsr	SlideVolOff
		jsr	tp_end
		move.w	#0,bananaplay
		move.w	#0,EnableMaus

Quit:		jsr	RestoreVBInt
		jsr	RestoreOSdisplay
		move.w	#$8020,$96(a5)
		rts



bananaplay:	dc.w	0

;-------------------------------------------------------------------


SetPlanes:	move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		add.l	d1,d0
		addq.l	#8,a0
		dbf	d7,SetPlanes
		rts


;-------------------------------------------------------------------


Raster:		movem.l	d0,-(sp)
.loop		move.l	$dff004,d0
		and.l	#$1ff00,d0
		cmp.l	#$3000,d0
		bne.s	.loop
		movem.l	(sp)+,d0
		rts

;-------------------------------------------------------------------

SlideVolOn:	move.w	#0,tp_volume
.loop:		bsr	Raster
		bsr	Raster
		bsr	Raster
		add.w	#1,tp_volume
		cmp.w	#255,tp_volume
		ble	.loop
		rts

;-------------------------------------------------------------------

SlideVolOff:	move.w	#255,tp_volume
.loop:		bsr	Raster
		bsr	Raster
		bsr	Raster
		sub.w	#1,tp_volume
		tst.w	tp_volume
		bne	.loop
		rts

;-------------------------------------------------------------------

; Blitter Routine 

StartBlitter:	lea	$dff000,a5
		bsr.w	WaitBlit
		clr.w	$42(a5)		
		move.l	SourceAdr,a2
		move.l	DestAdr,a3
		move.l	#$ffffffff,$44(a5)
		move.w	SourceMod,$62(a5)
		move.w	DestMod,$66(a5)
		move.w	#$05cc,$40(a5)
		move.w	BlitterLoops,d0
.loop:		move.l	a2,$4c(a5)
		move.l	a3,$54(a5)
		move.w	BlitterHeight,$58(a5)
		bsr.w	WaitBlit
		add.l	PicHeight,a2	
		add.l	DestHeight,a3	
		dbra	d0,.loop
		rts


WaitBlit:	btst	#14,$2(a5)
		bne.s	WaitBlit
		rts	

;-----------------------------------------------------------

SourceAdr:	dc.l	0
DestAdr:	dc.l	0
PicHeight:	dc.l	0
DestHeight:	dc.l	0
SourceMod:	dc.w	0
DestMod:	dc.w	0
BlitterLoops:	dc.w	0
BlitterHeight:	dc.w	0


		cnop	0,8

;-----------------------------------------------------------
;FadeRoutine
;-----------------------------------------------------------

Fade_in:	move.w	#14,d4		
.loop1:		move.w	ColorAnzahl,d3

		bsr	Waiting

		move.l	ColorTable,a1
		move.l	CopperColorAdr,a0	
.loop2:		bsr	ChangeColor
		addq.l	#2,a1		
		addq.l	#4,a0		
		dbra	d3,.loop2
		dbra	d4,.loop1
		rts

Fade_in_Menu:	move.w	#14,d4		
.loop1:		move.w	ColorAnzahl,d3

		move.l	ColorTable,a1
		move.l	CopperColorAdr,a0	
.loop2:		bsr	ChangeColor
		addq.l	#2,a1		
		addq.l	#4,a0		
		dbra	d3,.loop2
		dbra	d4,.loop1
		rts

;-----------------------------------------------------------


Fade_out:	move.w	#14,d4
.loop1:		move.w	ColorAnzahl,d3

		bsr	Waiting

		move.l	#Dunkel,a1
		move.l	CopperColorAdr,a0
.loop2:		bsr	ChangeColor
		addq.l	#4,a0
		dbra	d3,.loop2
		dbra	d4,.loop1
		rts


Fade_out_Banana:move.w	#14,d4
.loop1:		move.w	ColorAnzahl,d3

		move.l	#Dunkel,a1
		move.l	CopperColorAdr,a0
.loop2:		bsr	ChangeColor
		addq.l	#4,a0
		dbra	d3,.loop2
		dbra	d4,.loop1
		rts

Waiting:	movem.l	d0,-(sp)
		move.w	#50,d0
.loop:		bsr	Raster
		dbf	d0,.loop
		movem.l	(sp)+,d0
		rts

Waiting2:	movem.l	d0,-(sp)
		move.w	#1200,d0
.loop:		bsr	Raster
		dbf	d0,.loop
		movem.l	(sp)+,d0
		rts

Waiting3:	movem.l	d0,-(sp)
		move.w	#20,d0
.loop:		bsr	Raster
		dbf	d0,.loop
		movem.l	(sp)+,d0
		rts
			
;-----------------------------------------------------------

ChangeColor:	movem.l	d0-a6,-(a7)	
		move.w	(a0),d2		
		move.w	(a1),d3
		moveq	#2,d4	
.loop:		move.w	d2,d0
		move.w	d3,d1
		and.w	#$f,d0	
		and.w	#$f,d1
		cmp.w	d0,d1
		beq.b	.cont
		blt.b	.bigger
		add.w	#$1,d0
		bra.b	.cont
.bigger:	sub.w	#1,d0
.cont:		ror.l	#4,d0		
		ror.l	#4,d2
		ror.l	#4,d3				
		dbf	d4,.loop
		ror.l	#4,d0		
		swap	d0
		move.w	d0,(a0)	   
		movem.l	(a7)+,d0-a6
		rts


;-----------------------------------------------------------

ColorAnzahl:	dc.w	0
ColorTable:	dc.l	0
CopperColorAdr:	dc.l	0
Dunkel:		dc.w	$0000

;-----------------------------------------------------------

		cnop	0,8


;-----------------------------------------------------------
;CheckMousPosition
;-----------------------------------------------------------

CheckMausPos:	moveq	#0,d0
		move.w	$dff00a,d0
		and.w	#$ff00,d0

		cmp.w	#$7700,d0
		bls.b	.nocont_1

		cmp.w	#$8200,d0
		bls.w	Pos1

		cmp.w	#$8a00,d0
		bls.w	Pos2

		cmp.w	#$9200,d0
		bls.w	Pos3

		cmp.w	#$9a00,d0
		bls.w	Pos4

		cmp.w	#$a200,d0
		bls.w	Pos5

		cmp.w	#$aa00,d0
		bls.w	Pos6

		cmp.w	#$b200,d0
		bls.w	Pos7

		cmp.w	#$ba00,d0
		bls.w	Pos8

		cmp.w	#$c200,d0
		bls.w	Pos9

		cmp.w	#$ca00,d0
		bls.w	Pos10

		
		cmp.w	#$cb00,d0
		bgt.b	.nocont_2
		rts

.nocont_1:	move.w	#$7900,$dff036
		rts

.nocont_2:	move.w	#$ca00,$dff036
		rts

EnableMaus:	ds.w	1

;---------------------------------------------------

Pos1:		move.w	#1,Flag
		move.l	#$797f7e00,Spritedata
		rts

Pos2:		move.w	#2,Flag
		move.l	#$827f8700,Spritedata
		rts
		
Pos3:		move.w	#3,Flag
		move.l	#$8b7f9000,Spritedata
		rts

Pos4:		move.w	#4,Flag
		move.l	#$947f9a00,Spritedata
		rts

Pos5:		move.w	#5,Flag
		move.l	#$9d7fa200,Spritedata
		rts
	
Pos6:		move.w	#6,Flag
		move.l	#$a67fab00,Spritedata
		rts

Pos7:		move.w	#7,Flag
		move.l	#$af7fb400,Spritedata
		rts

Pos8:		move.w	#8,Flag
		move.l	#$b87fbd00,Spritedata
		rts
		
Pos9:		move.w	#9,Flag
		move.l	#$c17fc600,Spritedata
		rts

Pos10:		move.w	#10,Flag
		move.l	#$ca7fcf00,Spritedata
		rts


Flag:		ds.w	1




;------------------------------------------------

CheckTune:	move.w	Flag,d0

		cmp.w	#1,d0
		beq.s	PlayTune1

		cmp.w	#2,d0
		beq.w	PlayTune2

		cmp.w	#3,d0
		beq.w	PlayTune3

		cmp.w	#4,d0
		beq.w	PlayTune4

		cmp.w	#5,d0
		beq.w	PlayTune5

		cmp.w	#6,d0
		beq.w	PlayTune6

		cmp.w	#7,d0
		beq.w	PlayTune7

		cmp.w	#8,d0
		beq.w	PlayTune8

		cmp.w	#9,d0
		beq.w	PlayTune9

		cmp.w	#10,d0
		beq.w	PlayTune10
		bra	MenuLoop
		
;------------------------------------------------

PlayTune1:	bsr	SlideVolOff
		move.l	#Tune_1,tp_data	
		jsr	tp_init
		bsr	SlideVolOn
		bra	MenuLoop
		
PlayTune2:	bsr	SlideVolOff
		move.l	#Tune_2,tp_data	
		jsr	tp_init
		bsr	SlideVolOn
		bra	MenuLoop

PlayTune3:	bsr	SlideVolOff
		move.l	#Tune_3,tp_data	
		jsr	tp_init
		bsr	SlideVolOn
		bra	MenuLoop

PlayTune4:	bsr	SlideVolOff
		move.l	#Tune_4,tp_data	
		jsr	tp_init
		bsr	SlideVolOn
		bra	MenuLoop

PlayTune5:	bsr	SlideVolOff
		move.l	#Tune_5,tp_data	
		jsr	tp_init
		bsr	SlideVolOn
		bra	MenuLoop

PlayTune6:	bsr	SlideVolOff
		move.l	#Tune_6,tp_data	
		jsr	tp_init
		bsr	SlideVolOn
		bra	MenuLoop

PlayTune7:	bsr	SlideVolOff
		move.l	#Tune_7,tp_data	
		jsr	tp_init
		bsr	SlideVolOn
		bra	MenuLoop

PlayTune8:	bsr	SlideVolOff
		move.l	#Tune_8,tp_data	
		jsr	tp_init
		bsr	SlideVolOn
		bra	MenuLoop

PlayTune9:	bsr	SlideVolOff
		move.l	#Tune_9,tp_data	
		jsr	tp_init
		bsr	SlideVolOn
		bra	MenuLoop

PlayTune10:	bsr	SlideVolOff
		move.l	#Tune_10,tp_data	
		jsr	tp_init
		bsr	SlideVolOn
		bra	MenuLoop
		

;------------------------------------------------

SetSprite:	move.l	#Spritedata,d0
		lea	Sprite,a0
		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		moveq	#0,d0
		rts
				
;-----------------------------------------------------------
; BandAnim
;-----------------------------------------------------------

BandAnimInit:	move.l	#BananaBandGFX,SourceAdr
		move.l	SourceAdr,d0
		move.w	BandPicOffset,d1
		add.l	d1,d0
		move.l	d0,SourceAdr
		
		move.l	memadr,d0
		add.l	#320*201/8,d0
		move.l	d0,DestAdr
		move.w	#0,SourceMod
		move.w	#0,DestMod
		move.w	#5-1,BlitterLoops	
		move.w	#55*64+20,BlitterHeight
		move.l	#320*220/8,PicHeight
		move.l	#320*256/8,DestHeight
		bsr	StartBlitter
		rts


BandAnim:	sub.w	#1,AnimCount_2
		cmp.w	#0,AnimCount_2
		bne.s	.goon		
		bsr	BandSetNew	
		move.w	#6,AnimCount_2
.goon:		rts
					

BandSetNew:	bsr	BandAnimInit
		add.w	#320*55/8,BandPicOffset
		sub.w	#1,AnimCount_1
		cmp.w	#0,AnimCount_1
		bne.s	.no
		move.l	#BananaBandGFX,SourceAdr
		move.w	#0,BandPicOffset
		move.w	#4,AnimCount_1
.no:		rts




AnimCount_1:	dc.w	0
AnimCount_2:	dc.w	0
BandPicOffset:	dc.w	0

;-----------------------------------------------------------
;		TrackerPackerReply Routine

		Include	include/TrackerPackerReplayV3.1.S 

;-----------------------------------------------------------


		cnop	0,8


********************************************************************
***********	CopperList_1	   *********************************
********************************************************************


		section Copper,data_c


CopperList:	dc.w    $08e,$3081
		dc.w    $090,$30c1
        	dc.w    $092,$0038
        	dc.w    $094,$00d0
        	dc.w    $102,$0000
;        	dc.w    $104,$0000
        	dc.w    $106,$0020
		dc.w    $108,$0000
		dc.w    $10a,$0000
		dc.w	$10c,$0033
		dc.w    $1dc,$0020
		dc.w    $1fc,$0000
SpriteDMA:	dc.w	$096,$0020

Planes:		dc.w    $0e0,$0,$0e2,$0
		dc.w    $0e4,$0,$0e6,$0
		dc.w    $0e8,$0,$0ea,$0
		dc.w    $0ec,$0,$0ee,$0
		dc.w    $0f0,$0,$0f2,$0

Sprite:		dc.w	$120,$0,$122,$0
		dc.w	$124,$0,$126,$0
		dc.w	$128,$0,$12a,$0
		dc.w	$12c,$0,$12e,$0
		dc.w	$130,$0,$132,$0
		dc.w	$134,$0,$136,$0
		dc.w	$138,$0,$13a,$0
		dc.w	$13c,$0,$13e,$0

DMACON:		dc.w	$0100,$3201

TopColor:	dc.w	$180,$0,$182,$0
		dc.w	$184,$0,$186,$0
		dc.w	$188,$0,$18a,$0
		dc.w	$18c,$0,$18e,$0

		dc.w	$5211,$fffe

CopColor:	dc.w	$180,$0,$182,$0
		dc.w	$184,$0,$186,$0
		dc.w	$188,$0,$18a,$0
		dc.w	$18c,$0,$18e,$0
		dc.w	$190,$0,$192,$0
		dc.w	$194,$0,$196,$0
		dc.w	$198,$0,$19a,$0
		dc.w	$19c,$0,$19e,$0
		dc.w	$1a0,$0,$1a2,$0
		dc.w	$1a4,$0,$1a6,$0
		dc.w	$1a8,$0,$1aa,$0
		dc.w	$1ac,$0,$1ae,$0
		dc.w	$1b0,$0,$1b2,$0
		dc.w	$1b4,$0,$1b6,$0
		dc.w	$1b8,$0,$1ba,$0
		dc.w	$1bc,$0,$1be,$0
	
		dc.w	$f411,$fffe
		
BelowColor:	dc.w	$180,$0,$182,$0
		dc.w	$184,$0,$186,$0
		dc.w	$188,$0,$18a,$0
		dc.w	$18c,$0,$18e,$0
		dc.w	$190,$0,$192,$0
		dc.w	$194,$0,$196,$0
		dc.w	$198,$0,$19a,$0
		dc.w	$19c,$0,$19e,$0
		dc.w	$1a0,$0,$1a2,$0
		dc.w	$1a4,$0,$1a6,$0
		dc.w	$1a8,$0,$1aa,$0
		dc.w	$1ac,$0,$1ae,$0
		dc.w	$1b0,$0,$1b2,$0
		dc.w	$1b4,$0,$1b6,$0
		dc.w	$1b8,$0,$1ba,$0
		dc.w	$1bc,$0,$1be,$0

		dc.w	$ffff,$fffe

		cnop    0,8


;------------------------------------------------------
;SpriteDaten

Spritedata:	dc.w	$797f,$7d00		;Coords
		dc.w	$7000,$0000
		dc.w	$F800,$0000
		dc.w	$F800,$0000
		dc.w	$F800,$0000
		dc.w	$7000,$0000
		dc.w	0,0

;------------------------------------------------------

;		Menu Gfx and Colors


GraceGFX:	Incbin	raw/grace144x35x8.raw
RamonGFX:	Incbin	raw/ramon144x35x8.raw
CrushGFX:	Incbin	raw/crush144x35x8.raw
PresentsGFX:	Incbin	raw/presents320x80x8.raw
TitleGFX:	Incbin	raw/gate320x150x32.raw
BananaGFX:	Incbin	raw/banana48x35x32.raw
MenuGFX:	Incbin	raw/menu320x165x32.raw
BananaBandGFX:	Incbin	raw/banana320x220x8.anim

ClearMap:	blk.b	144*35

;------------------------------------------------------


PresentsCols:	Include	include/presents.col
CreditsCols:	Include	include/credits.col
TitleCols:	Include	include/gate.col
BananaCols:	Include	include/banana.col
MenuCols:	Include	include/menu.col
BandCols:	Include	include/band.col


;------------------------------------------------------
; TUNES

Tune_1:		Incbin	sound/eatbananas.tp3
Tune_2:		Incbin	sound/thebeepno1.tp3
Tune_3:		Incbin	sound/suckup.tp3
Tune_4:		Incbin	sound/siltup.tp3
Tune_5:		Incbin	sound/nocoment.tp3
Tune_6:		Incbin	sound/feelmagic.tp3
Tune_7:		Incbin	sound/introworx.tp3
Tune_8:		Incbin	sound/scheiss.tp3
Tune_9:		Incbin	sound/ablaze.tp3
Tune_10:	Incbin	sound/introchip.tp3

;------------------------------------------------------






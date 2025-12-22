**********************************************************************
*
*	Pack.asm
*	~~~~~~~~
*	Description : This is the Devious Designs MusIc PacK
*		      made for DVS. This is tha final spreadable
*		      version...  AGA Only !!
*
*		      >>> DO NOT SPREAD THE SOURCE CODE <<<  		              
*			
*	Code : Dennis Predovnik (SuLtAn/DVS)
*	Date : 26/4/96
*	Release Version : 1.0
*       Bugs/To Do : 
*            *- Music Fade not properly implemented !
*	     *- Bit of code redundancies, Due to hurried release..
*            *- Can easily be optimized to work on A500, but lazy !
*
**********************************************************************

	section		main_Code,code

	include "include/execbase.i"
        include "include/gfxbase.i"
        include "include/dmabits.i"
        include "include/graphics_lib.i"    
        include "include/exec_lib.i"        
        include "include/intuition_lib.i"  
	include "include/custom.i"
	include	"include/setup.asm"      

**********************************************************************
*	Other Macros						     *
**********************************************************************

CALL		MACRO
		jsr	_LVO\1(a6)
		ENDM

WaitBlit	MACRO
		tst.b	(a6)
.\@		btst	#6,(a6)
		bne.s	.\@
		ENDM

WaitVBL		MACRO
.\@
		lea	$dff000,a5
		move.l	4(a5),d7
		and.l	#$1ff00,d7
		cmp.l	#$12000,d7
		bne.s	.\@
		ENDM

WaitVBLint	MACRO
		clr.l	VB
.vbc\@
		cmpi	#1,VB
		blt.s	.vbc\@
		ENDM

**********************************************************************
*	Other Equates						     *
**********************************************************************

_LVOOutput	equ	-60      
_LVOWrite	equ	-48

 IFND	GFXB_AA_ALICE
	GFXB_AA_ALICE	SET	2
 ENDC

 IFND	gb_ChipRevBits0
	gb_ChipRevBits0	SET	$ec
 ENDC

 IFND	PALn
	PALn		SET	2
 ENDC

**********************************************************************
*	Main Routine						     *
**********************************************************************

	SETUPALL 

	move.l 	#PICBLPT,a0         	     ; Insert PIC in Copper
	move.l 	#OPENPIC,d0	       	     ; OPEN Pic !!
	moveq	#8-1,d1                	     ; 8 Planes..
	move.l	#(320*256)/8,d2        	     ; 320 * 256
	move.l	#8,d3                        ; 8 byte size
	jsr 	insertCopper	

	clr.w	VB			     ; Reset VB Counter !
	move.l  #PICLOGOBK,a0                ; Source palette
	move.l	#OPENPAL,a1                  ; Destination palette
	add.l	#2,a0                        ; Skip colour zero !
	add.l	#6,a1                        ; Skip colour zero !
	move.l	#512-1,d0                    ; Number of Colours-1
	move.w  #0,d1                        ; Fade Delay !
        move.l	#4,d7                        ; Modulo
	jsr	fadeIn

	jsr	init		       	     ; System Takeover etc !!
	jsr	PT_End                       ; Make sure any music ended !
	jsr	initINIT
	jsr	PT_Init         	     ; Initialize replay
	move.l	$6C.W,INTSAVE		     ; Get VB Interupt 
        jsr	_GetVBR			     ; Happening !
	move.l	d0,a0
	move.l	#VBInt,$6c(a0)

	clr.w	VB			     ; Reset VB Counter !
	move.l  #PICLOGOFK,a0                ; Source palette
	move.l	#OPENPAL,a1                  ; Destination palette
	add.l	#2,a0                        ; Skip colour zero !
	add.l	#6,a1                        ; Skip colour zero !
	move.l	#512-1,d0                    ; Number of Colours-1
	move.w  PDELAY,d1                    ; Fade Delay !
        move.l	#4,d7			     ; Modulo
	jsr	fadeOut

	clr.w	VB			     ; Reset VB Counter !
	move.l  #PICLOGONK,a0                ; Source palette
	move.l	#OPENPAL,a1                  ; Destination palette
	add.l	#6,a0                        ; Skip colour zero !
	add.l	#6,a1                        ; Skip colour zero !
	move.l	#512-1,d0                    ; Number of Colours-1
	move.w  PDELAY,d1                    ; Fade Delay !
        move.l	#4,d7                        ; Modulo
	jsr	fadeInAGA

	move.l	#250,d0
waitPic:
	WaitVBLint
	dbra	d0,waitPic	

	clr.w	VB			     ; Reset VB Counter !
	move.l  #PICLOGOFK,a0                ; Source palette
	move.l	#OPENPAL,a1                  ; Destination palette
	add.l	#2,a0                        ; Skip colour zero !
	add.l	#6,a1                        ; Skip colour zero !
	move.l	#512-1,d0                    ; Number of Colours-1
	move.w  PDELAY,d1                    ; Fade Delay !
        move.l	#4,d7			     ; Modulo
	jsr	fadeOut

	clr.w	VB			     ; Reset VB Counter !
	move.l  #PICLOGOBK,a0                ; Source palette
	move.l	#OPENPAL,a1                  ; Destination palette
	add.l	#2,a0                        ; Skip colour zero !
	add.l	#6,a1                        ; Skip colour zero !
	move.l	#512-1,d0                    ; Number of Colours-1
	move.w  PDELAY,d1                    ; Fade Delay !
        move.l	#4,d7                        ; Modulo
	jsr	fadeIn

        ;----------------- Odd Planes !! ---------------------
	
	move.l 	#MENUBLPT,a0         	     ; Insert Menu Screen in Copper
	move.l 	menuScreen1,d0	       	     ; Menu Screen 1 !!
	moveq.w	#2-1,d1                	     ; 2 Planes..
	move.l	#(320*230)/8,d2        	     ; 320 * 230
	move.l	#16,d3                       ; 16 byte size
	jsr 	insertCopper	

	move.l 	#MENUBLPT+32,a0        	     ; Insert Menu Screen in Copper
	move.l 	menuScreen1,d0	       	     ; Menu Screen 1 !!
	add.l	#(320*230*2),d0
	moveq.w	#1-1,d1                	     ; 1 Planes..
	move.l	#(320*230)/8,d2        	     ; 320 * 230
	move.l	#16,d3                       ; 16 byte size
	jsr 	insertCopper

        ;----------------- EVEN Planes !! --------------------
        
	move.l 	#MENUBLPT+8,a0         	     ; Insert Menu Screen in Copper
	move.l 	menuScreen1,d0
	add.l	#(320*230*3)/8,d0            ; Menu Screen 1 !!
	moveq.w	#1-1,d1                	     ; 1 Plane..
	move.l	#(320*230)/8,d2        	     ; 320 * 230
	move.l	#16,d3                       ; 16 byte size
	jsr 	insertCopper

	move.l 	#MENUBLPT+24,a0        	     ; Insert Menu Screen in Copper
	move.l 	menuScreen1,d0
	add.l	#(320*230*4)/8,d0            ; Menu Screen 1 !!
	moveq.w	#1-1,d1                	     ; 1 Plane..
	move.l	#(320*230)/8,d2        	     ; 320 * 230
	move.l	#16,d3                       ; 16 byte size
	jsr 	insertCopper

	move.l	#MENUBLPT+40,a0              ; Insert backdrop in Plane 6 ! 
	move.l  #MAINBACK,d0                 ; Back drop to chuck in..
	moveq.w #1-1,d1                      ; 1 plane
	move.l  #(320*256)/8,d2              ; etc...
        move.l  #16,d3                       ; 16 byte size
	jsr     insertCopper
	
	;----------------- HiRes Logo View -------------------
	
	move.l 	#SPLITPLANE,a0         	     ; Insert LOGO in Copper
	move.l 	#DVSLOGO1,d0	       	     ; DVS Logo !!
	moveq.w	#1-1,d1                	     ; 1 Plane..
	move.l	#(640*45)/8,d2	       	     ; 640 * 45, Hi-Res
        move.l  #8,d3
	jsr 	insertCopper	

	move.l	#LOGOBLPT,a0
	move.l	#DVSLOGO1,d0
	moveq.w	#4-1,d1
	move.l  #(640*45)/8,d2
        move.l  #8,d3
	jsr     insertCopper
	
        ;-----------------------------------------------------

	jsr	_GetVBR
	move.l	d0,a0
	move.l	INTSAVE,$6c(a0)	             ; Clear old interuptz !     
        move.l  #NEWCOPPER,$dff080.L         ; Put up main menu !!
	move.l	$6C.W,INTSAVE		     ; Get VB Interupt 
        jsr	_GetVBR			     ; Happening !
	move.l	d0,a0
	move.l	#mainInt,$6c(a0)
	jsr	printMenuText
	jsr	showCursor
main:
	WaitVBL
	jsr	checkSelection
chkLeft:
	move.b	$bfe001,d0
	andi.b	#$40,d0
	bne.s	chkRight
	jsr	modInfo
chkRight:
	move.w	$16+$dff000,d0
	btst	#10,d0
	bne.s 	main      

freeInts:
	jsr	_GetVBR
	move.l	d0,a0
	move.l	INTSAVE,$6c(a0)	             ; Clear old interuptz !
	jsr	PT_End			     ; Shut off Audio

NOAGAEXIT:
	jsr	cleanUp                	     ; Yep, Let's blow this joint !
	FREEALL			       	     ; Free Stuff etc..
ExitToDos:
	moveq	#0,d0			     ; Return Code !
	rts


	include	"include/init.asm"             ; Initialization routines
	include	"include/standardRoutines.asm" ; In alot of my prods..
	include "include/customRoutines.asm"   ; Specific to this pack.
	include	"include/effects.asm"          ; Special FX Routines !!
	include	"include/primitives.asm"       ; WritePixel,DrawLine etc
	include "include/IORoutines.asm"       ; Input/Output routines !
	include	"include/CIAMusic.asm"         ; Music Replayer..
	include	"include/data.asm"             ; Data used in this pack..
	include "modify.asm"     	       ; Data the "Packer" can change !

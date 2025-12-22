*****************************************************************
*	CustomRoutines.asm                                              
*	~~~~~~~~~~~~~~~~~~                                              
*	Description : This file contains all the routines specific
*		      to this intro/pack/demo..	 
*			
*	Code : Dennis Predovnik (SuLtAn/DVS)
*	Date : 13/3/96 
*
*****************************************************************

	section		custom_Code,code

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*		VBInt						*
*								*
* Description : Interupt which Counts Vertical Blanks !		*
*								*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

VBInt:
	movem.l	d0-d7/a0-a6,-(sp)
	addq	#1,VB			; Passed One VB !
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	#musicInt,-(sp)
	rts

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*		musicInt					*
*								*
* Description : Interupt which playz tha music !		*
*								*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

musicInt:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	PT_Music
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	INTSAVE,-(sp)
	rts

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*		mainInt						*
*								*
* Description : Interupt which controls everything at a         *
*               smooth 50Hz frame rate !!                       *
*								*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

mainInt:
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	#MENUBLPT,a0
	move.l	menuScreen1,d0
	move.l	menuScreen2,d1          ; Swap Playfield 1  
	move.l	#3-1,d2                  
        move.l	#(320*230)/8,d3
	move.l  #16,d4
	jsr	swap1

	move.l	#MENUBLPT+24,a0
	move.l	menuScreen1,d0
	add.l	#(320*230*4)/8,d0
	move.l	menuScreen2,d1          ; Swap Playfield 2  
	add.l	#(320*230*4)/8,d1
	move.l	#1-1,d2                  
        move.l	#(320*230)/8,d3
	move.l  #16,d4
	jsr	swap2

	move.l	dotBuf1,d0
	move.l	dotBuf2,d1              ; Swap Dot Buffer ! 
	jsr	swapDot

	lea     $dff000,a6	
	move.l	DOTLOG,bltdpt(a6)
	move.l	#$01000000,bltcon0(a6)  ; Clear Dot Cube !!
	move.w	#0,bltdmod(a6)
	move.w	#(64*58)+4,bltsize(a6)
	move.l	_GfxBase,a6		; Wait for Bliiter to finish !!
	jsr	_LVOWaitBlit(a6)

	jsr 	blitImages	        ; Blit Heart Images...
	jsr 	drawCube	        ; Plot Source Dot Cube.. 
	jsr	copyCube		; Copy Cube to other part of Screen !
        jsr	scroll                  ; Routine controls tha ScRoLLer !  
	
;	move	#$0f00,$dff180          ; Test raster time !!
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	#VBInt,-(sp)
	rts

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*		scroll   					*
*								*
* Description : Routine controls the HiREs 50Htz scroller !!    *   
*								*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

scroll:
	move.l	#LOGOBLPT,a0
	move.l	#DVSLOGO1,d0
	move.l	#DVSLOGO2,d1                    ; Controls tha page  
	move.l	#4-1,d2                         ; swapping !!
	move.l	#(640*45)/8,d3
	move.l  #8,d4
	jsr	swapLogo

	cmpi	#8,blitCount
	blt	blitScroll
	clr	blitCount
	move.l	scrollPtr,a0
	add.l	#1,scrollPtr
	cmpi.b	#EOT,(a0)
	bne	contScroll
	move.l	#scrollMSG,scrollPtr
contScroll:
	move.l	#77,d0                          ; 75
	move.l	#17,d1
	move.l	LPAGEPHY,a1
	add.l	#(640*45*2)/8,a1
	jsr	putch
blitScroll:
	move.l	_GfxBase,a6			; Wait for Bliiter to finish !!
	jsr	_LVOWaitBlit(a6)

	lea     $dff000,a6			; Custom base !
	move.l	LPAGEPHY,a0
	add.l   #(640*45*2)/8,a0
	add.l	#(17*80)+38,a0       ; 37,35
	move.l	LPAGELOG,a1
	add.l   #(640*45*2)/8,a1
	add.l	#(17*80)+36,a1
	move.w	#$ffff,bltafwm(a6)		; Source A first word mask !!
	move.w	#$ffff,bltalwm(a6)		; Source A last word mask !! 
	move.w  #$0<<12+0<<1,bltcon1(a6)        ; Bsh value (0)+ Dest (0)
	move.w  #$F<<12+%1001<<8+%11110000,bltcon0(a6)
	move.w	#36,bltamod(a6)			; A modulus, 80-(Words*2)
	move.w	#36,bltdmod(a6)			; D modulus, 80-(Words*2)
	move.l	a0,bltapt(a6)			; Source
	move.l	a1,bltdpt(a6)			; Destination
	move.w	#(64*10)+22,bltsize(a6)		; Create correct bltsize !
						; Execute tha blit
	addq	#1,blitCount
exitScroll:
	rts

blitCount
	dc.w	0

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*	drawCube                         			*
*								*
* Description : Routine simply plots the calculated points      *
*               of the image and effectively creates the        *
*               dot cube !                                      *
*                                                               *
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

drawCube:
	move 	NUMLINES,d6	; Number of lines
	move.l	CUBESAVE,a4
	cmpi.b	#$ff,(a4)
	bne	dotLoop
	move.l	#CUBETABLE+1,a4
dotLoop:	
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a4)+,d0
	move.b  (a4)+,d1
	move.l 	DOTLOG,a0	; Custom Plot Routine 
	jsr	writePixel

	moveq	#0,d0
	moveq	#0,d1
	move.b	(a4)+,d0
	move.b  (a4)+,d1
	move.l 	DOTLOG,a0	; Custom Plot Routine 
	jsr	writePixel

	moveq	#0,d0
	moveq	#0,d1
	move.b	(a4)+,d0
	move.b  (a4)+,d1
	move.l 	DOTLOG,a0	; Custom Plot Routine 
	jsr	writePixel
	
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a4)+,d0
	move.b  (a4)+,d1
	move.l 	DOTLOG,a0	; Custom Plot Routine 
	jsr	writePixel

	moveq	#0,d0
	moveq	#0,d1
	move.b	(a4)+,d0
	move.b  (a4)+,d1
	move.l 	DOTLOG,a0	; Custom Plot Routine 
	jsr	writePixel

	moveq	#0,d0
	moveq	#0,d1
	move.b	(a4)+,d0
	move.b  (a4)+,d1
	move.l 	DOTLOG,a0	; Custom Plot Routine 
	jsr	writePixel
	
	dbra 	d6,dotLoop
	move.l	a4,CUBESAVE
	rts

CUBESAVE:
	dc.l	CUBETABLE+1

NLINES  = 40      
NUMLINES:
	DC.W NLINES-1

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*		putch()    					*
*								*
* Description : Asm specific Version of C function.. (CuStOm)	*
* Code        : Dennis Predovnik (SuLtAn)                       *
*								*
*	Input Parameters:					*
*		a0 = Char Pointer !      			*
*		a1 = Dest Screen				*
*		d0 = Dest X..  Byte Aligned                     *
*               d1 = Dest Y                                     *
*								*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

CHARHEIGHT	equ	8			; Linez

putch:
	movem.l	d0-d7/a0-a6,-(sp)

	add.l	d0,a1				; Get to X position.
	muls	#SCREENWIDTHHI,d1      		; Get to Y position. 
	add.l	d1,a1		

	cmpi.b	#EOT,(a0)
	beq	endPrintf
	move.l	#FONT,a2                        ; FONT here !!

	clr.l	d0
	move.b	(a0)+,d0
	sub.w	#32,d0
	muls	#CHARHEIGHT,d0			; Offset to data
	add.l	d0,a2				; Go to offset !!			

	moveq.w	#CHARHEIGHT-1,d0                ; Font height - 1
pbyte:
	move.b  (a2),(a1)			; Print on screen..
	addq.l  #CHARHEIGHT/8,a2		; Bytes to Increment !
	add.l	#SCREENWIDTHHI,a1
	dbra	d0,pbyte	

endPutch:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*		blitImages					*
*								*
* Description : Routine simply Blits the Heart images    	*
*               on the calculated vertices surrounding          *
*               the central dot cube image !!!                  *   
*								*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

blitImages:
	move 	VNUMLINES,d6	                ; Number of lines
	move.l	HEARTSAVE,a4
	cmpi.b	#$ff,(a4)
	bne	dLoop
	move.l	#HEARTTABLE,a4
dLoop:	
	move.l	#HEART,a0
	move.l	PAGELOG1,a1
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a4)+,d0
	move.b	(a4)+,d1	
	move.l	#4,d2
	move.l	#27,d3
	move.l	#3-1,d4
	move.l	#40,d5                          ; Screen Width
	jsr	putImage

	move.l	#HEART,a0
	move.l	PAGELOG1,a1
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a4)+,d0
	move.b	(a4)+,d1
	move.l	#4,d2
	move.l	#27,d3
	move.l	#3-1,d4
	move.l	#40,d5                          ; Screen Width
	jsr	putImage

	dbra 	d6,dLoop
	move.l	a4,HEARTSAVE
	rts

HEARTSAVE:
	dc.l	HEARTTABLE

VNLINES  = 4    
VNUMLINES:
	DC.W VNLINES-1
	
*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*		copyCube					        *
*								        *
* Description : Routine controls the process of copying the             *
*               source cube image to another part of the                *
*               screen..                                                *   
*							         	*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

copyCube:
	move.l	DOTPHY,a0         ; Source 
	move.l	PAGELOG2,a1       ; Destination
        move.l	#0,d2             ; Dest X
        move.l  #2,d3             ; Dest Y
	jsr	memCopyCPU

	move.l	DOTPHY,a0         ; Source 
	move.l	PAGELOG2,a1       ; Destination
        move.l	#256,d2           ; Dest X
        move.l  #150,d3           ; Dest Y
	jsr	memCopyCPU

	rts

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*		memCopyCPU					        *
*								        *
* Description : Routine copies a rectangular region of 64*58 pixels     *
*               from the source to the destination, uses tha CPU..      *
*                                                                       *
* Code        : Dennis Predovnik (SuLtAn)                               *
* Date        : 10/4/96                                                 *
* Version     : 1.0                                                     *
*                A quick hack that just copies a rectangular region of  *
*                memory 64*58 pixels from a source memory location to   *
*                a destination memory location.. Plan is to implement   *
*                in later versions, the flexibility to copy variable    *
*                sized blocks of memory to different sized memory       *
*                destinations..                                         *
*                                                                       * 
* Input       :                                                         *  
*       a0 - Source Memory                                              *
*       a1 - Destination Memory                                         *
*       d2 - Dest X                                                     *
*       d3 - Dest Y                                                     *    
*							         	*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

memCopyCPU:
	movem.l	d0-d7/a0-a6,-(sp)

	mulu	#40,d3				; Go to Dest Y.. 
	lsr.w	#4,d2                   	; Divide by 16
	add.w	d2,d3                   	; Add it and 
	add.w	d2,d3                   	; turn into bytes..
	lea	(a1,d3.w),a1            	; Go to True Dest !!

	move.l  #57,d0
CPUcopy:
	move.l	(a0)+,(a1)+                     ; Copy Both 
	move.l	(a0)+,(a1)+                     ; Long Words.. 64 Pixelz !
	add.l	#32,a1
        dbra    d0,CPUcopy	  

        movem.l	(sp)+,d0-d7/a0-a6
	rts
	
*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*									*
*	putImage							*
*	~~~~~~~~							*	
*	Description : This Routine displays a BoB..			*					
*									*
*	Code	: Dennis Predovnik (Sultan)				*
*	Date    : 22/1/96						*
*									*
*	Parameters :							*
*		A0 - Graphic 						*
*		A1 - Destination screen 				*
*		D0 - Dest X						*
*		D1 - Dest Y						*
*		D2 - Width of Bob (Words)				*
*		D3 - Height of Bob					*
*		D4 - Depth of BoB					*
*		D5 - Screen Width (Bytes)				*
*									*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

putImage:
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	_GfxBase,a6			; Wait for Bliiter to finish !!
	jsr	_LVOWaitBlit(a6)
	lea     $dff000,a6			; Custom base !
	move.l	d2,d7
	mulu	d3,d7				; Get BOBSIZE()
	mulu	#40,d1				; Go to Y.. 
	move.w	d0,d6				; Temp..
	lsr.w	#4,d6                   	; Divide by 16
	add.w	d6,d1                   	; Add it and 
	add.w	d6,d1                   	; turn into bytes..
	lsl.w	#4,d6				; Multiply by 16
	sub.w	d6,d0				; = Pixels to shift right..
	lea	(a1,d1.w),a1            	; Go to True Destination !!

	move.w	#$000f,bltafwm(a6)		; Source A first word mask !!
	move.w	#$f000,bltalwm(a6)		; Source A last word mask !! 
	move.w	#%1001<<8+%11110000,d1		; Use A & D, Minterm A = D
	lsl.w	#7,d0
	lsl.w	#5,d0
	or.w	d0,d1
	move.w	d1,bltcon0(a6)			; Set Bltcon0
	move.w 	#0,bltcon1(a6)              	; Set Bltcon1 to Area !!
	move.w	#0,bltamod(a6)			; A modulus
	sub.w	d2,d5				; Get correct
	sub.w	d2,d5				; Modulus..
	move.w	d5,bltdmod(a6)			; D modulus
	mulu	#64,d3				; Create correct
	add.w	d2,d3				; bltsize !!

blitDepth:
	lea     $dff000,a6			; Custom base !
	move.l	a0,bltapt(a6)			; Source
	move.l	a1,bltdpt(a6)			; Destination
	move.w	d3,bltsize(a6)			; Execute tha blit
	add.l	#(27*64)/8,a0
	add.l	#(320*230)/8,a1
	move.l	_GfxBase,a6			; Wait for Bliiter to finish !!
	jsr	_LVOWaitBlit(a6)
	dbra	d4,blitDepth

	movem.l	(sp)+,d0-d7/a0-a6
	rts

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*		printf						*
*								*
* Description : Asm specific Version of C function.. (CuStOm)	*
* Code        : Dennis Predovnik (SuLtAn)                       *
*								*
*	Input Parameters:					*
*		a0 = Custom String StructuRe !			*
*		a1 = Dest Screen				*
*								*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

EOT		equ	$ff			; End of Text
EOB		equ	$fe			; End of Block
SCREENWIDTHLO	equ	40			; 40 Bytes = 360 PiXeLz !
SCREENWIDTHHI   equ     80                      ; 80 Bytes = 640 PiXeLz !
FONTHEIGHT	equ	8			; Linez

printf:
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	d0
	move.b	(a0)+,d0
	add.l	d0,a1				; Get to X position.

	clr.l	d0
	move.b	(a0)+,d0
	muls	#SCREENWIDTHLO,d0      		; Get to Y position. 
	add.l	d0,a1		

printLine:
	cmp.b	#EOT,(a0)
	beq	endPrintf
	move.l	#FONT,a2                        ; FONT here !!

	clr.l	d0
	move.b	(a0)+,d0
	sub.w	#32,d0
	muls	#FONTHEIGHT,d0			; Offset to data
	add.l	d0,a2				; Go to offset !!			

	moveq.w	#FONTHEIGHT-1,d0                ; Font height - 1
printChar:
	move.b  (a2),(a1)			; Print on screen..
	addq.l  #FONTHEIGHT/8,a2		; Bytes to Increment !
	add.l	#SCREENWIDTHLO,a1
	dbra	d0,printChar	
	sub.l    #(SCREENWIDTHLO*FONTHEIGHT),a1
	add.l	#1,a1
	bra	printLine
	
endPrintf:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*	showCursor                                              *
*                                                               *
* Description: Routine simply displays the cursor sprite..      *
*                                                               *
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

showCursor:
	move.w	#CURL_Y*256+CURL_X,curL    ; Y,X         ; 101,125
	move.w	#CURL_YSTOP*256,curL+2     ; Vertical Stop 113

	move.w	#CURR_Y*256+CURR_X,curR    ; Y,X         ; 101,162
	move.w	#CURR_YSTOP*256,curR+2     ; Vertical Stop 113

	move.l	#curL,d0
	move.l	#CURSPR,a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#curR,d0
	move.l	#CURSPR+8,a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	clr.w	VB			; Reset VB Counter !
	move.l  #initSpr,a0             ; Source palette
	move.l	#SPRCOL,a1              ; Destination palette
	move.l	#1-1,d0                 ; Number of Colours-1
	move.l  CDELAY,d1               ; Fade Delay !
	move.l	#0,d7                   ; Modulo !
	jsr	fadeOut	

	rts	

initSpr
	dc.w	$0b44	

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*	updateCursor                                            *
*                                                               *
* Description: Routine simply updates the cursor sprite..       *
*                                                               *
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

updateCursor:
        mulu	#LINEHEIGHT,d1          ; 18
        add.w   #CURL_YSTOP,d1  
	move.b	d1,2(a0)                ; Vertical Stop
	sub	#12,d1
        lsl     #8,d1
	add	d2,d1
	move.w	d1,(a0)                 ; Y,X

	rts

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*	modInfo                                                 *
*                                                               *
* Description: Routine when initiated displayz the module info. *
*                                                               *
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

modInfo:
	clr.w	VB			; Reset VB Counter !
	move.l  #sprSelect,a0           ; Source palette
	move.l	#SPRCOL,a1              ; Destination palette
	move.w	#1-1,d0                 ; Number of Colours-1
	move.w  CDELAY,d1               ; Fade Delay !
	move.l	#0,d7                   ; Modulo !
	jsr	fadeOut			

	clr.w	VB			; Reset VB Counter !
	move.l  #sprRid,a0              ; Source palette
	move.l	#SPRCOL,a1              ; Destination palette
	move.w	#1-1,d0                 ; Number of Colours-1
	move.w  CDELAY,d1               ; Fade Delay !
	move.l	#0,d7                   ; Modulo !
	jsr	fadeIn			

	clr.w	VB			; Reset VB Counter !
	move.l  #MENUGO,a0              ; Source palette
	move.l	#MENUCOL,a1             ; Destination palette
	addq.l	#2,a0                   ; Go to Colour !
	move.w	#2-1,d0                 ; Number of Colours-1
	move.w  TDELAY,d1               ; Fade Delay !
	move.l	#16,d7                  ; Modulo !
	jsr	fadeIn			; Fade In Menu Text !

	lea     $dff000,a6	
	move.l	menuScreen1,a1
	add.l	#(320*230*3)/8,a1 
	add.l	#(60*40)+16,a1          ; Go to Source !
	move.l	a1,bltdpt(a6)
	move.l	#$01000000,bltcon0(a6)  ; Clear Menu Text !!
	move.w	#30,bltdmod(a6)
	move.w	#(64*100)+5,bltsize(a6)
	move.l	_GfxBase,a6		; Wait for Bliiter to finish !!
	jsr	_LVOWaitBlit(a6)
	jsr	printInfo

	clr.w	VB			; Reset VB Counter !
	move.l  #PICLOGOFK,a0           ; Source palette
	move.l	#MENUCOL,a1             ; Destination palette
	addq.l	#2,a0                   ; Go to Colour !
	move.w	#2-1,d0                 ; Number of Colours-1
	move.w  TDELAY,d1               ; Fade Delay !
	move.l	#16,d7                  ; Modulo !
	jsr	fadeOut			; Fade Out Menu Text !

	clr.w	VB			; Reset VB Counter !
	move.l  #MENUDCOL,a0            ; Source palette
	move.l	#MENUCOL,a1             ; Destination palette
	addq.l	#2,a0                   ; Go to Colour !
	move.w	#2-1,d0                 ; Number of Colours-1
	move.w  TDELAY,d1               ; Fade Delay !
	move.l	#16,d7                  ; Modulo !
	jsr	fadeIn			; Fade In Menu Text !

chkMenu:
	WaitVBL
chkMRight:
	move.w	$16+$dff000,d0
	btst	#10,d0                  ; Wait Right !!  
	bne.s 	chkMLeft
	move.l	(sp)+,d0		; Get Rid of Routine on stack !!
	jmp	freeInts
chkMLeft:
	move.b	$bfe001,d0
	andi.b	#$40,d0                 ; $bfe001
	bne.s	chkMenu

	clr.w	VB			; Reset VB Counter !
	move.l  #MENUGO,a0              ; Source palette
	move.l	#MENUCOL,a1             ; Destination palette
	addq.l	#2,a0                   ; Go to Colour !
	move.w	#2-1,d0                 ; Number of Colours-1
	move.w  TDELAY,d1               ; Fade Delay !
	move.l	#16,d7                  ; Modulo !
	jsr	fadeIn			; Fade In Text !

	lea     $dff000,a6	
	move.l	menuScreen1,a1
	add.l	#(320*230*3)/8,a1 
	add.l	#(60*40)+11,a1          ; Go to Source !
	move.l	a1,bltdpt(a6)
	move.l	#$01000000,bltcon0(a6)  ; Clear Text !!
	move.w	#22,bltdmod(a6)
	move.w	#(64*100)+9,bltsize(a6)
	move.l	_GfxBase,a6		; Wait for Bliiter to finish !!
	jsr	_LVOWaitBlit(a6)

	jsr	printMenuText
	clr.w	VB			; Reset VB Counter !
	move.l  #sprNormal,a0           ; Source palette
	move.l	#SPRCOL,a1              ; Destination palette
	move.w	#1-1,d0                 ; Number of Colours-1
	move.w  CDELAY,d1               ; Fade Delay !
	move.l	#0,d7                   ; Modulo !
	jsr	fadeOut			

	rts

printInfo:
	cmpi.w	#0,exeVar
	bne	chkI1
	WaitVBL
	move.l	#Info0,a0
	move.l	menuScreen1,a1
	add.l	#(320*230*3)/8,a1             
	jsr	printBlock
	rts
chkI1:
	cmpi.w	#1,exeVar
	bne	chkI2	
	WaitVBL
	move.l	#Info1,a0
	move.l	menuScreen1,a1
	add.l	#(320*230*3)/8,a1             
	jsr	printBlock
	rts
chkI2:
	cmpi.w	#2,exeVar
	bne	chkI3	
	WaitVBL
	move.l	#Info2,a0
	move.l	menuScreen1,a1
	add.l	#(320*230*3)/8,a1             
	jsr	printBlock
	rts
chkI3:
	cmpi.w	#3,exeVar
	bne	chkI4	
	WaitVBL
	move.l	#Info3,a0
	move.l	menuScreen1,a1
	add.l	#(320*230*3)/8,a1             
	jsr	printBlock
	rts
chkI4:
	cmpi.w	#4,exeVar
	bne	chkI5	
	WaitVBL
	move.l	#Info4,a0
	move.l	menuScreen1,a1
	add.l	#(320*230*3)/8,a1             
	jsr	printBlock
	rts
chkI5:
	cmpi.w	#5,exeVar
	bne	endInfo	
	WaitVBL
	move.l	#Info5,a0
	move.l	menuScreen1,a1
	add.l	#(320*230*3)/8,a1             
	jsr	printBlock
endInfo:
	rts

printBlock:
	jsr	printf
	add.l	#INFSIZE,a0
	cmp.b	#EOB,(a0)
	bne	printBlock
	rts

sprSelect:
	dc.w	$0fff
sprNormal:
	dc.w	$0b44
sprRid:
	dc.w	$0302
	
*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*		printMenuText					*
*								*
* Description : Routine prints the menu text..                  *
*								*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

printMenuText:
	move.l	#menu1,a0
	move.l	menuScreen1,a1
	add.l	#(320*230*3)/8,a1             
	jsr	printf

	move.l	#menu2,a0
	move.l	menuScreen1,a1
	add.l	#(320*230*3)/8,a1             
	jsr	printf

	move.l	#menu3,a0
	move.l	menuScreen1,a1
	add.l	#(320*230*3)/8,a1             
	jsr	printf

	move.l	#menu4,a0
	move.l	menuScreen1,a1
	add.l	#(320*230*3)/8,a1             
	jsr	printf

	move.l	#menu5,a0
	move.l	menuScreen1,a1
	add.l	#(320*230*3)/8,a1             
	jsr	printf

	move.l	#menu6,a0
	move.l	menuScreen1,a1
	add.l	#(320*230*3)/8,a1             
	jsr	printf

	clr.w	VB			; Reset VB Counter !
	move.l  #PICLOGOFK,a0           ; Source palette
	move.l	#MENUCOL,a1             ; Destination palette
	addq.l	#2,a0                   ; Go to Colour !
	move.w	#2-1,d0                 ; Number of Colours-1
	move.w  TDELAY,d1               ; Fade Delay !
	move.l	#16,d7                  ; Modulo !
	jsr	fadeOut			; Fade Out Menu Text !

	clr.w	VB			; Reset VB Counter !
	move.l  #MENUDCOL,a0            ; Source palette
	move.l	#MENUCOL,a1             ; Destination palette
	addq.l	#2,a0                   ; Go to Colour !
	move.w	#2-1,d0                 ; Number of Colours-1
	move.w  TDELAY,d1               ; Fade Delay !
	move.l	#16,d7                  ; Modulo !
	jsr	fadeIn			; Fade In Menu Text !

	rts


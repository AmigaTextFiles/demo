*****************************************************************
*	Effects.asm                                              
*	~~~~~~~~~~~                                              
*	Description : This file contains all the Special
*		      Effect routines used in this 
*                     intro/pack/demo..	 Yeah,Yeah alot of
*                     redundancies... but I waz in a hurry
*                     OK !!!  I'll fix it in a further 
*                     release...
*			
*	Code : Dennis Predovnik (SuLtAn/DVS)
*	Date : 23/3/96 
*
*****************************************************************

	section		effects_Code,code

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*									*
*	fadeIn (CuSToM Version) 					*
*	~~~~~~								*	
*	Description : This Defacto Routine fades in the source palette  *
*                     over the destination palette, which should be set *
*                     to all white !! Custom version skips colours      *
*                     10 and 11..					*
*									*
*	Code	: Dennis Predovnik (Sultan)				*
*	Date    : 21/3/96						*
*       Version :                                                       *                                                               *
*                 1.0  A simple hack.. Not modular ! It worked though.  *
*                 1.5  Improved routine to handle FADE Delay, also      *
*                      made the routine more modular so it can be       *
*                      ported elsewhere with ease !                     *
*                 1.7  Data stored in registers, notible speed          *
*                      increase..                                       *
*                                                                       *									*
*	Parameters: 							*
*               a0 - Source palette                                     *
*               a1 - Destination pallete                                *
*               d0 - Palette number of colours.                         *
*		d1 - Fade Delay                                         *
*		d7 - Modulo (Bytes)					*
*									*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

fadeIn:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d0,d4                           ; Set Counter..
	clr.l	d5                              ; Clear colour flag ! 
        move.l  a0,a2                           ; Save Bases ! 
        move.l  a1,a3                           ; Save Bases !
firstPassIn:
	move.w	(a0),d2                         ; Copy colour to a temp.
	move.w	(a1),d3                         ; Copy colour to a temp.
	and.w	#$000f,d2                       ; Interigate BLUE Value !
	and.w	#$000f,d3                       ; Interigate BLUE Value !
	cmp.w	d2,d3
	ble     interigateInGREEN               ; Enuff BLUE ??
	sub.w	#$0001,(a1)                     ; No, Decrement BLUE Nibble!     
	move.w	#1,d5                           ; Set Flag !
interigateInGREEN:
	move.w  (a0),d2                         ; Copy colour to a temp.
	move.w  (a1),d3                         ; Copy colour to a temp.
	and.w   #$00f0,d2                       ; Interigate GREEN Value !
	and.w   #$00f0,d3                       ; Interigate GREEN Value !
	cmp.w   d2,d3                     
	ble     interigateInRED                 ; Enuff GREEN ??
	sub.w   #$0010,(a1)                     ; No, Decrement GREEN Nibble!
	move.w  #1,d5                           ; Set Flag !
interigateInRED:
	move.w  (a0),d2                         ; Copy colour to a temp.
	move.w  (a1),d3                         ; Copy colour to a temp.
	and.w   #$0f00,d2                       ; Interigate RED Value !
	and.w   #$0f00,d3                       ; Interigate RED Value !
	cmp.w   d2,d3
	ble     interigateInNEXT                ; Enuff RED ??   
	sub.w   #$0100,(a1)                     ; No, Decrement RED Nibble!
        move.w  #1,d5                           ; Set Flag !
interigateInNEXT:
	move.l	d4,d6
	divu	#32,d6
	swap	d6
	tst	d6
	bne	modIn
	add.l	#4,a1
	move.l	a2,a0    	
modIn:
	add.l	d7,a0                           ; Go to 
        add.l	d7,a1                           ; Next colour value !
	dbra    d4,firstPassIn
waitFadeIn:
	cmp.w   VB,d1                           ; Busy VB Wait !  
	bgt     waitFadeIn
	clr.w	VB
        tst.w	d5
        beq     exitFadeIn                      ; Finished ??  
	move.l	d0,d4                           ; No, Reset Counter !	
        clr.l   d5                              ; No, Reset Flag !
        move.l  a2,a0                           ; No, Restore Base !
        move.l  a3,a1                           ; No, Restore Base !
        bra     firstPassIn                     ; No, Loop Back
exitFadeIn:
	movem.l	(sp)+,d0-d7/a0-a6
	rts


fadeInAGA:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d0,d4                           ; Set Counter..
	clr.l	d5                              ; Clear colour flag ! 
        move.l  a0,a2                           ; Save Bases ! 
        move.l  a1,a3                           ; Save Bases !
firstPassInAGA:
	move.w	(a0),d2                         ; Copy colour to a temp.
	move.w	(a1),d3                         ; Copy colour to a temp.
	and.w	#$000f,d2                       ; Interigate BLUE Value !
	and.w	#$000f,d3                       ; Interigate BLUE Value !
	cmp.w	d2,d3
	ble     interigateInGREENAGA            ; Enuff BLUE ??
	sub.w	#$0001,(a1)                     ; No, Decrement BLUE Nibble!     
	move.w	#1,d5                           ; Set Flag !
interigateInGREENAGA:
	move.w  (a0),d2                         ; Copy colour to a temp.
	move.w  (a1),d3                         ; Copy colour to a temp.
	and.w   #$00f0,d2                       ; Interigate GREEN Value !
	and.w   #$00f0,d3                       ; Interigate GREEN Value !
	cmp.w   d2,d3                     
	ble     interigateInREDAGA              ; Enuff GREEN ??
	sub.w   #$0010,(a1)                     ; No, Decrement GREEN Nibble!
	move.w  #1,d5                           ; Set Flag !
interigateInREDAGA:
	move.w  (a0),d2                         ; Copy colour to a temp.
	move.w  (a1),d3                         ; Copy colour to a temp.
	and.w   #$0f00,d2                       ; Interigate RED Value !
	and.w   #$0f00,d3                       ; Interigate RED Value !
	cmp.w   d2,d3
	ble     interigateInNEXTAGA             ; Enuff RED ??   
	sub.w   #$0100,(a1)                     ; No, Decrement RED Nibble!
        move.w  #1,d5                           ; Set Flag !
interigateInNEXTAGA:
	move.l	d4,d6
	divu	#32,d6
	swap	d6
	tst	d6
	bne	modInAGA
	add.l	#4,a1
	add.l	#4,a0     	
modInAGA:
	add.l	d7,a0                           ; Go to 
        add.l	d7,a1                           ; Next colour value !
	dbra    d4,firstPassInAGA
waitFadeInAGA:
	cmp.w   VB,d1                           ; Busy VB Wait !  
	bgt     waitFadeInAGA
	clr.w	VB
        tst.w	d5
        beq     exitFadeInAGA                   ; Finished ??  
	move.l	d0,d4                           ; No, Reset Counter !	
        clr.l   d5                              ; No, Reset Flag !
        move.l  a2,a0                           ; No, Restore Base !
        move.l  a3,a1                           ; No, Restore Base !
        bra     firstPassInAGA                  ; No, Loop Back
exitFadeInAGA:
	movem.l	(sp)+,d0-d7/a0-a6
	rts


*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*									*
*	fadeOut (CuStom Version)					*
*	~~~~~~~								*	
*	Description : This Defacto Routine fades out the source palette *
*                     over the destination palette, which should be set *
*                     to all black !! Custom version skips colours 	*
*                     10 and 11..                                       *
*									*
*	Code	: Dennis Predovnik (Sultan)				*
*	Date    : 21/3/96						*
*       Version :                                                       *                                                               *
*                 1.0  A simple hack.. Not modular ! It worked though.  *
*                 1.5  Improved routine to handle FADE Delay, also      *
*                      made the routine more modular so it can be       *
*                      ported elsewhere with ease !                     *
*                 1.7  Data stored in registers, notible speed          *
*                      increase..                                       *
*                                                                       *									*
*	Parameters: 							*
*               a0 - Source palette                                     *
*               a1 - Destination pallete                                *
*               d0 - Palette number of colours.                         *
*		d1 - Fade Delay                                         *
*		d7 - Modulo (Bytes)					*
*									*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

fadeOut:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d0,d4                           ; Set Counter..
	clr.l	d5                              ; Clear colour flag ! 
        move.l  a0,a2                           ; Save Bases ! 
        move.l  a1,a3                           ; Save Bases !
firstPassOut:
	move.w	(a0),d2                         ; Copy colour to a temp.
	move.w	(a1),d3                         ; Copy colour to a temp.
	and.w	#$000f,d2                       ; Interigate BLUE Value !
	and.w	#$000f,d3                       ; Interigate BLUE Value !
	cmp.w	d2,d3
	bge     interigateOutGREEN              ; Enuff BLUE ??
	add.w	#$0001,(a1)                     ; No, Increment BLUE Nibble!     
	move.w	#1,d5                           ; Set Flag !
interigateOutGREEN:
	move.w  (a0),d2                         ; Copy colour to a temp.
	move.w  (a1),d3                         ; Copy colour to a temp.
	and.w   #$00f0,d2                       ; Interigate GREEN Value !
	and.w   #$00f0,d3                       ; Interigate GREEN Value !
	cmp.w   d2,d3                     
	bge     interigateOutRED                ; Enuff GREEN ??
	add.w   #$0010,(a1)                     ; No, Increment GREEN Nibble!
	move.w  #1,d5                           ; Set Flag !
interigateOutRED:
	move.w  (a0),d2                         ; Copy colour to a temp.
	move.w  (a1),d3                         ; Copy colour to a temp.
	and.w   #$0f00,d2                       ; Interigate RED Value !
	and.w   #$0f00,d3                       ; Interigate RED Value !
	cmp.w   d2,d3
	bge     interigateOutNEXT               ; Enuff RED ??   
	add.w   #$0100,(a1)                     ; No, Increment RED Nibble!
        move.w  #1,d5                           ; Set Flag !
interigateOutNEXT:
	move.l	d4,d6
	divu	#32,d6
	swap	d6
	tst	d6
	bne	modOut
	add.l	#4,a1
	move.l	a2,a0	
modOut:
        add.l	d7,a0                           ; Go to 
        add.l	d7,a1                           ; Next colour value !
	dbra    d4,firstPassOut
waitFadeOut:
	cmp.w   VB,d1                           ; Busy VB Wait !  
	bgt     waitFadeOut
	clr.w	VB
        tst.w	d5
        beq     exitFadeOut                     ; Finished ??  
	move.l	d0,d4                           ; No, Reset Counter !	
        clr.l   d5                              ; No, Reset Flag !
        move.l  a2,a0                           ; No, Restore Base !
        move.l  a3,a1                           ; No, Restore Base !
        bra     firstPassOut                    ; No, Loop Back
exitFadeOut:
	movem.l	(sp)+,d0-d7/a0-a6
	rts



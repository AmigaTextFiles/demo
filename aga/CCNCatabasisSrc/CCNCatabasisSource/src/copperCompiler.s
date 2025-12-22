 

    opt c+
    opt    ALINK
    
    ;include graphics/graphics_lib.i
    ;include graphics/gfxbase.i


    include hardware/custom.i
    include    demodata.i

	XREF	_ntsc	;1b
    XREF    _debugv    

	XREF	_InAlloc
	XREF	_InFree

    section code,code

    ;(OCS DOC): REGISTRE POUR CHOISIR RESOLUTION    
    ; bplcon0

    ;DC.W    $0100,$5200        ;5 PLANS+MODE COULEURS
    ;dc.w    $0100,$0010        ;8 plans

    ;8;BIT 15 HIRES        :0    HAUTE RESOLUTION      NON = 0 
;5    ;4;BIT 14 BPU2        :1      NBRE DE PLANS         1   SI 1 = +4 PLANS
    ;2;BIT 13 BPU1        :0          5            0   SI 1 = +2 PLANS
    ;1;BIT 12 BPU0        :1                1   SI 1 = +1 PLANS

    ;8;BIT 11 HOMOD        :0    MODE HAM         NON = 0
;2    ;4;BIT 10 DBPLF        :0    DUAL PLAYFIELD        NON = 0
    ;2;BIT 09 COLOR        :1    COULEURS          OUI = 1
        ; Only for A1000 composite output !
    
    ;1;BIT 08 GAUD        :0

    ;8;BIT 07 INUTILISE    :0                0
;0    ;4;BIT 06 INUTILISE    :0                0
    ;2;BIT 05 INUTILISE    :0                0
    ;1;BIT 04 INUTILISE    :0-> BPU3                0

    ;8;BIT 03 LPEN        :0    CRAYON OPTIQUE        NON = 0
;0    ;4;BIT 02 LACE        :0    MODE INTERLACE        NON = 0
    ;2;BIT 01 ERSY        :0    SYNCHRO EXTERNE        NON = 0
    ;1;BIT 00 INUTILISE    :0                0
    

	XDEF	_cc_InitLowResAGADbl
_cc_InitLowResAGADbl:
	; same params as _cc_InitLowResAGA
	

	; compute size of coppers
cBas set 8		;fmode+dma
cBas set cBas+16	;diw ddf
cBas set cBas+4		;bplcon0
cBas set cBas+16    ;bplcon2/con1/bpl1mod/2mod
cBas set cBas+8	   ;bplcon4/col0
cBas set cBas+(4*16)    ; sprite shunt
cBas set cBas+(4)   ; bplcon3 after color
cBas set cBas+8   ;2 ending ffe
;cBas=cBas+	   ;
;cBas=cBas+	   ;

	move.l	#cBas,d3	; static size

	clr.l	d2
	move.w	d0,d2
	lsl.w	#3,d2	;*8
	add.l	d2,d3	; + bitplane pointers size
; -  --  - - - - -  colors
	btst	#0,d1	;CCLR_DOCOLORS
	beq	.nocolors
		; start frame states
	btst    #2,d1	; CCLR_DUALPF
	beq        .nodp2
	; always 64c in dual (2 banks)
	add.l	#(64*8)+(16),d3 ; 4 bplcon3+(32*4*2) l&h
	bra	.endc
.nodp2
	moveq	#1,d2
	lsl.w	d0,d2 ;nbcolors
	; if 128, add 32 for sprite private colors
	cmp.w	#128,d2
	bne	.no128a
		move.w	#128+32,d2
.no128a
	move.w	d2,d4
	sub.w	#1,d2
	lsr.w	#5,d2 ;(nbc/32)
	add.w	#1,d2 ; nb/32 banks
	lsl.w	#3,d2 ; size of 2*bplcon3  *8
	ext.l	d2
	add.l	d2,d3	;
	; - - -
	lsl.l	#5,d2  ;*8*32
	add.l	d2,d3	;
.endc
.nocolors
	
	move.w	d1,d2
	and.w	#CCLR_WL_SCROLL|CCLR_WL_16c|CCLR_WL_HC,d2
	beq		.nowaits

	add.l	  #4*256,d3	  ; le wait per line

	btst	#3,d1	;8  CCLR_WL_SCROLL
	beq	.nosc
		add.l  #256*12,d3 ;bplcon1/1mod/2mod
.nosc
	btst	#4,d1	;16 CCLR_WL_16c
	beq		.nowl16c
		add.l	#256*(31*4),d3
.nowl16c

	; TODO: color palette change here
	btst	#5,d1	 ; CCLR_WL_HC32
	beq	.nocopsc
		; only 32c max
		;add.l	 #256*((16*9)+36),d3
		add.l	#12+(12*256)+(33*4*15),d3

.nocopsc

.nowaits
	movem.l	 d0/d1,-(sp)

	; - - - - - - - - - - - - - - - - -
	; - - -alloc fast structs
	move.l	#CopperDbl_SIZEOF,d0
	clr.l	d1	; fast
	bsr	_InAlloc
	tst.l	d0
	beq .fend
	move.l	d0,a2
	; - - - - - - - - - - - - - - - - -
	; - - - - -  Chip alloc for copper
	; then *2 chip for double buf...

	
	lsl.l	#1,d3
		move.l	d3,d0
		moveq	#1,d1
		bsr     _InAlloc
		;d0

	tst.l	d0
	bne		.aok
		; free
		move.l	a2,a0
		bsr	_InFree
		sub.l	a0,a0
		bra	.fend
.aok
	move.l	d0,a0
	; - - - - - - inits
	movem.l	 (sp),d0/d1 ; copper prefs
	move.l	a2,a1
	; a0 chip a1 struct


	move.l  a1,-(sp)
	;+0 lea cdb_cop1(a1),a1
	bsr _cc_InitLowResAGA
	lea cdb_cop2(a1),a1
	bsr _cc_InitLowResAGA
	move.l  (sp)+,a1

	; init double buf pointers
	move.l  a1,cdb_CopA(a1)
	lea	    cdb_cop2(a1),a2
	move.l  a2,cdb_CopB(a1)
	; out: a1 struct
	move.l	a1,a0

.fend
	addq	#8,sp
	rts
	XDEF    _cc_FreeCopperDbl
_cc_FreeCopperDbl:
	; a0 copper struct
	tst.l	a0
	beq		.end	; test better here

	move.l	cdb_cop1+cp_start(a0),a2	; chip
	bsr	_InFree
	move.l	a2,a0
	bsr	_InFree
.end
	rts
; - - - - - - - - - - - - - - -
    ;d0-d5/a0-a3 used, a4-a5-a6 preserved
    ;
    ; prepare the copper shape in chipram (a0)
    ; ... and keep pointers to dynamic parts in a struct (a1)
    ; does not set bm and palette
    ; lowres.
    ;
    ;a0: chip where to do copper
    ;a1 sCopperPtrs struct
    ;d0.w: nb planes: 1->8
    ;d1: prefsbits: CCLR_...
dffstopt:	dc.b	$d0,$c8,$c8,$a0
; modulo and start datafetch for scroll modes
; accoording to fmode
scrlm:
	dc.w	42,$0038-$08	;let 7
	dc.w	44,$0038-$10	;    5
	dc.w	44,$0038-$10	;let 5 sprite
	dc.w	48,$0038-$20	;let 1 sprite

    XDEF    _cc_InitLowResAGA
_cc_InitLowResAGA:
	movem.l	a3/a6,-(sp)
	;8b align ?
	move.l	a0,d2
	addq	#7,d2
	and.b	#$f8,d2
	move.l	d2,a0
	
    move.l    a0,cp_start(a1)
    ; keep flags
    move.w    d1,cp_flags(a1)

	; we use double CAS, must align line bitmap on 8b.
	; this allows blitter to run X4 speed.

	move.l	#(fmode<<16)|($000c),d2 ; sprite 64
	btst	#6,d1	; CCLR_BM32
	beq	.nobm32
		bset   #0,d2
.nobm32
	btst	#7,d1	; CCLR_BMDCAS
	beq	.nobmdcas
		bset   #1,d2
.nobmdcas
	move.l	d2,(a0)+

	;- - - - copy screen dimensions
   	; contains diwstart/stop dffstart/stop defaults:
	movem.l    windowRectRegs(pc),d2-d5

	move.w	#256,d6	; nblines	
	tst.b	_ntsc
	beq		.nont
		; american TV are 60hz,200 lines
		move.w	#$f4c1,d3 ; and not $2cc1
		move.w	#200,d6
.nont
	move.w	d6,cp_nbLines(a1)

	moveq	#40,d6 	; default modulo for 320px
	move.w	d1,d7
	and.w	#CCLR_BMDCAS|CCLR_BM32,d7
	lsr.w	#6,d7	;0-3
	move.w	d7,cp_fmodeIndex(a1)
	tst.w	d7
	beq	.nobmfm
		; it's bit 6 and 7, 4 case
		lea		dffstopt(pc),a2
		move.b	(a2,d7.w),d5	;dffstop according to fmode
.nobmfm


	btst	#1,d1	;CCLR_CANSCROLL
	beq		.noscroll    
		lea	scrlm(pc),a2
		move.w	(a2,d7.w*4),d6	  ; minimal byte modulo according to fmode+scroll
		move.w	2(a2,d7.w*4),d4	; start datafetch get left
		; dffstart lefted for scroll, modulo get +8
;		 move.w	 #$0038-$020,d4  ;$038- $020
	;	 move.w	 #$00a0-$20,d5
		; in lowres fmodeX4, each 64pixel costs $20 to dffstart/stop		
		; same as no scroll move.w	#$00a0,d5
.noscroll  
	move.w	d6,cp_baseModulo(a1) ; used by setBm
    movem.l	d2-d5,(a0)    ; 16b
    lea    16(a0),a0
;
;
	; - - - bplcon0: set hires/HAM/dualplayfield 
    ; - - -  and enabled planes
         
    ; encode nbplane
    move.b    d0,d2
; move.b #4,d2

    and.b    #7,d2
    lsl.w    #8,d2
    lsl.w    #4,d2 ;bpu0,1,2
    move.b    d0,d3

; move.b #4,d3

    lsl.w    #1,d3 
    and.b    #$10,d3 ; bpu3
    or.b    d3,d2 ;place bpu3 (for 8 planes)
	or.w	#$0201,d2 ; bit 9 and 0 (ecsena & old thing)
    
    ; add dual playfield ?
    btst    #2,d1	; CCLR_DUALPF		
    beq        .nodp
        bset #10,d2
.nodp    
    move.w    #bplcon0,(a0)+   
    move.w    d2,(a0)+

    ; - - - - bplcon1, bplcon2, (bplcon3 TODO?)
    ;bplcon2 screen priority .. kill EHB    
    ;bplcon1 screen shift,
    ;bpl1mod dual1 modulo
    ;bpl2mod dual2 modulo

	movem.l    bplconRegs(pc),d2-d5
	;d2 bplcon2: if sprite, front
	or.w	#$0040|$0007|$0038,d2   ;was $0024

    movem.l    d2-d5,(a0)    ; 16b
    ; keep pointers to it...
    lea    6(a0),a2
    move.l    a2,cp_bplcon1(a1)    
    lea    16(a0),a0

    ;sprite color banks to 16
	; $0011 -> means sprite palette is 16-31
	; 0011 ecs default 0022->32-47
	move.l    #(bplcon4<<16)|$0022,(a0)+

; - - - - - - - -  -
    ; - - - - clear sprite -> or not?
	lea	2(a0),a2
	move.l		a2,cp_sprite(a1)
    move.w    #sprpt,d2
    move.w    #16-1,d3
.l1
        move.w    d2,(a0)+
        addq    #2,d2
        clr.w    (a0)+
    dbf        d3,.l1
    ; - - - - then set bitplanes start
    ; note: static shouldn't be in copper ?...
    ; 
    ; first bplane values here:
    lea        2(a0),a2
    move.l    a2,cp_bitplane(a1)    
    move.w    #bplpt,d3
    move.w    d0,d2
    subq    #1,d2
    move.w    d2,cp_nbplanesm1(a1)
.l2
        move.w    d3,(a0) ; highptr
        addq    #2,d3
        move.w    d3,4(a0)    ;lowptr
        addq    #2,d3        
        lea    8(a0),a0        
    dbf        d2,.l2

	; - - -  - colors or not
	btst	#0,d1	;CCLR_DOCOLORS		
	beq	.nocolors	
	; start frame states
    btst    #2,d1	; CCLR_DUALPF		
    beq        .nodp2
; - - - - - set dual pf colors
; should set 48 base colors
; because pf2 can be 0-15 or 32-47 (or any 32*x+0)
;16c+16c 32c or maybe 48 for sprites
;todo extends 16 other for sprites...

	move.w	#64,d2
	bra	.fromdpf

;	 move.w	 #48,cp_nbColors(a1)
;	 lea cp_colorBanks+cpb_colorsh(a1),a2
;	 move.l	 #(bplcon3<<16)|$0000,(a0)+
;	 lea	 2(a0),a3
;	 move.l	 a3,(a2) ; keep
;
;	 move.l	 #($0180<<16)|($0000),d3
;	 move.l	 #$00020000,d4
;	 moveq	 #31,d2
;.cl1
;		 move.l	 d3,(a0)+
;		 add.l	 d4,d3
;;	  dbf d2,.cl1
;
	; - - - low 12 value
;	 lea cp_colorBanks+cpb_colorsl(a1),a2
;
;	 move.l	 #(bplcon3<<16)|$0200,(a0)+
;	 lea	 2(a0),a3
;	 move.l	 a3,(a2) ; keep
;
;	 move.l	 #($0180<<16)|($0000),d3
;	 ;move.l #$00020000,d4
;	 moveq	 #31,d2
;.cl2
;		 move.l	 d3,(a0)+
;		 add.l	 d4,d3
;	 dbf d2,.cl2
; - - - -  - - - - - -
;		bra .enddp
.nodp2
; - - - - - part that sets colors for indexed modes...
; - - - - - - set 24b colors for nb used
	
	moveq	#1,d2
	lsl.w	d0,d2 ;8p->256c
	; if 128, add 32 for sprite private colors
	cmp.w	#128,d2
	bne	.no128b
		move.w	#128+32,d2
.no128b

.fromdpf

	move.w	d2,cp_nbColors(a1)
	lea		cp_colorBanks(a1),a2
; - - - -  - - - - -
    subq    #1,d2 ; index of last (ie255) validated
    move.w    d2,d3
    lsr.w    #5,d3 ;nbbanks-1: 31c->0 32->0 33->1
                    ; 64-> d2=1 d1=63
	;d4 bplcon3+ bank index
	move.l	#(bplcon3<<16)|0,d4
.bankloopc
		move.l	d4,(a0)+ ;bplcon3 to high

    	; per 32c loop, high    
    	move.w    d2,d5 ; d2 nb color left-1
    	cmp.w    #31,d5
    	ble        .blc
        	move.w    #31,d5
.blc		move.w    d5,d6
		move.l	#$01800000,d7
		lea		2(a0),a3
		move.l	a3,(a2)+ ; cpb_colorsh	
.cl1high
			move.l	d7,(a0)+    
			add.l	#$20000,d7
    dbf    d5,.cl1high

    ; switch to low bit banks
    move.l	d4,d7
    or.w	#$0200,d7
	move.l	d7,(a0)+ ;bplcon3 low
        
	move.l	#$01800000,d7
	lea		2(a0),a3
	move.l	a3,(a2)+ ; cpb_colorsl
.cl1low
		move.l	d7,(a0)+    
		add.l	#$20000,d7    
    dbf    d6,.cl1low

	sub.w	#32,d2
	add.w	#$2000,d4

    dbf    d3,.bankloopc


; - - - - -  --
.enddp	

.nocolors
	; let bplcon3 with default here...
	; no need if color waitline ?   -> NEED

    btst    #2,d1	; CCLR_DUALPF
	beq        .nodp3
		; - - - Dual Playfield pf2 color banks:
		; stupid table for color offset in bplcon3:
		; $0400 +2
		; $0800 +4
		; $0c00 +8
		; $1000	+16 ->better, no bplcon3 to bank switch for dualpf
		; $1400 +32 -> good, use next bank
		; $1800 +64
		; $1c00 +128
		; + $0040 sprite lowres
		move.l	#(bplcon3<<16)|$1040,(a0)+
	bra		.endp3
.nodp3	  
		move.l	#(bplcon3<<16)|$0000,(a0)+
.endp3
	;;;;move.l  #$01800000,(a0)+ ; test


; - - - - - - - - after everything is set...
; - - - here: line wait...

	move.w	d1,d2
	and.w	#CCLR_WL_SCROLL|CCLR_WL_16c|CCLR_WL_HC,d2
	beq.w	 .nowaits
	
	; if here, must either waits for scrolls or colors or sprites...
	move.w	cp_nbLines(a1),d3


	lea	cp_scrollw(a1),a2
	lea	cp_colorw(a1),a6

	btst	#5,d1	 ; CCLR_WL_HC 32
	beq	.copscl	   
		;subq	 #1,d3	 ; manage 256 lines
		;wait second line $2d01
		;move.w	 #$2c01,d2 ; wait first line
		move.l	a0,cp_colorw(a1)
		add.l	#12+(12*256)+(32*4*15),a0
		bra .nowaits  ;rewritten now
	;olde bra .lend
.copscl
		move.l	cp_bplcon1(a1),(a2)+ ; first line scroll pointers are already here

		subq #2,d3	; manage 255 lines
		;wait second line $2d01
		move.w	#$2d01,d2 ;copper wait instr. part1
.lend

; - - - - first wait on top
.linesloop
	cmp.w	#$0001,d2	; when reach line 200
	bne	.nopt
	btst	#5,d1	 ; CCLR_WL_HC32
	bne	.nopt		; coperscreen horz wait eats it
;;finaly not	btst	#4,d1	; this other copperscreen also
;;	  bne .nopt
	; add wait at end of line 200
	move.l	#$ffdffffe,(a0)+	; pal l256 jump trick
.nopt

	move.w	d2,(a0)+
	move.w	#$fffe,(a0)+ ;$ff00 ? fffe?


	btst	#3,d1	;8  CCLR_WL_SCROLL
	beq	.nosc
		move.w	#bplcon1,(a0)+
	  move.l	a0,(a2) ; keep pointer to bplcon1
		move.w	#0,(a0)+ ; todo: set same as start as default
		move.w	#bpl1mod,(a0)+
		move.w	#0,(a0)+
		move.w	#bpl2mod,(a0)+
		move.w	#0,(a0)+
.nosc


	btst	#4,d1	; CCLR_WL_16c
	beq		.nopalperline
		; watch out, points adress
		; do 15 colors per lines
		lea	2(a0),a3
		move.l	a3,(a6)
		; apply per default colors 1-15
		move.w	#$0182,d5
		; one line touch 1->15, one line 17->31
		move.w	d3,d4
		and.w	#$01,d4
		lsl.w	#5,d4	; +32 or +0
		add.w	d4,d5

		moveq	#14,d4
.lpppl
			move.w	d5,(a0)+
			add.w	#2,d5
			clr.w	(a0)+
			;move.w	 d5,(a0)+
		dbf	d4,.lpppl
.nopalperline
	addq	#6,a6	;ptr+ word for trick
	
	; - -  -
;	 btst	 #5,d1	  ; CCLR_WL_HC32
;	 beq .nocopsc

	; need things here for dpf2 parallax scroll:
;	 move.l	 #(bplcon1<<16)|$0000,(a0)+
;	 move.l  #(bpl2mod<<16)|$0000,(a0)+
	
	; watch out, points adress
;old	move.l	a0,(cp_colorw-cp_scrollw)(a2)

;test	 ; low adress of cop2 -> TO BE FILLED
;	 move.l	 #(cop2lc+2)<<16,(a0)+
;	 move.l	 #$


;cop1lc	     EQU   $080
;cop2lc	     EQU   $084
;copjmp1     EQU   $088
;copjmp2     EQU   $08A


	; set color 1,2,3 at start
;OLDOK
;	 move.w	 #$0182,d5	 ; start col1
;	 moveq	 #11,d4
;.lpcps1
;		 move.w	 d5,(a0)+
;		 add.w	 #2,d5
;		 clr.w   (a0)+
;	 dbf d4,.lpcps1

;	  move.w  d2,d4
;	 ;hw for half screen
;	 or.b    #$68,d4 ;4a before
;	 move.w  d4,(a0)+
;	 move.w  #$fffe,(a0)+

;	 ; must have 1->12 twice
;	 move.w	 #$0182,d5	 ; start col1
;	 moveq	 #11,d4
;.lpcps2
;		 move.w	 d5,(a0)+
;		 add.w	 #2,d5
;		 move.w #$0ff0,(a0)+
;	 dbf d4,.lpcps2


;- - - - then waits
;	 move.w	 d2,d4
;	 ;hw for 24eme pixel: 4e
;	 or.b	 #$48,d4 ;4a before
;	 move.w	 d4,(a0)+
;	 move.w	 #$fffe,(a0)+
;	 move.w  #2,d4 ,9/3
;.lph
;	 move.l	 #$01820080,(a0)+
;	 move.l	 #$01840440,(a0)+
;	 move.l	 #$01880000,(a0)+
;	 move.l	 #$01880000,(a0)+

;	 move.l	 #$018600c8,(a0)+
;	 move.l	 #$01820404,(a0)+
;	 move.l	 #$01880000,(a0)+
;	 move.l	 #$01880000,(a0)+
	
;	 move.l	 #$01840cc0,(a0)+
;	 move.l	 #$018600cc,(a0)+
;	 move.l	 #$01880000,(a0)+
;	 move.l	 #$01880000,(a0)+	 
;	 dbf d4,.lph
;	 move.l	 #$01840080,(a0)+	 ; one more for scroll
;noneed	   move.l  #$01860fcc,(a0)+



.nocopsc
		
		
		; next line
		add.w	#$0100,d2
		addq	#4,a2

	dbf	d3,.linesloop		
	
.nowaits

; add wait/changes per lines: does fat coppers.
; allows parallax per lines:
;CCLR_WL_SCROLL	equ	8
; allow horizontal palette shading 
;CCLR_WL_16c	equ	16
    
    move.l    #$fffffffe,d2     ;wait end
    move.l    d2,(a0)+
    move.l    d2,(a0)+    ; twice for some hardware ?

	; compute size
	move.l	a0,a2
	sub.l	cp_start(a1),a2
	move.l	a2,cp_size(a1)


	;a0: following chip mem

	movem.l	(sp)+,a3/a6 
    rts        ; end _cc_Init
; - - - - - - -     
    ; quite static lowres 32 registers...    
windowRectRegs:
    ; display window.. doesn't vary except for overscan
    dc.w    diwstrt,$2c81    ;$08e   81 for 320px
    dc.w    diwstop,$2cc1    ;$090   c1
    ; horizontal timing: vary for res. and burst.
    ; default for Lowres320/noscroll/AGA burst
    dc.w    ddfstrt,$0038  ;$92  OCS default: $0038
	dc.w    ddfstop,$00d0 ;$94 def OCS: $00d0 change for burst mode
    
bplconRegs:
    ; note: default values
    dc.w    bplcon2,$0200    ; KILLEHB=9  
    ; keep order bplcon1/bpl1mod/bpl2mod like in wait lines
    dc.w    bplcon1,$0000    ; shift start
    dc.w    bpl1mod,0
    dc.w    bpl2mod,0
;/// - - - - - - _cc_switchCopper
	XDEF	_cc_switchCopper
_cc_switchCopper:
	; a1 copper

	movem.l	cdb_CopA(a1),a2/a3
	move.l	a3,cdb_CopA(a1)
	move.l	a2,cdb_CopB(a1)
	move.l	cp_start(a2),a2
    move.l  a2,cop1lc+$dff000
	rts
;///
;/// - - - - - - _cc_setBmAGA - - - - -

    ; a0 struct Bitmap
    ; screen mode should have same number of bitplanes
    XDEF    _cc_setBmAGA
    ; note: have different code for dualpf screens?
    ; version for AGA burst mode
_cc_setBmAGA:
    ; set bitmap to an inited copper    
    ; a0 struct Bitmap
    ; a1 copperptr
    ; d0.w    pixel dx*4
    ; d1.w    pixel dy


	; keep in d4
	move.w	bm_BytesPerRow(a0),d4
	move.w	d4,d5
	sub.w	cp_baseModulo(a1),d5	; has +8 for scroll
	; keep d4 d5
	

; - - - finaly do not clamp x: there is an empty line before top.
;	 tst.w	 d0
;	 bgt.b		 .x0g
;		 clr.w	 d0
;		 bra.b	 .x0l
;.x0g
;	 move.w	 d5,d6
;	 addq	 #8,d6	 ; 48->40
;	 lsl.w	 #3+2,d6 ; max scrollable x
;	 cmp.w	 d6,d0
;	 ble .x0l
;		 move.w	 d6,d0
;		 subq	 #1,d0
;.x0l
; - - -  -clamp Y
	tst.w	d1
	bgt.b	.y0g
		clr.w	d1	
		bra.b	.y0l
.y0g
	move.w	bm_Rows(a0),d6
;no because of setlines	   sub.w   cp_nbLines(a1),d6
	cmp.w	d6,d1
	ble	.y0l
		move.w	d6,d1
		subq	#1,d1	
.y0l

    ; - - -set width modulo
	move.w	d0,d6	; d0 >=0
	; - - find the bltcon1 scroll part
	neg.w	d0

	; === Parts that differs for 16b 32b 64b scrolls

	move.w	cp_fmodeIndex(a1),d7
	bne		.no16b
		; --16b scroll
		and.w	#$003f,d0 ; done
		; - - - find the -8,0,8,16,24 part
		add.w	#63,d6
		lsr.w	#6,d6;
		subq	#1,d6
		lsl.w	#1,d6
	bra	.caseend
.no16b
	cmp.w	#3,d7
	bne	.c32b
		; --64b scroll
		and.w	#$00ff,d0 ; done
		; - - - find the -8,0,8,16,24 part
		add.w	#(63*4)+3,d6
		lsr.w	#8,d6; >>6 >>2
		subq	#1,d6
		lsl.w	#3,d6
	bra	.caseend
.c32b
		; --the both 32b scroll cases
		; --64b scroll
		and.w	#$007f,d0 ; done
		; - - - find the -8,0,8,16,24 part
		add.w	#127,d6
		lsr.w	#7,d6; >>6 >>2
		subq	#1,d6
		lsl.w	#2,d6	 
.caseend
	
	; keep start value for parallax things.
	move.w	d6,cp_line0ByteDxPF1(a1)
	move.w	d6,cp_line0ByteDxPF2(a1)
    ext.l    d6
    
    move.l    cp_bplcon1(a1),a2
    ; in bpl1mod/bpl2mod
    move.w    d5,4(a2)
    move.w    d5,8(a2)

    ; d4 y scroll
    mulu.w    d1,d4    ; KEEP d4 it's bplane delta
    add.l    d6,d4 
    ; - - - the dreaded AGA SHRES scroll
    ; have to scramble...
    
;oldok
;    move.w	d0,d3
;    move.w	d0,d5
;    lsr.w    #2,d0 ; pixel4
;    lsl.w	#4,d5
;    and.w    #$000f,d0
;    and.w	#$0c00,d5	;to scroll 64 ($0c00) or 32 ($0400)   
;    lsl.w    #8,d3
;    and.w    #$0300,d3 ; low sub pixel    
;    or.w    d3,d0
;	or.w	d5,d0
;
;    move.w    d0,d3
;    lsl.w    #4,d3
;    or.w    d3,d0
;            
;    move.w    d0,(a2)

	clr.w	d3
	bfins	d0,d3{22:2}
	lsr.w	#2,d0
	bfins	d0,d3{28:4}
	lsr.w	#4,d0
	bfins	d0,d3{20:2}

    move.w    d3,d0
    lsl.w    #4,d0
    or.w    d0,d3
	move.w	d3,(a2)

    
    ; - - - -set planes pointers
    move.w    cp_nbplanesm1(a1),d3
    movem.l bm_Planes(a0),d6/d7
    sub.l    d6,d7    ; d2 delta
    add.l    d4,d6    ; Y scroll added to plane ptr

    ; todo: add 16b scrool on a1 here.

    move.l    cp_bitplane(a1),a2
.lp
        swap    d6
        move.w    d6,(a2) ;  high bplpt
        swap    d6
        move.w    d6,4(a2) ; low bplpt
        lea    8(a2),a2
        add.l    d7,d6
    dbf        d3,.lp

    rts
;///

;/// - - - - - - _cc_setBmAGADPF - - - - -

	; a0 struct Bitmap pf1 1->4 planes
	; a2 struct Bitmap pf2 1->4 planes
	; a1 copperptr
	XDEF    _cc_setBmAGADPF
_cc_setBmAGADPF:
    ; set bitmap to an inited copper
	; a0 bm pf1
    ; a1 copperptr
	; a2 bm pf2

    ; d0.w    pixel dx*4
    ; d1.w    pixel dy
    ; - -  for dualp
    ; d2.w pixel dx2*4 TODO
    ; d3.w dy2

	; keep in d4
	move.w  bm_BytesPerRow(a2),d4
	swap	d4
	move.w	bm_BytesPerRow(a0),d4
	; d4 bytewidthpf2/bytewidthpf1


	move.l    cp_bplcon1(a1),a3

	move.l	d4,d5
	move.w  cp_baseModulo(a1),d6
	sub.w	d6,d5
	move.w   d5,4(a3)  ; in bpl1mod
	
	swap	d5
	sub.w	d6,d5
	move.w	d5,8(a3)  ; in bpl2mod

	;keep d4

; - - finaly, does not clip x, there is an empty line before top now
;	 tst.w	 d0
;	 bgt.b		 .x0g
;		 clr.w	 d0
;		 bra.b	 .x0l
;.x0g
;	 move.w	 d5,d6
;	 addq	 #8,d6	 ; 48->40
;	 lsl.w	 #3+2,d6 ; max scrollable x

;	 cmp.w	 d6,d0
;	 ble .x0l
;		 move.w	 d6,d0
;		 subq	 #1,d0
;.x0l

	; still clamp Y
	tst.w	d1
	bgt.b	.y0g
		clr.w	d1
		bra.b	.y0l
.y0g
	move.w	bm_Rows(a0),d6
;no because of setlines	   sub.w   cp_nbLines(a1),d6
	cmp.w	d6,d1
	ble	.y0l
		move.w	d6,d1
		subq	#1,d1
.y0l

	; - - -set width modulo PF1
	move.w	d0,d6	; d0 >=0
	; - - find the bpl1mod scroll part
	neg.w	d0

	; === Parts that differs for 16b 32b 64b scrolls
	move.w	cp_fmodeIndex(a1),d7
	bne		.no16b1
		; --16b scroll
		and.w	#$003f,d0 ; done
		; - - - find the -8,0,8,16,24 part
		add.w	#63,d6
		lsr.w	#6,d6;
		subq	#1,d6
		lsl.w	#1,d6
	bra	.caseend1
.no16b1
	cmp.w	#3,d7
	bne	.c32b1
		; --64b scroll
		and.w	#$00ff,d0 ; done
		; - - - find the -8,0,8,16,24 part
		add.w	#(63*4)+3,d6
		lsr.w	#8,d6; >>6 >>2
		subq	#1,d6
		lsl.w	#3,d6
	bra	.caseend1
.c32b1
		; --the both 32b scroll cases
		; --32b scroll
		and.w	#$007f,d0 ; done
		; - - - find the -8,0,8,16,24 part
		add.w	#127,d6
		lsr.w	#7,d6; >>6 >>2
		subq	#1,d6
		lsl.w	#2,d6
.caseend1

	; keep start value for parallax things.
	move.w	d6,cp_line0ByteDxPF1(a1)
    ext.l    d6


	; d1 y scroll
	mulu.w    d4,d1    ; KEEP d4 it's bplane delta
	add.l    d6,d1
    ; - - - -set planes pointers

	

	;move.l	bm_Planes(a0),d6
	;sub.l    d6,d7    ;
	move.l	d1,d7	 
	;add.l    d1,d6    ; Y scroll added to plane ptr

	clr.w	d1
	move.b	bm_Depth(a0),d1
	sub.b	#1,d1

	lea		bm_Planes(a0),a0

	move.l    cp_bitplane(a1),a3
.lp1
		move.l	(a0)+,d6
		add.l	d7,d6

		move.w    d6,4(a3) ;  low bplpt
        swap    d6
		move.w    d6,(a3) ; high bplpt

		lea    16(a3),a3 ; jump 2 planes, does 0,2,4,6

	dbf        d1,.lp1
; - - - - - dpf2
	swap	d4

	; - - -set width modulo PF2
	move.w	d2,d6	; d0 >=0
	; - - find the bpl1mod scroll part
	neg.w	d2

	; === Parts that differs for 16b 32b 64b scrolls
	move.w	cp_fmodeIndex(a1),d7
	bne		.no16b2
		; --16b scroll
		and.w	#$003f,d2 ; done
		; - - - find the -8,0,8,16,24 part
		add.w	#63,d6
		lsr.w	#6,d6;
		subq	#1,d6
		lsl.w	#1,d6
	bra	.caseend2
.no16b2
	cmp.w	#3,d7
	bne	.c32b2
		; --64b scroll
		and.w	#$00ff,d2 ; done
		; - - - find the -8,0,8,16,24 part
		add.w	#(63*4)+3,d6
		lsr.w	#8,d6; >>6 >>2
		subq	#1,d6
		lsl.w	#3,d6
	bra	.caseend2
.c32b2
		; --the both 32b scroll cases
		; --64b scroll
		and.w	#$007f,d2 ; done
		; - - - find the -8,0,8,16,24 part
		add.w	#127,d6
		lsr.w	#7,d6; >>6 >>2
		subq	#1,d6
		lsl.w	#2,d6
.caseend2
	
	; keep start value for parallax things.

	move.w	d6,cp_line0ByteDxPF2(a1)
    ext.l    d6

    ; d4 y scroll
	mulu.w	d4,d3 ; y2
	add.l    d6,d3
    ; - - - -set planes pointers

;	 movem.l bm_Planes(a2),d6/d7
;	 sub.l    d6,d7    ;
;	 add.l    d3,d6    ; Y scroll added to plane ptr
	move.l	d3,d7

	clr.w	d1
	move.b	bm_Depth(a2),d1
	sub.b	#1,d1

	lea     bm_Planes(a2),a2

    ; todo: add 16b scrool on a1 here.

	move.l	cp_bitplane(a1),a3
	lea   	8(a3),a3
.lp2
		move.l	(a2)+,d6
		add.l	d7,d6
		move.w    d6,4(a3) ;  low bplpt
        swap    d6
		move.w    d6,(a3) ; high bplpt
		lea    16(a3),a3 ; jump 2 planes, does 1,3,5,7
	dbf        d1,.lp2

	
	; - - - the dreaded AGA SHRES scroll
	; have to scramble BPLCON1

	; PF1 d0
	bfins	d0,d3{22:2}
	lsr.w	#2,d0
	bfins	d0,d3{28:4}
	lsr.w	#4,d0
	bfins	d0,d3{20:2}

	bfins	d2,d3{18:2}
	lsr.w	#2,d2
	bfins	d2,d3{24:4}
	lsr.w	#4,d2
	bfins	d2,d3{16:2}

	move.l    cp_bplcon1(a1),a3
	move.w	d3,(a3)

    rts
;///

;/// - - - - - - _cc_setLineScrolls
	XDEF	_cc_setLineScrolls
_cc_setLineScrolls:
    ; a0 struct Bitmap
    ; a1 copperDbl cdb_
	move.l	a1,-(sp)

	
	lea	cdb_scrollvh(a1),a3
	move.w	(a3),d1
	move.w	2(a3),d0
	move.l	cdb_CopA(a1),a1
	
    bsr    _cc_setBmAGA

	move.l	(sp),a1 ; cdb_
	
	lea		cdb_scrollvh(a1),a3 ; one buffered yx scrolls per line
	; a1 cdb_ -> cp_
	move.l	cdb_CopA(a1),a1	; double buffered copper 

	lea	cp_scrollw+4(a1),a2	; in copper, point bltcon1
	;+1 because we modify bpl1mod in previous line 

	move.w	cp_nbLines(a1),d0
	subq	#2,d0	; start at line1

	; pf2dx high16  pf1dx low16
	move.l	cp_line0ByteDxPF2(a1),d6

	; - -  -- trash a0 a1
	clr.l	d5
	move.w	bm_BytesPerRow(a0),d5
	move.w	d5,d1	
	sub.w	cp_baseModulo(a1),d5

		move.w	cp_fmodeIndex(a1),d2 ; read here before a1 trashed
	move.w	d5,a0
	move.w	d1,a1	

	; -  -
	move.w  (a3),d1	; first Y pos PF1, used for bitmap pointers
	move.w	d1,a5


	; - - branch loop according to 16b,32b or 64b scroll mode
	tst.w	d2 	;  cp_fmodeIndex
	beq	.loop16
	cmp.w	#3,d2
	beq	.loop64
	bra.b	.loop32
	nop
	cnop	0,16	; inst cache align
.loop32
	; playfield 1
	movem.w	(a3)+,d1/d2 ;d1.w yl  d2.w x*4
	;- - -bplcon1=d3 scroll part
	move.w	d2,d4
	neg.w	d2	; it's the 7 low, consider and $007f

	clr.w	d3
	bfins	d2,d3{22:2}
	lsr.w	#2,d2
	bfins	d2,d3{28:4}
	lsr.w	#4,d2
	bfins	d2,d3{21:1}	;d3.w: pf1 scroll scramble

	; if one pf:
    move.w    d3,d2
    lsl.w    #4,d2
    or.w    d2,d3

	move.l	(a2),a4
	move.w	d3,(a4)	; bplcon1
	; - - - find the -4,0,4,8,12 part
	; 32b!
	add.w	#127,d4
	asr.w	#7,d4
	subq	#1,d4
	lsl.w	#2,d4

	move.l	-4(a2),a4 ; previous line
	; set 8balign modulos of previous line
	; it's defaultmod -prevdx + thisdx
	move.w	a0,d5	; because ax doesnt like .w
	sub.w	d6,d5	; -pf1 prevdx
	add.w	d4,d5
	; then
	move.w	d4,d6	; prev=current for next line

	; d1 curr y
	; a5 prev y
	move.w	d1,d4 ;
	sub.w	a5,d4 ; delta
	move.w	d1,a5 ; keep for next
	sub.w	#1,d4 ; -natural modulo
	move.w	a1,d3	; bytesperrow
	muls.w	d3,d4
	add.w	d4,d5

	move.w	d5,4(a4) ; prevline bpl1mod
	move.w	d5,8(a4) ; prevline bpl2mod

	lea	4(a2),a2
	dbf	d0,.loop32
	bra	.end
	cnop	0,16
.loop64
; - - - - -  -
;d0.w loop dec
;d1 dy
;d2 dx then tool
;d3 compute bltcon1
;d4 byte 8align dx
;d5.w 
;d6 "previous BDx" , pf2, pf1
;d7 

;a0 sbm 	-> then  default bpl1mod 
;a1 cp_then -> then  bm_ byteperRow

;a2 bplcon1// ptr
;a3	Y.w/X.w precomp base
;a4 comp
;a5 pf1 prev Y
;a6
		
; - - - like setbm, compute start
	
	; playfield 1
	movem.w	(a3)+,d1/d2 ;d1.w yl  d2.w x*4
	;- - -bplcon1=d3 scroll part
	move.w	d2,d4
	neg.w	d2	; it's the 8 low, consider and $00ff
	
	clr.w	d3
	bfins	d2,d3{22:2}
	lsr.w	#2,d2
	bfins	d2,d3{28:4}
	lsr.w	#4,d2
	bfins	d2,d3{20:2}	;d3.w: pf1 scroll scramble
	
	; if one pf:	
    move.w    d3,d2
    lsl.w    #4,d2
    or.w    d2,d3

	move.l	(a2),a4
	move.w	d3,(a4)	; bplcon1
	; - - - find the -8,0,8,16,24 part	
	add.w	#(63*4)+3,d4 ; aka 255
	asr.w	#8,d4; >>6 >>2
	subq	#1,d4
	lsl.w	#3,d4	

	move.l	-4(a2),a4 ; previous line
	; set 8balign modulos of previous line	
	; it's defaultmod -prevdx + thisdx
	move.w	a0,d5	; because ax doesnt like .w
	sub.w	d6,d5	; -pf1 prevdx
	add.w	d4,d5
	; then
	move.w	d4,d6	; prev=current for next line

	; d1 curr y
	; a5 prev y
	move.w	d1,d4 ;
	sub.w	a5,d4 ; delta
	move.w	d1,a5 ; keep for next
	sub.w	#1,d4 ; -natural modulo
	move.w	a1,d3	; bytesperrow
	muls.w	d3,d4
	add.w	d4,d5
	
	move.w	d5,4(a4) ; prevline bpl1mod
	move.w	d5,8(a4) ; prevline bpl2mod

	lea	4(a2),a2
	dbf	d0,.loop64
	bra	.end
	; - - - - -
	cnop	0,16
.loop16
	; playfield 1
	movem.w	(a3)+,d1/d2 ;d1.w yl  d2.w x*4
	;- - -bplcon1=d3 scroll part
	move.w	d2,d4
	neg.w	d2	; it's the 6 low, consider and $003f

	clr.w	d3
	bfins	d2,d3{22:2}
	lsr.w	#2,d2
	bfins	d2,d3{28:4}

	; if one pf:
    move.w    d3,d2
    lsl.w    #4,d2
    or.w    d2,d3

	move.l	(a2),a4
	move.w	d3,(a4)	; bplcon1
	; - - - find the -2,0,2,4,6 part
	; 16b!
	add.w	#63,d4
	asr.w	#6,d4
	subq	#1,d4
	lsl.w	#1,d4

	move.l	-4(a2),a4 ; previous line
	; set 8balign modulos of previous line
	; it's defaultmod -prevdx + thisdx
	move.w	a0,d5	; because ax doesnt like .w
	sub.w	d6,d5	; -pf1 prevdx
	add.w	d4,d5
	; then
	move.w	d4,d6	; prev=current for next line

	; d1 curr y
	; a5 prev y
	move.w	d1,d4 ;
	sub.w	a5,d4 ; delta
	move.w	d1,a5 ; keep for next
	sub.w	#1,d4 ; -natural modulo
	move.w	a1,d3	; bytesperrow
	muls.w	d3,d4
	add.w	d4,d5

	move.w	d5,4(a4) ; prevline bpl1mod
	move.w	d5,8(a4) ; prevline bpl2mod

	lea	4(a2),a2
	dbf	d0,.loop16
.end
	move.l	(sp)+,a1
	rts
;///
;/// - - - - - - _cc_setLineScrollsDPF
	XDEF	_cc_setLineScrollsDPF
_cc_setLineScrollsDPF:
    ; a0 struct Bitmap
	; a1 copperDbl
	; a2  struct Bitmap pf2
	movem.l	 a0/a1/a2,-(sp)

	lea	cdb_scrollvh(a1),a3
	move.w	(a3),d1
	move.w	2(a3),d0
	move.w	VHSIZE(a3),d3
	move.w	VHSIZE+2(a3),d2

	move.l	cdb_CopA(a1),a1
	bsr    _cc_setBmAGADPF


	movem.l	 (sp),a0/a1/a2 ; cdb_

	lea		cdb_scrollvh(a1),a3 ; one buffered yx scrolls per line

	; a1 cdb_ -> cp_
	move.l	cdb_CopA(a1),a1	; double buffered copper

	move.w	cp_nbLines(a1),d0
	subq	#2,d0	; start at line1

	; pf2dx high16  pf1dx low16
	move.l	cp_line0ByteDxPF2(a1),d6

	; - -  -- trash a0 a1
	;clr.l	 d5
	;move.w	 bm_BytesPerRow(a0),d5
	;move.w	 d5,d1
	;sub.w	 cp_baseModulo(a1),d5
	;move.w	 d5,a0
	;move.w	 d1,a1
	move.w	 bm_BytesPerRow(a0),d5
	move.w	d5,d1
	sub.w	 cp_baseModulo(a1),d5
	swap	d5
	move.w	d1,d5
	move.l	d5,a0 ; defmodpf1/bprpf1

	move.w	 bm_BytesPerRow(a2),d5
	move.w	d5,d1
	sub.w	 cp_baseModulo(a1),d5
		move.w	cp_fmodeIndex(a1),d2

	swap	d5
	move.w	d1,d5
		; last use of a1, scramble shit
		lea	cp_scrollw+4(a1),a2	; in copper, point bltcon1
		;+1 because we modify bpl1mod in previous line

	move.l	d5,a1 ; now a1 defmodpf2/bprpf2

	; - - -  - -
	; security: if copper compiled without vertical line waits
	; cannot apply scroll per line
	tst.l	a2
	beq	.end

	; -  -
	move.w	VHSIZE(a3),d1
	move.w	d1,a6	; a6 first Y pf2
	move.w  (a3),a5	; first Y pos PF1, used for bitmap pointers

	addq	#4,a3

	; - - branch loop according to 16b 32b 64b scroll mode
	tst.w	d2
	beq		.loop16
	cmp.w	#3,d2
	beq		.loop64
	bra		.loop32
	nop
	cnop	0,16	; inst cache align
.loop32
	; playfield 1
	move.w	2(a3),d2 ;Y/X pf1
	;- - -bplcon1=d3 scroll part
	move.w	d2,d4
	swap	d4
	neg.w	d2	; it's the 7 low, consider and $007f

	clr.w	d3
	bfins	d2,d3{22:2}
	lsr.w	#2,d2
	bfins	d2,d3{28:4}
	lsr.w	#4,d2
	bfins	d2,d3{21:1}	;d3.w: pf1 scroll scramble

	;playfield2
	move.l	VHSIZE(a3),d2	;Y/X pf2
	move.w	d2,d4	;d4 XPF1/XPF2
	neg.w	d2	; it's the 7 low, consider and $007f

	bfins	d2,d3{18:2}
	lsr.w	#2,d2
	bfins	d2,d3{24:4}
	lsr.w	#4,d2
	bfins	d2,d3{17:1}

	move.l	(a2),a4
	move.w	d3,(a4)	; bplcon1
	; - - - - -  - - - - -  - - - bpl2mod
	; pf2 first, y is in high d2
	add.w	#127,d4
	asr.w	#7,d4
	sub.w	#1,d4
	lsl.w	#2,d4

	move.l	-4(a2),a4 ; previous line

	move.l	a1,d5
	swap	d5
	swap	d6
	sub.w	d6,d5
	add.w	d4,d5
	move.w	d4,d6  ; prev=current
	swap	d6
	; out: d5

	; a1->  defmodpf2/bprpf2
	; d1 curr y
	; a6 prev y
	;move.w	 d1,d4 ;
	swap	d2	; d2 curr y pf2

	move.w	d2,d1 ; keep
	sub.w	a6,d2 ; delta
	move.w	d1,a6 ; keep for next

	sub.w	#1,d2 ; -natural modulo
	move.w	a1,d3	; bytesperrow pf2
	muls.w	d3,d2
	add.w	d2,d5

	move.w	d5,8(a4) ; prevline bpl2mod

	; - - - - - - - - -- -- - -
	swap	d4	;d4 X pf1
	; - - - find the -4,0,4,8,12 part
	add.w	#127,d4
	asr.w	#7,d4; >>6 >>2
	subq	#1,d4
	lsl.w	#2,d4

	; set 8balign modulos of previous line
	; it's defaultmod -prevdx + thisdx
	move.l	a0,d5	; because ax doesnt like .w
	swap	d5
	sub.w	d6,d5	; -pf1 prevdx
	add.w	d4,d5
	; then
	move.w	d4,d6	; prev=current for next line

	; d1 curr y
	; a5 prev y
	move.w	(a3),d4 ; y pf1
	move.w	d4,d1
	;old move.w	 d1,d4 ;
	sub.w	a5,d4 ; delta
	move.w	d1,a5 ; keep for next
	sub.w	#1,d4 ; -natural modulo
	move.w	a0,d3	; bytesperrow pf1
	muls.w	d3,d4
	add.w	d4,d5

	move.w	d5,4(a4) ; prevline bpl1mod

	lea	4(a2),a2
	lea	4(a3),a3
	dbf	d0,.loop32
	bra	.end
	cnop	0,16
.loop64
; - - - - -  -
;d0.w loop dec
;d1 dy
;d2 dx then tool
;d3 compute bltcon1
;d4 byte 8align dx
;d5.w
;d6 "previous BDx" , pf2, pf1
;d7 previous bdx pf2 ?

;old a0 sbm 	-> then a0.w  default bpl1mod
;old a1 cp_then -> then a1.w  bm_ byteperRow

; a0->  defmodpf1/bprpf1
; a1->  defmodpf2/bprpf2

;a2 bplcon1// ptr
;a3	Y.w/X.w precomp base
;a4 comp
;a5 pf1 prev Y
;a6 NEW pf2 prevY

; - - -  compute start

	; playfield 1
	move.w	2(a3),d2 ;Y/X pf1
	;- - -bplcon1=d3 scroll part
	move.w	d2,d4
	swap	d4
	neg.w	d2	; it's the 8 low, consider and $00ff

	bfins	d2,d3{22:2}
	lsr.w	#2,d2
	bfins	d2,d3{28:4}
	lsr.w	#4,d2
	bfins	d2,d3{20:2}	;d3.w: pf1 scroll scramble

	;playfield2
	move.l	VHSIZE(a3),d2	;	Y/X pf2
	move.w	d2,d4	;d4 XPF1/XPF2
	neg.w	d2	; it's the 8 low, consider and $00ff

	bfins	d2,d3{18:2}
	lsr.w	#2,d2
	bfins	d2,d3{24:4}
	lsr.w	#4,d2
	bfins	d2,d3{16:2}
	
	move.l	(a2),a4
	move.w	d3,(a4)	; bplcon1
	; - - - - -  - - - - -  - - - bpl2mod
	; pf2 first, y is in high d2
	add.w	#(63*4)+3,d4 ;xpf2      aka 255
	asr.w	#8,d4; >>6 >>2
	sub.w	#1,d4
	lsl.w	#3,d4	 
	
	move.l	-4(a2),a4 ; previous line

	move.l	a1,d5
	swap	d5
	swap	d6
	sub.w	d6,d5
	add.w	d4,d5
	move.w	d4,d6  ; prev=current
	swap	d6
	; out: d5

	; a1->  defmodpf2/bprpf2
	; d1 curr y
	; a6 prev y
	;move.w	 d1,d4 ;
	swap	d2	; d2 curr y pf2

	move.w	d2,d1 ; keep
	sub.w	a6,d2 ; delta
	move.w	d1,a6 ; keep for next

	sub.w	#1,d2 ; -natural modulo
	move.w	a1,d3	; bytesperrow pf2
	muls.w	d3,d2
	add.w	d2,d5

	move.w	d5,8(a4) ; prevline bpl2mod

	; - - - - - - - - -- -- - -
	swap	d4	;d4 X pf1
	; - - - find the -8,0,8,16,24 part
	add.w	#(63*4)+3,d4 ; aka 255
	asr.w	#8,d4; >>6 >>2
	subq	#1,d4
	lsl.w	#3,d4

	; set 8balign modulos of previous line
	; it's defaultmod -prevdx + thisdx
	move.l	a0,d5	; because ax doesnt like .w
	swap	d5
	sub.w	d6,d5	; -pf1 prevdx
	add.w	d4,d5
	; then
	move.w	d4,d6	; prev=current for next line

	; d1 curr y
	; a5 prev y
	move.w	(a3),d4 ; y pf1
	move.w	d4,d1
	;old move.w	 d1,d4 ;
	sub.w	a5,d4 ; delta
	move.w	d1,a5 ; keep for next
	sub.w	#1,d4 ; -natural modulo
	move.w	a0,d3	; bytesperrow pf1
	muls.w	d3,d4
	add.w	d4,d5

	move.w	d5,4(a4) ; prevline bpl1mod

	lea	4(a2),a2
	lea	4(a3),a3
	dbf	d0,.loop64
	bra	.end
	cnop	0,16
.loop16
	; playfield 1
	move.w	2(a3),d2 ;Y/X pf1
	;- - -bplcon1=d3 scroll part
	move.w	d2,d4
	swap	d4
	neg.w	d2	; it's the 8 low, consider and $003f

	clr.w	d3
	bfins	d2,d3{22:2}
	lsr.w	#2,d2
	bfins	d2,d3{28:4}

	;playfield2
	move.l	VHSIZE(a3),d2	;	Y/X pf2
	move.w	d2,d4	;d4 XPF1/XPF2
	neg.w	d2	; it's the 8 low, consider and $003f

	bfins	d2,d3{18:2}
	lsr.w	#2,d2
	bfins	d2,d3{24:4}

	move.l	(a2),a4
	move.w	d3,(a4)	; bplcon1
	; - - - - -  - - - - -  - - - bpl2mod
	; pf2 first, y is in high d2
	add.w	#63,d4 ;xpf2
	asr.w	#6,d4; >>6 >>2
	sub.w	#1,d4
	lsl.w	#1,d4

	move.l	-4(a2),a4 ; previous line

	move.l	a1,d5

	swap	d5
	swap	d6
	
	sub.w	d6,d5
	add.w	d4,d5
	move.w	d4,d6  ; prev=current
	swap	d6
	; out: d5

	; a1->  defmodpf2/bprpf2
	; d1 curr y
	; a6 prev y
	;move.w	 d1,d4 ;
	swap	d2	; d2 curr y pf2

	move.w	d2,d1 ; keep
	sub.w	a6,d2 ; delta
	move.w	d1,a6 ; keep for next

	sub.w	#1,d2 ; -natural modulo, one line
	move.w	a1,d3	; bytesperrow pf2
	muls.w	d3,d2
	add.w	d2,d5

	move.w	d5,8(a4) ; prevline bpl2mod

	; - - - - - - - - -- -- - -
	swap	d4	;d4 X pf1
	; - - - find the -2,0,2,4,6 part
	add.w	#63,d4
	asr.w	#6,d4; >>6 >>2
	subq	#1,d4
	lsl.w	#1,d4

	; set 8balign modulos of previous line
	; it's defaultmod -prevdx + thisdx
	move.l	a0,d5	; because ax doesnt like .w
	swap	d5
	sub.w	d6,d5	; -pf1 prevdx
	add.w	d4,d5
	; then
	move.w	d4,d6	; prev=current for next line

	; d1 curr y
	; a5 prev y
	move.w	(a3),d4 ; y pf1
	move.w	d4,d1
	;old move.w	 d1,d4 ;
	sub.w	a5,d4 ; delta
	move.w	d1,a5 ; keep for next
	sub.w	#1,d4 ; -natural modulo
	move.w	a0,d3	; bytesperrow pf1
	muls.w	d3,d4
	add.w	d4,d5

	move.w	d5,4(a4) ; prevline bpl1mod

	lea	4(a2),a2
	lea	4(a3),a3
	dbf	d0,.loop16

.end
	movem.l	 (sp)+,a0/a1/a2
	rts
;///



;/// - - - - - - _initBm - - - - - - -  -
    XDEF    _initBm
_initBm:
	move.l	a2,-(sp)
	
	;d0.w width pixel
    ;d1.w height pixel
    ;d2.w nbplanes
    ;d3 prefs: interlaced planes?

	movem.l	d0-d3,-(sp)

	; alloc struct for BM and also a write-bob struct
	move.l	#sbms_SIZEOF,d0 ; sbm_SIZEOF+bod_SIZEOF
	clr.l	d1
	bsr     _InAlloc
	tst.l	d0
	beq		.endf
	move.l	d0,a0

	movem.l	(sp),d0-d3

	lsr.w	#3,d0
    move.w    d0,bm_BytesPerRow(a0)
    move.w    d1,bm_Rows(a0)
    move.b    d2,bm_Depth(a0)
	addq	#2,d1	; actually have 1 empty line at top and bottom for scroll purpose

    mulu.w    d0,d1    ;d1.l size of 1 plane
    move.l    d1,sbm_PlaneSize(a0)
	move.l	a0,a2

	clr.l	d0
	move.b	d2,d0
	mulu.l  d1,d0
	addq	#8,d0	; for 8b align,
	moveq	#1,d1 ; chip
	bsr	_InAlloc

	move.l	d0,a0
	tst.l	a0
	bne	.cok
		; chip fail,
		move.l	a2,a0
		bsr		_InFree
		sub.l	a0,a0
		bra .endf
.cok
	move.l	a0,sbm_ChipAlloc(a2)
	
	; here chip alloc ok
	; 8b align for aga fmode
	; a0==d0
	addq	#7,d0
	and.l	#$fffffff8,d0
	move.l	d0,a1

	move.l	a2,a0
	; - -  init bitplanes pointers
	; jump 1st line for nice scrolls
	move.w	bm_BytesPerRow(a0),d2
	lea		(a1,d2.w),a1

	move.l  sbm_PlaneSize(a0),d1
	clr.w	d2
	move.b	bm_Depth(a0),d2
       
	lea    bm_Planes(a0),a2
    subq    #1,d2
.lpd
		move.l    a1,(a2)+
        add.l    d1,a1
    dbf    d2,.lpd
.endf

	; - - init bob destination struct
	; since this func init screens
	move.l	a0,sbms_bobDest+bod_background(a0)
	move.l	a0,sbms_bobDest+bod_dest(a0)
	clr.l	d1
	move.w    bm_BytesPerRow(a0),d1
	move.w    d1,sbms_bobDest+bod_OnePlaneByteWidth(a0)

	lsl.w	#3,d1 ;x1=0 x2=pix width
	move.l	d1,sbms_bobDest+bod_clipX1(a0)
	move.w	bm_Rows(a0),d1
	; y1=0 y2=rows
	move.l	d1,sbms_bobDest+bod_clipY1(a0)

	add.l	 #16,sp
	move.l	(sp)+,a2
    rts
; - - - - - -
	XDEF	_closeBm
_closeBm
	;a0 struct
	tst.l	a0
	beq		.end
	;free chip
	move.l	a0,a2
	move.l	sbm_ChipAlloc(a0),a0
	bsr	_InFree
	move.l	a2,a0
	bsr	_InFree
.end
	rts

;///
;/// - - - -  _SetCopperPaletteAga  - - - -
		XDEF	_SetCopperPaletteAga
_SetCopperPaletteAga
	;a0 sPalette
	;a1 copperPtr inited with DOCOLOR
	;d0 offset by 16 colors.
	move.w	d0,d4
	lsr.w	#1,d0	; bank32 offset
	and.w	#1,d4
	lsl.w	#6,d4	;*16*4 d4 offset in bank


	lea		cp_colorBanks(a1),a1
	; cpb_SIZEOF=8
	lea		(a1,d0.w*8),a1 ; a1 points start of banks

	move.w    spa_ColorCount(a0),d1
	beq		.noc
    lea        spa_Colors(a0),a0

    subq    #1,d1 ; index of last (ie255)
    move.w    d1,d2
    lsr.w    #5,d2 ;nbbanks-1

	
	move.l    a0,a3 ; color to read

.bankloop
    ; per 32c loop, high
	move.l	(a1)+,a2 ;a2 wr    
	lea		(a2,d4.w),a2 ; optional offset in bank
    move.w    d1,d3
    cmp.w    #31,d3
    ble        .bl
        move.w    #31,d3                
.bl	
	move.w    d3,d6

.clhigh
    	clr.w    d4
    	move.b    (a3)+,d4
    	lsl.w    #4,d4    
    	move.b    (a3)+,d4
    	move.b    (a3)+,d5
    	; get high4 of each
    	and.b    #$f0,d4
    	lsr.b    #4,d5
    	or.b    d5,d4
    	move.w    d4,(a2)
		addq	#4,a2
    dbf    d3,.clhigh

    ; switch to low bit banks
	move.l	(a1)+,a2 ;a2 wr    

.cllow
		move.b    (a0)+,d4
			and.b    #$0f,d4
			lsl.w    #8,d4
    	move.b    (a0)+,d4
    	move.b    (a0)+,d5
    	; get low4 of each

		lsl.b    #4,d4
    	and.b    #$0f,d5
		or.b    d5,d4
		move.w    d4,(a2)
    	lea	4(a2),a2
    dbf    d6,.cllow

	sub.w	#32,d1
	clr.w	d4	; no more offset
    dbf    d2,.bankloop	
.noc
	rts    
;///
;/// - - - - - - - _SetCopperPaletteAgaDbl
	XDEF	_SetCopperPaletteAgaDbl
_SetCopperPaletteAgaDbl:
	; - -  - - set palette in DOCOLOR copperlist
	; a0 palette struct.b
	; a1 copperdbl
	; d0 offset	
	movem.l	d0/a0/a1,-(sp)

	move.l	cdb_CopA(a1),a1
	bsr		_SetCopperPaletteAga
	; - - dbl copper
	movem.l	(sp)+,d0/a0/a1

	move.l	cdb_CopB(a1),a1
	bsr		_SetCopperPaletteAga

	rts
;///

;	 STRUCTURE	 sShadeTable,0
	; 32*16*4 is enough
;		 UWORD	 spa_ColorCount
;		 UWORD	 spa_dummy ; used by gif reader
;		 STRUCT	 spa_Colors,256*3   ; or less


;/// - - - - palette15c shading tables
		XDEF	_initShade15Table
_initShade15Table:
	;a0 original 16c palette in bytes
	;a1 table to fill
	;

	lea		spa_Colors(a0),a0
	move.l	a0,a2
	; - - - dark to normal
	move.l	#64,d1
	move.l	#(256-64)>>4,d2

	move.w	#15,d0	; per shade value
.lpshd1
	move.l	a2,a0
	move.w	#15,d7	; per color
.lpc1
		; -- -R
		clr.w	d3
		move.b	(a0)+,d3
		mulu.w	d1,d3
		lsr.l	#8,d3
		; -- -G
		clr.w	d4
		move.b	(a0)+,d4
		mulu.w	d1,d4
		lsr.l	#8,d4
		; -- -B
		clr.w	d5
		move.b	(a0)+,d5
		mulu.w	d1,d5
		lsr.l	#8,d5

		clr.w	d6
		lsr.w	#4,d3
		lsr.w	#4,d4
		lsr.w	#4,d5
		bfins	d3,d6{20:4}
		bfins	d4,d6{24:4}
		bfins	d5,d6{28:4}

		move.w	d6,(a1)+

	dbf		d7,.lpc1

	add.l	d2,d1
	dbf	d0,.lpshd1
; - -  -clearer

	; - - - dark to normal
	move.l	#256,d1
	move.l	#(256-128)>>4,d2


	
	move.w	#15,d0
.lpshd2
	move.l	a2,a0
	move.w	#15,d7	; per color, fixed width
.lpc2
		; -- -R
		move.w	#255,d3
		move.w	d3,d4
		move.w	d3,d5
		
 		 sub.b  (a0)+,d3
		sub.b  (a0)+,d4
		sub.b  (a0)+,d5

		mulu.w	d1,d3
		mulu.w	d1,d4
		mulu.w	d1,d5		 
		lsr.l	#8,d3
		lsr.l	#8,d4
		lsr.l	#8,d5
		neg.w	d3
		neg.w	d4
		neg.w	d5
		add.b	#255,d3
		add.b	#255,d4
		add.b	#255,d5


		;move.b  (a0)+,d3
		;move.b  (a0)+,d4
		;move.b  (a0)+,d5


		clr.w	d6
		lsr.w	#4,d3
		lsr.w	#4,d4
		lsr.w	#4,d5
		bfins	d3,d6{20:4}
		bfins	d4,d6{24:4}
		bfins	d5,d6{28:4}

		move.w	d6,(a1)+

	dbf		d7,.lpc2

	sub.l	d2,d1
	dbf	d0,.lpshd2

	; - +1 line
;	 move.w	 #1,d7
;.lpx
	lea	-32*2(a1),a0
	movem.l	(a0)+,d0-d6/a2
	movem.l	d0-d6/a2,(a1)
;	 lea	 32(a1),a1
;	 movem.l (a0)+,d0-d6/a2
;	 movem.l d0-d6/a2,(a1)
;	 lea	 32(a1),a1
;	 dbf d7,.lpx



	rts
;///
;/// - - - - _SetShadePerLines15DPF
	XDEF    _SetShadePerLines15DPF
_SetShadePerLines15DPF:
	;a0 inited pal shade table
	;a1 copdbl with colorw set


	lea	(33*32)(a0),a6
	move.l	cdb_CopA(a1),a1

	lea	cp_colorw(a1),a3 ; no ptr for first line !


	; ** HAVE TO APPLY 1ST LINE SHADE ON ORIGINAL PALETTE

	lea		cp_colorBanks(a1),a2
	move.l	(a2)+,a5 ; point copper high start palette
	; add 4 to start at color1 and do 15 not 16
	lea		4(a5),a5 ; optional offset in bank

	move.b	4(a3),d5
	and.w	#$001f,d5	; secure shade table length
	lsl.w	#5,d5	;*32 width
	lea		2(a0,d5.w),a4
; - -
	moveq	#14,d2
.flp
	; high values:
	move.w	(a4)+,(a5)
	addq	#4,a5

	dbf	d2,.flp
; - - - - -  -- DPF2 ...
	addq	#4,a5 ; jump over color16 unused
	move.b	4+6(a3),d5
	and.w	#$001f,d5	; secure shade table length
	lsl.w	#5,d5	;*32 width
	lea		2(a6,d5.w),a4
; - -
	moveq	#14,d2
.flp2
	; high values:
	move.w	(a4)+,(a5)
	addq	#4,a5
	dbf	d2,.flp2



;d0 color offset
;d1 bplcon3
;d2 line loop
;d3
;d4
;d5
;d6
;d7

;a0 shade table
;a1 cp_
;a2 point in copper
;a3 shade line value
;a4 selected shade line read
;a5
;a6
	
	; - - - - part2 per lines
;
	lea	cp_colorw(a1),a5 ; no ptr for first line !

; - - - - -V loop
	; no need to set first line ?
	move.w	cp_nbLines(a1),d2
	lsr.w	#1,d2 ; unroll *2
	sub.w	#2,d2

	bra	.lpl
	nop
	cnop	0,16
.lpl

DoOneLine	MACRO
	move.l	(a5),a2	   ; points after $0182 in copper
	move.w	4(a5),d0 ;set/old
	move.w	d0,d1
	lsr.w	#8,d0	;set
	cmp.b	d0,d1	; if previous has same shade, do not recopy
	beq	.elp\@
	move.b	d0,5(a5)
	lsl.w	#5,d0
	lea	    2(\1,d0.w),a4   ; start at color1

	; fastest/shortest cpu copy possible with .w
	movem.w	(a4)+,d0/d1/d3-d7/a1
	move.w	d0,(a2)
	move.w	d1,4(a2)
	move.w	d3,8(a2)
	move.w	d4,12(a2)
	move.w	d5,16(a2)
	move.w	d6,20(a2)
	move.w	d7,24(a2)
	move.w	a1,28(a2)

	movem.w	(a4)+,d0/d1/d3-d7
	move.w	d0,32(a2)
	move.w	d1,32+4(a2)
	move.w	d3,32+8(a2)
	move.w	d4,32+12(a2)
	move.w	d5,32+16(a2)
	move.w	d6,32+20(a2)
	move.w	d7,32+24(a2)
.elp\@
	addq	#6,a5
	ENDM
	; with offset in table, use 2 tables for both fields
	DoOneLine	a0
	DoOneLine	a6
	; - - -
	dbf	d2,.lpl	; end loop per line
.lpend
	; last line
	DoOneLine	a0



	rts
;///

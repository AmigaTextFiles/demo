
    opt c+   ;?
    opt    ALINK
;
; Date: 2016-11-09
;

; phxass blt.s I=include: M=68000

    incdir  include:
    
    
    include bob.i    
    include graphics/gfx.i
    include hardware/blit.i

    XREF    _debugv

; BitMap struct is extended by plane size:
sbm_PlaneSize equ bm_SIZEOF


CUSTOM      equ $dff000

bltddat     EQU   $000
dmaconr     EQU   $002
intenar     EQU   $01C
intreqr     EQU   $01E


bltcon0     EQU   $040
bltcon1     EQU   $042
bltafwm     EQU   $044
bltalwm     EQU   $046
bltcpt      EQU   $048
bltbpt      EQU   $04C
bltapt      EQU   $050
bltdpt      EQU   $054
bltsize     EQU   $058
bltcon0l    EQU   $05B      ; note: byte access only
bltsizv     EQU   $05C
bltsizh     EQU   $05E

bltcmod     EQU   $060
bltbmod     EQU   $062
bltamod     EQU   $064
bltdmod     EQU   $066

bltcdat     EQU   $070
bltbdat     EQU   $072
bltadat     EQU   $074


cop1lc      EQU   $080
cop2lc      EQU   $084
copjmp1     EQU   $088
copjmp2     EQU   $08A
copins      EQU   $08C
diwstrt     EQU   $08E
diwstop     EQU   $090
ddfstrt     EQU   $092
ddfstop     EQU   $094
dmacon      EQU   $096
clxcon      EQU   $098
intena      EQU   $09A
intreq      EQU   $09C
adkcon      EQU   $09E

* write definitions for dmaconw
DMAF_SETCLR    EQU   $8000
DMAF_AUDIO     EQU   $000F  * 4 bit mask
DMAF_AUD0      EQU   $0001
DMAF_AUD1      EQU   $0002
DMAF_AUD2      EQU   $0004
DMAF_AUD3      EQU   $0008
DMAF_DISK      EQU   $0010
DMAF_SPRITE    EQU   $0020
DMAF_BLITTER   EQU   $0040
DMAF_COPPER    EQU   $0080
DMAF_RASTER    EQU   $0100
DMAF_MASTER    EQU   $0200
DMAF_BLITHOG   EQU   $0400
; used
DMAF_ALL       EQU   $01FF  * all dma channels

* read definitions for dmaconr
* bits 0-8 correspnd to dmaconw definitions
DMAF_BLTDONE   EQU   $4000
DMAF_BLTNZERO  EQU   $2000

DMAB_SETCLR    EQU   15
DMAB_AUD0      EQU   0
DMAB_AUD1      EQU   1
DMAB_AUD2      EQU   2
DMAB_AUD3      EQU   3
DMAB_DISK      EQU   4
DMAB_SPRITE    EQU   5
DMAB_BLITTER   EQU   6
DMAB_COPPER    EQU   7
DMAB_RASTER    EQU   8
DMAB_MASTER    EQU   9
DMAB_BLITHOG   EQU   10
DMAB_BLTDONE   EQU   14
DMAB_BLTNZERO  EQU   13


  
    section code,code

; ==============================================================
; ========              NPrepBobBlit                    ========
; ==============================================================

;    register __d0 int destX, // left up corner on destination bitmap
;    register __d1 int destY, // left up corner on destination bitmap
;    register __a0 bob_ *bobBm,
;    register __a1 bod_ *dest,
;    register __a6 bld_ *pDesc );

    xdef    _NPrepBobBlit
    xdef    NPrepBobBlit    
_NPrepBobBlit
NPrepBobBlit
    movem.l d2-d7/a2-a6,-(sp)
    move.w  bod_clipX1(a1),d3
    ; exit if x2<=clipX1
    move.w  d0,d2
    add.w   bob_pixelWidth(a0),d2 ; visible pixel width
    ; KEEP d2=visible X2 ? ->no
    cmp.w   d2,d3
    bge NPrepBobBlitNoOp    ; all visible< x1 border
    ; test startx< x2 border now...
    cmp.w   bod_clipX2(a1),d0
    bge NPrepBobBlitNoOp
    
    move.l  bob_bm(a0),a4
    
    ; clip Y1
    sub.l   a5,a5   ; a5=d1 bob Y shifting
    move.w  bm_Rows(a4),a3    

    move.w  bod_clipY1(a1),d6
    sub.w   d1,d6   
    ble .noClipY1
        
        ; d7 free
        move.w  bm_Rows(a4),d1
        sub.w   d6,d1
        ble NPrepBobBlitNoOp

        move.l  d1,a3        
        mulu.w  bm_BytesPerRow(a4),d6
        move.l  d6,a5   ; a5 shift inside bob
        move.w  bod_clipY1(a1),d1
.noClipY1   

    ; clip Y2
    move.w  a3,d7
    add.w   d1,d7
    sub.w   bod_clipY2(a1),d7
    ble .noClipY2
        ; d7 >0
        ;ext.l    d7
        suba.w  d7,a3
        cmpa.w  #0,a3
        ble NPrepBobBlitNoOp
.noClipY2


;    ; clip Y2
;    move.w  a3,d7
;    add.w   d1,d7
;    sub.w   id_clipY2(a1),d7
;    ble .noClipY2
;        ; d7 >0
;        suba.w  d7,a3
;        cmpa.l  #0,a3
;        ble NPrepBobBlitNoOp
;.noClipY2



    
    ; from here: 
    ; d0: x1 -> nb byte to add to dest & source start pointers
    ; d1 start Y
    ; d3 clipX1 ->free
    ; d4 bob & mask modulo
    ; d5 bytes used for sprite width
    ; d6 free for work at start 
    ; d7.w (15bit scroll)
    
    move.w  bob_bytesPerRowPlane(a0),d5  ; byte width with extra column
    clr.w   d4  ; d4 bob & mask modulo -> width with ext column by default.
    
    ; clip X1
    move.w  d3,d6
    sub.w   d0,d6   ; inversed so left exceed is positive
    ble     .noClipX1   ; jump if x1>clipx1
        ; - - - - - if left clipped:
        lsr.w   #4,d6   ;nb words
        add.w   d6,d6   ; nb bytes rounded to 2
        ;addq   #2,d6   ; nb bytes really left for hardware metrics.-> no because left "masked" blit column
        ; apply shift:
        sub.w   d6,d5 ; to bob width
        add.w   d6,d4 ; to bob modulo
        
    move.w  d0,d7   ; d0 total pixel start position, d7 low scroll
        ; line start blitting on dest:
        ; forget d0... interesting value is in d3
        clr.l   d0
        move.w  d3,d0
        lsr.w   #3,d0
        and.b   #$fe,d0     ; ...word aligned (should be...)
            
    and.w   #$000f,d7
    bne .noAlign16  
    ; here: "aligned clip"
        addq    #2,d4 ; sprite modulo: jump unused extra column
        subq    #2,d5
        move.w  #-1,bld_bltafwm(a6)  ;not masking last column
        bra .endAlign16
.noAlign16      
    ; unaligned left clip: use bltafwm mask.
        lea leftClipTab(pc),a2
		move.w  (a2,d7.w*2),bld_bltafwm(a6)    ; right mask
        subq.l  #2,d0   ; start blit column before
        ; note: a left 16b column is actually or'ed with zeroes with that techniques
        ; but it is necessary to have first visible column OK.
.endAlign16     
        ; then for bit shifting and X coords:
        move.l  bm_Planes(a4),a2
        adda.w  d6,a2
        add.l   a5,a2
        move.l  a2,bld_bltbpt(a6)    ; source B pointer ->Bob
        move.l  bob_mask(a0),a2
        adda.w  d6,a2
        add.l   a5,a2       
        move.l  a2,bld_bltapt(a6)    ; source A pointer ->mask
    
        bra .endClipX1Test
.noClipX1
    move.w  d0,d7   ; d0 total pixel start position, d7 low scroll
    and.w   #$000f,d7
    bne .noAlign16b
        addq    #2,d4 ; sprite modulo: jump extra column
        subq    #2,d5
.noAlign16b
        move.l  bm_Planes(a4),a2
        add.l   a5,a2
        move.l  a2,bld_bltbpt(a6)    ; source B pointer ->Bob

        move.l  bob_mask(a0),a2
        add.l   a5,a2
        move.l  a2,bld_bltapt(a6)    ; source A pointer ->mask
    
        ; d0: x1 -> destination bitmap offset...
        lsr.w   #3,d0       ; (d0 is .l) pixel->bytes
        and.b   #$fe,d0     ; ...word aligned
    
        ; if no left clipped
        move.w  #-1,bld_bltafwm(a6)  ; first mask: unused if no X1 clip
.endClipX1Test

    move.w  #-1,bld_bltalwm(a6) ; default
    
    ; manage x2 clip after x1 clip ... d3 d6
    move.w  bod_clipX2(a1),d3
    lsr.w   #3,d3
	and.b	#$fe,d3
    sub.w   d0,d3
    sub.w   d5,d3   
    bge .noClipX2 
    ; d3<0
        sub.w   d3,d4 ; add to sprite modulo
        add.w   d3,d5 ; sub to blit width

        lea rightClipTab(pc),a2
        move.w  d7,d3
        add.w   d7,d3 ;<<1
        move.w  (a2,d3.w),bld_bltalwm(a6)    ; right mask        
.noClipX2

    ; - - - - -  --  - - - 
    ; dest and source modulo...
    move.w  bod_OnePlaneByteWidth(a1),d6
    sub.w   d5,d6
    move.w  d6,bld_bltcmod(a6)   ; 
    move.w  d6,bld_bltdmod(a6)

    move.w  d4,bld_bltamod(a6)   
    move.w  d4,bld_bltbmod(a6)
    
    ; a5 free, a4 free
    move.l  bod_background(a1),a2
    mulu.w  bm_BytesPerRow(a2),d1   
	ext.l	d0
    add.l   d1,d0 ; - - - - add vertical shifting   
    move.l  bm_Planes(a2),a2
    adda.l  d0,a2   ; horizontal scroll NO WAY, D0 MUST BE .L
    move.l  a2,bld_bltcpt(a6)    ; source C pointer ->BG (has no shift)
    
    move.l  bod_dest(a1),a2
    move.l  bm_Planes(a2),a2    
    adda.l  d0,a2; NO WAY, D0 MUST BE .L
    move.l  a2,bld_bltdpt(a6)    ; dest D pointer ->BG

; - - - d7 scroll bits
    ror.w   #4,d7
    move.w  #$0fca,d6 ; bltcon0 conf   e0 -> ca
    or.w    d7,d6
    move.w  d6,bld_bltcon0(a6)   ; ASH321ASA | 8->11: Use ABCD | low8 is minterm 
    ;clr.w  d7
    move.w  d7,bld_bltcon1(a6)   ; 12->15: x- 16 shift  bit 0: 0: area mode, 1: line
; - - - - bltsize
    lsr.w   #1,d5   ; in word now
    and.w   #$003f,d5   ; sure ?
    
    move.w  a3,d6   
       ; no need not interlaced
       ; clr.w   d7
       ; move.b  bm_Depth(a4),d7 ; same in dest ?
       ; mulu.w  d7,d6
         
    lsl.w   #6,d6
    or.w    d6,d5
    
    move.w  d5,bld_bltsize(a6)

;examp      move.l  a0,BLTAPTH(a6)  ; Plane1
;       move.l  a1,BLTBPTH(a6)  ; BobData
;       move.l  a0,BLTDPTH(a6)  ; Plane1 (Destination)
;       move.w  d3,BLTCON0(a6)  ; EOR   move.w  #$0d3c,d3
;       move.w  d7,BLTCON1(a6)
;       move.l  #-1,BLTAFWM(a6) ; No mask (hit both masks at once)
;       move.w  d0,BLTBMOD(a6)
;       move.w  d1,BLTAMOD(a6)  ; Clear BMOD, AMOD=ScreenWide-BobWide
;       move.w  d1,BLTDMOD(a6)
;       move.w  d2,BLTSIZE(a6)  ; (BobTall<<6)+(BobWide/2)

; test  
;       tst.b   (a6)        ; Agnus Bug
;.wait      btst.b  #14-8,dmaconr(a6)
;       bne.s   .wait
    movem.l (sp)+,d2-d7/a2-a6
    rts 
NPrepBobBlitNoOp
    ; if here, no blit needed
    clr.w   bld_bltsize(a6)
    movem.l (sp)+,d2-d7/a2-a6
    rts 


;re    xdef    _MBobI
;re   xdef    MBobI   
    xdef    _CopyBm
    xdef    CopyBm
        
;   register __d0 short destX, // left up corner on destination bitmap
;   register __d1 short destY, // left up corner on destination bitmap
;   register __a0 sInterlaceBob *bobBm,
;   register __a1 sInterlaceDest *dest 

leftClipTab
    dc.w    $0000,$0001,$0003,$0007
    dc.w    $000f,$001f,$003f,$007f
    dc.w    $00ff,$01ff,$03ff,$07ff
    dc.w    $0fff,$1fff,$3fff,$7fff
rightClipTab
    dc.w    $ffff,$fffe,$fffc,$fff8
    dc.w    $fff0,$ffe0,$ffc0,$ff80
    dc.w    $ff00,$fe00,$fc00,$f800
    dc.w    $f000,$e000,$c000,$8000        

CopyBm
_CopyBm
;    register __d0 short destX, // left up corner on destination bitmap
;    register __d1 short destY, // left up corner on destination bitmap
;    register __a0 sInterlaceBob *bobBm,
;    register __a1 sInterlaceDest *dest );
    ;a0 bob_
    ;a1 bod_

    movem.l d2-d7/a2-a6,-(sp)

    move.w  bod_clipX1(a1),d3    ; exit if x2<=clipX1
    move.w  d0,d2
    add.w   bob_pixelWidth(a0),d2 ; visible pixel width
    cmp.w   d2,d3
    bge .exit   ; all visible< x1 border

    ; test startx< x2 border now...
    cmp.w   bod_clipX2(a1),d0
    bge .exit
    
    move.l  bob_bm(a0),a4

;d0.w dx
;d1.w dy
;d2 free
;d3. clipX1 gardé a travers clipY
;d4
; d5.w bltsize
; d6.w rows to draw
;d7

;a0 bob
;a1 bod
;a2 tool table, puis..dest bm, puis dest plane
;a3 nbrows.w ->pouark
;a4 bob bm
;a5 shift inside bob  plane, puis bob plane src
;a6  dff

    sub.l   a5,a5   ; a5=d1 bob Y shifting
    move.w  bm_Rows(a4),d2
        
    movem.w    bod_clipY1(a1),d6/d7 ; d6 cy1, d7 cy2
    cmp.w    d1,d6
    ble    .noClipY1
        move.w    d6,d4
        sub.w    d1,d4        
        sub.w    d4,d2
        ble        .exit
        mulu.w  bm_BytesPerRow(a4),d4
        move.w    d6,d1
        move.l    d4,a5
.noClipY1
    ; clip Y2
    move.w  d2,d4
    add.w   d1,d4
    sub.w   d7,d4
    ble .noClipY2
        sub.w    d4,d2
        ble .exit
.noClipY2
    ; d6/d7/d4 reusable here    
    ; here: d2.w nb rows
    ;        a5.l future bob line start    
  
        lea CUSTOM,a6
    
    move.w  bob_bytesPerRowPlane(a0),d5  ; byte width with extra column

    clr.w   d4  ; d4 bob & mask modulo -> width with ext column by default.
    
    ; clip X1
    move.w  d3,d6
    sub.w   d0,d6   ; inversed so left exceed is positive
    ble     .noClipX1   ; jump if x1>clipx1
        ; - - - - - if left clipped:
        lsr.w   #4,d6   ;nb words
        add.w   d6,d6   ; nb bytes rounded to 2
        ; apply shift:
        sub.w   d6,d5 ; to bob width
        add.w   d6,d4 ; to bob modulo
	

    move.w  d0,d7   ; d0 total pixel start position, d7 low scroll
        ; line start blitting on dest:
        ; forget d0... interesting value is in d3
        clr.l   d0
        move.w  d3,d0
        lsr.w   #3,d0
        and.b   #$fe,d0     ; ...word aligned (should be...)
            
    and.w   #$000f,d7
    bne .noAlign16
    ; here: "aligned clip"
        addq    #2,d4 ; sprite modulo: jump unused extra column
		subq    #2,d5
        move.w  #-1,bltafwm(a6) ;not masking last column
        bra .endAlign16
.noAlign16      

    ; unaligned left clip: use bltafwm mask.
        lea leftClipTab(pc),a2
        move.w  d7,d3
        add.w   d7,d3 ;<<1
        move.w  (a2,d3.w),bltafwm(a6)   ; right mask
        subq.l  #2,d0   ; start blit column before
        ; note: a left 16b column is actually or'ed with zeroes with that techniques
        ; but it is necessary to have first visible column OK.
.endAlign16     
        ; then for bit shifting and X coords:
        lea    (a5,d6.w),a5
        ;adda.w    d6,a5    ; on adress .w is propagated (sure?)
        ;oldok:
        ;move.l  bm_Planes(a4),a2
		;adda.w  d6,a2
        ;add.l   a5,a2
        ;move.l  a2,bltapt(a6)   ; source B pointer ->Bob
    
        bra .endClipX1Test
.noClipX1
	move.w  d0,d7   ; d0 total pixel start position, d7 low scroll	  
	and.w   #$000f,d7
; - -no, was removing 2bytes when x0=16x
; --> only ok if 16 column added
	bne .noAlign16b
		addq    #2,d4 ; sprite modulo: jump extra column
		subq    #2,d5
.noAlign16b
        ;a5 aptr ok
        ;oldok move.l  bm_Planes(a4),a2
        ;oldok add.l   a5,a2
        ;oldok move.l  a2,bltapt(a6)   ; source B pointer ->Bob

        ; d0: x1 -> destination bitmap offset...
        lsr.w   #3,d0       ; (d0 is .l) pixel->bytes
        and.b   #$fe,d0     ; ...word aligned
		;not masking first column
		; because extra empty column coming in
		move.w  #-1,bltafwm(a6) 
.endClipX1Test
    
	moveq  #-1,d6	; for bltalwm
       
    ; manage x2 clip after x1 clip ... d3 d6
    move.w  bod_clipX2(a1),d3
    lsr.w   #3,d3
	and.b	#$fe,d3
    sub.w   d0,d3
    sub.w   d5,d3   
    bge .noClipX2 
    ; d3<0
        sub.w   d3,d4 ; add to sprite modulo
        add.w   d3,d5 ; sub to blit width   
        
        lea rightClipTab(pc),a2
        move.w  d7,d3
        add.w   d7,d3 ;<<1
		move.w  (a2,d3.w),d6	; right mask
.noClipX2
	move.w	d6,bltalwm(a6) ; default

	; - - - - -  --  - - -
    ; dest and source modulo...

    move.w  bod_OnePlaneByteWidth(a1),d6
	sub.w   d5,d6
    move.w  d6,bltdmod(a6)  
    move.w  d4,bltamod(a6)
    
    ; a5 free, a4 free
            
    move.l  bod_dest(a1),a2
    mulu.w  bm_BytesPerRow(a2),d1   
    move.l    sbm_PlaneSize(a2),a1 ; at last
	ext.l	d0
    add.l   d1,d0 ; - - - - add vertical shifting       
    
    move.l  bm_Planes(a2),a2    
    adda.l  d0,a2; NO WAY, D0 MUST BE .L
;latter,a2 dest kept    move.l  a2,bltdpt(a6)   ; dest D pointer ->BG

; - - - d7 scroll bits
    ror.w   #4,d7
    move.w  #$09f0,d6 ;  use C,D  minterm:  
    or.w    d7,d6
	move.w  d6,bltcon0(a6)  ; ASH3210 | 8->11: Use ABCD | low8 is minterm
	clr.w  d7
    move.w  d7,bltcon1(a6)  ; 12->15: x- 16 shift  bit 0: 0: area mode, 1: line
    
; - - - - bltsize
;;	  move.w  d5,_debugv+6

	
	lsr.w   #1,d5   ; in word now
;;    and.w   #$003f,d5   ; sure ?
    lsl.w   #6,d2    ;rows
    or.w    d2,d5

    add.l    bm_Planes(a4),a5

    clr.w   d7
    move.b  bm_Depth(a4),d7 ; same in des
	subq    #1,d7

    ;d2 free
    ;d3 free
    ;d4 free
    ;d5 BLTSIZE
    ;d6 free
    ;d7 nbplanes for loop

    ;a0 bob_
    ;a1 dest plane size
    ;a2 dest plane  dpt
    ;a3 rows -> can set in d6?        
    ;a4 bm of bob
    ;a5 bob y shifting? -> apt

    move.l    sbm_PlaneSize(a4),d6

; use: d7 d6 d5

    ; want no CPU when blitting
	move.w    #$8000|DMAF_BLITHOG,dmacon(a6)

    ; blit all planes now...
.planeLoop          
         move.l  a5,bltapt(a6)   ; source 
        move.l    a2,bltdpt(a6)    
            move.w  d5,bltsize(a6)    ; start 1plane blit
        add.l    a1,a2
        add.l    d6,a5        

.wait       
		btst.b  #14-8,dmaconr(a6)
        bne.s   .wait
	dbf        d7,.planeLoop

    ; switch off blit hog?
	move.w    #DMAF_BLITHOG,dmacon(a6)

.exit
    movem.l (sp)+,d2-d7/a2-a6
    rts 
        
	XDEF    CopyBmAl16NoClip
	XDEF	_CopyBmAl16NoClip
CopyBmAl16NoClip
_CopyBmAl16NoClip
;    register __d0 short destX, // left up corner on destination bitmap
;    register __d1 short destY, // left up corner on destination bitmap
;    register __a0 sInterlaceBob *bobBm,
;    register __a1 sInterlaceDest *dest );
    ;a0 bob_
    ;a1 bod_

    movem.l d2-d7/a2-a6,-(sp)

    move.l  bob_bm(a0),a4
    move.w  bm_Rows(a4),d2
	lea CUSTOM,a6
    move.w  bob_bytesPerRowPlane(a0),d5  ; byte width with extra column
    clr.w   d4  ; d4 bob & mask modulo -> width with ext column by default.
	; - - no clip here
	move.w  d0,d7   ; d0 total pixel start position, d7 low scroll
	and.w   #$000f,d7
	lsr.w   #3,d0       ; (d0 is .l) pixel->bytes
	and.b   #$fe,d0     ; ...word aligned
	;not masking first column
	; because extra empty column coming in
	moveq  #-1,d6
	move.w  d6,bltafwm(a6)
	move.w  d6,bltalwm(a6) ; default

	; - - - - -  --  - - -
    ; dest and source modulo...

    move.w  bod_OnePlaneByteWidth(a1),d6
	sub.w   d5,d6
    move.w  d6,bltdmod(a6)
    move.w  d4,bltamod(a6)

    move.l  bod_dest(a1),a2
    mulu.w  bm_BytesPerRow(a2),d1
	move.l	sbm_PlaneSize(a2),a1 ; at last
	ext.l	d0
    add.l   d1,d0 ; - - - - add vertical shifting

    move.l  bm_Planes(a2),a2
	adda.l  d0,a2	; must be .l?

; - - - d7 scroll bits
    ror.w   #4,d7
    move.w  #$09f0,d6 ;  use C,D  minterm:
    or.w    d7,d6
	move.w  d6,bltcon0(a6)  ; ASH3210 | 8->11: Use ABCD | low8 is minterm
	clr.w  d7
    move.w  d7,bltcon1(a6)  ; 12->15: x- 16 shift  bit 0: 0: area mode, 1: line

; - - - - bltsize
  ;test div height/2
  ;;;;lsr.w	  #1,d2
	
	
	lsr.w   #1,d5   ; in word now
    lsl.w   #6,d2    ;rows
    or.w    d2,d5

	move.l    bm_Planes(a4),a5

    clr.w   d7
    move.b  bm_Depth(a4),d7 ; same in des
	subq    #1,d7
    move.l    sbm_PlaneSize(a4),d6

    ; want no CPU when blitting
    move.w    #$8000|DMAF_BLITHOG,dmacon(a6)

    ; blit all planes now...
.planeLoop
		move.l  a5,bltapt(a6)   ; source
        move.l    a2,bltdpt(a6)
            move.w  d5,bltsize(a6)    ; start 1plane blit
        add.l    a1,a2
        add.l    d6,a5
.wait
		btst.b  #14-8,dmaconr(a6)
        bne.s   .wait
    dbf        d7,.planeLoop

	; switch off blit hog
    move.w    #DMAF_BLITHOG,dmacon(a6)

.exit
    movem.l (sp)+,d2-d7/a2-a6
    rts
	XDEF	_ClearBmRect
_ClearBmRect
;    register __d0 short destX, // left up corner on destination bitmap
;    register __d1 short destY, // left up corner on destination bitmap
;    register __a0 sInterlaceBob *bobBm,
;    register __a1 sInterlaceDest *dest );
	;d0 x start pix
	;d1 y start
	; - -
	;d2 width
	;d3 height

    ;a1 bod_
    movem.l d2-d7/a2-a6,-(sp)

	move.w	d0,d4
	add.w	d2,d4

	cmp.w  bod_clipX1(a1),d4    ; exit if x2<=clipX1
	ble		.exit



    ; test startx< x2 border now...
    cmp.w   bod_clipX2(a1),d0
	bge .exit

;	 move.w	 d0,_debugv+6
;	 move.w  bod_clipX2(a1),_debugv+2





;d0.w dx
;d1.w dy
;d2 width
;d3. ->ROW to draw
;d4
; d5.w bltsize
;
;d7

;a0 -
;a1 bod
;a2 tool table, puis..dest bm, puis dest plane
;a3 nbrows.w ->pouark
;a4 -
;a5 -
;a6  dff
 
    movem.w    bod_clipY1(a1),d5/d6 ; d5 cy1, d6 cy2
    cmp.w    d1,d5
    ble    .noClipY1
		move.w    d5,d4
        sub.w    d1,d4
		sub.w	d4,d3
        ble        .exit
        move.w    d5,d1
.noClipY1
    ; clip Y2
	move.w  d3,d4
	add.w   d1,d4
	sub.w   d6,d4
    ble .noClipY2
		sub.w    d4,d3
        ble .exit
.noClipY2


	move.w	d0,d5
	add.w	d2,d5 ; d4 end pix
	lsr.w	#3,d0
	lsr.w	#3,d5	;byte
	and.b	#$fe,d0
	and.b	#$fe,d5

	sub.w	d0,d5	; byte width length to write
	ble		.exit

	;OLD        a5.l future bob line start

        lea CUSTOM,a6

    clr.w   d4  ; d4 bob & mask modulo -> width with ext column by default.

	; simple X1 clip for clearing
;	 move.w  bod_clipX2(a1),..

	moveq  #0,d6   ; for bltalwm
	move.w  d6,bltalwm(a6) ; default
	move.w  d6,bltafwm(a6)

    ; manage x2 clip after x1 clip ... d3 d6
;	 move.w  bod_clipX2(a1),d3
;	 lsr.w   #3,d3
;	 and.b	 #$fe,d3
;	 sub.w   d0,d3
;	 sub.w   d5,d3
;	 bge .noClipX2
;	 ; d3<0
;		 sub.w   d3,d4 ; add to sprite modulo
;		 add.w   d3,d5 ; sub to blit width
;
;		 lea rightClipTab(pc),a2
;		 move.w  d7,d3
;		 add.w   d7,d3 ;<<1
;		 move.w  (a2,d3.w),d6	 ; right mask
;.noClipX2
;	 move.w	 d6,bltalwm(a6) ; default

	; - - - - -  --  - - -
    ; dest and source modulo...

    move.w  bod_OnePlaneByteWidth(a1),d6
	sub.w   d5,d6
    move.w  d6,bltdmod(a6)
	;no use move.w  d4,bltamod(a6)

    ; a5 free, a4 free

    move.l  bod_dest(a1),a2
    mulu.w  bm_BytesPerRow(a2),d1
	move.l	sbm_PlaneSize(a2),a1 ; at last
	ext.l	d0
	add.l   d1,d0 ; - - - - add vertical shifting

	clr.w	d7
	move.b	bm_Depth(a2),d7

	subq    #1,d7

	
	move.l  bm_Planes(a2),a2
	adda.l  d0,a2	; NO WAY, D0 MUST BE .L
;latter,a2 dest kept    move.l  a2,bltdpt(a6)   ; dest D pointer ->BG

	;$01ff for fill
	move.w  #$0100,bltcon0(a6)  ; ASH3210 | 8->11: Use ABCD | low8 is minterm
	clr.w  bltcon1(a6)  ; 12->15: x- 16 shift  bit 0: 0: area mode, 1: line

; - - - - bltsize


	lsr.w   #1,d5   ; in word now


;;    and.w   #$003f,d5   ; sure ?
	lsl.w   #6,d3    ;rows
	or.w    d3,d5

    ;d2 free
    ;d3 free
    ;d4 free
    ;d5 BLTSIZE
    ;d6 free
    ;d7 nbplanes for loop

    ;a0 bob_
    ;a1 dest plane size
    ;a2 dest plane  dpt
    ;a3 rows -> can set in d6?
    ;a4 bm of bob
    ;a5 bob y shifting? -> apt

; use: d7 d6 d5
;	 move.w	 d7,_debugv+6

    ; want no CPU when blitting
	move.w    #$8000|DMAF_BLITHOG,dmacon(a6)

    ; blit all planes now...
.planeLoop

        move.l    a2,bltdpt(a6)
			move.w  d5,bltsize(a6)    ; start 1plane blit
        add.l    a1,a2
.wait
		btst.b  #14-8,dmaconr(a6)
        bne.s   .wait
	dbf        d7,.planeLoop

	; switch off blit hog
	move.w    #DMAF_BLITHOG,dmacon(a6)

.exit
    movem.l (sp)+,d2-d7/a2-a6
    rts

		XDEF    _PrepareParaClear
_PrepareParaClear

;    register __d0 short destX, // left up corner on destination bitmap
;    register __d1 short destY, // left up corner on destination bitmap
;    register __a0 sInterlaceBob *bobBm,
;    register __a1 sInterlaceDest *dest );
	;d0 x start pix
	;d1 y start
	; - -
	;d2 width
	;d3 height

    ;a1 bod_
    movem.l d2-d7/a2-a6,-(sp)

	move.w	d0,d4
	add.w	d2,d4

	cmp.w  bod_clipX1(a1),d4    ; exit if x2<=clipX1
	ble		.exit



    ; test startx< x2 border now...
    cmp.w   bod_clipX2(a1),d0
	bge .exit

;	 move.w	 d0,_debugv+6
;	 move.w  bod_clipX2(a1),_debugv+2





;d0.w dx
;d1.w dy
;d2 width
;d3. ->ROW to draw
;d4
; d5.w bltsize
;
;d7

;a0 -
;a1 bod
;a2 tool table, puis..dest bm, puis dest plane
;a3 nbrows.w ->pouark
;a4 -
;a5 -
;a6  dff

    movem.w    bod_clipY1(a1),d5/d6 ; d5 cy1, d6 cy2
    cmp.w    d1,d5
    ble    .noClipY1
		move.w    d5,d4
        sub.w    d1,d4
		sub.w	d4,d3
        ble        .exit
        move.w    d5,d1
.noClipY1
    ; clip Y2
	move.w  d3,d4
	add.w   d1,d4
	sub.w   d6,d4
    ble .noClipY2
		sub.w    d4,d3
        ble .exit
.noClipY2


	move.w	d0,d5
	add.w	d2,d5 ; d4 end pix
	lsr.w	#3,d0
	lsr.w	#3,d5	;byte
	and.b	#$fe,d0
	and.b	#$fe,d5

	sub.w	d0,d5	; byte width length to write
	ble		.exit

	;OLD        a5.l future bob line start

        lea CUSTOM,a6

    clr.w   d4  ; d4 bob & mask modulo -> width with ext column by default.

	; simple X1 clip for clearing
;	 move.w  bod_clipX2(a1),..

	moveq  #0,d6   ; for bltalwm
	move.w  d6,bltalwm(a6) ; default
	move.w  d6,bltafwm(a6)

    ; manage x2 clip after x1 clip ... d3 d6
;	 move.w  bod_clipX2(a1),d3
;	 lsr.w   #3,d3
;	 and.b	 #$fe,d3
;	 sub.w   d0,d3
;	 sub.w   d5,d3
;	 bge .noClipX2
;	 ; d3<0
;		 sub.w   d3,d4 ; add to sprite modulo
;		 add.w   d3,d5 ; sub to blit width
;
;		 lea rightClipTab(pc),a2
;		 move.w  d7,d3
;		 add.w   d7,d3 ;<<1
;		 move.w  (a2,d3.w),d6	 ; right mask
;.noClipX2
;	 move.w	 d6,bltalwm(a6) ; default

	; - - - - -  --  - - -
    ; dest and source modulo...
	add.w	#2,d5
    move.w  bod_OnePlaneByteWidth(a1),d6
	sub.w   d5,d6
    move.w  d6,bltdmod(a6)
	;no use move.w  d4,bltamod(a6)

    ; a5 free, a4 free

    move.l  bod_dest(a1),a2
    mulu.w  bm_BytesPerRow(a2),d1
	move.l	sbm_PlaneSize(a2),a1 ; at last
	ext.l	d0
	add.l   d1,d0 ; - - - - add vertical shifting

	clr.w	d7
	move.b	bm_Depth(a2),d7

	subq    #1,d7


	move.l  bm_Planes(a2),a2
	adda.l  d0,a2
;latter,a2 dest kept    move.l  a2,bltdpt(a6)   ; dest D pointer ->BG


; add.w  #1,tstval
; move.w tstval,d2
; btst   #0,d2
; beq    .nott
;	 move.w  #$0100,bltcon0(a6)  ; ASH3210 | 8->11: Use ABCD | low8 is minterm
;	 bra .nott2
;.nott
;	 move.w  #$01ff,bltcon0(a6)  ; ASH3210 | 8->11: Use ABCD | low8 is minterm
;.nott2
	;$01ff for fill
	move.w  #$0100,bltcon0(a6)  ; ASH3210 | 8->11: Use ABCD | low8 is minterm
	clr.w  bltcon1(a6)  ; 12->15: x- 16 shift  bit 0: 0: area mode, 1: line

; - - - - bltsize


	lsr.w   #1,d5   ; in word now


;;    and.w   #$003f,d5   ; sure ?
	lsl.w   #6,d3    ;rows
	or.w    d3,d5

    ;d2 free
    ;d3 free
    ;d4 free
    ;d5 BLTSIZE
    ;d6 free
    ;d7 nbplanes for loop

    ;a0 bob_
    ;a1 dest plane size
    ;a2 dest plane  dpt
    ;a3 rows -> can set in d6?
    ;a4 bm of bob
    ;a5 bob y shifting? -> apt

	; here it's set, just blit first plane and let go


        move.l    a2,bltdpt(a6)
		move.w  d5,bltsize(a6)    ; start 1plane blit
		;add.l    a1,a2

	lea cPlanes(pc),a3
	movem.l	 a1/a2,(a3)
	move.w	d5,10(a3)

	move.w	#3,cLeftToDo

.exit
    movem.l (sp)+,d2-d7/a2-a6
    rts
;tstval: dc.w	 0
; - -  - -
; memorize
cLeftToDo:	dc.w	0
	; func ptr, current planeptr, planesize
cPlanes:
	dc.l	0,0,0
	XDEF    _ContinueParaClear
_ContinueParaClear:

	; if still in work, do nothing
	lea CUSTOM,a0
	btst.b  #14-8,dmaconr(a0)
	bne.b	.end

	; - -
	tst.w   cLeftToDo
	beq.b	.end
	movem.l	a2/a3/a4/a5,-(sp)
	
	lea		cPlanes(pc),a2
	movem.l (a2),a3/a4/a5

	add.l   a3,a4
	move.l  a4,4(a2)
	move.l  a4,bltdpt(a0)
	move.w  a5,bltsize(a0)


	movem.l	(sp)+,a2/a3/a4/a5


	sub.w	#1,cLeftToDo

.end
	rts
; - - - - - - -
	XDEF    _EndParaClear
_EndParaClear:

	lea CUSTOM,a6
; - - real cpu wait that does not hog bus
; works because of cache
	btst.b  #14-8,dmaconr(a6)
	beq.b   .endw
.wait
		rept	8
		nop
		endr
	btst.b  #14-8,dmaconr(a6)
	bne.s   .wait
.endw

	tst.w   cLeftToDo
	beq.b	.end
; - -set hog
   ; want no CPU when blitting
	move.w    #$8000|DMAF_BLITHOG,dmacon(a6)
    lea		cPlanes(pc),a2
    movem.l	(a2),a3/a4/a5
.reloop

	add.l	a3,a4
	move.l	a4,bltdpt(a6)
	move.w  a5,bltsize(a6)

.wait2
		nop
		btst.b  #14-8,dmaconr(a6)
		bne.s   .wait2

	sub.w	#1,cLeftToDo
	bgt.s	.reloop
	

	; switch off blit hog
	move.w    #DMAF_BLITHOG,dmacon(a6)

.end
	rts


	opt c+
    opt    ALINK

	ifnd	EXEC_TYPES_I
		include	exec/types.i
	endc

	include	demoData.i

	XREF	_InAlloc
	XREF	_InFree
	XREF	_debugv
	XREF	_mfast

	XREF    _ContinueParaClear
	XREF    _EndParaClear

	XREF    _UpdateCB

	include	k3d.i

CUSTOM      equ $dff000
dmaconr     EQU   $002

CB_NEAR=1
CB_FAR=2

CB_LEFT=4
CB_RIGHT=8
CB_UP=16
CB_DOWN=32

CLIPLEFT=0
CLIPRIGHT=320
CLIPUP=2
CLIPDOWN=256-2
CLIPNEAR=(128)
CLIPFAR=($1d80)

CENX=(160)
CENY=(128+32)

    section code,code
;/// - - - - - _Scene2d_init
	XDEF    _Scene2d_init
_Scene2d_init:
	; return a0 to be freed with _InFree
	;a1: obj ptr list
	;d5.w nbv
	;d1.w nbquads
 
	; - - - -
	; one alloc for scn_ + n*obr + nbvt*vtc_

	;d0 alloc size
	move.l	#obr_SIZEOF+scn_SIZEOF,d0

	;d3 d2 nbq
	move.w	d1,d3
	move.w	d1,d2
	; 4*3 for sort buffers
; (8*plce_SIZEOF) for clipping cells& vertex -> SHOULD 12
NBCCELLSBYPOL=8
	mulu.w	#polc_SIZEOF+(4*2)+(NBCCELLSBYPOL*plce_SIZEOF),d2
	add.l	d2,d0
	
	move.w	d5,d2 ; d5 total nbv
	mulu.w	#vtf_SIZEOF,d2
	add.l	d2,d0

	; - -  -d0 byte alloc
	clr.l	d1
	bsr	_InAlloc
	tst.l	a0
	beq		.end

	move.w	d3,scn_TotalNbPols(a0)


	lea	scn_obj(a0),a6
	lea scn_SIZEOF(a0),a5  ; point first obr

	; -  - init chained list of object refs
	;subq	 #1,d7
; - - 1 obj to init
		move.l	a5,(a6) ; current obj to pointer
		;lea	 obr_next(a5),a6
		clr.l   obr_next(a5)	;1obj
		; - - NO obr_ref
		clr.l  obr_ref(a5)
		lea     obr_SIZEOF(a5),a5
; - - - -
	; now a5 is start of vtf_ list
	; - - loop again
	move.l	a5,scn_mainvtf(a0)
	move.l	scn_obj(a0),a6
;.lp2
;	 tst.l	 a6
;	 beq	 .lp2e
	; - - - init obr values
	; a5 is vtt
	move.l	a5,obr_vtf(a6)
	move.w	d5,d0

	; - - get pointers to vertex write tables
	mulu.w  #vtf_SIZEOF,d0
	add.l	d0,a5
	move.l	a5,obr_vtfEnd(a6)
	; - - -
;	 move.l	 obr_next(a6),a6
;	 bra .lp2
.lp2e

; - - reloop to set polygons
	clr.w	d1 ; used as line counter

	move.l	a5,scn_PolcsBase(a0)
	move.l	scn_mainvtf(a0),a2
	move.l	scn_obj(a0),a6

	move.w	scn_TotalNbPols(a0),d0

	move.l  a5,obr_polc(a6)

	sub.w	#1,d0 ; last quad is special
.lpcomppl
		; init quad
		move.b	#1,polc_NbV(a5) ; means 4

		;does 0,2,3,1...
		move.w	#0,d2
		add.w   d1,d2
		mulu.w	#vtf_SIZEOF,d2
		lea		(a2,d2.l),a4
		move.l	a4,polc_c0+plc_vertex(a5)

		move.w	#1,d3
		add.w   d1,d3
		mulu.w	#vtf_SIZEOF,d3
		lea		(a2,d3.l),a4
		move.l	a4,polc_c1+plc_vertex(a5)

		move.w	#3,d4
		add.w   d1,d4
		mulu.w	#vtf_SIZEOF,d4
		lea		(a2,d4.l),a4
		move.l	a4,polc_c2+plc_vertex(a5)

		move.w	#2,d5
		add.w   d1,d5
		mulu.w	#vtf_SIZEOF,d5
		lea		(a2,d5.l),a4
		move.l	a4,polc_c3+plc_vertex(a5)


		add.w	#2,d1

		lea	polc_SIZEOF(a5),a5
	dbf	d0,.lpcomppl
; - - - - - last quad close circle
		; init quad
 ifd FINALYNOT
		move.b	#1,polc_NbV(a5) ; means 4

		;;movem.w  pls_v0(a3),d2/d3/d4/d5
		;does 0,2,3,1...
		move.w	#0,d2
		add.w   d1,d2
		mulu.w	#vtf_SIZEOF,d2
		lea		(a2,d2.l),a4
		move.l	a4,polc_c0+plc_vertex(a5)

		move.w	#1,d3
		add.w	d1,d3
		mulu.w	#vtf_SIZEOF,d3
		lea		(a2,d3.l),a4
		move.l	a4,polc_c1+plc_vertex(a5)

		move.w	#1,d4
		mulu.w	#vtf_SIZEOF,d4
		lea		(a2,d4.l),a4
		move.l	a4,polc_c2+plc_vertex(a5)

		move.w	#0,d5
		mulu.w	#vtf_SIZEOF,d5
		lea		(a2,d5.l),a4
		move.l	a4,polc_c3+plc_vertex(a5)
		;add.w	 #2,d1
		lea	polc_SIZEOF(a5),a5
	 endc
; - - -  -
	move.l  a5,obr_polcEnd(a6)

; - -  -
	move.w  scn_TotalNbPols(a0),d0

	move.l	a5,scn_polyTab1(a0)
	lea		(a5,d0.w*4),a5
	move.l	a5,scn_polyTab2(a0)
	lea		(a5,d0.w*4),a5
;	 move.l	 a5,scn_polyTab3(a0)
;	 lea	 (a5,d0.w*4),a5

	move.l	a5,scn_ClipCellStart(a0)
	move.w	scn_TotalNbPols(a0),d0
	sub.w	#1,d0
.lpInitExtraClipCell
	move.w	#(NBCCELLSBYPOL/2)-1,d1
.lpInitCell2
		lea		plce_SIZEOF(a5),a6
	; they all points their own vertex
		lea		plce_vinst(a5),a4
		move.l	a4,plc_vertex(a5)	; point their own vertex
		lea		plce_vinst(a6),a4
		move.l	a4,plc_vertex(a6)	; point their own vertex
	; they are linked 2 by 2:
	;NOt HERE	 move.l	 a5,plc_next(a6)
	;NOt here	 move.l	 a6,plc_prev(a5)
		lea		plce_SIZEOF(a6),a5
	
	dbf	d1,.lpInitCell2
	dbf	d0,.lpInitExtraClipCell

	;a0 still ok
.end
	rts
;///


;/// - - - - -  - - _scene2d_Refresh (wobble)
fxconfs:
	; r1 r2 freq / l1freq
	dc.w	32*4,40*4,1024/48,1024/32
    dc.w	32*4,40*4,1024/48,1024/32
;	 dc.w	 40*4,64*4,1024/16,1024/32
	dc.w	48*4,64*4,1024/32,1024/64
	dc.w	32*4,40*4,1024/(48),1024/64


	XDEF	_scene2d_Refresh
_scene2d_Refresh:
	;a0 scn_
	;d0 timer

	move.l	_mfast,a6

startfx=300*2
lengthfx=300*11-100

	sub.l   #startfx,d0
	blt		.end

	move.l	scn_obj(a0),a1
	tst.l	a1
	beq		.end


	; - -  go away if time>lengthfx
	; y on d5
	cmp.w	#lengthfx,d0
	blt.b	  .nogoaway
	move.l	d0,d1

		;go away
		lea		sf_Exp(a6),a5
;;		  move.w  #-128,d5 ;dy default

		sub.w	#lengthfx,d1 ; 0->....
		lsr.l	#2,d1
		cmp.w	#255,d1
		ble	.nolt
			move.w	#255,d1
.nolt
		move.w	(a5,d1.w*2),d5
		neg.w	d5
		asr.w	#2,d5
		add.w	#128,d5

		bra		.aftermove
.nogoaway



	move.l	d0,d1

	;need sintab
	move.w	#128,d5	;dy default
	lea		sf_Exp(a6),a5

	lsr.l	#2,d1
	cmp.l	#255,d1
	bgt		.aftermove
	
		neg.w	d1
		add.w	#255,d1
		move.w	(a5,d1.w*2),d5	;255->0
		neg.w	d5
		add.w	#128,d5
.aftermove

realgone=lengthfx+(21*300)
	cmp.w	#realgone,d0
	blt.b	  .nogoaway2
	move.l	d0,d1

		;go away
		lea		sf_Exp(a6),a5

		sub.w	#realgone,d1 ; 0->....
		lsr.l	#2,d1
		cmp.w	#255,d1
		ble	.nolt2
			move.w	#255,d1
.nolt2
		move.w	(a5,d1.w*2),d1
		;lsr.w	 #1,d1
		sub.w	d1,d5

.nogoaway2



	lea 	sf_SinTab(a6),a6

;d0 timer
;d1 ngl1
;d2 r2
;d3 temp
;d4 r1
;d5 r2
;d6 comp
;d7

;a0 scn_
;a1 obr_
;a2 vtf_
;a3 vtfEnd
;a4
;a5
;a6 sintab

cenx=160
;	 clr.w	 d1
decals=800
	move.l	d0,d7
	add.l	#decals,d7
	lsr.l	#8,d7
	lsr.l	#3,d7
	and.w	#3,d7
	; want 1st to happend longer
;	 sub.w	 #1,d7
;	 bge .notrick
;		 clr.w	 d7
;.notrick
	lea     fxconfs(pc),a4
	move.w	6(a4,d7.w*8),d7

	
;	 move.w	 #90*4,d4  ;r2
;	 move.w	 #80*4,d2
	; - - main ray sinus
	move.l	d0,d1
	lsr.l	#1,d1	; slow
	and.w	#$03ff,d1
	move.w 	   (a6,d1.w*2),d2
	asr.w	#7,d2	;-64->63
	;asr.w	 #1,d2	 ;-32->31
	add.w	#128,d2
	move.w	d2,d4
	add.w	#64,d4


;	 move.w	 #32*4,d4  ;r2
;	 move.w	 #(96+32)*4,d2

	movem.l obr_vtf(a1),a2/a3	;vtf,vtfEnd
	move.l	d0,d1
	lsr.l	#8,d1
.lpfreq1
	and.w	#$03ff,d1
	lea 	(a6,d1.w*2),a4	; sinus
	move.w	(a4),d3
	move.w	d3,d6

	muls.w	d2,d3	;r1*sin
	swap	d3		;y1
	add.w	d5,d3
	move.w	d3,vtf_py(a2)

	muls.w	d4,d6	;r2*sin
	swap	d6
	add.w	d5,d6
	move.w	d6,vtf_py+vtf_SIZEOF(a2)

	; - - - - cos	 
	move.w	512(a4),d3 ;cos
	move.w	d3,d6
	muls.w	d2,d3	;r1*cos
	swap	d3		;x1
	add.w	#cenx,d3
	move.w	d3,vtf_px(a2)

	muls.w	d4,d6	;r2*sin
	swap	d6
	add.w	#cenx,d6
	move.w	d6,vtf_px+vtf_SIZEOF(a2)


	add.w	d7,d1

	lea		vtf_SIZEOF*2(a2),a2
	cmp.l	a3,a2
	blt		.lpfreq1

	; -add other freqs
; bra .no2
;	 move.w	 #1024/16,d5

;	 move.w	 #64*4,d4  ;r2
;	 move.w	 #32*4,d2	 ;r1

;	 move.w	 #32*4,d4  ;r2
;	 move.w	 #0*4,d2	;r1

	;V good: avec 64
;	 move.w	 #40*4,d4  ;r2
;	 move.w	 #32*4,d2    ;r1
;	 move.w	 #1024/48,d5

;mf	   move.w  #0*4,d2	  ;r1
;	 move.w	 #32*4,d4  ;r2
;	 move.w	 #1024/16,d5

;	 move.w	 #32*4,d2	 ;r1
;	 move.w	 #64*4,d4  ;r2
;	 move.w	 #1024/16,d5

;ok
;	 move.w	 #16*4,d2	 ;r1
;	 move.w	 #64*4,d4  ;r2
;	 move.w	  #1024/(56),d5


	move.l	d0,d7
	add.l	#decals,d7
	lsr.l	#8,d7
	lsr.l	#3,d7
	and.w	#3,d7
	lea     fxconfs(pc),a4
	; want 1st to happend longer
;	 sub.w	 #1,d7
;	 bge .notrickb
;		 clr.w	 d7
;.notrickb
	lea		(a4,d7.w*8),a4
	movem.w	(a4),d2/d4/d5

	move.w	#1,d7
.lpbfrq
	
	move.l	d0,d1
	lsl.l   #1,d1

	move.l obr_vtf(a1),a2


.lpfreq
	and.w	#$03ff,d1
	lea 	(a6,d1.w*2),a4	; sinus
	move.w	(a4),d3
	move.w	d3,d6

	muls.w	d2,d3	;r1*sin
	swap	d3		;y1
	add.w  d3,vtf_py(a2)

	muls.w	d4,d6	;r2*sin
	swap	d6
	add.w  d6,vtf_py+vtf_SIZEOF(a2)

	; - - - - cos
	move.w	512(a4),d3 ;cos
	move.w	d3,d6

	muls.w	d2,d3	;r1*cos
	swap	d3		;x1
	add.w  d3,vtf_px(a2)

	muls.w	d4,d6	;r2*sin
	swap	d6
	add.w  d6,vtf_px+vtf_SIZEOF(a2)


	add.w	d5,d1

	lea		vtf_SIZEOF*2(a2),a2
	cmp.l	a3,a2
	blt		.lpfreq

	lsl.w	#1,d5
	
;	 btst	 #10,d0
;	 bne	 .noneg
	neg.w	d5
.noneg

	lsr.w	#1,d2
	lsr.w	#1,d4

	dbf		d7,.lpbfrq
.no2
;///
;/// - - - final loop get clipbits

	move.l obr_vtf(a1),a2

.lpf
	movem.w	vtf_px(a2),d0/d1

	clr.w	d7
	cmp.w	#CLIPUP,d1
	bgt.b .noup1
	bset	#4,d7
	bra.b .nodown1
.noup1
	cmp.w	#CLIPDOWN,d1
	ble.b .nodown1
	bset	#5,d7
.nodown1
; - - - $
; this disables useless left/right clipping
	cmp.w   #CLIPLEFT,d0
	bgt.b .noleft1
	bset    #2,d7
	bra.b .noright1
.noleft1
	cmp.w   #CLIPRIGHT,d0
	ble.b .noright1
	bset    #3,d7
.noright1

	move.w  d7,vtf_cb(a2)

	lea	    vtf_SIZEOF(a2),a2
	;addq	 #vtf_SIZEOF,a2
	cmp.l	a3,a2
	blt		.lpf
;///
.end
	rts
; - - - - - - - - _Scene2d_3dTo2d
	XDEF    _Scene2d_3dTo2d
_Scene2d_3dTo2d:
	;a0	scn_
	;a1 bmd_ bmdata

	movem.l	a0/a1,-(sp)


;/// - - - update all obj matrix from rot./pos


	; - - load sinus table
	move.l    _mfast,a6
	lea sf_SinTab(a6),a6

	move.l	scn_obj(a0),a1

.lpmobj
	tst.l	a1
	beq		.lpmobjend


	; - - - create 3 rotations matrix
	move.w	#$03ff,d3
	movem.w	 obr_o1(a1),d0/d1/d2 ; o1 o2 o3
	and.w	d3,d0
	and.w	d3,d1
	and.w	d3,d2

	lea	 (a6,d0.w*2),a5
	move.w	(a5),d3			;d3 sin1
	move.w	512(a5),d4      ;d4 cos1

	lea	 (a6,d1.w*2),a5
	move.w	(a5),d5			;d5 sin2
	move.w	512(a5),d6      ;d6 cos2

	lea	 (a6,d2.w*2),a5
	move.w	(a5),d0			;d0 sin3
	move.w	512(a5),d1      ;d1 cos3

	;d2 d7 free

	; - start with line Y, more simple
	move.w	d5,d2
	asr.w	#6,d2   ;<<14-><<8
	move.w	d2,obr_mtx+mtrx_yz(a1)	; sin2

	move.w	d6,d7
	move.w	d6,d2
	muls.w	d4,d2
	swap	d2
	asr.w	#4,d2	;<<28 -><<8
 neg.w	d2
	move.w	d2,obr_mtx+mtrx_yy(a1)	;cos1.cos2

	muls.w	d3,d7
	swap	d7
	asr.w	#4,d7	;<<28 -><<8
	neg.w	d7
	move.w	d7,obr_mtx+mtrx_yx(a1)	;-sin1.cos2

	; - - - also simple

	move.w	d6,d7
	move.w	d6,d2
	muls.w	d0,d2
	swap	d2
	asr.w	#4,d2	;<<28 -><<8
	move.w	d2,obr_mtx+mtrx_xz(a1)	;sin3.cos2

	muls.w	d1,d7
	swap	d7
	asr.w	#4,d7	;<<28 -><<8
	move.w	d7,obr_mtx+mtrx_zz(a1)	;-sin1.cos2

	; - - big (a.b)+(c.d.e) case

	move.w  d3,d2
	muls.w	d5,d2	;sin1.sin2
	swap	d2 		;<<12
	move.w	d2,a2	; save sin1.sin2<<12
	muls.w  d0,d2	; sin3.sin1.sin2<<26
	swap	d2		; sin3.sin1.sin2<<10

	move.w	d1,d7
	muls.w	d4,d7
	swap	d7		;<<12
	asr.w	#2,d7	;<<10
	add.w	d7,d2
	asr.w	#2,d2   ; cos3.cos1 + sin3.sin1.sin2
	move.w	d2,obr_mtx+mtrx_xx(a1)

	; - - -  - - - -
	move.w	a2,d2
	muls.w 	d1,d2	;cos3.sin1.sin2<<26
	swap	d2		;<<10

	move.w	d0,d7
	muls.w	d4,d7   ;sin3.cos1
	swap	d7		;<<12
	asr.w	#2,d7	;<<10
	sub.w	d7,d2
	asr.w	#2,d2	;cos3.sin1.sin2 - sin3.cos1
	move.w	d2,obr_mtx+mtrx_zx(a1)

	; - - - - -  - -
	;;move.w  d4,d2
	muls.w	d5,d4
	swap	d4  	;<<12
	move.w	d4,a2	;cos1.sin2
	muls.w  d0,d4	;sin3.cos1.sin2<<26
	swap	d4		;<<10

	move.w  d1,d7
	muls.w	d3,d7	;cos3.sin1
	swap	d7		;<<12
	asr.w	#2,d7	;<<10
	;sub.w	 d2,d7
	sub.w	d7,d4
	asr.w	#2,d4	;cos3.sin1-sin3.cos1.sin2<<8
; neg.w	 d7
	move.w	d4,obr_mtx+mtrx_xy(a1)

	; - - -  - - - -
	move.w	a2,d2	;<<12
	muls.w  d1,d2
	swap	d2		;cos3.cos1.sin2<<10
;inv	neg.w	d2

	;;move.w  d0,d7
	muls.w	d3,d0
	swap	d0
	asr.w	#2,d0	;<<10
	; sub->add
	add.w	d0,d2	;-sin3.sin1-cos3.cos1.sin2 <<10
	asr.w	#2,d2
; neg.w	 d2
	move.w	d2,obr_mtx+mtrx_zy(a1)

	; - - - copy translation to matrix...
	movem.w obr_tx(a1),d0/d1/d2
	move.w	d0,obr_mtx+mtrx_xp(a1)
	move.w	d1,obr_mtx+mtrx_yp(a1)
	move.w	d2,obr_mtx+mtrx_zp(a1)
	; - - - -
	move.l	obr_next(a1),a1
	bra	.lpmobj
.lpmobjend
;///

;/// - - - transform vtx with matrix

	move.l	scn_obj(a0),a1
.lpmobjvtx
	tst.l	a1
	beq		.lpmobjvtxend

	; per obj,
	; = = = = = = = = = = == = = = = = =
	; - - load matrix in regs once for all
	movem.w	obr_mtx+mtrx_xx(a1),d0-d2
	movem.w	obr_mtx+mtrx_zx(a1),d3-d5

	swap	d3
	swap	d4
	swap	d5
	; do not movem.w, it does ext.l
	move.w  obr_mtx+mtrx_yx(a1),d3
	move.w  obr_mtx+mtrx_yy(a1),d4
	move.w  obr_mtx+mtrx_yz(a1),d5


	;a0 scn_ -> accum z
	;a1 obr_
	;a2 read vtx
	;a3 write vtx
	;a4 read end - test loop
	;a5 accum x
	;a6 accum y

	;d0.w xx
	;d1.w xy
	;d2.w xz
	;d3 yx zx<
	;d4 yy zy<
	;d5 yz zz<
	;d6 read
	;d7 read mul

	; prepare a2 a3 a4
	; TODO movem
	move.l	obr_vtx(a1),a2
	move.l	obr_vtf(a1),a3 ; vtx camera space
;old	move.l	obr_vtfEnd(a1),a4

	move.l	_mfast,a4
	lea     sf_YDistortSine(a4),a4



	; then loop in the inst cache:
	; note this should parallelie OK with blitter;
	; code in cache, massive regs use, no extra read/write
.lprotvtx

	;x
	move.w	(a2)+,d6
	; - - - x
	move.w	d6,d7
	muls.w	d0,d7
	move.l	d7,a5
	; - - - y
	move.w	d6,d7
	muls.w	d1,d7
	move.l	d7,a6
	; - - - z
	muls.w	d2,d6
	move.l	d6,a0
	; = = = = = = = = = =
	move.w	(a2)+,d6
; neg.w	 d6
	; - - - x
	move.w	d6,d7
	muls.w	d3,d7
	add.l	a5,d7  ;a5 free
	asr.l	#8,d7
	move.w	d7,vtf_cx(a3)

		asr.l	#2,d7
		add.w   obr_distort(a1),d7
		move.w	d7,a5
     
	; - - - y
	move.w	d6,d7
	muls.w	d4,d7
	add.l	a6,d7
	asr.l	#8,d7
	; - - distort y here ?
	tst.w	a5
	ble.b .nodistort
	cmp.w	#255,a5
	bge.b .nodistort
	swap	d0
		move.w	a5,d0
		move.w	(a4,d0.w*2),d0
		asr.w	#2,d0
		add.w	d0,d7
		swap	d0
.nodistort
	move.w	d7,vtf_cy(a3)
	; - - - z
	muls.w	d5,d6
	add.l	a0,d6
	asr.l	#8,d6
	move.w	d6,vtf_cz(a3)
	; = = = = = = = = = =
	addq	#2,a2
;no z	 move.w	 (a2)+,d6

	lea		vtf_SIZEOF(a3),a3
	;cmp.l   a4,a3
	cmp.l	obr_vtfEnd(a1),a3
	blt	    .lprotvtx



; - - -
	move.l	obr_next(a1),a1
	bra	.lpmobjvtx
.lpmobjvtxend




	move.l	(sp),a0

; - - - -loop again to add translation and project,
; and projection

	move.l	scn_obj(a0),a1
	move.w	scn_FarClip(a0),d7

	; keep minx maxx
firstX1=1024
firstX2=-8

	move.w	#firstX1,a6 ; will be x min
	move.w	#firstX2,a0 ; max

.lpmobjvtxproj
	tst.l	a1
	beq		.lpmobjvtxprojend

	move.w obr_mtx+mtrx_xp(a1),d0
	move.w obr_mtx+mtrx_yp(a1),d1
	move.w obr_mtx+mtrx_zp(a1),d2
	ext.l	d0 ;x
	;ext.l	 d1 ;y
	move.l	d0,a3

;optim after
	; fov related constant
	;move.l	 #$00010000,d7
;	 moveq	 #1,d7
;	 swap	 d7


	;a0 maxx
	;a1 obj
	;a2 read/write
	;a3 tx.l
	;a4 _vtfEnd
	;a5 write proj/cb
	;a6 minx

	;d0 clipbits
	;d1 ty.l
	;d2 tz.w
	;d3 x work
	;d4 y
	;d5 z work
	;d6 work trash
	;d7 cte fov


	move.l	obr_vtf(a1),a2
	move.l	obr_vtfEnd(a1),a4

;	 move.w  obr_distort(a1),d3
;	 move.l	 a1,-(sp)
;	 move.l	 _mfast,a1
;	 lea     sf_YDistortSine(a1),a1


.lpproj
	; read vtc without translation...
	movem.w	vtf_cx(a2),d3/d4/d5	  ; rotated x,y,z & ext.l

	add.l	a3,d3
	add.w	d1,d4
	add.w	d2,d5
	; resave cam pos for clipping:
	movem.w	 d3/d4/d5,vtf_cx(a2) ; final position to camera

	cmp.w	#CLIPNEAR,d5
	bgt		.front ; test d5
	;behind
	move.w	#CB_NEAR,vtf_cb(a2)
	bra.b .projend
.front

	; - - project
	; does 1/x
;	 move.l	 d7,d6
	moveq	#1,d6
	swap	d6

	divs.w	d5,d6

	muls.w	d6,d3	; project
	muls.w	d6,d4

	asr.l	#8,d3
	add.w	#CENX,d3
	move.w	d3,vtf_px(a2)
	asr.l	#8,d4
	add.w	#CENY,d4
	move.w	d4,vtf_py(a2)

	clr.w	d0
	cmp.w	d7,d5	; #CLIPFAR
	ble.b 	.nofar
	bset	#1,d0
.nofar
	cmp.w	#CLIPLEFT,d3
	bgt.b .noleft
	bset	#2,d0
	bra.b .noright
.noleft
	cmp.w	#CLIPRIGHT,d3
	ble.b .noright
	bset	#3,d0
.noright
	; - get x min max
	cmp.w	a6,d3
	bgt.b	.nobetterminX
		move.w	d3,a6
.nobetterminX
	cmp.w	a0,d3
	blt.b	.nobettermaxX
		move.w	d3,a0
.nobettermaxX

	cmp.w	#CLIPUP,d4
	bgt.b .noup
	bset	#4,d0
	bra.b .nodown
.noup
	cmp.w	#CLIPDOWN,d4
	ble.b .nodown
	bset	#5,d0
.nodown
	move.w	d0,vtf_cb(a2)

.projend
	lea		vtf_SIZEOF(a2),a2
	cmp.l	a4,a2
	blt		.lpproj


;CB_NEAR=1
;CB_FAR=2
;CB_LEFT=4
;CB_RIGHT=8
;CB_UP=16
;CB_DOWN=32
;;	  move.l  (sp)+,a1

	move.l	obr_next(a1),a1
	bra	.lpmobjvtxproj
.lpmobjvtxprojend



	cmp.w	#CLIPLEFT,a6
	bgt.b	.noclx1
		move.w	#CLIPLEFT,a6
.noclx1

	cmp.w	#CLIPRIGHT,a0
	ble.b	.noclx2
		move.w	#CLIPRIGHT,a0
.noclx2
	; if no vtx set x minmax at all..
	cmp.w	#firstX1,a6
	bne.b	  .ldX1ok
		move.w	#0,a6	; no better idea but resolve bug
.ldX1ok
	cmp.w	#firstX2,a0
	bne.b	  .ldX2ok
		move.w	#32,a0	 ; no better idea but resolve bug
.ldX2ok

	move.l	4(sp),a1
	move.w	a6,bmd_ldX1(a1)
	move.w	a0,bmd_ldX2(a1)

;///

	addq	#8,sp
	rts

	XDEF    _Scene2d_render
_Scene2d_render:
	;a0	scn_
	;a1 bmd_ bmdata

	movem.l	a0/a1,-(sp)

;/// - - - select polys: or bits/removeouts/test CCW/link CL
	movem.l	(sp),a0/a1

	move.w  scn_TotalNbPols(a0),d0
	sub.w	#1,d0
;test
;	 clr.w d0
	
	; pointer that select polygons
	movem.l	 scn_polyClipNone(a0),a3/a5
	move.l  scn_PolcsBase(a0),a1


;d0 loop poly
;d1 polyclipbit and
;d2 
;d5 farest Z
;d6 v1
;d7 polyclipbit or

;a0 vtf_ 1
;a1 polc_ current
;a2 vtf_ 0
;a3 select ClipNone
;a4 vtf_ 2/3
;a5 select Screen
;a6

	bra.b	.lpPrepPoly
	nop
	cnop	0,16	; cache align
.ppsizestart
.lpPrepPoly

	move.l	polc_c0+plc_vertex(a1),a2
	move.w	vtf_cb(a2),d1
	move.w	d1,d7

	move.l	polc_c1+plc_vertex(a1),a0
	move.w	vtf_cb(a0),d3
	and.w	d3,d1
	or.w	d3,d7

; does order v0 v1 (v3 option) v2
; so we can reuse pointers to v0 v1 v2 as:a2,a0,a4
;PROBLEM tri has lower z
	;  - - - optional 4rth
;	 tst.b   polc_NbV(a1)
;	 beq.b	   .pnoquad

		move.l	polc_c3+plc_vertex(a1),a4
		move.w	vtf_cb(a4),d3
		and.w	d3,d1
		or.w	d3,d7
;.pnoquad
	; add 4 v on z like that tris has same z weight as quads->bad
	;add.w	 d6,d5
;.afterz

	move.l	polc_c2+plc_vertex(a1),a4
	move.w	vtf_cb(a4),d3
	and.w	d3,d1
	or.w	d3,d7

	; - - decide if poly selected
	tst.w	d1
	bne.w	.unselect ; completely out

;OLD write z
;noneed	   move.w  d5,polc_z(a1)

	; keep clipbit state for the polygon
	move.w	d7,polc_cb(a1)

	movem.w	 vtf_px(a2),d1/d2 ;x0 y0
	movem.w	 vtf_px(a0),d3/d4 ;x1 y1	
	movem.w	 vtf_px(a4),d5/d6 ;x2 y2

	sub.w	d3,d1
	sub.w	d4,d2
	sub.w	d3,d5
	sub.w	d4,d6

	; d1d2->v0 d5/d6 v2
	; get z of cross product
	muls.w	d1,d6
	muls.w	d2,d5
	sub.l	d5,d6
	bge.b .unselect

	; here: we know selected
	; d7 knows the clip work to be done
	tst.b	d7
	beq.b	.noClip

		move.l	a1,(a5)+
    bra.b	.endSelect
.noClip
	move.l	a1,(a3)+	; in no clip base
.endSelect
	; - - poly is selected
	;140b before
	; - - - chain list here as we know we are selected
	;a0 a2  a4
	;a1 main polc_ base
 
	; for quad & tris:

	lea		polc_c1(a1),a0
	move.l	a0,polc_c0+plc_next(a1)
	move.l	a0,polc_c2+plc_prev(a1)

	lea		polc_c0(a1),a0
	move.l	a0,polc_cell(a1)	;default entry cell
								; after clipping.
	move.l	a0,polc_c1+plc_prev(a1)

	lea		polc_c2(a1),a2	;c2
	move.l	a2,polc_c1+plc_next(a1)
	;a0 c0
	;a2 c2

	tst.b	polc_NbV(a1)
	beq.b	  .mtri
.mquad
	move.l	a0,polc_c3+plc_next(a1)
	move.l	a2,polc_c3+plc_prev(a1)

	lea		polc_c3(a1),a0	;c3
	move.l	a0,polc_c2+plc_next(a1)
	move.l	a0,polc_c0+plc_prev(a1)

	bra.b .mend
.mtri
	move.l	a0,polc_c2+plc_next(a1)
	move.l	a2,polc_c0+plc_prev(a1)
.mend
;	 move.b   #1,polc_selected(a1) ;knows if need lighting
	lea	polc_SIZEOF(a1),a1
	dbf	d0,.lpPrepPoly
	bra	.pend
.unselect:
;	 clr.b   polc_selected(a1)
	lea	polc_SIZEOF(a1),a1
	dbf	d0,.lpPrepPoly
.ppsizeend
.pend
	move.l	(sp),a0

	movem.l	a3/a5,scn_polyClipNoneSe(a0)

	; - -count how many pols selected in each base
	; by subbing pointers
;	 sub.l	 scn_polyClipNone(a0),a3
;	 sub.l	 scn_polyClipScreen(a0),a5
;	 move.l	 a3,d0
;	 move.l	 a5,d1
;	 lsr.l	 #2,d0	 ; pointer size
;	 lsr.l	 #2,d1
;	 move.l	 d0,_debugv
;	 move.l	 d1,_debugv+4
;	 bra	 .endnopols
;	 move.l	 #789,_debugv+8
;	 move.l	 #.ppsizeend-.ppsizestart,_debugv+8

;///

	movem.l	(sp),a0/a1


;	 bra .nobdclip

;/// - - - clip up/down left/right
	move.l  scn_polyClipScreen(a0),a4
	cmp.l	a4,a5
	beq		.nobdclip
	move.l	a5,-(sp) ;scn_polyClipScreenSe(a0)

	move.l	scn_polyClipNoneSe(a0),a5

	;a3 stay
	move.l  scn_ClipCellStart(a0),a3


; - - - macro to search cell
FindFI	Macro
	;2 loops approach. big but fast
.lpbad\@
	move.l	plc_next(\1),\1
	move.l	plc_vertex(\1),\2
	move.w	vtf_cb(\2),d1
	btst	#\3,d1
	beq.s	.lpbad\@
	;here \1 is out with clip bit on.
.lpgood\@
	move.l	plc_next(\1),\1
	move.l	plc_vertex(\1),\2
	move.w	vtf_cb(\2),d1
	btst	#\3,d1
	bne.s	.lpgood\@
	; here \1 is First In for sure
	;a2
	endm


FindFO	Macro
	;1 more loop
.lpbad\@
	move.l	plc_next(\1),\1
	move.l	plc_vertex(\1),\2
	move.w	vtf_cb(\2),d1
	btst	#\3,d1
	beq.s	.lpbad\@
	;here \1 is out with clip bit on.
	endm

	
	bra.w	.lpPolyClipb1
	nop
	cnop	0,16
.createYVertex
	;params:
	;d0 xi
	;d1 yi
	;d2
	;d3 xo
	;d4 yo
	;d5
	;d6 Z clip consts

	;a2 fi
	;a3 new
	; -  - -

	;d6 clip near
	;a3 plce clip cell+vtf
	;d0d1d2 d3d4d5 in / out

	; z difs are unsigned
	sub.w	d4,d1	;(zi-zo) shd be >0
	neg.w	d4
	add.w	d6,d4 ;	(cz-zo)
	swap	d4	;<<16
	clr.w	d4
	lsr.l	#1,d4	; <<15, can then be used signed.

	divu.w	d1,d4	; result on 15b, express [0,1[
	;x/y dif are signed... ouch
	sub.w	d3,d0	;(xi-xo)

	muls.w	d4,d0
	add.l	d0,d0	;<<1 for the signed thing
	swap	d0
	add.w	d0,d3	;xo+(xi-xo)*((yc-yo)/(yi-yo))

	;set x,y
   movem.w  d3/d6,plce_vinst+vtf_px(a3)
	; - - check left/right clipbits
	clr.w	d0
	cmp.w	#CLIPLEFT,d3
	bgt.b .noleftz2
	bset	#2,d0
	bra.b .norightz2
.noleftz2
	cmp.w	#CLIPRIGHT,d3
	ble.b .norightz2
	bset	#3,d0
.norightz2
	move.w	d0,plce_vinst+vtf_cb(a3)
	rts
.createXVertex
	;params:
	;d0 xi
	;d1 yi
	;d2
	;d3 xo
	;d4 yo
	;d5
	;d6 Z clip consts

	;a2 fi
	;a3 new
	; -  - -

	;d6 clip near
	;a3 plce clip cell+vtf
	;d0d1d2 d3d4d5 in / out


	move.w	d6,plce_vinst+vtf_px(a3)
	; z difs are unsigned
	sub.w	d3,d0	;(xi-xo) shd be >0

	neg.w	d3
	add.w	d6,d3 ;	(cx-xo)

	swap	d3	;<<16
	clr.w	d3
	lsr.l	#1,d3	; <<15, can then be used signed.

	clr.w  plce_vinst+vtf_cb(a3)

	divu.w	d0,d3	; result on 15b, express [0,1[
	;x/y dif are signed... ouch
	sub.w	d4,d1	;(yi-yo)

	muls.w	d3,d1
	add.l	d1,d1	;<<1 for the signed thing
	swap	d1
	add.w	d1,d4	;xo+(xi-xo)*((yc-yo)/(yi-yo))

	;set x,y
   move.w  d4,plce_vinst+vtf_py(a3)

   rts
.samedx


	rts

; - - - - -
.lpPolyClipb1
	move.l	(a4)+,a1
	move.l	polc_cell(a1),a2
	move.w	polc_cb(a1),d0
	btst	#4,d0
	beq	.noup2

	; must have at least one vtx out

	;\1 	->get firstIn
	;\2      -> vertex of fi
	;\3 clip bit to btst
	FindFI	a2,a6,4

	;d2/d5 fre
	movem.w	 vtf_px(a6),d0/d1 ;pxi pyi projected

	move.l	plc_prev(a2),a6
	move.l	plc_vertex(a6),a6 ; lo
	; this is all we need from lo:
	movem.w	 vtf_px(a6),d3/d4 ;pxo pyo projected

	; link new to fi
	move.l	a3,plc_prev(a2)
	move.l	a2,plc_next(a3)

	;d6 clip z value
	move.w  #CLIPUP,d6
	bsr .createYVertex

	lea 	plce_SIZEOF(a3),a6 ;next new cell
	move.l	a3,plc_next(a6)
	move.l	a6,plc_prev(a3)
	move.l	a6,a3

	; - - - a2 still fi, walk to fo
	FindFO  a2,a6,4
	; this is all we need from fo:
	movem.w	 vtf_px(a6),d3/d4 ;pxo pyo
	move.l	plc_prev(a2),a2 ; a2:li
	move.l	plc_vertex(a2),a6
	movem.w	 vtf_px(a6),d0/d1 ;pxi pyi

	; link new to li
	move.l	a3,plc_next(a2)
	move.l	a2,plc_prev(a3)

	bsr .createYVertex

	lea 	plce_SIZEOF(a3),a3 ;next new cell

	;a2 must be "in" cell here ->li
	; note: no need to rehash for far cb

	move.l	a2,polc_cell(a1)

	; - - -after left and right clip
	bsr     _UpdateCB
	; d0 ored cb
	; d1 anded cb
	tst.w	d1
	bne	.notselected ; all out

.noup2

	btst	#5,d0
	beq	.nodown2


	;\1 	->get firstIn
	;\2      -> vertex of fi
	;\3 clip bit to btst
	FindFI	a2,a6,5

	movem.w	 vtf_px(a6),d3/d4

	move.l	plc_prev(a2),a6
	move.l	plc_vertex(a6),a6 ; lo
	; this is all we need from lo:
	movem.w	 vtf_px(a6),d0/d1

	; link new to fi
	move.l	a3,plc_prev(a2)
	move.l	a2,plc_next(a3)


	;d6 clip z value
	move.w  #CLIPDOWN,d6
	bsr .createYVertex

	lea 	plce_SIZEOF(a3),a6 ;next new cell
	move.l	a3,plc_next(a6)
	move.l	a6,plc_prev(a3)
	move.l	a6,a3

	; - - - a2 still fi, walk to fo
	FindFO  a2,a6,5
	; this is all we need from fo:
	movem.w	 vtf_px(a6),d0/d1
	move.l	plc_prev(a2),a2 ; a2:li
	move.l	plc_vertex(a2),a6
	movem.w	 vtf_px(a6),d3/d4

	; link new to li
	move.l	a3,plc_next(a2)
	move.l	a2,plc_prev(a3)

	bsr .createYVertex

	lea 	plce_SIZEOF(a3),a3 ;next new cell

	;a2 must be "in" cell here ->li
	; note: no need to rehash for far cb

	move.l	a2,polc_cell(a1)

	bsr     _UpdateCB
	; d0 ored cb
	; d1 anded cb
	tst.w	d1
	bne	.notselected ; all out

.nodown2

;;	  bra .tok

	btst	#2,d0
	beq		.noleft2

	; must have at least one vtx out

	;\1 	->get firstIn
	;\2      -> vertex of fi
	;\3 clip bit to btst
	FindFI	a2,a6,2

	;d2/d5 fre
	movem.w	 vtf_px(a6),d0/d1 ;pxi pyi projected

	move.l	plc_prev(a2),a6
	move.l	plc_vertex(a6),a6 ; lo
	; this is all we need from lo:

	movem.w	 vtf_px(a6),d3/d4 ;pxo pyo projected

	; link new to fi
	move.l	a3,plc_prev(a2)
	move.l	a2,plc_next(a3)

	;d6 clip z value
	move.w  #CLIPLEFT,d6
	bsr .createXVertex

	lea 	plce_SIZEOF(a3),a6 ;next new cell
	move.l	a3,plc_next(a6)
	move.l	a6,plc_prev(a3)
	move.l	a6,a3

	; - - - a2 still fi, walk to fo
	FindFO  a2,a6,2
	; this is all we need from fo:
	movem.w	 vtf_px(a6),d3/d4 ;pxo pyo
	move.l	plc_prev(a2),a2 ; a2:li
	move.l	plc_vertex(a2),a6
	
	movem.w	 vtf_px(a6),d0/d1 ;pxi pyi

	; link new to li
	move.l	a3,plc_next(a2)
	move.l	a2,plc_prev(a3)

	bsr .createXVertex

	lea 	plce_SIZEOF(a3),a3 ;next new cell

	;a2 must be "in" cell here ->li
	; note: no need to rehash for far cb

	move.l	a2,polc_cell(a1)

	; - - -after left and right clip
	;TODO just reload polc_cb here
	bsr     _UpdateCB
	; d0 ored cb
	; d1 anded cb
	tst.w	d1
	bne	.notselected ; all out

.noleft2

	btst	#3,d0
	beq		.noright2

	; must have at least one vtx out

	;\1 	->get firstIn
	;\2      -> vertex of fi
	;\3 clip bit to btst
	FindFI	a2,a6,3

	;d2/d5 fre
	movem.w	 vtf_px(a6),d3/d4 ;pxi pyi projected

	move.l	plc_prev(a2),a6
	move.l	plc_vertex(a6),a6 ; lo
	; this is all we need from lo:

	movem.w	 vtf_px(a6),d0/d1 ;pxo pyo projected

	; link new to fi
	move.l	a3,plc_prev(a2)
	move.l	a2,plc_next(a3)

	;d6 clip z value
	move.w  #CLIPRIGHT,d6
	bsr .createXVertex

	lea 	plce_SIZEOF(a3),a6 ;next new cell
	move.l	a3,plc_next(a6)
	move.l	a6,plc_prev(a3)
	move.l	a6,a3

	; - - - a2 still fi, walk to fo
	FindFO  a2,a6,3
	; this is all we need from fo:
	movem.w	 vtf_px(a6),d0/d1 ;pxo pyo
	move.l	plc_prev(a2),a2 ; a2:li
	move.l	plc_vertex(a2),a6

	movem.w	 vtf_px(a6),d3/d4 ;pxi pyi

	; link new to li
	move.l	a3,plc_next(a2)
	move.l	a2,plc_prev(a3)

	bsr .createXVertex

	lea 	plce_SIZEOF(a3),a3 ;next new cell

	;a2 must be "in" cell here ->li
	; note: no need to rehash for far cb

	move.l	a2,polc_cell(a1)

	; - - -after left and right clip
	;TODO just reload polc_cb here
	bsr     _UpdateCB
	; d0 ored cb
	; d1 anded cb
	tst.w	d1
	bne	.notselected ; all out

.noright2




.tok
	move.l	a1,(a5)+ ;select to no clip list

.notselected
	cmp.l   (sp),a4
	blt	    .lpPolyClipb1
.ClipBdle
	addq.l	#4,sp

	move.l	a5,scn_polyClipNoneSe(a0)


;///
.nobdclip


	ifd	trcl
	move.w	#$fd8,$0dff180
	endc
	;a0 scn
	movem.l	(sp),a0/a1

;/// - - - - Find Edge Cells

;d0 tool 1
;d1 max Y
;d2 more up y
;d3 more down y
;d4 tool
;d5 minY
;d6 -
;d7 test end

	; search min/max y
startMaxY=-8
startMinY=512+16
	moveq   #startMaxY,d1 ; will be max
	move.w  #startMinY,d5 ; will be min	   move.w  d1,bmd_ldY2(a1) ;max

;	 move.l  #.afterFe-.lpFindEdgeCells,_debugv
;	 move.l  #.pe1-.ps1,_debugv+4
;	 bra .endnopols


	move.l  scn_polyTab1(a0),a2
	move.l  scn_polyTab1Se(a0),d7

	cmp.l	d7,a2
	beq		.endnopols

	bra.b   .lpFindEdgeCells
	nop
	cnop	0,16
.lpFindEdgeCells


	move.l	(a2)+,a1
	; to cell
	move.l	polc_cell(a1),a3

;	 clr.l	 d2
;	 move.b	 polc_txt(a1),d2
;	 move.l	 d2,_debugv

;	 move.l	 plc_vertex(a3),a4
;	 movem.w  vtf_px(a4),d2/d3
;	 move.l	 d2,_debugv
;	 move.l	 d3,_debugv+4

;	 move.l	 plc_next(a3),a3
;	 move.l	 plc_vertex(a3),a4
;	 movem.w  vtf_px(a4),d2/d3
;	 move.l	 d2,_debugv+8
;	 move.l	 d3,_debugv+12
	; - - - -
;	 move.l	 plc_next(a3),a3
;	 move.l	 plc_vertex(a3),a4
;	 movem.w  vtf_px(a4),d2/d3
;	 move.l	 d2,_debugv
;	 move.l	 d3,_debugv+4

;	 move.l	 plc_next(a3),a3
;	 move.l	 plc_vertex(a3),a4
;	 movem.w  vtf_px(a4),d2/d3
;	 move.l	 d2,_debugv+8
;	 move.l	 d3,_debugv+12
;	 bra .endnopols


	; - - search upmost/left cell - just loop all cells
	;d2 more up Y
	;d3 more down
	;a3 elected
	;a4 tool
	move.l	a3,a6
	move.l	a3,a5 ;end
	move.w	#1<<14,d2 ; more up y
	moveq	#-1,d3
.lpzy1
	move.l	plc_next(a6),a6
	move.l	plc_vertex(a6),a4
	move.w	vtf_py(a4),d4
	cmp.w   d3,d4
	blt.b	.noya
		move.w	d4,d3
.noya
	cmp.w	d2,d4
	bgt.b	  .noyb
		;note: equals are took too
		move.w	d4,d2
		move.l	a6,a3
.noyb
	cmp.l	a6,a5
	bne		.lpzy1
	;a3 more high cell
	;d2 start y
	;d3 end y

	cmp.w	d2,d3	;poly on one line, bad case...
	beq		.badpoly

	move.w	d3,polc_maxy(a1)

	; search min/max with poly min/max
	cmp.w	d5,d2
	bge.b	.nobetterminY
		move.w	d2,d5
.nobetterminY
	cmp.w	d1,d3
	ble.b	.nobettermaxY
		move.w	d3,d1
.nobettermaxY

	; - - make sure it's more left cell
.retestleftmost
	move.l	plc_prev(a3),a5
	move.l	plc_vertex(a5),a4
	move.w	vtf_py(a4),d4
	cmp.w	d2,d4
	bne.b	.wasleftmost
		move.l	a5,a3
		bra.s	.retestleftmost
.wasleftmost
	; set the up/left cell here:
	move.l	plc_vertex(a3),a4 ; must !
	move.w	vtf_px(a4),d3

	move.l	a3,a5 	; l2=l1 default
	; find if same height l1/l2
.retestNextSamey
	move.l	plc_next(a5),a4
	move.l	plc_vertex(a4),a6
	move.w	vtf_py(a6),d0
	cmp.w	d2,d0
	bne.b	  .notpzcase
		move.l	a4,a5
		bra.s	.retestNextSamey
.notpzcase

	movem.l	 a3/a5,polc_upLeftCell(a1)

	;d7 end pointer
	cmp.l   d7,a2
	blt     .lpFindEdgeCells
	bra.b	.afterFe
.badpoly
	clr.l   -4(a2)
	cmp.l   d7,a2
	blt     .lpFindEdgeCells
.afterFe
; - - -  - -
	move.l	4(sp),a1		;bmd_

	cmp.w	#startMaxY,d1
	beq     .endnopols	; means no Y actually used

	move.w	d1,bmd_ldY2(a1)	;max
	move.w	d5,bmd_ldY1(a1) ;min

	move.w	#0,bmd_ldX1(a1)
	move.w	#319,bmd_ldX2(a1)

	cmp.w	d5,d1
	ble		.endnopols	; more secure

	move.w	#2,bmd_flags(a1) ; dirty rectangle

;	 move.w	 bmd_ldX1(a1),_debugv+2
;	 move.w  bmd_ldY1(a1),_debugv+6
;	 move.w	 bmd_ldX2(a1),_debugv+10
;	 move.w  bmd_ldY2(a1),_debugv+14

;///
	
	movem.l	(sp),a0/a1

;/// - - - -  cells-to-stream
; - - - - -  - - - - - -  - - - - - -


;d1.w current color->no

SetJPtr	 Macro
	move.w	#(\1-STL_BASE)-2,\2
	;move.l	 #\1,\2
		endm

;a0 -> bm
;a1 polc_ -> cell
;a2 read list of poly
;a3 stream write
;a4 tool cell
;	 move.l	 scn_polyClipNone(a0),a2
;	 move.l  scn_polyClipNoneSe(a0),a6

	move.l  scn_polyTab1(a0),a2
	move.l  scn_polyTab1Se(a0),a6

	;old lea     scn_PolyStream(a0),a3
	move.l	_mfast,a3
	move.l	sf_datFiles+dfi_Buffer(a3),a3

	
	move.l  4(sp),a1 ; this is bmd_
	move.l	bmd_bm(a1),a1 ; bm_
	move.l	bm_Planes(a1),a0	; start  const

	;.pe1-.ps1 = 210b


    bra		.lpPolyToStream
	nop
	cnop	0,16	
.ps1
.startplctostr
.lpPolyToStream
	move.l	-(a6),a1
	tst.l	a1
	beq     .linebroken

	; to cell
	move.w	polc_maxy(a1),d7
	movem.l	 polc_upLeftCell(a1),a1/a5

	move.l	plc_vertex(a1),a4 ; must !
	move.w	vtf_px(a4),d3   ;xl1 start
	move.w	vtf_py(a4),d2	;high y
	move.l	plc_vertex(a5),a4 ; must !
	move.w	vtf_px(a4),d4 	;xl2 start

;	 ext.l	 d2
;	 ext.l	 d3
;	 ext.l	 d4
;	 move.l	 d2,_debugv
;	 move.l	 d3,_debugv+4
;	 move.l	 d4,_debugv+8

;a0 bm start
;a1 polc_ -> l1
;a2 read list of poly
;a3 stream write
;a4 tool cell
;a5 tool-> l2
;a6 end pointer

;d0 tool
;d1 prev color
;d2 current y
;d3 xl1
;d4 xl2
;d5
;d6
;d7 maxy


	SetJPtr STL_Start,(a3)+

	; get start bm ..better than mulu #40:

	move.w	d2,d5
	lsl.w	#2,d5	;*4
	add.w	d2,d5	;*5
	lea		(a0,d5.w*8),a4	;*40
	;a4 start of line
	move.l	a4,(a3)+

	; let's say:
	clr.w	d0	;y still to do l1
	clr.w	d6  ;y still to do l2

	; loop that translate chained list to "stop and change"
.lpCelltoStream
	swap	d7
; -  - -
;d0 l1 still to do
;d1.w prev color
;d2 current y
;d3 xl1
;d4 xl2
;d5 tool
;d6 l2 stil to do
;d7 maxy

	tst.w	d0
	bne.b	.nochangel1
	; - - -  - - - just l1
.retryl1
	move.l	plc_prev(a1),a1
	move.l	plc_vertex(a1),a4
	move.w	vtf_py(a4),d0	; next l1

	sub.w	d2,d0 ;y length of line l1
;	 blt     .linebroken
	ble.s	.retryl1
	
	move.w  vtf_px(a4),d5

	SetJPtr STL_ChangeL1,(a3)+

	move.w	d5,d7
	sub.w   d3,d5
	ext.l	d5
	lsl.l	#8,d5
	
	move.w	d3,(a3)+
	
	divs.w	d0,d5
	ext.l	d5
	lsl.l	#8,d5
	move.l  d5,(a3)+

	;d3 ok
	move.w  d7,d3 ; new x1 after

.nochangel1

	tst.w	d6
	bne.b	.nochangel2
.retryl2
	move.l	plc_next(a5),a5
	move.l	plc_vertex(a5),a4
	move.w	vtf_py(a4),d6	; next l2

	sub.w	d2,d6 ;y length of line l2
	ble.s	.retryl2

	move.w  vtf_px(a4),d5

	SetJPtr STL_ChangeL2,(a3)+

    move.w	d5,d7
	sub.w   d4,d5
	ext.l	d5
	lsl.l	#8,d5
	
	move.w	d4,(a3)+
	
	divs.w	d6,d5
	ext.l	d5
	lsl.l	#8,d5
	move.l  d5,(a3)+

	move.w  d7,d4 ; new x1 after

.nochangel2
; - - - - -
.getNewHeight
	; - - use the shorter height
	move.w	d6,d5
	cmp.w	d0,d6
	ble.b	  .nobetterheight
		move.w	d0,d5
.nobetterheight


	SetJPtr STL_RunLines,(a3)+

	add.w	d5,d2	; get down to next
	sub.w	d5,d0
	sub.w	d5,d6
	subq   #1,d5
	;sub.w	#1,d5
    
	move.w	d5,(a3)+

; test break
;;	  cmp.w	  #96,d2
;;	  ble .lpCelltoStream
	swap	d7
	cmp.w	d7,d2
	bge.b   .linebroken

	bra     .lpCelltoStream


.linebroken

	;d7 end pointer
	cmp.l   a6,a2
	blt     .lpPolyToStream

.endplctostr
.pe1
	;terminate
	SetJPtr STL_End,(a3)+

 ; debug to compute size of stream used
; move.l maxstreamSize,d0
; move.l  a3,a1
;	 movem.l (sp),a0/a3 ;
; lea     scn_PolyStream(a0),a4
; sub.l   a4,a1
;	 cmp.l	 d0,a1
;	 blt	 .nogss
;		 move.l	 a1,maxstreamSize
;		 move.l	 a1,_debugv+8
;.nogss

	ifd	trcl
	move.w	#$0f0,$0dff180
	endc
;;;	   bsr	_EndParaClear


waitBlit	Macro
	lea CUSTOM,a6
	btst.b  #14-8,dmaconr(a6)
	beq.b   .endw\@
.wait\@
		rept	8
		nop
		endr
	btst.b  #14-8,dmaconr(a6)
	bne.s   .wait\@
.endw\@
	endm
	
	waitBlit

	; a0 scn_
	movem.l (sp),a0/a3 ; a3 is bmd_
	move.l	bmd_bm(a3),a3
;noneed	   move.l  sbm_PlaneSize(a3),a2
	move.w	bm_BytesPerRow(a3),d0

;old	lea     scn_PolyStream(a0),a1
	move.l	_mfast,a1
	move.l	sf_datFiles+dfi_Buffer(a1),a1

	ifd	trcl
	move.w	#$0ff,$0dff180
	endc


	moveq	#-1,d4	;const
	bsr     _drawTrapezeStream1P


;	 move.l  #endlength-startlength,_debugv+8

; - - -- - -  -
;///

.endnopols
	;movem.l (sp)+,a0/a1
	addq	#8,sp
	rts
;maxstreamSize:	 dc.l	 0
;/// - - -  - -raster routine 1 Plane
	;d0.w l1 px trashable
	;d1.w l2 px trashable
	;d2.l l2 y run
	;d3.w compute  /.w y counter
	
	;color constant:
	;d4
	;d5
	;d6
	;d7

	;a0 line start bp0
	;a1 write line
	;a2 planesize const
	;a3 tool scratch
	; - - to discution:
	;a4 l2add
	;a5 l1
	;a6 l1ad


	; const:
	; modulo
	; planesize

; entry:
;d2 start l2<<16
;d3.w y length

;a0 screen start line
;a4 l1dy
;a5 l2dy

;a6 l1

;a0  bm start line
;a1 stream->
;a2
;a3  temp
;a4  l1a
;a5  l2a
;a6  l1


; - - - - - - - - - - - entry
	cnop	0,16	;inst cache align
startlength
_drawTrapezeStream1P:
loopTrapezeStream
	move.w	(a1)+,d0
STL_BASE
	jmp		(pc,d0.w)
STL_Start:
	move.l	(a1)+,a0
	bra.s   loopTrapezeStream
STL_ChangeL1:
	clr.l	d1
	move.w	(a1)+,d1
	swap	d1
	move.l	d1,a6
	move.l (a1)+,a4
	bra.s   loopTrapezeStream
STL_ChangeL2:
	clr.l	d2
	move.w	(a1)+,d2
	swap	d2
	move.l (a1)+,a5
	bra.s   loopTrapezeStream
STL_RunLines:
	move.w	(a1)+,d3
	move.l	a1,-(sp) ; save this one
; - - - --
startline	; dbf back here
	swap	d3
	move.l	a6,d0	;l1
	move.l	d2,d1	;l2
	swap	d0
	swap	d1
	
	move.w	d1,d3
	sub.w	d0,d1	;d1 length px
	ble.w	  .endline ; can happen, geometry error

	lsr.w	#5,d0	;long slot
	sub.w	#1,d3 	; because last pix not drawn
	lsr.w	#5,d3	;long slot

	lea	(a0,d0.w*4),a1 ; to start .l

	sub.w	d0,d3	;nb.l-1 to touch

	move.l	a6,d0	;startx again-all cases
	clr.w	d0	;UAE bug ???
	swap	d0
	and.w   #$001f,d0

	tst.w	d3
	bne.b .complexline

	bfset	(a1){d0:d1} ; dont need and $1f->uae bug ?

	bra.b .endline
.complexline	
	; here:
	;d3 free
	;d1 nb pixels still to do on line.
	;first .l	 
	move.w	#32,d3
	sub.w	d0,d3

	bfset	(a1){d0:d3}
	addq	#4,a1
	sub.w	d3,d1
	; if some full.l need to be done
	move.w	#32,d3
	cmp.w	d3,d1
	blt.b	  .lastofline
.fullslotloop
	move.l	d4,(a1)+
	sub.w	d3,d1
	cmp.w	d3,d1
	bge.s .fullslotloop
	tst.w	d1	; +2b but less test here
	beq.b	  .endline
.lastofline
	; here d1 [0,32]
	bfset	(a1){0:d1}
.endline
; - - - - - - next line
	swap	d3
	lea		(a0,40.w),a0   ; start line write +=modulo
	add.l   a4,a6	; line1vec left
	add.l	a5,d2 	; line2vec right

	dbf.w     d3,startline
	; stream back
	move.l	(sp)+,a1

	; as long as bra.w, but one less branch !
	bra loopTrapezeStream
;	 move.l	 (a1)+,a3
;	 jmp	 (a3)
STL_End:
	rts
endlength
;///


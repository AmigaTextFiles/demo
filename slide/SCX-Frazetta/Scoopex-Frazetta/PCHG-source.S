
;		#-----+-----------------------------------------#
;		|Name:| PCHG converter source			|
;		+-----+-----------------------------------------+
;		|V1.00|	Just cleaned up from RC3 for ConvPCHG	|
;		+-----+-----------------------------------------+
;		|	    	© Photon/Scoopex		|
;		#-----------------------------------------------#

;Converter from ConvPCHG command to also do PCHG and CAMG hunks.

MaxLsize=$19000				;max copper list size (test!)
maxpic	=$28020				;352/8*536*6, real max is 384/8*576*6
copsiz	=20+128				;nullcop with palette


	SECTION ConvPCHGCF,Code

Example:
	lea R(PC),a5			;-R(A5) used to save some bytes for
					;nonexistant d16(PC) writes
	lea Pic,a0			;source ILBM data.
	bsr ConvPCHG			;fills Buff0 and copdst, see below.
	tst.l d0
	beq.s .dontshow
    *--- show Buff0 with copdst here! ---*
.dontshow:
	rts


ConvPCHG:				;a0=src ILBM data.
	lea Buff0,a1			;bitmap dest
	move.l a1,d7			;save copy
	lea copdst,a2			;cop1

	lea copsiz(a2),a2
	lea copdst2,a3
	lea copsiz(a3),a3
	moveq #$26,d1			;startline of copper(s)

	bsr CheckILBM
    *--- this... ---*
	beq.w lbmerr
	tst.w d0
	bne.s lbmok
lbmerr:
;	WRITELN "Incorrect CAMG hunk! Can't determine screenmode."
	bra.w camgerr			;throw up if lace not detectable.
lbmok:
    *--- ...won't happen ---*		;© Way2Predict.com
	btst #2,d0
	bne.s .laceok
	sub.l a3,a3			;only one cop, tell ConvILBM nonlace
.laceok:
	moveq #6,d0			;max #bpls to unpack
	clr.l PicInfo			;default: error. Will be NZ if okay.
	move.l #$01000200,MyScrMode

	lea cmapdst,a4			;palette dest.
	bsr ConvILBM
;;    ---  do this after sw to hw  ---
	movem.l d2/d3,MyScrMode
	movem.l d0/d1/a0-a3,PicInfo
	RTS
camgerr:
	moveq #0,d0
	RTS


CheckILBM:		;reads bplcon0 to d0 if present, otherwise 0=err
	MOVEM.L D1-A6,-(SP)
	clr.w .bplcon0-R(A5)
	moveq #0,d7			;default: error.
	cmp.l #"FORM",(a0)+
	bne.w .err			;not an iff file
	move.l (a0)+,d4			;end of ilbm form
	lea (a0,d4.l),a3		;stopadr of ILBM hunk
	cmp.l #"ILBM",(a0)+		;form type (not hunktype, so formlen=hunklen)
	bne.s .err			;not an ILBM pic

    *--- hunkloop:read hunk, bra to handler, until endadr ---*

.hunkl:	move.l (a0)+,d1			;hunkname:BMHD,BODY, or CMAP etc
	move.l (a0)+,d2
	MOVEM.L D0/D2/A0/A2-A4,-(SP)	;minst a3 (d2&a4 used in body)

    *--- not doing most of the hunks for the screen mode check. ---*

	cmp.l #"CAMG",d1
	beq.w .camg

.hunkc:	MOVEM.L (SP)+,D0/D2/A0/A2-A4
	beq.s .err			;if returned 0 from subparts, conv error
	add.l d2,a0			;srcptr at next hunk
	btst #0,d2			;odd hunklen? then even it out
	beq.s .even
	addq.w #1,a0
.even:	cmp.l a3,a0			;more hunks in this ILBM?
	blt.s .hunkl			;then continue
.err:	move.w .bplcon0(PC),d0		;if zero, invalid.
	tst.l d7
	MOVEM.L (SP)+,D1-A6
	RTS

    *--- just do CAMG ---*

.camg:
	moveq #0,d7
	move.l (a0)+,d7
	move.w d7,.bplcon0-R(A5) ;bplcon0 MODE bits ONLY - ignore UHRES bit 7
	moveq #1,d7
	tst.w d7
	bra.w .hunkc			;return to hunkloop
.bplcon0:
	dc.w 0


********************  ConvILBM  ********************

;IN:	a0=src filedata (points to "FORM")
;	a1=dst for interleaved bitplanedata
;	d0=max #bpls to rawconvert (scrstruct not modified though)
;	a4=palette dest addr. (32 words)
;if PCHG:
;	d1=Startline (topline of generated coppers)
;	a2=copper for EVEN frames (or default, if nonlaced.)
;	a3=copper for ODD frames if laced, otherwise 0.
;	a5=R (to save some bytes for "write to d16(PC))

;OUT:	d0=size of interleaved RAWbpls+scrstruct(16b), EQ=error
;	d1=bploffs (bpl1-bpl0)
;	d2=bplcon0 displaymode
;	d3=bwid
;(offset 10,12 in scrstruct is width and height)
;	a0=ptr to scrstruct(16b) before bpl0.
;	a1=cmap ptr (sep obj)
;if PCHG:
;	a2=end of evencop
;	a3=end of oddcop

ConvILBM:
	MOVEM.L D4-D7/A4-A6,-(SP)
	move.w d0,-(SP)
	subq.w #1,d1			;$xxdf...
	move.w d1,.startline-R(A5)
	movem.l a2-a4,.evencop-R(A5)	;,oddcop,cmapdst
	moveq #0,d7
	cmp.l a2,a3
	bgt.s .oki
	addq.w #1,d7			;evencop addr larger.
.oki:	move.w d7,.evenlarge-R(A5)
	clr.w .bplcon0-R(A5)

    *--- find ILBM length, set endcmpadr ---*

	move.w d0,.reqbpls	;save for use in .body.0=no bpls, just hdr&cmap
	moveq #0,d0		;errcode, pre-set to error if errexit
	not.w .mask-R(A5)	;set mask&compr to "illegal". BMHD fixes it
				;causes error if no bmhd before body.
	move.l a1,a4		;save DSscr-struct-ptr

	cmp.l #"FORM",(a0)+
	bne.w .err		;not an iff file
	move.l (a0)+,d4		;end of ilbm form
	lea (a0,d4.l),a3	;stopadr of ILBM hunk
	cmp.l #"ILBM",(a0)+	;form type (not hunktype, so formlen=hunklen)
	bne.s .err		;not an ILBM pic

    *--- hunkloop:read hunk, bra to handler, until endadr ---*

.hunkl:	move.l (a0)+,d1		;hunkname:BMHD,BODY, or CMAP
	move.l (a0)+,d2
	MOVEM.L D0/D2/A0/A2-A4,-(SP)	;minst a3 (d2&a4 used in body)

	cmp.l #"BMHD",d1	;a0=hunkstart,a2=hunkstop
	beq.s .bmhd		;they all return to .hunkc
	cmp.l #"BODY",d1	;a4=dst
	beq.w .body
	cmp.l #"CAMG",d1
	beq.w .camg
	cmp.l #"PCHG",d1
	beq.w .pchg
	cmp.l #"CMAP",d1
	beq.w .cmap		;otherwise just ignore hunk & cont

.hunkc:	MOVEM.L (SP)+,D0/D2/A0/A2-A4
	beq.s .err		;if returned 0 from subparts, conv error
	add.l d2,a0		;srcptr at next hunk
	btst #0,d2		;odd hunklen? then even it out
	beq.s .even
	addq.w #1,a0
.even:	cmp.l a3,a0		;more hunks in this ILBM?
	blt.s .hunkl		;then continue

    *--- fixup retdata ---*

	moveq #0,d1
	move.w .bwid(PC),d1	;d1=bploffs (wid/16)
	move.l a4,a0		;restore dstptr (start of scrstruct)

	move.l #$01000000,d2
	move.w 8(a0),d2		;d2=correct dispmode for bplcon0
	or.w .bplcon0(PC),d2
	move.w d2,8(a0)
	
	move.l a1,d0		;end of raw body
	sub.l a0,d0		;size of (bpldata+scrstruct) (0=err)
	move.l .cmapdst(PC),a1

	movem.l .evencop(PC),a2-a3	;stop addr of coppers.
.err:
	move.w .bwid(PC),d3		;d3=bwid
	mulu (SP)+,d3
	tst.l d0
	MOVEM.L (SP)+,D4-D7/A4-A6
	RTS

    *--- BMHD ---*

.bmhd:				;interpret bmhd.a0=hunkstart in ilbmfile
	lea 16(a1),a3
	move.l a3,(a1)+			;bpl0 ptr
	clr.l (a1)+			;x,y=0,0 (dispstart $2681)
	clr.w (a1)+			;dispmode=0(temp)
	moveq #0,d7			;errflag

	moveq #15,d1			;add 15 to round upward
	add.w (a0)+,d1			;wid
	and.w #-16,d1			;guaranteed even16 width
	move.w d1,(a1)+			;->wid.w
	lsr.w #3,d1			;/8=#bytes/bplline
	move.w d1,.bwid-R(A5)		;->bwid (of picture, not usual bwid)

	move.w (a0)+,(a1)+		;->hgt.w

	addq.w #4,a0			;skip something+dpt (set to reqbpls)

	moveq #0,d1
	move.b (a0)+,d1
	move.w d1,(a1)+			;->dpt.w
	lsl.b #4,d1
	addq.b #2,d1			;dflt:"straight" dispmode=$x200
	move.b d1,-8(a1)		;set hibyte of dispmode(lobyte preclrd)

	move.b (a0)+,d1			;masking
	move.b d1,.mask-R(A5)		;->mask.b
	cmp.b #1,d1			;0 & 1 are known
	bhi.s .berr			;unknown masking type!

	move.b (a0)+,d1			;compr
	move.b d1,.compr-R(A5)		;->compr.b
	cmp.b #1,d1			;compr:0=raw, 1=PackByte
	bhi.w .berr			;unknown compression type!

	moveq #1,d7			;ok, a1 now pts to start of bpl0
.berr:	tst.w d7
	bra.w .hunkc			;return to hunkloop

    *--- BODY ---*

.body:					;a1=ptr to bpl0(scrstruct,12b before)
	tst.w .reqbpls-R(A5)		;if 0 bpl req'd, then dont depack!
	beq.w .bok			;but report ok (=extract cmap)

	moveq #0,d7			;errflag

	move.l -4(a1),d3		;hgt.w<<16+dpt.w

	move.b .mask(PC),d1		;neg=error (set by bmhd)
	bmi.w .bdErr
	add.b d1,d3			;add #maskbpls (0 or 1, really) to bpls

	move.w .bwid(PC),d2

	move.w .reqbpls(PC),d6
	sub.w d3,d6			;D6=skipcode:0=same,+=skipdst,-=skipsrc
	bgt.s .hiest
	move.w .reqbpls(PC),d3		;set d3 (loopctr) to the loest of the 2
.hiest:
	subq.w #1,d3			;bpls-1
	move.w d3,a3			;a3=least common #bpls-1 (save)
	swap d3				;hgt
	subq.w #1,d3			;d3=hgt-1

	move.b .compr-R(A5),d1
	bne.w .packb			;1=packbyte algorithm

	move.w .bwid(PC),d2

    *--- RAW ---*

	move.w d2,d1			;for bpladd later
	lsr.w #1,d1			;#words/scanline
	subq.w #1,d1			;for dbra
	move.w d1,a4			;save

.Line:	move.w a3,d4			;bpls-1
.Bpl:	move.w a4,d1
.Word:	move.w (a0)+,(a1)+
	dbra d1,.Word
	dbra d4,.Bpl

	move.w d6,d4			;skip any bpls?
	beq.s .nos1
	bpl.s .sd1			;+=skipdst

.ss1:	not.w d4			;=neg, then subq.w!
.ssl1:	add.w d2,a0			;skip src bpls
	dbra d4,.ssl1
	bra.s .nos1

.sd1:	subq.w #1,d4
.sdl1:	add.w d2,a1			;skip dst bpls
	dbra d4,.sdl1

.nos1:	dbra d3,.Line
	bra.s .bok			;done,exit

    *--- Compressed? ---*

.packb:					;d3=hgt-1,d2=#bytes/bplline
	move.w d2,a4			;save
.CLine:	move.w a3,d4			;least common #bpls -1
.CBpl:	move.w a4,d2

.Byte:	moveq #0,d0
	move.b (a0)+,d0			;#copybytes-1
	bmi.s .NoCpy
	sub.w d0,d2
.CLp1:	move.b (a0)+,(a1)+
	dbra d0,.CLp1
	subq.w #1,d2
	bgt.s .Byte			;repeat until bpl done
	bpl.s .BplD			;bpl done! 
	bra.s .bdErr			;(minus SHOULD gen error!)

.NoCpy:	cmp.b #-128,d0			;-128=NOP (weird!)
	beq.s .Byte
	neg.b d0			;#fillbytes-1
	sub.w d0,d2
.Rep:	move.b (a0)+,d1
.CLp2:	move.b d1,(a1)+
	dbra d0,.CLp2
	subq.w #1,d2
	bgt.s .Byte			;repeat until bpl done
	bmi.s .bdErr
.BplD:	dbra d4,.CBpl

    *--- skip ---*

	move.w d6,d4			;skip any bpls?
	beq.s .nos2
	bmi.s .ss2			;-=skipsrc

.sd2:	subq.w #1,d4
.sdl2:	add.w a4,a1			;skip dst bpls
	dbra d4,.sdl2
	bra.s .nos2

.ss2:	not.w d4			;=neg, then subq.w!
.ssl2:	move.w a4,d2

.Byte2:	moveq #0,d0
	move.b (a0)+,d0
	bmi.s .NoCpy2
	addq.w #1,d0
	add.w d0,a0
	sub.w d0,d2
	bgt.s .Byte2			;repeat until bpl done
	bpl.s .ssd2
	bra.s .bdErr
.NoCpy2:cmp.b #-128,d0			;-128=NOP (weird!)
	beq.s .Byte2
	neg.b d0
	sub.w d0,d2
	tst.b (a0)+			;poll fill-byte (not used)
	subq.w #1,d2
	bgt.s .Byte2			;repeat until bpl done
	bmi.s .bdErr
.ssd2:	dbra d4,.ssl2

.nos2:	dbra d3,.CLine

.bok:	moveq #1,d7			;noerror

.bdErr:	tst.w d7
	bra.w .hunkc			;return to hunkloop

    *--- CMAP ---*

.cmap:
	moveq #0,d7			;errflag, dflt err
	move.l .cmapdst(PC),a3		;dst for colormap

	move.l d2,d6
	divu #3,d6			;d2=hunklen (#cols*3)
	cmp.w #32,d6			;more than 32 palette colors?
	blt.s .ok1
	moveq #32,d6			;then only use 32!
.ok1:
	subq.w #1,d6			;for dbra

.cl:	move.b (a0)+,d1
	lsr.b #4,d1			;r
	move.b d1,(a3)+			;>$0x
	move.b (a0)+,d1
	and.b #$f0,d1
	move.b (a0)+,d3
	lsr.b #4,d3
	or.b d3,d1
	move.b d1,(a3)+
	dbra d6,.cl

	moveq #1,d7
.cerr:	tst.w d7
	bra.w .hunkc			;return to hunkloop

    *--- CAMG ---*

.camg:
	move.l (a0)+,d7			;bplcon0 bits
	and.w #-1-$7280,d7		;less colorburst and USEx and UHRES...
	move.w d7,.bplcon0-R(A5)	;store for OR at end of convILBM.
	moveq #1,d7
	bra.w .hunkc			;return to hunkloop

    *--- PCHG ---*

.pchg:
	move.l a0,a4
	add.l d2,a4			;for endcmp

    *--- header ---*

	move.l a4,-(SP)
	move.l .evencop(PC),a3
	move.w 4(a0),d6
	move.l .oddcop(PC),a4		;if dual cop, halve startline offset.
	move.l a4,d5
	beq.s .nohlf
	asr.w #1,d6
.nohlf:	add.w .startline(PC),d6		;startline of cop pic ($2c typ)

	move.w 6(a0),d5			;#bits in bitmask
	lea 20(a0),a0

    *--- bitmask ---*

	move.w d5,d4			;save away for last round.
	subq.w #1,d4
	and.w #31,d4			;even 32=31 as lastctr, else count-1

	add.w #31,d5
	lsr.w #5,d5			;+31/32=#longwords

	move.w d5,d0
	add.w d0,d0
	add.w d0,d0			;x4 longs
	lea (a0,d0.w),a2

	subq.w #1,d5			;loopctr
.longl:	move.l (a0)+,d0			;bitmask
	moveq #31,d3
	tst.w d5
	bne.s .bitl			;not last longword.
	move.w d4,d3

.bitl:	add.l d0,d0			;test bit in bitmask
	bcc.s .nochg

    *--- wait ---*

	move.b d6,(a3)+			;WAIT
	move.b #$df,(a3)+
	move.w #$fffe,(a3)+

    *--- palette-changes ---*

	moveq #0,d1
	move.b (a2)+,d1
	swap d1
	move.b (a2)+,d1
	swap d1
	subq.w #1,d1
	bmi.s .skip16

.ch16l:	move.w (a2)+,d2
	move.w d2,d7
	rol.w #4,d7
	and.w #$f,d7
	and.w #$fff,d2			;d3=reg0-15,d2=rgbcolor.
	add.w d7,d7
	add.w #$180,d7
	move.w d7,(a3)+
	move.w d2,(a3)+
	dbf d1,.ch16l
.skip16:
	swap d1
	subq.w #1,d1
	bmi.s .skip32

.ch32l:	move.w (a2)+,d2
	move.w d2,d7
	rol.w #4,d7
	and.w #$f,d7
	and.w #$fff,d2			;d3=reg16-31,d2=rgbcolor.
	add.w d7,d7
	add.w #$1a0,d7
	move.w d7,(a3)+
	move.w d2,(a3)+
	dbf d1,.ch32l
.skip32:

    *--- continue ---*

	addq.b #1,d6			;default: nonlaced, always inc.
	bra.s .nolf			;wait present line $ff already, skip.

.nochg:	addq.b #1,d6			;default: nonlaced, always inc.
	bne.s .nolf			;did we just wrap 255->0?
	move.l #$ffdffffe,(a3)+		;extra WAIT before the real one coming...
.nolf:			;this gets hit twice if lace, so a3,a4 updated ok
	move.l .oddcop(PC),d7		;two coppers? then only add after odd
	beq.s .noswp2
	btst #0,d3			;was this the odd frame just now?
	beq.s .oddok			;odd, then the add was ok
	subq.b #1,d6			;otherwise keep this line# for another
.oddok:	exg a3,a4
.noswp2:

	dbf d3,.bitl
	dbf d5,.longl
	
	move.l #-2,(a3)+		;end copper list.
	move.l .oddcop(PC),d7		;two coppers? then end copper 2 too.
	beq.s .no2
	move.l #-2,(a4)+		;end copper list.
.no2:
	moveq #0,d7
	cmp.l a3,a4
	bgt.s .oki2
	addq.w #1,d7			;evencop addr larger.
.oki2:	move.w .evenlarge-R(A5),d0
	eor.w d0,d7			;0 if same a3-a4 order as at start.
	beq.s .noexg
	exg a3,a4
.noexg:	movem.l a3-a4,.evencop-R(A5)	;for loading into a2,a3 on exit.

	move.l a2,a0			;all palettechanges parsed.

	move.l (SP)+,a4
	moveq #0,d7			;default: error.
	cmp.l a0,a4
	bne.s .pcerr			;if didn't match up, an error occurred.
	moveq #1,d7
.pcerr:	tst.w d7
	bra.w .hunkc			;return to hunkloop

    *--- local data ---*

.mask:	dc.b 0			;mask: 0 or 1, otherwise err
.compr:	dc.b 0			;compr: 0=raw,1=PACKBYTE, otherwise err
.bwid:	dc.w 0			;bytes per bplline
.reqbpls:	dc.w 0		;requested # bpls
.evencop:	dc.l 0		;only if PCHG
.oddcop:	dc.l 0		;only if PCHG+lace, nonlace=0.
.cmapdst:	dc.l 0		;dest addr for 32 words palette
.evenlarge:	dc.w 0		;addr supplied in a2 is larger.
.startline:	dc.w 0		;topline of copper(s)
.bplcon0:	dc.w 0		;special bplcon0 mode-bits set in CAMG hunk.

R:


	SECTION ConvPCHGBF,BSS

cmapdst:	ds.w 32
PicInfo:	ds.w 12
MyScrMode:	ds.w 4


	SECTION ConvPCHGBC,BSS_C

Buff0:	ds.b maxpic			;pic size, upto 384x568 EHB
copdst2:ds.b 128			;nullcop until dual cop supported
copdst:	ds.b MaxLsize

	SECTION ConvPCHGFD,DATA

Pic:	INCBIN "pics/egyptqueen.lbm"	;the nice picture <3

	END



    opt c+   ;?
    opt    ALINK

    include exec/execbase.i
    include exec/exec_lib.i
    include exec/memory.i
    
    include graphics/graphics_lib.i
    include graphics/gfxbase.i
    include hardware/custom.i
	; for VPrintf...
	include dos/dos_lib.i

    
    include demodata.i

	; implemented in fx.. files
	STRUCTURE	sPart,0
		APTR	spr_init
		APTR	spr_frame	; can draw on many frames 
		APTR	spr_end
		APTR	spr_vblank	; must be done quickly at top of frame
	LABEL		spr_SIZEOF

	; used for scripting demo at end of this file.
	STRUCTURE	sScript,0
		APTR	scr_part
		LONG	scr_endtime
		LONG	scr_deltatime
		LONG	scr_xxx
	LABEL		scr_SIZEOF ; 16b
; - - flags for script engine
SCF_StopVBlc=1
SCF_SetBlack=2

    
	XREF	_irqcode
	XREF	_time
    XREF    _exitErrNo    
    XREF    _GfxBase
    XREF    _DosBase
    XREF	_wbView
    XREF	_shunt
    XREF    _debugv

	XREF    __XCEXIT

	XREF    initKeyboard
	XREF    closeKeyboard

    XREF    Playrtn
    XREF    P61_Init
    XREF	P61_Music
    XREF    P61_End

    XREF    _cc_InitLowResAGADbl
    XREF    _cc_setBmAGA
    XREF	_cc_setLineScrolls
	XREF	_cc_switchCopper

    XREF    _initBm
	XREF	_SetCopperPaletteAga


    XREF    _dat_initWithHeader
    XREF    _dat_loadFile
    XREF    _dat_close

	XREF    setColSc

	XREF    _doEnd

	XREF	_InAlloc
	XREF	_InFree

	; - - -from C
    XREF    @GifBinToSBm
	XREF    @GifBinToChip
	XREF    @GifBinToChunky

    XREF    _CopyBm

	XREF	_initMoves

    section code,code


	XDEF	_mfast
    XDEF	_mchip1
    XDEF	_mchip2
    XDEF	_mchip3
    XDEF    _dmain
	XDEF    _demoEnd

_dmain:

    ; - - - alloc fast & chip
    move.l    4.w,a6
    move.l    #smFast_SIZEOF,d0
    move.l    #MEMF_CLEAR,d1

    CALL    AllocMem
    move.l    d0,_mfast
    tst.l   d0 ;  mandatory for emulation
    bne        .fastok
        move.w    #ERR_NOMEM,_exitErrNo
        bra    errnofast
.fastok

	moveq	#2,d7	; 3chip alloc
	lea		_mchipsize(pc),a5
	lea		_mchip1(pc),a4
.chipmemloop
    move.l	(a5)+,d0
    move.l    #MEMF_CLEAR|MEMF_CHIP,d1
    CALL    AllocMem
    move.l	d0,(a4)+
    tst.l   d0    
    bne        .chipok
        move.w    #ERR_NOMEM,_exitErrNo        
		bra    errnochip
.chipok
	dbf		d7,.chipmemloop

	; - - - init the internal memory management

	move.l	_mfast(pc),a1
	lea		sf_MemCells(a1),a2
	; - - fast chunk 1
	lea		sf_FastStart(a1),a3
	move.l	a3,inm_retroptr(a2)
	move.l	a2,(a3)

	lea		sf_temp(a1),a3
	move.l	a3,inm_ptr(a2)
	move.l	#FASTTEMPSIZE,inm_size(a2)
	moveq	#1,d0	; 1 means available
	move.w	d0,inm_state(a2)

	; - - -  -
	lea		sf_Chip1Start(a1),a3
	lea		inm_SIZEOF(a2),a2
	move.l	a3,inm_retroptr(a2)
	move.l	a2,(a3)
	move.l	_mchip1(pc),inm_ptr(a2)
	move.l	#smChip1_SIZEOF,inm_size(a2)
	move.w	d0,inm_state(a2)

	; - - -  -
	lea		sf_Chip2Start(a1),a3
	lea		inm_SIZEOF(a2),a2
	move.l	a3,inm_retroptr(a2)
	move.l	a2,(a3)
	move.l	_mchip2(pc),inm_ptr(a2)
	move.l	#smChip2_SIZEOF,inm_size(a2)
	move.w	d0,inm_state(a2)	
	; - - -  - - - - - - - - -
   
	; - - - load .dat file header and check errors
	lea        sf_datFiles(a1),a5
    bsr        _dat_initWithHeader   
    tst.l    d0
	bne        errNoDat

	bsr	_initMoves

	; - - -shunt intuition & create irq here...
	; finish on 2 waitTof
	bsr		_shunt

	; - - -  init of start effect
	move.l	_script(pc),a0
	move.l	spr_init(a0),a0
	jsr	(a0)
	move.l	_script(pc),a0
	move.l  spr_vblank(a0),_fxVBlankCode ; only after init.

	; -  - - - - - - - -
	; p61 
   ; launch intro music

	ifd	   DOMUSIC
	lea modboot,a0
    sub.l a1,a1
    sub.l a2,a2
    moveq #0,d0
    ;lea p61coppoke+3,a4        ;only used in P61mode >=3
    jsr P61_Init
;no	jsr P61_Music
	endc

     ; - - -trigger irq-only effect ?
	lea    vblankCode,a6
    move.l    a6,_irqcode
; - - - - - - - - - - - - - - - loop per fx
	;start later clr.l	 _time
.fxloop

	; note previous vblank *may* run here during init

	move.w	_scriptCurrent(pc),d0
	lsl.w	#4,d0
	lea		_script(pc),a0
	lea		(a0,d0.w),a0
	move.l	a0,_currentfx	
	move.l	scr_part(a0),a1
	move.l	spr_init(a1),a1
	tst.l	a1
	beq	.noinit
		jsr (a1)    ; does effect init, can have to load, take some frames
.noinit
	; reset main demo time after init of effect2
	cmp.w	#1,_scriptCurrent
	bne	.noreset
		clr.l	 _time
.noreset
	
	;- - - change vblank after init
	move.l	_currentfx(pc),a0
	move.l	scr_part(a0),a0
	move.l  spr_vblank(a0),_fxVBlankCode

	clr.l	_fxTime

; - - - frame loop
; - - note: should at least implement a WaitTof
; - -  so we are not testing cpu effect ptr for null
.w1:

	move.l	_fxFrame,_cpuStartFrame

	; this is the main drawing loop for an effect
	move.l	_currentfx(pc),a0
	move.l	scr_endtime(a0),d1
	cmp.l	_time,d1
	ble	.nextfx

	move.l	scr_part(a0),a0
	move.l	spr_frame(a0),a0
	jsr (a0)

    tst.b    _doEnd
    beq    .w1
.nextfx
	; - - assume we can close previous fx ressources
	move.w	_scriptCurrent(pc),d0
	sub.w	#1,d0	; close resource of effect before !
	lsl.w	#4,d0
	lea		_script(pc),a0
	lea		(a0,d0.w),a0
	move.l	scr_part(a0),a1
	move.l	spr_end(a1),a1
	tst.l	a1
	beq	.nofxclose
		jsr (a1)    ; does effect init, can have to load, take some frames
.nofxclose
 
	; - - - - check if next effect
	add.w	#1,_scriptCurrent
	move.w	_scriptCurrent,d0
	move.w	_scriptSize,d1

	cmp.w	d0,d1
	beq.b  .scriptend

    tst.b    _doEnd
    beq    .fxloop

.scriptend

; - - - - - - - - -- 
.endloop
_demoEnd:
	; do not execute vblank code, effective later
	; should not be usefull because end tested in that code
	clr.l   _irqcode

	ifd	   DOMUSIC
		jsr P61_End
	endc

	; set intui screen back before closing vmem:
	bsr	_wbView


    ; close files
    move.l    _mfast(pc),a1
    lea    sf_datFiles(a1),a5
    bsr    _dat_close
  
; - - - - demo end
  
; it does 2 waitof, should finish vblank code
errNoDat:
    ;free chip
errnochip
	; chip chunks can each have alloked or not
	; free in reverse order, may be better
    move.l    4.w,a6   
	moveq	#2,d7	; 3chip alloc
	lea		_mchipsize+4*3(pc),a5
	lea		_mchip1+4*3(pc),a4
.closechiploop
	move.l	-(a5),d0
	move.l	-(a4),a1
	tst.l	a1
	beq	.noclosechip
	CALL	FreeMem			
.noclosechip
	dbf		d7,.closechiploop

    ;free fast
    move.l    _mfast(pc),a1
    move.l    #smFast_SIZEOF,d0
    CALL    FreeMem
errnofast:
    rts        ; end _dmain


; - - - - - - - - -
	XREF	_ntsc
vblankCode:
	tst.b	_ntsc
	beq	.pal
		addq.l	#5,_fxTime ;ntsc 300=1sec
		addq.l	#5,_fxTime2
	bra	.nopal
.pal
		addq.l	#6,_fxTime	  ; pal 300=1sec
		addq.l	#6,_fxTime2
.nopal
	addq.l	#1,_fxFrame

	move.w	#1,_vblankStamp ; means launched since then
	; get mouse click whatever happens...
	btst.b	#6,$bfe001
	bne		.nop
		move.b #1,_doEnd
		; unlink this function
		clr.l    _irqcode
		rts	; don't run following...
.nop
	;- does device thing for keyboard ? need irq ? -


	; - - - - throw effect per frame code
	move.l	_fxVBlankCode(pc),a0
	tst.l	a0
	beq.b	.nof
		jsr	(a0)
.nof
    rts    
; - - - - - - -
	XDEF	_fxTime
	XDEF	_fxTime2
	XDEF    _fxFrame
	XDEF    _cpuStartFrame
_mfast:    dc.l    0
_mchip1    dc.l   	0
_mchip2:	dc.l	0
_mchip3:	dc.l	0
;_fxTimerStart	 dc.l	 0
_fxTime:		dc.l	0
_fxTime2:		dc.l	0	; since real start
_fxFrame:		dc.l	0	; real vbl
_cpuStartFrame:	dc.l	0
_fxVBlankCode:	dc.l	0
_vblankStamp	dc.w	0
_currentfx:		dc.l	0
_mchipsize:		dc.l	smChip1_SIZEOF,smChip2_SIZEOF,smChip3_SIZEOF
; - - - - - -  - - 
; - - -  fx table
	XREF	fx_Start
	XREF	fx_Load
	XREF	fx_LoadGo
	XREF	fx_Dual3D
	XREF    fx_3DExt1
	XREF    fx_3DExt2
	XREF    fx_3DExt3
	XREF    fx_RNoise
	XREF	fx_Title
	XREF    fx_DualLisa
_scriptCurrent:	dc.w	1 ; first is boot fx


; trick to compute start date of effects
TIMEACC     SET     0
DOTIME	    MACRO		; function pointer (32 bits - all bits valid)
TIMEACC		SET		TIMEACC+(\1)
THISTIME	SET		TIMEACC
			ENDM
; F03 ->1152 3.84 sec

;MODPATSIZE	 equ  3*64*6

_scriptSize:	
			;phxass wont do that
			;dc.w	 ((_scriptEnd-_script)/scr_SIZEOF)
			dc.w 	10
_script:	
			dc.l	fx_Start,0,0,0	;vblank only

			DOTIME	300*8-150 ;300*8
			dc.l	fx_Load,THISTIME,0,0

			DOTIME  300*6-200
			dc.l    fx_LoadGo,THISTIME,0,0

			DOTIME  13*300-200
			dc.l    fx_Dual3D,THISTIME,0,0

			DOTIME  16*300-100
			dc.l    fx_Title,THISTIME,0,0

			DOTIME  16*300
			dc.l    fx_3DExt1,THISTIME,0,0

			DOTIME  25*300
			dc.l    fx_RNoise,THISTIME,0,0

			DOTIME  16*300
			dc.l    fx_3DExt2,THISTIME,0,0
			
			DOTIME  41*300-150
			dc.l    fx_DualLisa,THISTIME,0,0

			DOTIME  2000*300
			dc.l    fx_3DExt3,THISTIME,0,0
_scriptEnd:

; - - - - - -
	XDEF    _readBin
_readBin:
	movem.l	 d6/d7/a6,-(sp)
	;d0 file index
	; - - load file

	move.l	_mfast(pc),a6
	lea		sf_datFiles(a6),a5
	bsr    _dat_loadFile
	; here: d0 is file byte read, a5 dfi_

	move.l	d0,d7
	clr.l	d1	; fast
	bsr		_InAlloc
	tst.l	a0
	beq		.end

	move.l	a0,a1
	move.l	dfi_Buffer(a5),a2
	;just copy
	move.l	d7,d6
	lsr.l	#4,d6
	sub.l	#1,d6
	blt.b	  .nol1
.lpc1
	movem.l	(a2)+,d0/d1/d2/d3
	movem.l	d0/d1/d2/d3,(a1)
	lea		16(a1),a1
	subq	#1,d6
	bge.s	.lpc1

.nol1
	and.w	#$000f,d7
	sub.w	#1,d7
	blt		.end
.lp2
	move.b	(a2)+,(a1)+
	dbf		d7,.lp2
.end
	movem.l	 (sp)+,d6/d7/a6
	rts
; - -  -stub to C GifToBm Routine
	ifd erzerzerzer
	XDEF    _readGifToChip
_readGifToChip:
	; a0 chip to fill
	; d0.w dat file index

	move.l	a0,a2
	move.l	d0,d7
	; alloc gifparams struct
	move.l	#gfp_SIZEOF,d0
	clr.l	d1 ;fast
	bsr	_InAlloc
	tst.l	d0
	sub.l	a0,a0
	beq		.end

	; - - - keep allocs
	move.l	d0,-(sp)
	move.l	d0,a0

	; - - - prepare params
	clr.l	gfp_pSBmMask(a0)
	clr.l	gfp_Flags(a0)
	move.l	a2,gfp_pSBitmap(a0)
	clr.l	gfp_ppPalette(a0)

	; - - load file
	move.l	d7,d0
	move.l	_mfast(pc),a6
	lea		sf_datFiles(a6),a5
	bsr    _dat_loadFile
	; here: d0 is file byte read, a5 dfi_

	move.l	(sp),a0 ; gfp_

	move.l	dfi_Buffer(a5),gfp_GifBin(a0)
	move.l	d0,gfp_FileSize(a0)

	; - - easy C jump - -
	; gfp already in a0 and in stack
	jsr    @GifBinToChip

	move.l	(sp)+,a0
	move.l	gfp_pSBitmap(a0),a1
	move.l  gfp_FileSize(a0),d0
	move.l	a1,a2
	add.l	#smChip3_SIZEOF,a2 ; size of uncopmpressed p61
	clr.l	d0
.lpdt
	add.b	(a1),d0
	move.b	d0,(a1)+
	cmp.l	a1,a2
	bne	.lpdt

	; - - - free gifparams struct
	;a0 ok
	bsr	_InFree
.end
	rts	   
	endc ; disabled
; - -  - - -
	XDEF	_readGifToChunky
_readGifToChunky
	;d0.w dat file index
	;a3.l receive palette or null
	move.w	d0,d2

	; alloc gifparams struct
	move.l	#gfp_SIZEOF,d0
	clr.l	d1 ;fast
	bsr	_InAlloc
	tst.l	d0
	beq		.end

	; - - - keep allocs
	move.l	d0,-(sp)
	move.l	d0,a0
	; take params back
	move.l	d2,d0

	; - - - prepare params
	clr.l	gfp_pSBmMask(a0) ; no mask
	clr.l	gfp_Flags(a0)
	clr.l	gfp_pSBitmap(a0)
	move.l  a3,gfp_ppPalette(a0)


	; - - load file
	move.l	_mfast(pc),a6
	lea		sf_datFiles(a6),a5
	bsr    _dat_loadFile
	; here: d0 is file byte read, a5 dfi_

	move.l	(sp),a0 ; gfp_

	move.l	dfi_Buffer(a5),gfp_GifBin(a0)
	move.l	d0,gfp_FileSize(a0)

	; - - easy C jump - -
	; gfp already in a0 and in stack
	jsr    @GifBinToChunky

	; - - - free gifparams struct
	move.l	(sp)+,a0

	move.l  gfp_pSBitmap(a0),a2	; keep
	bsr	_InFree
	; return chunky width.w,height.w,bm
	move.l	a2,a0

.end
	rts
; - - - -  -
	XDEF	_readGifToBm
_readGifToBm:    
    ;d0.w dat file index
	;a3 pointer to ptr to receive palette to free 256*3
	; d1.w bm flags

	move.l	d0,d2	; save params
	move.l	d1,d3

	move.l	#sbm_SIZEOF+bob_SIZEOF,d0
	clr.l	d1 ;fast
	bsr	_InAlloc
	tst.l	d0
	beq		.end
	move.l	d0,a2
	
	; alloc gifparams struct
	move.l	#gfp_SIZEOF,d0
	clr.l	d1 ;fast
	bsr	_InAlloc
	tst.l	d0
	bne		.ok1
		move.l	a2,a0
		bsr	_InFree
		bra	.end
.ok1


	; - - - keep allocs
	move.l	d0,-(sp)
	move.l	d0,a0
	; take params back
	move.l	d2,d0
	move.l	d3,d1

	; - - - prepare params
	clr.l	gfp_pSBmMask(a0) ; no mask
	move.l	d1,gfp_Flags(a0)
	move.l	a2,gfp_pSBitmap(a0)
	move.l  a3,gfp_ppPalette(a0)

	; - - load file
	move.l	_mfast(pc),a6
	lea		sf_datFiles(a6),a5
	bsr    _dat_loadFile
	; here: d0 is file byte read, a5 dfi_

	move.l	(sp),a0 ; gfp_

	move.l	dfi_Buffer(a5),gfp_GifBin(a0)
	move.l	d0,gfp_FileSize(a0)

	; - - easy C jump - -
	; gfp already in a0 and in stack
	jsr    @GifBinToSBm
	
	; - - - free gifparams struct
	move.l	(sp)+,a0

	move.l  gfp_pSBitmap(a0),a2	; keep
	bsr	_InFree
	; return bitmap
	move.l	a2,a0
	; init bob struct
	move.l	a0,sbm_SIZEOF+bob_bm(a0)
	clr.l  sbm_SIZEOF+bob_mask(a0) ; TODO mask if flag

	move.w    bm_BytesPerRow(a0),d0
	move.w    d0,sbm_SIZEOF+bob_bytesPerRowPlane(a0)
	lsl.w    #3,d0
	move.w    d0,sbm_SIZEOF+bob_pixelWidth(a0) ; better done on gif size

    ;  - -  struct passed to C
;	 lea        sf_gifparams(a6),a4
;	 move.l    a2,gfp_pSBmMask(a4)
;	 lea        (a6,sf_temp.l),a2
;	 move.l    a2,gfp_MemTemp(a4)
;	 move.w    d2,gfp_Flags(a4)
;	 move.l    a1,gfp_AvailableChipPtr(a4)
;	 move.l    a0,gfp_pSBitmap(a4)
;	 move.l    a3,gfp_pPalette(a4)

.end
	tst.b    _doEnd
	beq.b	.nodemoexit
		bsr _demoEnd
		jmp     __XCEXIT
.nodemoexit
	rts
	
	section    copro,data_c
modboot:
	incbin	"res/P61.boot"

     

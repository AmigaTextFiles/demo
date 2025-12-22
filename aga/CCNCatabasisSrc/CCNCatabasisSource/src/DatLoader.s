; - - - use DOS to load files - - - -

    opt c+
    opt	ALINK

	include exec/execbase.i
	include exec/exec_lib.i
	include exec/memory.i

	include	dos/dos_lib.i
	include dos/dos.i
	include dos/dostags.i

	include graphics/graphics_lib.i
	
	include demodata.i
	
	include hardware/custom.i

	XREF	_debugv
	XREF	_DosBase
	XREF	_GfxBase
	XREF	_exitErrNo	

	XREF    setColSc


	XREF	__XCEXIT
	XREF    _demoEnd


	section	code,code
	
	;a5 DatFileInfo
	;return d0 : 0->FAIL
	XDEF	_dat_initWithHeader
_dat_initWithHeader:

; read word at offset 18 gives table length	
;	file = Open( name, accessMode )
;	D0	     D1    D2

	move.l	_DosBase,a6
	move.l	#datName,d1
	move.l	#MODE_OLDFILE,d2
	CALL	Open
	;d0 handler
	move.l	d0,dfi_Handler(a5)
	tst.l	d0
	bne.b	.fileOk
		clr.w dfi_nbFiles(a5)
		move.w	#ERR_NODAT,_exitErrNo
		bra	errinit
.fileOk
	move.l	d0,d7

;   SYNOPSIS
;	oldPosition = Seek( file, position, mode )
;	D0		    		D1	  D2	    D3

	; - - - jump jump linker header & rts in .dat
	move.l	_DosBase,a6
	move.l	d7,d1
	move.l	#34,d2 ; 34 is offset in file
	moveq.l	#0,d3  ;mode: -1 back to begin, 0 add from current
	CALL	Seek

	;move.l	_DosBase,a6
	move.l	d7,d1 ; d1 file
	lea	dfi_nbFiles(a5),a0
	move.l	a0,d2 ; d2 buffer
	moveq.l	#2,d3 ; d3 length to read
	CALL	Read

;    Read( hdl, buffer, size );
;   SYNOPSIS
;	actualLength = Read( file, buffer, length )
;	D0		     		D1    D2	   D3
	
	; - - - - read header table

	move.w	dfi_nbFiles(a5),d3
	move.w	d3,d4
	mulu.w	#10,d3 ; *10
	move.l	d3,dfi_tableL(a5)
	move.l	d3,d0
	move.l	4.w,a6
	clr.l	d1	; ask fast if possible
	CALL	AllocMem
	move.l	d0,dfi_table(a5)
	tst.l	d0
	beq	errinit
	
	move.l	_DosBase,a6
	move.l	d0,d2 ; d2 buffer
	;d3 already length to read
	move.l	d7,d1	
	CALL	Read	

	; - - - Get the Max file Size reader
	move.l  dfi_table(a5),a4

	moveq	#0,d0
	subq	#1,d4
.lp
	move.l	6(a4),d1
	cmp.l	d1,d0
	bgt.b	.nobigger
		move.l	d1,d0
.nobigger
		lea	10(a4),a4
	dbf	d4,.lp
	; this is madness ! do not alloc temps size as file max size !
	; the only big file is the music directly load with no temp !
	; MAXFILETEMP is from makefile args:
	move.l	#FILETEMP,d0

	move.l  d0,dfi_FileMaxSize(a5)

	; - - - -  alloc max read buffer
	; - - - alloc so
	move.l	4.w,a6
	moveq.l	#0,d1 ; flags
	CALL	AllocMem	
	move.l	d0,dfi_Buffer(a5)
	tst.l	d0
	bne.s	.aok
.ert
		bsr _dat_close ; got to close file handler
		move.w	#ERR_NOMEM,_exitErrNo
		bra	errinit
.aok	

	; so we don't hog much ?
	move.l    _GfxBase,a6
	CALL    WaitTOF


	moveq	#0,d0	
	rts
errinit:
	moveq	#-1,d0
	rts
; - - - - - - - - - - -  - - - - - - - - 	

	XDEF    _dat_loadFileTo
_dat_loadFileTo:
	;d0 file index
	;a5 struct dfi
	;a0 where to load
	move.l	a0,-(sp)

	ifne    DDEBUG
		move.l	d0,_debugv+12
	endc

	move.l	_DosBase,a6
	move.l	dfi_Handler(a5),d7
	; - - -
	mulu.w	#10,d0 ; in header table
	move.l	 dfi_table(a5),a4
	add.l	d0,a4

	move.l	2(a4),d2 ; offset

	move.l	d7,d1
	moveq.l	#-1,d3  ;mode: -1 back to begin, 0 add from current
	CALL	Seek

	; - - - -Read
;;;no	 move.l	 dfi_Buffer(a5),d2
	move.l	(sp)+,d2

	move.l	d7,d1

	move.l	6(a4),d3 ; file size
	CALL	Read
	; test result ? ->todo
	cmp.l	d3,d0
	bne.b	.rerror
	move.l	d0,dfi_BufSize(a5)

	; so we don't hog much ?
	move.l    _GfxBase,a6	 
	CALL    WaitTOF

	move.l  dfi_BufSize(a5),d0

	rts
.rerror
		clr.l	dfi_BufSize(a5)
		; exception !
		bsr _demoEnd
		ifne    DDEBUG
			move.l	d0,_debugv
			move.l	d3,_debugv+4
			move.l	#777,_debugv+8
		endc
		jmp     __XCEXIT
		rts
	XDEF	_dat_loadFile
_dat_loadFile:
	;d0 file index
	;a5 struct dfi
	ifne    DDEBUG
		move.l	d0,_debugv+12
	endc
	
	move.l	_DosBase,a6
	move.l	dfi_Handler(a5),d7
	; - - - 
	mulu.w	#10,d0 ; in header table 
	move.l	 dfi_table(a5),a4
	add.l	d0,a4

	move.l	2(a4),d2 ; offset

	move.l	d7,d1
	moveq.l	#-1,d3  ;mode: -1 back to begin, 0 add from current	
	CALL	Seek

	; - - - -Read
	move.l	dfi_Buffer(a5),d2
	move.l	d7,d1
	
	move.l	6(a4),d3 ; file size
	CALL	Read
	cmp.l	d0,d3
	bne.b	.rerror
	move.l	d0,dfi_BufSize(a5)

	; so we don't hog much ?
	move.l    _GfxBase,a6
	CALL    WaitTOF

	move.l  dfi_BufSize(a5),d0

	rts
.rerror
	clr.l	dfi_BufSize(a5)
	; exception !
	bsr _demoEnd
	ifne    DDEBUG
		move.l	d0,_debugv
		move.l	d3,_debugv+4
		move.l	#7777,_debugv+8
	endc
	jmp     __XCEXIT
	rts
; - - - - - - -- - - - -  -- - - 
	XDEF	_dat_close
_dat_close:
	; at end of demo...

	;a5 dfi
	move.l	4.w,a6

	move.l  dfi_table(a5),d1
	beq	.notb		 
		move.l	d1,a1
		move.l	dfi_tableL(a5),d0
		CALL	FreeMem
.notb
	move.l	dfi_Buffer(a5),d1
	beq.b	.noclb
		move.l	d1,a1
		move.l	dfi_FileMaxSize(a5),d0
		CALL	FreeMem	
.noclb
	
	move.l	dfi_Handler(a5),d1
	beq.b	.noclose

		move.l	_DosBase,a6
		CALL	Close

.noclose
	rts
datName:	dc.b 'progdir:Catabasis.dat',0
	even
	
 

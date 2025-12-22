; - - - mem structs

DDEBUG=1
FILETEMP=32768
DOMUSIC=1

	ifnd	EXEC_TYPES_I
		include exec/types.i
	endc

	include graphics/gfx.i
	include bob.i

ERR_NOAGA	equ	1
ERR_NOMEM	equ	2   
ERR_NODAT	equ	3


;--- orable flags for _copperCompile_InitLowResAGA(d1)
; copperCompile Init modes
CCLR_CANSCROLL	equ	2	; then any larger BM width size can be used with
						; if not, only 320 width bm
; will use 2 playfield 16c+16c
CCLR_DUALPF		equ	4

; will set all colors from copper
; bplcon3 modifies from copper.
; if not, colors set from CPU setpalette (vblank)
; if dualpf, just set 0-15 and 16-31
; else set 1<<nbplane colors, high and low
CCLR_DOCOLORS	equ	1

; add wait/changes per lines: does fat coppers.
; allows parallax per lines:
CCLR_WL_SCROLL	equ	8
; allow horizontal palette shading 
CCLR_WL_16c	equ	16
; horizontal waiting for 3 colors (full copperscreen)
CCLR_WL_HC	 equ	32

; fmode for bm
; do not change
CCLR_BM32	equ		64
CCLR_BMDCAS	equ		128
CCLR_64		equ		(64|128)



CALL	MACRO
    jsr	_LVO\1(a6)
    ENDM

	; extends gfx.i's struct BitMap
	; planar bitmap in chip description
	; can be used for screens and bobs.
	STRUCTURE	sBitMap,bm_SIZEOF
    	; add planesize to bitmap struct
	 ULONG	sbm_PlaneSize
	 APTR	sbm_ChipAlloc	; unaligned for freeing
	LABEL	sbm_SIZEOF	; 
	; ...then extended to sbmb (bob) and sbms (screens)

	; created with gif reader:
	STRUCTURE	sBmBob,sbm_SIZEOF
		STRUCT	sbmb_bob,bob_SIZEOF
		LABEL	sbmb_SIZEOF

	; Bm for screens, created with initBm:
	STRUCTURE	sBmScreen,sbm_SIZEOF
		STRUCT	sbms_bobDest,bod_SIZEOF
		LABEL	sbms_SIZEOF

	; - - - data for each triple buf
	; link some info per bitmap to be following switches
	STRUCTURE	BmData,0
		; always starts with bm
		APTR	bmd_bm

		WORD	bmd_Y1
		WORD	bmd_Y2
		; - - keep chaos delta applied to chaoszoomer
		WORD	bmd_czdx
		WORD	bmd_czdy
		; - -
		UWORD	bmd_flags	;1 dirty
		UWORD	bmd_ldX1
		UWORD	bmd_ldY1
		UWORD	bmd_ldX2
		UWORD	bmd_ldY2

	LABEL	bmd_sizeof




	; palette thing, reused in gif reader
	STRUCTURE sPalette,0
		UWORD	spa_ColorCount
		UWORD	spa_dummy ; used by gif reader
		STRUCT	spa_Colors,256*3   ; or less
	LABEL	spa_SIZEOF



GIF_ADDCOLUMN  		equ	 8

	; need a struct to pass params to gif reader asm->c
	; and manage pre-alloc memory...
	STRUCTURE GifParams,0
		APTR	gfp_GifBin
		ULONG	gfp_FileSize
		ULONG 	gfp_Flags
		; - - - - point struct to be filled. (sbm)
		APTR	gfp_pSBitmap
		APTR	gfp_pSBmMask
		APTR	gfp_ppPalette ; ptr to ptr to receive palette
		; this is the private struct of gif reader.
		STRUCT	gfp_GifPrivate,16724 ; 16718 from C sizeof(struct)
	LABEL	gfp_SIZEOF

	STRUCTURE DatFileInfo,0
		APTR	dfi_Handler
		ULONG	dfi_FileMaxSize
		; load files in here:
		APTR	dfi_Buffer
		ULONG	dfi_BufSize
		; read file table in that
		UWORD	dfi_nbFiles
		APTR	dfi_table ; 10*nbFiles
		ULONG	dfi_tableL
	LABEL	dfi_SIZEOF


CP_MAXLINES	equ	256	; definitively

	STRUCTURE	sCopperColorBankPtr,0
		APTR	cpb_colorsh	; high12 next+4
		APTR	cpb_colorsl ; low12, next+4
		; do not insert or modify compiler
	LABEL		cpb_SIZEOF

	; describe where to modify compiled copper in real time:
	STRUCTURE	sCopperPtrs,0
		APTR	cp_start	; start of copper in chip
		ULONG	cp_size ; byte size of compiled copper
		APTR	cp_bitplane ; ptr to .w in copper, next adr is:+4
		APTR	cp_bplcon1	;ptr to low scroll bits .w 
		APTR	cp_sprite	; always: ptr to sprpt, then +4
		UWORD	cp_nbplanesm1 ;nbp-1, saves a subq 
		UWORD	cp_flags	; CC_xx knows when dualpf, ...
		; bus align config for bitplanes.
		UWORD	cp_fmodeIndex	;0:16b 1,2:32b 3:64b
		
		UWORD	cp_baseModulo	; bytes video read (320p->40), with scroll ->48
		UWORD	cp_nbLines
		
		UWORD	cp_line0ByteDxPF2	; byte shift aplied on bm ptr for x scroll
		UWORD	cp_line0ByteDxPF1
		; - - - set if CC_DOCOLORS
		UWORD	cp_nbColors ;->256 for start of frame
							; bplcon2 bpl1mod/bpl2mod are next

		; there are 8 possible 0-31 color banks
		STRUCT	cp_colorBanks,cpb_SIZEOF*8	;64b
		; - - - - - - - -  - - - - - - 
		; - - line waits pointers to copper
		;TODO could manage 12b copperscreens ?		
		
		; - - scroll line waits bplcon1
		; ptr to bplcon1+bpl1mod+bpl2mod, 12b at line start
		; palette per line change are at +12, per line.
		STRUCT	cp_scrollw,4*CP_MAXLINES	;1kb, ptr
		
		;DO NOT insert here
		; - - color line waits
		; TODO points color0 value
		STRUCT	cp_colorw,6*CP_MAXLINES ;ptr+word for trick
	LABEL	CopperPtrs_SIZEOF
	
	; - - use 2 copper struct for dbl buf
	STRUCTURE	sCopperDbl,0
		; the 2 actual twin struct
		STRUCT	cdb_cop1,CopperPtrs_SIZEOF
		STRUCT	cdb_cop2,CopperPtrs_SIZEOF
		; switchable drawn/shown double buffer
		APTR	cdb_CopA
		APTR	cdb_CopB
VHSIZE	equ    (4*CP_MAXLINES)

		STRUCT	cdb_scrollvh,VHSIZE ;yx table for parallax scroll
		;reuse same table for palette per line trick
cdb_shadevh	equ cdb_scrollvh
		STRUCT	cdb_scrollvh2,4*CP_MAXLINES ;yx pf2		
	LABEL	CopperDbl_SIZEOF



	; struct to manage inner allocations
	; so effects can alloc/init when previous
	; effect is finishing.
	; and adapt memory use.
	; management is private
	STRUCTURE	inMemCell,0
		APTR	inm_next
		APTR	inm_prev
		APTR	inm_retroptr	; **me
		UWORD	inm_state
		UWORD	inm_xxx
		APTR	inm_ptr
		ULONG	inm_size
	LABEL	inm_SIZEOF

MAXNBMEMCELL	equ	(64+16+8)
; was 120 -> 146
FASTTEMPSIZE	equ	(1024*(146+12))
	; - - common states and reusable chunks
	STRUCTURE smFast,0    
		
		; retain files inside dat:
		STRUCT	sf_datFiles,dfi_SIZEOF
	
		; math and moves tables...
		; and #$03ff on index, then (ax,dx*2)
		STRUCT sf_SinTab,(1024+512)*2  ;1<<14 3kb
		STRUCT sf_SinTab2,(1024+512)*2 ;1<<10 3kb
		; signals that distort screen paralax
		STRUCT sf_YDistortSine,2*256

		STRUCT sf_Smooth,256*2
		STRUCT sf_Exp,256*2

		STRUCT sf_Bplcon1Scramble,256*2

		; struct for internal memory management
		STRUCT sf_MemCells,inm_SIZEOF*MAXNBMEMCELL
		APTR	sf_Chip1Start
		APTR	sf_Chip2Start
		APTR	sf_FastStart

		; mem managed by allocs
		STRUCT	sf_temp,FASTTEMPSIZE; size of a chunky screen+stuffs

	LABEL	smFast_SIZEOF
		

	; - - the CHIP thing.
	; can get big with waits, 42164b copscreen ...
MAX_COPPER_SIZE	equ	1024*(46*2)

; - - - - - - now chip is alloked in 3 parts:
; This works far better on splitted mem conf, 
; --- 1: 320kb highres alloc for 640*512, and big scrollable and bobs
; --- 2: 200kb ext screen+64kb copper
; --- 3: music (around 250k max ?)
; note fast alloc should be around 250 ?
;---> try to take 1.2 or 1.3 Mb

	STRUCTURE smChip1,0
		STRUCT	sc1_bm,640*512+2968+64512+1024	;320kb
	LABEL	smChip1_SIZEOF

	STRUCTURE smChip2,0
		STRUCT	sc2_bm,1024*(216+35)
		; watch out size !
		STRUCT	sc2_copper,MAX_COPPER_SIZE
	LABEL	smChip2_SIZEOF		;264kb
	; for music ?
	STRUCTURE smChip3,0			;250kb
		;size of p61
		STRUCT	sc3_p61,163050
	LABEL	smChip3_SIZEOF


		
	; SASC - compiled function:			
	XREF	@GifBinToSBm

	
;int GifBinToSBm( 
;
;	GifFilePrivateType *pReader,  	a0
;	char *pGifBin, 					a1
;	unsigned int gifSize,			d0
;	void **outputPalette,			a2
;	struct BitMap **outputBM,		a3
;	struct BitMap **outputMask,		a4
;	int nbPlanes,					d1
;	int flags						d2
	
	
	
	
	




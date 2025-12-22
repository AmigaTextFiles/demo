;*******************************
;**** BACKSTAB.LIBRARY V1.0 ****
;****    By Sami Vaarala    ****
;*******************************

err_audio:	equ	-1		;error message definitions (-1 .. -128)
err_cache:	equ	-2

	;Library call offsets:
	;
	;TakeOverSystem		-30		\
	;ReturnToSystem		-36		 \ these 4 form the method I
	;ActivateSystem		-42		 /
	;DeactivateSystem	-48		/
	;
	;FullTakeOver		-54		\ these 2 form the method II
	;DoReset		-60		/
	;
	;FlushCaches		-66
	;
	;If there is a need for any special routines, add them here. Especially
	;if Exec needs patching for a routine, the routine can be included here
	;in full.

start:

call:	macro
	jsr	_LVO\1(a6)
	endm
go:	macro
	jmp	_LVO\1(a6)
	endm

	incdir	B:text/howtocode/source/include/	;new includes from
	include	graphics_lib.i				;howtocode 7
	include	intuition_lib.i

	incdir	p:oinc/
	include	exec/exec_lib.i
	include	exec/execbase.i
	include	exec/exec.i
	include	exec/types.i
	include	exec/initializers.i
	include	exec/libraries.i
	include	exec/lists.i
	include	exec/alerts.i
	include	exec/resident.i
	include	exec/ports.i
	include	libraries/dos.i
	;include	graphics/graphics_lib.i
	include	graphics/gfxbase.i
	include	libraries/dos_lib.i
	;include	intuition/intuition_lib.i
	include	intuition/intuitionbase.i
	include	workbench/workbench.i

	;All the includes from the "include:" are <KS2.0 (1.2/1.3) includes,
	;and so I've 'updated' some of the libraries from HowToCode7.
	;Ofcourse if you have better versions of the includes, use them!

;**** sprite resolutions, taken from OS3.0 includes "include/graphics/view.i"
SPRITERESN_ECS		equ	0
SPRITERESN_140NS 	equ	1
SPRITERESN_70NS		equ	2
SPRITERESN_35NS		equ	3

;**** other include from "include/graphics/videocontrol.i"
VTAG_SPRITERESN_SET	equ	$80000031
VTAG_SPRITERESN_GET	equ	$80000032

;**** from "include/utility/tagitem.i"
TAG_DONE   equ 0  ; terminates array of TagItems. ti_Data unused

_LVOCacheClearU:	equ	-636	;from new Exec includes
_LVOCacheControl:	equ	-648	;

GFXB_AA_ALICE:		equ	2	;from HowToCode
gb_ChipRevBits0:	equ	$ec	;

VERSION:	equ	1		;version number (0...255)
REVISION:	equ	0		;revision number (0...255)

	;lib base
	RSRESET
bks_flags:	rs.b	1	;lib flags
bks_pad:	rs.b	1	;alignment
bks_syslib:	rs.l	1	;execbase
bks_seglist:	rs.l	1	;seglist-pointer
bks_size:	rs.w	0	;size of structure

bks_sizeof:	equ	bks_size+LIB_SIZE ;=> real size of lib base

	moveq	#-1,d0			;if someone runs us...
	rts				;

	;Exec will seek for matchword and check if next longword pointer
	;matches matchword also...

ROMTag:	dc.w	RTC_MATCHWORD	;uword	rt_matchword
	dc.l	ROMTag		;aptr	rt_matchtag

	dc.l	EndOfLib	;aptr	rt_endskip	= end of library

	dc.b	RTF_AUTOINIT	;ubyte	rt_flags	= auto initialized lib
	dc.b	VERSION		;ubyte	rt_version	> from EQU
	dc.b	NT_LIBRARY	;ubyte	rt_type		= use type LIBRARY
	dc.b	0		;ubyte	rt_pri		???

	dc.l	LibName		;aptr	rt_name
	dc.l	LibID		;aptr	rt_idstring
	dc.l	InitStuff	;aptr	rt_init		???

 dc.b "$VER: backstab.library version 1.0 by Sami Vaarala in 6.12.93",0
 even

InitStuff:
	dc.l	bks_sizeof	;structure size (library base???)
	dc.l	Functions	;function list
	dc.l	LibBaseData	;information for initializing (!?)
	dc.l	InitRoutine	;own routine for initialization

Functions:
	dc.l	r_open		;Open()		-	the basic lib functions
	dc.l	r_close		;Close()
	dc.l	r_expunge	;Expunge()
	dc.l	r_null		;reserved...

	dc.l	r_takeover	;TakeOverSystem() - run your program after this
	dc.l	r_return	;ReturnToSystem() - exit with this
	dc.l	r_activate	;ActivateSystem() - temp. activ. for loading...
	dc.l	r_deactivate	;DeactivateSystem() - after ActivateSystem()

	dc.l	r_fulltakeover	;FullTakeOver() - now able to _wreck_ CIAs!
	dc.l	r_reset		;DoReset() - reset the amiga

	dc.l	r_flushcaches	;FlushCaches() - flush all caches (if higher
				;than V37)

	dc.l	-1		;ENDMARK!


LibBaseData:	INITBYTE	LN_TYPE,NT_LIBRARY
		INITLONG	LN_NAME,LibName
		INITBYTE	LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
		INITWORD	LIB_VERSION,VERSION
		INITWORD	LIB_REVISION,REVISION
		INITLONG	LIB_IDSTRING,LibID
		dc.l	0	;end!
	
InitRoutine:
	move.l	a5,-(sp)		;store a5
	move.l	d0,a5			;lib base address to a5

	move.l	a6,bks_syslib(a5) 	;execbase to device		??!
	move.l	a0,bks_seglist(a5)	;seglist to device		??!

	 move.l	#$400,d0		;alloc 0-page copy buffer
	 moveq	#0,d1			;
	 call	AllocMem		;
	 move.l	d0,zero_copy		;
	 beq.s	.panic			;

	 ;Opens all required libs: DOS, Intuition and Graphics. If any of these
	 ;fails, the library won't open!
	 move.l	4.w,a6			;
	 lea	dosn(pc),a1		;
	 moveq	#0,d0			;
	 call	OpenLibrary		;
 	 move.l	d0,dos_base		;
	 beq.w	.nod			;
	 lea	intn(pc),a1		;
	 moveq	#0,d0			;
	 call	OpenLibrary		;
 	 move.l	d0,int_base		;
	 beq.w	.noi			;
	 lea	gfxn(pc),a1		;
	 moveq	#0,d0			;
	 call	OpenLibrary		;
	 move.l	d0,gfx_base		;
	 beq.s	.nog			;zero flag = 0 (D0 != 0)

	move.l	a5,d0			;
	;lib base is in D0 (for return value)
	move.l	(sp)+,a5		;restore a5
	rts				;

.nog:	 move.l	int_base(pc),a1		;Close down the libs that were opened
	 call	CloseLibrary		;
.noi:	 move.l	dos_base(pc),a1		;
	 call	CloseLibrary		;
.nod:
.panic:
	 moveq	#-1,d0			;As we can't necessarily display an
.cols:	 move.w	#$f00,$dff180		;alert, let's use colors instead!
	 move.w	#$ff0,$dff180		;
	 dbf	d0,.cols		;
	 moveq	#0,d0			;zero flag = 1 (D0 = 0)
	 rts				;


r_open:
	addq.w	#1,LIB_OPENCNT(a6)	;new user, nest him. expunge is thereby
	bclr	#LIBB_DELEXP,bks_flags(a6);forbidden!
	move.l	a6,d0			;return base address in D0!
	rts				;


r_close:
	subq.w	#1,LIB_OPENCNT(a6)	;one user less, if not last one, exit!
	bne.s	r_close_notlast	  	;

	btst	#LIBB_DELEXP,bks_flags(a6);delayed expunge? no, exit!
	beq.s	r_close_nodelayedexpunge   ;

	bsr.s	r_expunge		;use Expunge() as a subroutine!
r_close_nodelayedexpunge:
r_close_notlast:
	moveq	#0,d0			;return zero
	rts				;


r_expunge:
	move.l	a5,-(sp)		;store...
	move.l	a6,a5			;lib base
	move.l	bks_syslib(a5),a6	;exec base

	tst.w	LIB_OPENCNT(a5)		;library still open? yes, use delayed
	beq.s	r_expunge_ok		;expunge! else go for it!

	bset	#LIBB_DELEXP,bks_flags(a5);
	move.l	a5,a6			;
	move.l	(sp)+,a5		;restore...
	moveq	#0,d0			;return zero	
	rts				;

r_expunge_ok:
	 move.l	zero_copy(pc),a1	;Free 0-page buffer
	 move.l	#$400,d0		;
	 call	FreeMem			;

	 ;Closes all opened libraries and all the other OS stuff that has been
	 ;affected.

	 move.l	dos_base(pc),a1		;Close all opened libraries
	 call	CloseLibrary		;
	 move.l	int_base(pc),a1		;
	 call	CloseLibrary		;
	 move.l	gfx_base(pc),a1		;
	 call	CloseLibrary		;

	move.l	d2,-(sp)		;

	move.l	bks_seglist(a5),d2	;SegList-pointer for returning...

	move.l	a5,a1			;lib base
	call	Remove			;kill library from exec lists...

	moveq	#0,d0			;free library: get base address to a1
	move.l	a5,a1			;and size to D0.
	move.w	LIB_NEGSIZE(a5),d0	;
	sub.l	d0,a1			;
	add.w	LIB_POSSIZE(a5),d0	;
	call	FreeMem			;
	move.l	d2,d0			;return SegList pointer!

	move.l	(sp)+,d2		;exit
	move.l	a5,a6			;
	move.l	(sp)+,a5		;
	rts				;

r_null:
	moveq	#0,d0			;no problem, illegal call!?
	rts				;



no_audio:
	moveq	#err_audio,d0		;error code and return
	move.l	(sp)+,a6		;
	rts				;

	;*** actual routines starting from -30 ...
r_takeover:
	move.l	d0,flags		;Store flags
	move.l	a6,-(sp)		;

	move.l	4.w,a6			;New client! Task pointer to 'aud_task'
	sub.l	a1,a1			;(*in* the audio device structure)
	call	FindTask		;
	move.l	d0,aud_task		;
	move.l	d0,a1			;Set task priority as high as possible
	moveq	#127,d0			;to prevent someone running with us
	call	SetTaskPri		;
	move.l	d0,old_taskpri		;

	;allocate audio channels and do an illegal audio reset
	bsr.w	alloc_audio		;Allocate audio (or takeover illegally)
	beq.s	no_audio		;If fails, exit with error code

	lea	$dff096,a0		;Force audio DMAs and volumes off, for
	moveq	#0,d0			;extra safety.
	move.w	d0,$0a8-$096(a0)	;
	move.w	d0,$0b8-$096(a0)	;
	move.w	d0,$0c8-$096(a0)	;
	move.w	d0,$0d8-$096(a0)	;
	move.w	#$000f,(a0)		;

	move.l	4.w,a6			;Disable interrupts
	call	Disable			;

	;prepare internal variables
	clr.l	old_VBR			;VBR swap value
	clr.l	chip_stores		;Values that will be loaded when exited
	clr.l	chip_stores+4		;-> chipregs


	;check if caches can be disabled (in case it is required)
	btst	#AFB_68020,AttnFlags+1(a6);If user is running <68020 (no caches
	bne.s	.check_nocache		;CPU), force NoCache flag down.
	bclr	#0,flags+3		;
.check_nocache:
	btst	#0,flags+3		;Check if we can disable caches in case
	beq.s	.nocache_ok		;'nocache' flag is set.
	move.w	LIB_VERSION(a6),d0	;
	cmp.w	#37,d0			;
	bhs.s	.nocache_ok		;

	move.l	int_base(pc),a6		;Alert user about the fault.
	moveq	#0,d0			;
	lea	cache_alert(pc),a0	;
	moveq	#60,d1			;
	call	DisplayAlert		;
	tst.l	d0			;D0 is nonzero if left was pressed
	bne.s	.nocache_ok		;(left means that we continue!)

	moveq	#err_cache,d0		;Error code and exit
	rts				;
.nocache_ok:

	;reset graphic chips
	bsr.w	reset_gfx		;Reset graphics chips to OCS state

	move.l	4.w,a6			;Fill zeropage with the current real
	call	SuperState		;zeropage (determined by VBR if >68010)
	move.l	d0,oldsysstack		;
	moveq	#0,d0			;
	btst	#AFB_68010,AttnFlags+1(a6);
	beq.s	.vbr_68000		;
	movec	vbr,d0			;
.vbr_68000				;
	move.l	d0,-(sp)		;
	move.l	oldsysstack(pc),d0	;
	call	UserState		;
					;
	move.l	(sp)+,a1		;
	move.l	zero_copy(pc),a0	;
	move.w	#[$400/4]-1,d0		;
.fill:					;
	move.l	(a1)+,(a0)+		;
	dbf	d0,.fill		;

	;'Deactivate' and 'takeover' have a common part from hereon, use that
	;for size optimization!

	bra.s	common_part_takeover	;

r_deactivate:
	;Flags are the same as TakeOver() [still stored]

	move.l	a6,-(sp)		;

	move.l	4.w,a6			;Disable interrupts
	call	Disable			;

common_part_takeover:
	bsr.w	wait_devices		;Wait devices to finish
	bsr.w	own_blitter		;Takeover blitter

	bsr.w	reset_caches		;Turn off caches if required

	move.l	4.w,a6			;Go to supervisor mode (zeropage
	call	SuperState		;handling requires this)
	move.l	d0,oldsysstack		;

	bsr.w	swap_zeropage_and_vbr	;Zeropage and VBR handling

	btst	#1,flags+3		;If flag SUPERVISOR is set, don't go
	bne.s	.nouser			;back to userstate
	move.l	4.w,a6			;
	move.l	oldsysstack(pc),d0	;
	call	UserState		;
.nouser:

	bsr.w	swap_chipregs		;Chip handling

	bsr.w	get_return_datas	;Get return datas abouut the system
	move.l	(sp)+,a6		;
	moveq	#0,d0			;error code = none
	rts				;
.panic:
	move.l	(sp)+,a6		;
	moveq	#err_cache,d0		;
	rts				;

r_activate:
	move.l	d2,-(sp)		;
	moveq	#0,d2			;
	bra.s	common_activation	;
r_return:
	move.l	d2,-(sp)		;
	moveq	#-1,d2			;
	;Just go on...

common_activation:
	;This piece of code is almost similar to 'ActivateSystem' and 'Return-
	;ToSystem'. The only difference is that ReturnToSystem frees audio
	;channels and restores gfx. To optimize size, D2 indicates which case
	;are we running, and some things are bypassed if it isn't ReturnTo-
	;System..

	move.l	a6,-(sp)		;
	move.w	#$4000,$dff09a		;Disable interrupts

	bsr.w	swap_chipregs		;Chip handling

	btst	#1,flags+3		;If SUPERVISOR flag wasn't set, we have
	bne.s	.was_super		;to go into supervisor.
	move.l	4.w,a6			;
	call	SuperState		;
	move.l	d0,oldsysstack		;
.was_super:
	bsr.w	swap_zeropage_and_vbr	;Swap zeropage and VBR

	move.l	4.w,a6			;Back to userstate
	move.l	oldsysstack(pc),d0	;
	call	Userstate		;

	bsr.w	restore_caches		;Restore cache states

	bsr.w	disown_blitter		;Blitter back to system

	tst.w	d2			;System view back (if ReturnToSystem)
	beq.s	.only_in_return1	;
	bsr.w	restore_gfx		;
.only_in_return1:

	move.l	4.w,a6			;Enable interrupts
	call	Enable			;

	tst.w	d2			;Audio chans back (if ReturnToSystem)
	beq.s	.only_in_return2	;

	lea	$dff096,a0		;Illegal audio reset before giving back
	moveq	#0,d0			;audio channels to system.
	move.w	d0,$0a8-$096(a0)	;
	move.w	d0,$0b8-$096(a0)	;
	move.w	d0,$0c8-$096(a0)	;
	move.w	d0,$0d8-$096(a0)	;
	move.w	#$000f,(a0)		;
					;
	bsr.w	restore_audio		;Audio channels back
					;
	move.l	4.w,a6			;Task priority back
	move.l	aud_task(pc),a1		;
	move.l	old_taskpri(pc),d0	;
	call	SetTaskPri		;

.only_in_return2:

	move.l	(sp)+,a6		;
	move.l	(sp)+,d2		;
	rts				;


	;This routine is exactly same as TakeOverSystem() at the moment, but
	;in future versions this routine can kill system less legally if
	;needed. This routine is here just for compatibility and expandability
	;of future versions.

r_fulltakeover:
	bra.w	r_takeover		;Use same routine

r_reset:
	;The Exec code under V39 (A1200) does NOT work properly. Proper reset
	;routines ARE possible, I don't have an idea how. If someone knows of
	;a _proper_ (preferable Commodore recommended) way to do this, REPORT!
	;
	;This is written as the Commodores ''supported'' reset routine is.

ROMEND:		equ	$01000000	;
SIZE_OFFSET:	equ	-$14		;

KICK_V36:	equ	36		;
V36_ColdReboot:	equ	-726		;

	move.l	4.w,a6			;
	cmp.w	#KICK_V36,LIB_VERSION(a6);
	blt.s	.old_kick		;

	jmp	V36_ColdReboot(a6)	;Use V36 or upwards reset code

.old_kick:
	move.w	#$4000,$dff09a		;(I feel safer this way, so does KS3.0)

	;KS3.0 disables caches here as well, no reason to do it if <V36?

	lea	.Reset_Code(pc),a5	;
	jsr	_LVOSupervisor(a6)	;
	;never here, supervisor jumps to reset code

	cnop	0,4			;DON'T TOUCH!
.Reset_Code:
	lea	ROMEND,a0		;Calc entrypoint
	sub.l	SIZE_OFFSET(a0),a0	;
	move.l	4(a0),a0		;
	subq.l	#2,a0			;
	reset				;reset peripherie
	jmp	(a0)			;done

	;! <reset> and <jmp (a0)> in the same longword! (i.e. reset address
	;bits 0 and 1 are zero)


r_flushcaches:
	move.l	a6,-(sp)		;
	move.l	4.w,a6			;KS2.04 or higher? No, alert user!
	move.w	LIB_VERSION(a6),d0	;
	cmp.w	#37,d0			;
	blo.s	.noflush		;

	call	CacheClearU		;Flush it!
	move.l	(sp)+,a6		;
	moveq	#0,d0			;
	rts				;No error: D0 = 0
.noflush:
	move.l	(sp)+,a6		;
	moveq	#-1,d0			;ERROR! D0 = -1
	rts				;



	;*** Subroutines

get_return_datas:
	moveq	#0,d1			;Start from OCS

	move.l	4.w,a6			;>PROB< I don't know if one is able to
	cmp.w	#36,LIB_VERSION(a6)	;check chipset under 1.2/1.3, so this
	blo.s	.nocheck		;is for 'safety'?

	move.l	gfx_base(pc),a6		;
	btst	#GFXB_AA_ALICE,gb_ChipRevBits0(a6)
	bne.s	.aga			;
	btst	#1,gb_ChipRevBits0(a6)	;
	beq.s	.checkover		;
	moveq	#1,d1			;
	bra.s	.checkover		;
.aga:	moveq	#2,d1			;
.nocheck:
.checkover:

	move.l	4.w,a6			;Get Kickstart version (= Exec version)
	moveq	#0,d2			;
	move.w	LIB_VERSION(a6),d2	;

	move.w	AttnFlags(a6),d0	;Get CPU number
	btst	#3,d0			;
	bne.s	.040			;
	btst	#2,d0			;
	bne.s	.030			;
	btst	#1,d0			;
	bne.s	.020			;
	btst	#0,d0			;
	bne.s	.010			;
	moveq	#0,d3			;
	bra.s	.CPUover		;
.010:	moveq	#1,d3			;
	bra.s	.CPUover		;
.020:	moveq	#2,d3			;
	bra.s	.CPUover		;
.030:	moveq	#3,d3			;
	bra.s	.CPUover		;
.040:	moveq	#4,d3			;
.CPUover:
	moveq	#0,d4			;Get math emulation types
	lsr.w	#4,d0			;
	and.w	#%111,d0		;
	move.w	d0,d4			;

	rts				;

reset_caches:
	clr.l	old_cachebits		;(rerunning has to be possible)

	btst	#0,flags+3		;NoCache? Yes, exit
	beq.s	.noreq			;

	;If we are here, the CPU -has- caches and they are killable.

	move.l	4.w,a6			;
	call	CacheClearU		;Safety flush (surely Exec does this?)

	moveq	#0,d0			;Get old cache state
	moveq	#0,d1			;
	call	CacheControl		;
	move.l	d0,old_cachebits	;

	move.l	d0,d1			;Clear only SET bits to avoid masking
	moveq	#0,d0			;d1 with -1
	call	CacheControl		;
.noreq:
	rts				;


restore_caches:
	move.l	old_cachebits(pc),d0	;
	beq.s	.nofix			;

	;If the cache was fixed, it's possible to unfix it! [no error checks]

	move.l	4.w,a6			;Reset old cache state: set all bits
	move.l	old_cachebits(pc),d0	;with identical mask!
	move.l	d0,d1			;
	call	CacheControl		;
.nofix:
	rts				;


alloc_audio:
	;Allocates and initializes audio channels and returns zero flag set if
	;the audio wasn't ok: exit the whole shit. Also illegally turns the
	;audio DMA off along with volumes that are set to zero. Ofcourse only
	;if channels were allocated or user agreed to takeover.

	;Initialize structure for OpenDevice(), which will allocate the
	;channels specifies in the channel map structure. The mask is always
	;(in this code) %1111, and that is the only entry. -> All channels are
	;always allocated.

	clr.b	audio_alloc		;Reset audio allocated flag

	;Task pointer is already set into the structure!

	moveq	#-1,d0			;AllocSignal for audio device
	call	AllocSignal		;
	move.b	d0,aud_signal		;
	bmi.s	.nosig			;

	lea	aud_messageport(pc),a1	;Add msgport into system lists
	call	AddPort			;
	tst.l	d0			;
	beq.s	.noport			;

	;Open the device. Strangely, no IO command needs to be assigned for
	;allocation (by the books). Priority 127 means that no-one can steal
	;these channels no more, in effect no handling for stolen channels is
	;required.

	lea	audn(pc),a0		;name ("audio.device")
	moveq	#0,d0			;unit (always 0)
	lea	aud_ioreq(pc),a1	;ioreq
	moveq	#0,d1			;flags (always 0)
	call	OpenDevice		;
	tst.l	d0			;
	bne.s	.nodev			;

	not.b	audio_alloc		;flag: audio allocated!
	rts				;zeroflag = 0

.nodev:
	lea	aud_messageport(pc),a1	;Handle errors, display alert for user
	call	RemPort			;to choose whether to exit demo or
.noport:				;take over anyway
	moveq	#0,d0			;
	move.b	aud_signal(pc),d0	;
	call	FreeSignal		;
.nosig:					;
	move.l	int_base(pc),a6		;
	moveq	#0,d0			;
	lea	audio_alert(pc),a0	;
	moveq	#60,d1			;
	call	DisplayAlert		;

	tst.l	d0			;If RMB pressed -> cancel -> D0=zero ->
	rts				;zeroflag set. Else zeroflag=0.


restore_audio:
	tst.b	audio_alloc		;If audio was allocated, get
	beq.s	.audio_over		;rid of it and all the system
					;stuff needed for it.
	move.l	4.w,a6			;
	lea	aud_ioreq(pc),a1	;
	call	CloseDevice		;
	lea	aud_messageport(pc),a1	;
	call	RemPort			;
	moveq	#0,d0			;
	move.b	aud_signal(pc),d0	;
	call	FreeSignal		;
.audio_over:
	rts				;


wait_devices:
	;Somekind of device wait would be ideal here. Anyone know how to wait
	;for all devices to finish?
	rts				;




reset_gfx:
	;Flushes all graphics hardware to basic state (according to system).

	;If V39 or higher, forces sprites back to 140ns resolution. No return
	;codes.

	sub.l	a1,a1			;
	call	FindTask		;
	move.l	d0,a1			;

	clr.l	wbscreen		;If someone runs us again...

	move.l	4.w,a6			;The sprite fix only if KS 3.0 (V39)
	move.w	LIB_VERSION(a6),d0	;or higher.
	cmp.w	#39,d0			;
	blo.w	.exit			;

	move.l	#VTAG_SPRITERESN_GET,taglist;must work even if many calls...
	move.l	#SPRITERESN_ECS,res	;

	move.l	int_base(pc),a6		;Store old resolution
	lea	wbn(pc),a0		;
	call	LockPubScreen		;
	move.l	d0,wbscreen		;
	beq.s	.exit			;
	move.l	d0,a0			;
					;
	move.l	sc_ViewPort+vp_ColorMap(a0),a0;
	lea	taglist(pc),a1		;
	move.l	gfx_base(pc),a6		;
	call	VideoControl		;
	move.l	res,oldres		;

        move.l	#VTAG_SPRITERESN_SET,taglist;Reset sprites to 140ns resolution
        move.l	#SPRITERESN_140NS,res	;
					;
        move.l	wbscreen(pc),a0		;
        move.l	sc_ViewPort+vp_ColorMap(a0),a0;
        lea	taglist(pc),a1		;
	call	VideoControl		;

	move.l	wbscreen(pc),a0		;Make system actually do the change
	move.l	int_base(pc),a6		;reality
	call	MakeScreen		;
	call	RethinkDisplay		;

	move.l	gfx_base(pc),a6		;Wait for the change...
	call	WaitTOF			;
	call	WaitTOF			;
	;Sprites are now 140ns!
.exit:
	move.l	gfx_base(pc),a6		;Store system view and reset the
	move.l  gb_ActiView(a6),sysview	;graphics hardware to the original
	sub.l	a1,a1			;state: AGA is flushed. The bug in the
	call	LoadView		;LoadView(NULL) leaves AGA sprites un-
	call	WaitTOF			;fixed, but that was handled before.
	go	WaitTOF			;(wait twice for interlace)

restore_gfx:
	move.l	wbscreen(pc),d0		;Reset sprites to original rez,
	beq.s	.exit			;if WBscreen not available do
	move.l	d0,a0			;nothing

	;If < V39, the wbscreen will be zero, so exit is ok!
	;
	;VTAG command has to be set to 'SET' now, as we exited TakeOver with
	;that value...
	move.l	oldres(pc),res		;
	lea	taglist(pc),a1		;
	move.l	sc_ViewPort+vp_ColorMap(a0),a0	;
	move.l	gfx_base(pc),a6		;
	call	VideoControl		;

	move.l	int_base(pc),a6		;Make system believe the truth.
	move.l	wbscreen(pc),a0		;
	call	MakeScreen		;(ReThinkDisplay() done later on)

	move.l	wbscreen(pc),a1		;
	sub.l	a0,a0			;(Unlock the WB screen)
	call	UnlockPubScreen		;

	move.l	gfx_base(pc),a6		;Wait for the change...
	;Sprites are now in original resolution
.exit:
	move.l	gfx_base(pc),a6		;Restore original view
	move.l	sysview(pc),a1		;
	call	LoadView		;
	call	WaitTOF			;(if interlace)
	call	WaitTOF			;

	move.l	gb_copinit(a6),$dff080	;Reset copper 1 address

	move.l	int_base(pc),a6		;Rethink...
	go	ReThinkDisplay		;



own_blitter:
	;Take over blitter and wait for it to get done totally.

	move.l	gfx_base(pc),a6		;
	call	OwnBlitter		;*some* blit safety! Wait blitter twice
	call	WaitBlit		;with system routines and then with an
	call	WaitBlit		;own illegal waitup. No config should
	btst	#14,$dff002		;go through that one unnoticed? :)
.wblit:					;
	btst	#14,$dff002		;
	bne.s	.wblit			;
	rts				;

disown_blitter:
	btst	#14,$dff002			;Wait and disown blitter
.wblit:						;(some safety here also...)
	btst	#14,$dff002			;
	bne.s	.wblit				;
	move.l	gfx_base(pc),a6			;
	call	WaitBlit			;
	call	WaitBlit			;
	call	DisownBlitter			;
	rts					;

swap_zeropage_and_vbr:
	;Requires SUPERVISOR mode!

	move.l	zero_copy(pc),a0		;Swap stored zeropage with the
	sub.l	a1,a1				;real zeropage (physical,
	move.w	#$400/4-1,d0			;starting from $0)
.swap:						;
	move.l	(a0),d1				;
	move.l	(a1),(a0)+			;
	move.l	d1,(a1)+			;
	dbf	d0,.swap			;

	move.l	4.w,a6				;If >68010, swap stored and
	btst	#AFB_68010,AttnFlags+1(a6)	;real VBR (the runned program's
	beq.s	.vbr_68000			;VBR is always zero, though)
	move.l	old_vbr(pc),d0			;
	movec	vbr,d1				;
	move.l	d1,old_vbr			;
	movec	d0,vbr				;
.vbr_68000:					;
	rts					;




swap_chipregs:
	;Wait for disk DMA to finish and swap the 4 important chipregs

	lea	$dff096,a0			;Custom base

	btst	#14,$01a-$096(a0)		;Wait disk DMA for maximum
	beq.s	.nodiskdma			;certainty!
.diskdma:					;
	btst	#1,$01e+1-$096(a0)		;DO NOT clear the bit, system
	beq.s	.diskdma			;may be expecting it...
.nodiskdma:

	move.w	$002-$096(a0),d1		;
	move.w	old_dmacon(pc),d0		;
	bset	#15,d0				;
	and.w	#%1000011111111111,d0		;
	move.w	d0,(a0)				;
	not.w	d0				;
	and.w	#%1000011111111111,d0		;
	move.w	d0,(a0)				;
	move.w	d1,old_dmacon			;
						;
	move.w	$01c-$096(a0),d1		;
	move.w	old_intena(pc),d0		;(master is disabled!)
	bset	#15,d0				;
	move.w	d0,$09a-$096(a0)		;
	not.w	d0				;
	move.w	d0,$09a-$096(a0)		;
	move.w	d1,old_intena			;
						;
	move.w	$01e-$096(a0),d1		;
	move.w	old_intreq(pc),d0		;
	bset	#15,d0				;
	move.w	d0,$09c-$096(a0)		;
	not.w	d0				;
	move.w	d0,$09c-$096(a0)		;
	move.w	d1,old_intreq			;
						;
	move.w	$010-$096(a0),d1		;
	move.w	old_adkcon(pc),d0		;
	bset	#15,d0				;
	move.w	d0,$09e-$096(a0)		;
	not.w	d0				;
	move.w	d0,$09e-$096(a0)		;
	move.w	d1,old_adkcon			;
	rts					;


aud_ioreq:	dc.l	0		;succ		\
		dc.l	0		;pred		 \
		dc.b	5		;type = message	   node structure
		dc.b	127		;pri		 / (in message struct)
		dc.l	0		;name		/

aud_msgport:	dc.l	aud_messageport	;message port	      \ actual message
		dc.w	0		;byte nbr of message  / structure

		dc.l	0		;device
		dc.l	0		;unit

aud_cmd:	dc.w	0		;command
aud_flags:	dc.b	0		;flags
aud_error:	dc.b	0		;error

		;here begins the audio request extra datas

aud_allockey:	dc.w	0		;allocation key (dev fills up)
aud_data:	dc.l	channel_map	;data pointer
aud_len:	dc.l	1		;size data field
aud_per:	dc.w	0		;frequency
aud_vol:	dc.w	0		;volume
ayd_cycles:	dc.w	0		;cycles

		;this is the WriteMsg structure trailing the real IO req.
		;device will fill this space up, so only 14 zeros is ok.
		;
		;
		blk.b	mn_size,0	;device will fill this up (14 bytes)


aud_messageport:dc.l	0		;succ
		dc.l	0		;pred
		dc.b	4		;type = messageport
		dc.b	0		;pri
		dc.l	0		;name

		dc.b	0		;flags
aud_signal:	dc.b	0		;signal bit
aud_task:	dc.l	0		;task

		dc.l	0		;head
		dc.l	0		;tail
		dc.l	0		;tailpred
		dc.b	0		;type
		dc.b	0		;pad

oldres:		dc.l	0		;Old sprite resolution
wbscreen:	dc.l	0		;WB screen

taglist:	dc.l  	0		;VTAG command (set resn/get resn)
res:		dc.l  	0		;resolution
tagdone:	dc.l	TAG_DONE,0	;


flags:		dc.l	0		;Takeover input flags

dos_base:	dc.l	0		;dos base
gfx_base:	dc.l	0		;graphics base
int_base:	dc.l	0		;intuition base
zero_copy:	dc.l	0		;zeropage copy address
old_VBR:	dc.l	0		;old VBR
old_taskpri:	dc.l	0		;old task priority
sysview:	dc.l	0		;system view address
oldsysstack:	dc.l	0		;old stack pointer:superstate/userstate
old_cachebits:	dc.l	0		;old cache control bits

chip_stores:
old_dmacon:	dc.w	0		;chipreg storages...
old_intena:	dc.w	0		;
old_intreq:	dc.w	0		;
old_adkcon:	dc.w	0		;

audio_alloc:	dc.b	0		;Flag: audio was allocated succesfully

channel_map:	dc.b	%1111		;all 4 channels or nothing (alloc map)

dosn:	dc.b	'dos.library',0
gfxn:	dc.b	'graphics.library',0
intn:	dc.b	'intuition.library',0
wbn:	dc.b	'Workbench',0
audn:	dc.b	'audio.device',0


t:	macro
	;\1	X coord (+12 will be added)
	;\2	Y coord (+12 will be added)
	;\3	string
	;\4	0 / -1 (end, continue)

	dc.b	[\1+12]/$100,[\1+12]&$FF,\2+12,\3,0,\4
	endm

audio_alert:
 t 9*8+4,0,'BACKSTAB LIBRARY ALERT: Unable to allocate audio channels.',-1
 t 9*8+4+1,0,'BACKSTAB LIBRARY ALERT: Unable to allocate audio channels.',-1
 t 25*8+4,10,'Take over channels anyway?',-1
 t 10*8,30,'Left mousebutton',-1
 t 50*8,30,'Right mousebutton',-1
 t 16*8+4,40,'YES',-1
 t 57*8+4,40,'NO',0

cache_alert:
 t 14*8,0,'BACKSTAB LIBRARY ALERT: Unable to disable caches',-1
 t 15*8+1,0,'BACKSTAB LIBRARY ALERT: Unable to disable caches.',-1
 t 33*8,10,'Run anyway?',-1
 t 10*8,30,'Left mousebutton',-1
 t 50*8,30,'Right mousebutton',-1
 t 16*8+4,40,'YES',-1
 t 57*8+4,40,'NO',0

;77 chars / line, top left = (12,12)
;
;01234567890123456789012345678901234567890123456789012345678901234567890123456
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;+1/2     BACKSTAB LIBRARY ALERT: Unable to allocate audio channels.
;+1/2                     Take over channels anyway?
;
;          Left mousebutton                        Right mousebutton
;
;+1/2            YES                             +1/2     NO

;01234567890123456789012345678901234567890123456789012345678901234567890123456
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;             BACKSTAB LIBRARY ALERT: Unable to disable caches.
;                                 Run anyway?
;
;          Left mousebutton                        Right mousebutton
;
;+1/2            YES                             +1/2     NO


LibName: dc.b	'backstab.library',0
LibID:	 dc.b	'backstab.library 1.0',13,10,0

	even

EndOfLib:	;LIBRARY ENDS HERE!!!

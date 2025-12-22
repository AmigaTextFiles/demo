	include	'exec/types.i'
	include 'exec/semaphores.i'

	STRUCTURE	ProfileSem,SS_SIZE
	APTR	ps_ProfileCounters
	APTR	ps_ProfileTask		; pointer to profiling task for signalling
	APTR	ps_WatchTask		; task being watched or 0
	ULONG 	ps_stack_pc_offset	; offset of PC in interrupt stack frame.
	APTR	ps_ExecBase
	LABEL	ps_SIZEOF

CTR_ALWAYS	equ	0				; always incremented unelss the semaphore is held
CTR_USUALLY	equ	CTR_ALWAYS+1	; incremented on task match
CTR_ANYROM	equ	CTR_USUALLY+1
CTR_NONIDLE	equ	CTR_ANYROM+1
CTR_SW		equ	CTR_NONIDLE+1	; 32 software counters
CTR_FIRSTROM	equ	CTR_SW+32	; and 128K rom counters

ONTIMER	macro	bitnum
	ifd	PROFILE
	ifne	PROFILE
	or.l	#(1<<\1),$0
	endc
	endc
	endm

OFFTIMER	macro	bitnum
;; only handles 0-7!
	ifd	PROFILE
	ifne	PROFILE
	and.l	#$ffffffff-(1<<\1),$0
	endc
	endc
	endm

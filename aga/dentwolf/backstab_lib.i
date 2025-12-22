;This is the include file for backstab.library version 1.0

_LVOTakeOverSystem:	equ	-30
_LVOReturnToSystem:	equ	-36
_LVOActivateSystem:	equ	-42
_LVODeactivateSystem:	equ	-48
_LVOFullTakeOver:	equ	-54
_LVODoReset:		equ	-60
_LVOFlushCaches:	equ	-66

bsb_supervisor:		equ	1			;bits for flags
bsb_nocaches:		equ	0			;

bsf_supervisor:		equ	1<<bsb_supervisor	;values for flags
bsf_nocaches:		equ	1<<bsb_nocaches		;

CALLBACKSTAB:	macro
	move.l	_BackStabBase,a6
	jsr	_LVO\1(a6)
	endm
BACKSTABNAME:	macro
	dc.b	'backstab.library',0
	endm

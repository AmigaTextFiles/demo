	xdef	_installLevel3Interrupt__16ProductionRunnerFPPFv_v
	xref	@verticalBlankInterrupt__16ProductionRunnerFv
	xref	@blitterInterrupt__16ProductionRunnerFv

	section	code

_installLevel3Interrupt__16ProductionRunnerFPPFv_v:
	move.l	#Level3Interrupt,(a1)
	move.l	a0,Level3InterruptProductionRunner
	rts

Level3Interrupt:
	movem.l	d0-d7/a0-a6,-(sp)

	move.w	$dff01e,d0
	and.w	#$0020,d0
	beq.s	l3I.noVerticalBlankRequest
	move.w	#$0020,$dff09c
	move.w	#$0020,$dff09c
	move.l	Level3InterruptProductionRunner,a0
	jsr	@verticalBlankInterrupt__16ProductionRunnerFv
	movem.l	(sp)+,d0-d7/a0-a6
	rte
	rte

l3I.noVerticalBlankRequest:
	move.w	$dff01e,d0
	and.w	#$0040,d0
	beq.s	l3I.noBlitterRequest
	move.w	#$0040,$dff09c
	move.w	#$0040,$dff09c
	move.l	Level3InterruptProductionRunner,a0
	jsr	@blitterInterrupt__16ProductionRunnerFv
	movem.l	(sp)+,d0-d7/a0-a6
	rte
	rte

l3I.noBlitterRequest:
	; Shouldn't end up here: clear vertical blank and blitter interrupt requests to avoid infinite interrupt loop
	move.w	#$0060,$dff09c
	move.w	#$0060,$dff09c
	movem.l	(sp)+,d0-d7/a0-a6
	rte
	rte

Level3InterruptProductionRunner:	dc.l	0

	end

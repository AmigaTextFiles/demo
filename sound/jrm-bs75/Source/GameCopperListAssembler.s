	xdef	_writeCopperlist__14GameCopperListFsUsPss

; Offsets to various C++ structures. These MUST match the C++ structures!
; -----------------------------------------------------------------------
data_		equ	4
roadLineZ	equ	14
roadLineScale	equ	18
ROAD_HEIGHT	equ	96
INDEX_ROAD	equ	95

	section	code

_writeCopperlist__14GameCopperListFsUsPss:
	movem.l	d2-d7/a3-a6,-(sp)

	neg.w	d0		; ((uint16_t)(-xPosition)) & 1023
	and.w	#$3ff,d0
	add.w	d0,d0

	move.l	data_(a0),a3	; uint32_t* road = data_ + INDEX_ROAD + 1;
	lea	(INDEX_ROAD*4+6)(a3),a3
	move.l	roadLineZ(a0),a4
	move.l	roadLineScale(a0),a5

	move.w	(a4)+,d2	; uint16_t z = roadLineZ[0] + zPosition;
	add.w	d1,d2

	move.l	(a5)+,a6	; int16_t dx = roadLineScale[0][((uint16_t)(-xPosition)) & 1023] - (roadGeometry[z >> 7] - bottomRoadX);
	move.w	(a6,d0.w),d3
	move.w	d2,d6
	lsr.w	#7,d6
	add.w	d6,d6
	sub.w	(a1,d6.w),d3
	add.w	a2,d3

	move.w	d3,d4		; int16_t dxBytes = (dx >> 3) & 0xfffe;
	asr.w	#3,d4
	and.w	#$fffe,d4

	and.w	#15,d3		; *road++ = copperMove(bplcon1, (dx & 15) << 4);
	lsl.w	#4,d3
	move.w	d3,(a3)

	btst	#9,d2
	beq.s	.brightRoadColor1
	move.w	#$666,8(a3)	; *road++ = copperMove(color01, roadColors[(z & 512) < 256 ? 1 : 5]);
	move.w	#$fff,16(a3)	; *road++ = copperMove(color03, roadColors[(z & 512) < 256 ? 3 : 7]);
	bra.s	.roadColorOk1
.brightRoadColor1:
	move.w	#$566,8(a3)
	move.w	#$566,16(a3)
.roadColorOk1:

	btst	#8,d2
	beq.s	.brightMarkingColor1
	move.w	#$fff,12(a3)	; *road++ = copperMove(color02, roadColors[(z & 256) < 128 ? 2 : 6]);
	bra.s	.markingColorOk1
.brightMarkingColor1:
	move.w	#$b00,12(a3)
.markingColorOk1:

	lea	20(a3),a3
	move.w	#ROAD_HEIGHT-2,d7
.yLoop:	move.w	d4,d5		; int16_t oldDxBytes = dxBytes;

	move.w	(a4)+,d2	; uint16_t z = roadLineZ[y] + zPosition;
	add.w	d1,d2

	move.l	(a5)+,a6	; int16_t dx = roadLineScale[y][((uint16_t)(-xPosition)) & 1023] - (roadGeometry[z >> 7] - bottomRoadX);
	move.w	(a6,d0.w),d3
	move.w	d2,d6
	lsr.w	#7,d6
	add.w	d6,d6
	sub.w	(a1,d6.w),d3
	add.w	a2,d3

	move.w	d3,d4		; int16_t dxBytes = (dx >> 3) & 0xfffe;
	asr.w	#3,d4
	and.w	#$fffe,d4

	sub.w	d4,d5		; *road++ = copperMove(bpl1mod, ((ROAD_BITPLANES * ROAD_WIDTH - SCREEN_WIDTH) >> 3) - (dxBytes - oldDxBytes) - 2);
	add.w	#342,d5
	move.w	d5,(a3)

	and.w	#15,d3		; *road++ = copperMove(bplcon1, (dx & 15) << 4);
	lsl.w	#4,d3
	move.w	d3,8(a3)

	btst	#9,d2
	beq.s	.brightRoadColor2
	move.w	#$666,16(a3)	; *road++ = copperMove(color01, roadColors[(z & 512) < 256 ? 1 : 5]);
	move.w	#$fff,24(a3)	; *road++ = copperMove(color03, roadColors[(z & 512) < 256 ? 3 : 7]);
	bra.s	.roadColorOk2
.brightRoadColor2:
	move.w	#$566,16(a3)
	move.w	#$566,24(a3)
.roadColorOk2:

	btst	#8,d2
	beq.s	.brightMarkingColor2
	move.w	#$fff,20(a3)	; *road++ = copperMove(color02, roadColors[(z & 256) < 128 ? 2 : 6]);
	bra.s	.markingColorOk2
.brightMarkingColor2:
	move.w	#$b00,20(a3)
.markingColorOk2:

	lea	28(a3),a3
	dbra	d7,.yLoop

	movem.l	(sp)+,d2-d7/a3-a6
	rts

	end

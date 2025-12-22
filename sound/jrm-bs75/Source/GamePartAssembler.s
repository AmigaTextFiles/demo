	xdef	_renderFrame__8GamePartFv
	xdef	_displayFrame__8GamePartFv
	xdef	_calculateRoadLineTables__8GamePartFv
	xdef	_projectObjectPosition__8GamePartFPQ2_8GamePart6Object
	xdef	_furthestNonRenderedObject__8GamePartFv
	xdef	_bitmapIndexForWidth__8GamePartFPQ2_8GamePart12BitmapObjectUs
	xdef	_animateBikeTire__8GamePartFv
	xdef	_updateBikeSpriteStance__8GamePartFs
	xdef	_bitmapObjectForObject__8GamePartFPQ2_8GamePart6Objects
	xdef	_bikeSpriteForStance__8GamePartFl
	xdef	_moveObjectsTowardsCamera__8GamePartFv
	xdef	_updateRoadGeometry__8GamePartFv
	xdef	_renderObject__8GamePartFRCQ2_8GamePart6ROArgsRC7Point2D
	xdef	_updateSpeedText__8GamePartFv
	xdef	_updateScoreText__8GamePartFPcUl
	xdef	_writeText__8GamePartFPCcUsUsUs
	xdef	_updateScroller__8GamePartFv
	xdef	_updateCamera__8GamePartFv
	xdef	_clearRenderTargetObjectsBitmap__8GamePartFv
	xdef	_updateScore__8GamePartFv
	xdef	_spawnRoadSideObjects__8GamePartFv
	xref	_sin__4Util
	xref	_clear__6BitmapFUsUsUsUs
	xref	_copy__6BitmapFRC6BitmapUsUsUsUsUsUsUs
	xref	_copyWithMask__6BitmapFRC6BitmapRC6BitmapUsUsUsUsUsUsUsUsUc
	xref	_unite__4RectFRC4Rect
	xref	_hasQueuedBlits__13AmigaHardware
	xref	@setCopperList__13AmigaHardwareFRC10CopperListUc
	xref	@showCurrentBikeSprite__8GamePartFv
	xref	@spawnBikes__8GamePartFv
	xref	@showRoad__14GameCopperListFRC6BitmapsUsPss
	xref	@showHorizonBack__14GameCopperListFRC6Bitmaps
	xref	@showObjects__14GameCopperListFRC6Bitmap
	xref	@setScrollerXOffset__14GameCopperListFUs
	xref	_speedText
	xref	_scoreText
	xref	_topScoreText
	xref	_scrollText
	xref	_font

; Offsets to various C++ structures. These MUST match the C++ structures!
; -----------------------------------------------------------------------
ROAD_HEIGHT	equ	96
Z_MIN		equ	1536
Z_MAX		equ	40000
ROADSIDE_OBJECT_DISTANCE	equ	((Z_MAX-Z_MIN)/4)
MAX_OBJECTS	equ	6
SCREEN_WIDTH	equ	320
SCREEN_HEIGHT	equ	224
SCREEN_FETCH_WIDTH	equ	(SCREEN_WIDTH+16)
HEADER_WIDTH	equ	SCREEN_FETCH_WIDTH
HEADER_HEIGHT	equ	29
ROAD_HEIGHT	equ	96
SKY_HEIGHT	equ	(SCREEN_HEIGHT-ROAD_HEIGHT)
OBJECTS_WIDTH	equ	SCREEN_WIDTH
OBJECTS_HEIGHT	equ	(SCREEN_HEIGHT-HEADER_HEIGHT)
OBJECTS_SKY_HEIGHT	equ	(OBJECTS_HEIGHT-ROAD_HEIGHT)
HORIZON_BACK_HEIGHT	equ	64
HORIZON_FRONT_HEIGHT	equ	16
HORIZON_PARALLAX_WIDTH	equ	(SCREEN_WIDTH+16)
HORIZON_PARALLAX_HEIGHT	equ	HORIZON_FRONT_HEIGHT
BIKE_SPRITE_STANCE_DELAY_SAME_DIRECTION	equ	4
BIKE_SPRITE_STANCE_DELAY_OTHER_DIRECTION	equ	12
ZDELTA_MAX		equ	808

objectBitmapObjects	equ	0
objectX		equ	16
objectZ		equ	18
objectAnchorRight	equ	20
objectIsBike	equ	21
objectIsRendered	equ	22
objectSizeOf	equ	24
bitmapObjectBitmaps	equ	0
bitmapObjectMasks	equ	4
bitmapObjectBitmapCount	equ	8
bitmapData	equ	0
bitmapWidth	equ	4
bitmapHeight	equ	6
bitmapWidthInBytes	equ	12
bitmapRowSizeInBytes	equ	14
bikeSpriteSizeOf	equ	64
point2DX	equ	0
point2DY	equ	2
rectTopLeftX		equ	0
rectTopLeftY		equ	2
rectBottomRightX	equ	4
rectBottomRightY	equ	6
rectWidth		equ	8
rectHeight		equ	10
rectCenterX		equ	12
rectCenterY		equ	14
rectIsEmpty		equ	16
rectIsNull		equ	17
rectSizeOf		equ	18
gameCopperListSizeOf	equ	22

roadLineZ	equ	12
roadLineScale	equ	16
roadGeometry	equ	20
roadAngle	equ	24
xPosition	equ	26
zPosition	equ	28
zDelta		equ	30
horizonBackX	equ	32
horizonFrontX	equ	34
bottomRoadX	equ	36
bikeSpriteStance	equ	38
bikeSpriteStanceDelay	equ	40
score			equ	42
topScore		equ	46
scrollerXOffset		equ	50
scoreboardBitmap	equ	52
horizonBackBitmap	equ	56
horizonFrontBitmap	equ	60
horizonFrontMask	equ	64
renderTargetObjectsBitmap	equ	68
renderTargetCopperList	equ	72
previousBoundingRect	equ	76
distanceToPreviousRoadsideObject	equ	80
distanceToPreviousBike			equ	82
bikeToSpawn				equ	84
frameReady		equ	86
objects		equ	88
bikeSpriteRight3		equ	(objects+MAX_OBJECTS*objectSizeOf)
bikeSpriteRight2		equ	(bikeSpriteRight3+bikeSpriteSizeOf)
bikeSpriteRight1		equ	(bikeSpriteRight2+bikeSpriteSizeOf)
bikeSpriteMiddle	equ	(bikeSpriteRight1+bikeSpriteSizeOf)
bikeSpriteLeft1		equ	(bikeSpriteMiddle+bikeSpriteSizeOf)
bikeSpriteLeft2		equ	(bikeSpriteLeft1+bikeSpriteSizeOf)
bikeSpriteLeft3		equ	(bikeSpriteLeft2+bikeSpriteSizeOf)
currentBikeSprite	equ	(bikeSpriteLeft3+bikeSpriteSizeOf)
scrollerBitmap		equ	(currentBikeSprite+4)
headerBitmap		equ	(scrollerBitmap+4)
objectsBitmap1		equ	(headerBitmap+4)
objectsBitmap2		equ	(objectsBitmap1+4)
roadBitmap		equ	(objectsBitmap2+4)
horizonParallaxBitmap	equ	(roadBitmap+4)
left			equ	(horizonParallaxBitmap+4)
right			equ	(left+4)
tree			equ	(right+4)
previousBoundingRect1	equ	(tree+29*4)
previousBoundingRect2	equ	(previousBoundingRect1+rectSizeOf)
copperList1		equ	(previousBoundingRect2+rectSizeOf)
copperList2		equ	(copperList1+gameCopperListSizeOf)

	section	code

objectPos:
objectPosX:	dc.w	0
objectPosY:	dc.w	0
roArgs:		dc.l	0
		dc.l	0
		dc.l	0

_renderFrame__8GamePartFv:
	movem.l	d2-d7/a2-a6,-(sp)

	move.l	a0,a5

	move.l	horizonParallaxBitmap(a5),a0	; horizonParallaxBitmap->copy(*horizonBackBitmap, 16, 0, horizonBackX, HORIZON_BACK_HEIGHT - HORIZON_PARALLAX_HEIGHT, HORIZON_PARALLAX_WIDTH - 16, HORIZON_PARALLAX_HEIGHT);
	move.l	horizonBackBitmap(a5),a1
	move.w	#16,d0
	moveq	#0,d1
	move.w	horizonBackX(a5),d2
	move.w	#HORIZON_BACK_HEIGHT-HORIZON_PARALLAX_HEIGHT,d3
	move.w	#HORIZON_PARALLAX_WIDTH-16,d4
	move.w	#HORIZON_PARALLAX_HEIGHT,d5
	moveq	#-1,d7
	bsr	_copy__6BitmapFRC6BitmapUsUsUsUsUsUsUs

	move.l	horizonParallaxBitmap(a5),a0	; horizonParallaxBitmap->copyWithMask(*horizonFrontBitmap, *horizonFrontMask, 16, 0, horizonFrontX, 0, horizonFrontX, 0, HORIZON_PARALLAX_WIDTH - 16, HORIZON_PARALLAX_HEIGHT);
	move.l	horizonFrontBitmap(a5),a1
	move.l	horizonFrontMask(a5),a2
	sub.l	a3,a3
	move.w	#16,d0
	moveq	#0,d1
	move.w	horizonFrontX(a5),d2
	moveq	#0,d3
	move.w	d2,d4
	moveq	#0,d5
	move.w	#HORIZON_PARALLAX_WIDTH-16,d6
	move.w	#HORIZON_PARALLAX_HEIGHT,d7
	bsr	_copyWithMask__6BitmapFRC6BitmapRC6BitmapUsUsUsUsUsUsUsUsUc

	move.l	a5,a0

	bsr	_updateRoadGeometry__8GamePartFv	; int16_t roadDelta = updateRoadGeometry();
	move.w	d0,d3
	bsr	_updateCamera__8GamePartFv		; int16_t bottomRoadXDelta = updateCamera();
	move.w	d0,d2

	bsr	_clearRenderTargetObjectsBitmap__8GamePartFv	; clearRenderTargetObjectsBitmap();

	move.l	a5,a0
	move.w	d2,d0					; updateBikeSpriteStance(bottomRoadXDelta);
	bsr	_updateBikeSpriteStance__8GamePartFs

	move.l	currentBikeSprite(a5),d2		; BikeSprite* oldBikeSprite = currentBikeSprite;
	move.w	bikeSpriteStance(a5),d0			; currentBikeSprite = bikeSpriteForStance(bikeSpriteStance);
	ext.l	d0
	bsr	_bikeSpriteForStance__8GamePartFl
	move.l	d0,currentBikeSprite(a5)
	cmp.l	d0,d2					; if (currentBikeSprite != oldBikeSprite) {
	beq.s	rF.bikeSpriteOk
	bsr	@showCurrentBikeSprite__8GamePartFv	; showCurrentBikeSprite();
rF.bikeSpriteOk:

	move.l	a5,a0
	bsr	_animateBikeTire__8GamePartFv		; animateBikeTire();
	bsr	_moveObjectsTowardsCamera__8GamePartFv	; moveObjectsTowardsCamera();

	lea	objects(a0),a1
	moveq	#MAX_OBJECTS-1,d0			; for (uint16_t i = 0; i < MAX_OBJECTS; i++) {
rF.setObjectsUnrenderedLoop:
	clr.b	objectIsRendered(a1)			; objects[i].isRendered = false;
	lea	objectSizeOf(a1),a1
	dbra	d0,rF.setObjectsUnrenderedLoop

	moveq	#MAX_OBJECTS-1,d7			; for (i = 0; i < MAX_OBJECTS; i++) {
rF.renderObjectsLoop:
	bsr	_furthestNonRenderedObject__8GamePartFv	; GamePart::Object* object = furthestNonRenderedObject();
	tst.l	d0					; if (object) {
	beq	rF.objectOk
	move.l	d0,a2

	pea	objectPos				; Point2D objectPos = projectObjectPosition(object);
	move.l	d0,a1
	bsr	_projectObjectPosition__8GamePartFPQ2_8GamePart6Object
	addq	#4,sp

	move.l	a2,a1				; BitmapObject* bitmapObject = bitmapObjectForObject(object, objectPos.x);
	move.w	objectPosX,d0
	bsr	_bitmapObjectForObject__8GamePartFPQ2_8GamePart6Objects
	move.l	d0,a4

	move.w	bitmapObjectBitmapCount(a4),d0	; uint16_t expectedWidth = roadLineScale[objectPos.y][bitmapObject->bitmaps[bitmapObject->bitmapCount - 1]->width];
	subq	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	bitmapObjectBitmaps(a4),a1
	move.l	(a1,d0.w),a1
	move.w	bitmapWidth(a1),d0
	move.l	roadLineScale(a0),a1
	move.w	objectPosY,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	(a1,d1.w),a1
	add.w	d0,d0
	move.w	(a1,d0.w),d0
	move.l	a4,a1		; uint16_t bitmapIndex = bitmapIndexForWidth(bitmapObject, expectedWidth);
	bsr	_bitmapIndexForWidth__8GamePartFPQ2_8GamePart12BitmapObjectUs

	add.w	d0,d0
	add.w	d0,d0
	lea	roArgs,a3			; ROArgs roArgs = { bitmapObject->bitmaps[bitmapIndex], bitmapObject->masks[bitmapIndex], object };
	move.l	bitmapObjectBitmaps(a4),a1
	move.l	(a1,d0.w),(a3)
	move.l	bitmapObjectMasks(a4),a1
	move.l	(a1,d0.w),4(a3)
	move.l	a2,8(a3)
	lea	objectPos,a4
	bsr	_renderObject__8GamePartFRCQ2_8GamePart6ROArgsRC7Point2D	; renderObject(roArgs, objectPos);

rF.objectOk:
	dbra	d7,rF.renderObjectsLoop

	move.l	renderTargetCopperList(a5),a0		; renderTargetCopperList->showRoad(*roadBitmap, xPosition, zPosition, roadGeometry, bottomRoadX);
	move.l	roadBitmap(a5),a1
	move.w	xPosition(a5),d0
	move.w	zPosition(a5),d1
	move.w	bottomRoadX(a5),d2
	ext.l	d2
	move.l	d2,-(sp)
	move.l	roadGeometry(a5),-(sp)
	jsr	@showRoad__14GameCopperListFRC6BitmapsUsPss
	addq	#8,sp

	move.l	a5,a0
	move.w	d3,d0
	bsr	_spawnRoadSideObjects__8GamePartFv	; spawnRoadSideObjects(roadDelta);

	cmp.w	#ZDELTA_MAX,zDelta(a5)			; if (zDelta < ZDELTA_MAX) {
	bcc.s	rF.fullSpeed
	add.w	#1,zDelta(a5)				; zDelta++;
	bsr	_updateSpeedText__8GamePartFv		; updateSpeedText();
	move.l	_speedText,a1				; writeText(speedText, 232, 21, 1);
	move.w	#232,d0
	move.w	#21,d1
	moveq	#1,d2
	bsr	_writeText__8GamePartFPCcUsUsUs
	bra.s	rF.speedOk

rF.fullSpeed:
	bsr	@spawnBikes__8GamePartFv		; spawnBikes();

rF.speedOk:
	bsr	_updateScore__8GamePartFv		; updateScore();

rF.waitDone:
	tst.b	_hasQueuedBlits__13AmigaHardware	; while (AmigaHardware::hasQueuedBlits || AmigaHardware::isBlitterBusy());
	bne.s	rF.waitDone
	tst.w	$dff002
	btst	#14,$dff002
	bne.s	rF.waitDone

	movem.l	(sp)+,d2-d7/a2-a6
	rts

_displayFrame__8GamePartFv:
	move.l	a2,-(sp)
	move.l	a0,a2

	move.l	renderTargetCopperList(a2),a0		; renderTargetCopperList->showHorizonBack(*horizonBackBitmap, horizonBackX);
	move.l	horizonBackBitmap(a2),a1
	move.w	horizonBackX(a2),d0
	bsr	@showHorizonBack__14GameCopperListFRC6Bitmaps

	move.l	renderTargetCopperList(a2),a0		; renderTargetCopperList->showObjects(*renderTargetObjectsBitmap);
	move.l	renderTargetObjectsBitmap(a2),a1
	bsr	@showObjects__14GameCopperListFRC6Bitmap

	move.l	renderTargetCopperList(a2),a0		; AmigaHardware::setCopperList(*renderTargetCopperList, true);
	moveq	#1,d0
	bsr	@setCopperList__13AmigaHardwareFRC10CopperListUc

	move.l	objectsBitmap1(a2),d0			; renderTargetObjectsBitmap = renderTargetObjectsBitmap == objectsBitmap1 ? objectsBitmap2 : objectsBitmap1;
	cmp.l	renderTargetObjectsBitmap(a2),d0
	beq.s	dF.useObjectsBitmap2
	move.l	d0,renderTargetObjectsBitmap(a2)
	bra.s	dF.renderTargetObjectsBitmapOk
dF.useObjectsBitmap2:
	move.l	objectsBitmap2(a2),renderTargetObjectsBitmap(a2)
dF.renderTargetObjectsBitmapOk:

	lea	copperList1(a2),a1			; renderTargetCopperList = renderTargetCopperList == &copperList1 ? &copperList2 : &copperList1;
	cmp.l	renderTargetCopperList(a2),a1
	beq.s	dF.useCopperList2
	move.l	a1,renderTargetCopperList(a2)
	bra.s	dF.renderTargetCopperListOk
dF.useCopperList2:
	lea	gameCopperListSizeOf(a1),a1
	move.l	a1,renderTargetCopperList(a2)
dF.renderTargetCopperListOk:

	lea	previousBoundingRect1(a2),a1		; previousBoundingRect = previousBoundingRect == &previousBoundingRect1 ? &previousBoundingRect2 : &previousBoundingRect1;
	cmp.l	previousBoundingRect(a2),a1
	beq.s	dF.useBoundingRect2
	move.l	a1,previousBoundingRect(a2)
	bra.s	dF.previousBoundingRectOk
dF.useBoundingRect2:
	lea	rectSizeOf(a1),a1
	move.l	a1,previousBoundingRect(a2)
dF.previousBoundingRectOk:

	move.l	(sp)+,a2
	rts

_calculateRoadLineTables__8GamePartFv:
	movem.l	d3-d7/a2-a4,-(sp)

	move.l	roadLineZ(a0),a2
	move.l	roadLineScale(a0),a3
	moveq	#3,d5					; y
	move.w	#ROAD_HEIGHT-1,d7
.yLoop:	move.l	#1536*224*ROAD_HEIGHT/218,d3
	divu	d5,d3
	move.w	d3,(a2)+

	move.l	(a3)+,a4
	moveq	#0,d4					; x
	move.w	#512-1,d6
.xLoop1:
	move.l	d4,d3
	muls	d5,d3
	divs	#ROAD_HEIGHT,d3
	move.w	d3,(a4)+
	addq	#1,d4
	dbra	d6,.xLoop1

	move.l	#-512,d4				; x
	move.w	#512-1,d6
.xLoop2:
	move.l	d4,d3
	muls	d5,d3
	divs	#ROAD_HEIGHT,d3
	move.w	d3,(a4)+
	addq	#1,d4
	dbra	d6,.xLoop2

	addq	#1,d5
	dbra	d7,.yLoop

	movem.l	(sp)+,d3-d7/a2-a4
	rts

_projectObjectPosition__8GamePartFPQ2_8GamePart6Object:
	move.l	a2,-(sp)
	move.w	objectX(a1),d0		; int16_t unscaledX = (int16_t)(object->x - xPosition);
	sub.w	xPosition(a0),d0
	bpl.s	pOP.unscaledXPositive
	neg.w	d0
	mulu	#Z_MIN,d0		; int16_t objectX = Z_MIN * unscaledX / object->z - (roadGeometry[((object->z + zPosition) >> 7) & 511] - bottomRoadX);
	move.w	objectZ(a1),d1
	divu	d1,d0
	neg.w	d0
	bra.s	pOP.xProjected
pOP.unscaledXPositive:
	mulu	#Z_MIN,d0		; int16_t objectX = Z_MIN * unscaledX / object->z - (roadGeometry[((object->z + zPosition) >> 7) & 511] - bottomRoadX);
	move.w	objectZ(a1),d1
	divu	d1,d0
pOP.xProjected:
	add.w	zPosition(a0),d1
	lsr.w	#7,d1
	and.w	#511,d1
	add.w	d1,d1
	move.l	roadGeometry(a0),a2
	move.w	(a2,d1.w),d1
	sub.w	bottomRoadX(a0),d1
	sub.w	d1,d0
	move.l	8(sp),a2
	move.w	d0,(a2)+
	move.l	#Z_MIN*224*ROAD_HEIGHT/218,d0
	divu	objectZ(a1),d0
	subq	#3,d0
	move.w	d0,(a2)
	move.l	(sp)+,a2
	rts

_furthestNonRenderedObject__8GamePartFv:
	move.l	d2,-(sp)
	lea	objects(a0),a1
	move.w	#Z_MIN-1,d1		; uint16_t furthestZ = Z_MIN - 1;
	moveq	#0,d0			; uint16_t furthestIndex = 0;
	moveq	#MAX_OBJECTS-1,d2	; for (uint16_t i = 0; i < MAX_OBJECTS; i++) {
fNRO.loop:
	tst.b	objectIsRendered(a1)	; if (!objects[i].isRendered && objects[i].z > furthestZ) {
	bne.s	fNRO.next
	cmp.w	objectZ(a1),d1
	bcc.s	fNRO.next
	move.l	a1,d0			; furthestIndex = i;
	move.w	objectZ(a1),d1		; furthestZ = objects[i].z;
fNRO.next:
	lea	objectSizeOf(a1),a1
	dbra	d2,fNRO.loop
	move.l	(sp)+,d2
	rts

_bitmapIndexForWidth__8GamePartFPQ2_8GamePart12BitmapObjectUs:
	movem.l	a2/a3,-(sp)
	move.l	bitmapObjectBitmaps(a1),a2
	move.w	bitmapObjectBitmapCount(a1),d1
	move.l	a2,a1				; for (uint16_t bitmapIndex = 0;
	subq	#2,d1
bIFW.loop:
	move.l	(a2)+,a3			; bitmapObject->bitmaps[bitmapIndex]->width < expectedWidth && bitmapIndex < bitmapObject->bitmapCount - 1;
	cmp.w	bitmapWidth(a3),d0
	bcs.s	bIFW.found1
	dbra	d1,bIFW.loop			; bitmapIndex++;
bIFW.found1:
	subq	#4,a2
	cmp.l	a1,a2				; if (bitmapIndex > 0 &&
	beq.s	bIFW.found2
	move.w	bitmapWidth(a3),d1		; (bitmapObject->bitmaps[bitmapIndex]->width - expectedWidth) > (expectedWidth - bitmapObject->bitmaps[bitmapIndex - 1]->width)) {
	move.l	-4(a2),a3
	add.w	bitmapWidth(a3),d1
	sub.w	d0,d1
	sub.w	d0,d1
	bmi.s	bIFW.found2
	subq	#4,a2				; bitmapIndex--;
bIFW.found2:
	move.l	a2,d0
	sub.l	a1,d0
	lsr.w	#2,d0
	movem.l	(sp)+,a2/a3
	rts

_animateBikeTire__8GamePartFv:
	move.w	zPosition(a0),d0
	btst	#9,d0
	bne.s	aBT.zHigh
	move.w	#$aba,$dff1b8
	move.w	#$888,$dff1be
	rts
aBT.zHigh:
	move.w	#$aba,$dff1be
	move.w	#$888,$dff1b8
	rts

_updateBikeSpriteStance__8GamePartFs:
	sub.w	a1,a1				; uint16_t maxDelay = 0;

	move.w	bikeSpriteStance(a0),d1		; if (bikeSpriteStance < 0) {
	beq.s	uBSS.stanceZero
	bpl.s	uBSS.stancePositive

	cmp.w	d1,d0				; if (bottomRoadDelta < bikeSpriteStance) {
	blt.s	uBSS.maxDelaySameDirection	; maxDelay = BIKE_SPRITE_STANCE_DELAY_SAME_DIRECTION;
	bgt.s	uBSS.maxDelayOtherDirection	; } else if (bottomRoadDelta > bikeSpriteStance) {
	rts					; maxDelay = BIKE_SPRITE_STANCE_DELAY_OTHER_DIRECTION;

uBSS.stancePositive:				; } else if (bikeSpriteStance > 0) {
	cmp.w	d1,d0				; if (bottomRoadDelta > bikeSpriteStance) {
	bgt.s	uBSS.maxDelaySameDirection	; maxDelay = BIKE_SPRITE_STANCE_DELAY_SAME_DIRECTION;
	blt.s	uBSS.maxDelayOtherDirection	; } else if (bottomRoadDelta < bikeSpriteStance) {
	rts					; maxDelay = BIKE_SPRITE_STANCE_DELAY_OTHER_DIRECTION;

uBSS.stanceZero:
	cmp.w	d1,d0				; } else if (bottomRoadDelta != bikeSpriteStance) {
	bne.s	uBSS.maxDelayOtherDirection	; maxDelay = BIKE_SPRITE_STANCE_DELAY_OTHER_DIRECTION;
	rts

uBSS.maxDelaySameDirection:
	move.w	#BIKE_SPRITE_STANCE_DELAY_SAME_DIRECTION,a1
	bra.s	uBSS.checkDelay

uBSS.maxDelayOtherDirection:
	move.w	#BIKE_SPRITE_STANCE_DELAY_OTHER_DIRECTION,a1

uBSS.checkDelay:
	add.w	#1,bikeSpriteStanceDelay(a0)	; bikeSpriteStanceDelay++;
	cmp.w	bikeSpriteStanceDelay(a0),a1	; if (bikeSpriteStanceDelay >= maxDelay) {
	bcs.s	uBSS.delayExceeded
	rts

uBSS.delayExceeded:
	cmp.w	#BIKE_SPRITE_STANCE_DELAY_SAME_DIRECTION,a1	; if (maxDelay == BIKE_SPRITE_STANCE_DELAY_SAME_DIRECTION) {
	bne.s	uBSS.otherDirection
	move.w	d0,bikeSpriteStance(a0)		; bikeSpriteStance = bottomRoadDelta;
	clr.w	bikeSpriteStanceDelay(a0)	; bikeSpriteStanceDelay = 0;
	rts

uBSS.otherDirection:
	cmp.w	d1,d0				; if (bottomRoadDelta > bikeSpriteStance) {
	blt.s	uBSS.substract
	add.w	#1,bikeSpriteStance(a0)		; bikeSpriteStance++;
	clr.w	bikeSpriteStanceDelay(a0)	; bikeSpriteStanceDelay = 0;
	rts
uBSS.substract:
	sub.w	#1,bikeSpriteStance(a0)		; bikeSpriteStance--;
	clr.w	bikeSpriteStanceDelay(a0)	; bikeSpriteStanceDelay = 0;
	rts

_bitmapObjectForObject__8GamePartFPQ2_8GamePart6Objects:
	tst.b	objectIsBike(a1)		; if (object->isBike) {
	beq.s	bOFO.bitmapObject0
	tst.w	d0				; uint16_t deltaFromPlayer = objectX >= 0 ? objectX : -objectX;
	bpl.s	bOFO.deltaFromPlayerPositive
	neg.w	d0
bOFO.deltaFromPlayerPositive:
	cmp.w	#30,d0				; if (deltaFromPlayer < 30) {
	bcs.s	bOFO.bitmapObject0
	cmp.w	#60,d0				; } else if (deltaFromPlayer < 60) {
	bcs.s	bOFO.bitmapObject1
	cmp.w	#90,d0				; } else if (deltaFromPlayer < 90) {
	bcs.s	bOFO.bitmapObject2
	move.l	(objectBitmapObjects+12)(a1),d0	; return object->bitmapObjects[3];
	rts
bOFO.bitmapObject2:
	move.l	(objectBitmapObjects+8)(a1),d0	; return object->bitmapObjects[2];
	rts
bOFO.bitmapObject1:
	move.l	(objectBitmapObjects+4)(a1),d0	; return object->bitmapObjects[1];
	rts
bOFO.bitmapObject0:
	move.l	objectBitmapObjects(a1),d0	; return object->bitmapObjects[0];
	rts

_bikeSpriteForStance__8GamePartFl:
	addq.l	#3,d0
	bmi.s	bSFS.bikeSpriteStanceLow
	cmp.w	#7,d0
	bcs.s	bSFS.bikeSpriteStanceOk
	moveq	#6,d0
bSFS.bikeSpriteStanceLow:
	moveq	#0,d0
bSFS.bikeSpriteStanceOk:
	lsl.w	#6,d0
	add.w	#bikeSpriteRight3,d0
	add.l	a0,d0
	rts

_moveObjectsTowardsCamera__8GamePartFv:
	move.w	zDelta(a0),d0
	lea	objects(a0),a1
	moveq	#MAX_OBJECTS-1,d1
mOTC.loop:
	cmp.w	#Z_MIN,objectZ(a1)
	bcs.s	mOTC.nextObject
	tst.b	objectIsBike(a1)
	bne.s	mOTC.objectIsBike
	sub.w	d0,objectZ(a1)
	bra.s	mOTC.nextObject
mOTC.objectIsBike:
	sub.w	#350,objectZ(a1)
mOTC.nextObject:
	lea	objectSizeOf(a1),a1
	dbra	d1,mOTC.loop
	rts

_updateRoadGeometry__8GamePartFv:
	movem.l	d2-d3/a2-a3,-(sp)

	move.w	zPosition(a0),d0		; uint16_t start = zPosition >> 7;
	move.w	d0,d1				; uint16_t end = (zPosition + zDelta) >> 7;
	add.w	zDelta(a0),d1
	bcs.s	uRG.pastBufferEnd
	moveq	#-1,d3				; loop 2 count: 0
	swap	d3
	lsr.w	#7,d0
	lsr.w	#7,d1
	sub.w	d0,d1				; loop 1 count: end-start
	subq	#1,d1				; (-1 for dbra)
	move.w	d1,d3
	bra.s	uRG.loopCountOk

uRG.pastBufferEnd:
	lsr.w	#7,d1				; loop 2 count: after the end of the buffer
	subq	#1,d1
	move.w	d1,d3
	swap	d3
	move.w	#512-1,d3			; loop 1 count: up to the end of the buffer
	lsr.w	#7,d0
	sub.w	d0,d3
uRG.loopCountOk:

	move.l	roadGeometry(a0),a1
	add.w	d0,d0
	add.w	d0,a1
	lea	_sin__4Util,a2
	lea	2048(a2),a3
	move.w	roadAngle(a0),d1
	add.w	d1,d1
	add.w	d1,a2
	move.w	(a2)+,d0			; int16_t roadSin = Util::sin[roadAngle++ & 1023];
	tst.w	d3
	bmi.s	uRG.loop1Done
uRG.loop1:
	cmp.l	a3,a2
	bcs.s	uRG.sinOk1
	lea	-2048(a2),a2
uRG.sinOk1:
	move.w	(a2)+,d1			; roadDelta = (int16_t)(Util::sin[roadAngle & 1023] - roadSin);
	move.w	d1,d2
	sub.w	d0,d2
	asr.w	#8,d0				; roadGeometry[i & 511] = (int16_t)(roadSin >> 9);
	asr.w	#1,d0
	move.w	d0,(a1)+
	move.w	d1,d0
	dbra	d3,uRG.loop1

uRG.loop1Done:
	swap	d3
	tst.w	d3
	bmi.s	uRG.loop2Done
	move.l	roadGeometry(a0),a1
uRG.loop2:
	cmp.l	a3,a2
	bcs.s	uRG.sinOk2
	lea	-2048(a2),a2
uRG.sinOk2:
	move.w	(a2)+,d1
	move.w	d1,d2
	sub.w	d0,d2
	asr.w	#8,d0
	asr.w	#1,d0
	move.w	d0,(a1)+
	move.w	d1,d0
	dbra	d3,uRG.loop2

uRG.loop2Done:
	move.l	a2,d0
	sub.l	#_sin__4Util+2,d0
	lsr.w	#1,d0
	move.w	d0,roadAngle(a0)

	move.w	d2,d0				; return roadDelta;

	movem.l	(sp)+,d2-d3/a2-a3
	rts

_renderObject__8GamePartFRCQ2_8GamePart6ROArgsRC7Point2D:
	movem.l	d2-d7/a2-a5,-(sp)

	move.l	(a3)+,a1		; bitmap
	move.l	(a3)+,a2		; mask
	move.l	(a3),a3			; object

	move.b	#1,objectIsRendered(a3)	; object->isRendered = true;

	move.w	bitmapWidth(a1),d2

	move.w	#SCREEN_WIDTH/2,d0	; int16_t x1 = SCREEN_WIDTH / 2 + objectPos.x;
	add.w	point2DX(a4),d0
	move.w	#OBJECTS_SKY_HEIGHT,d1		; int16_t y1 = OBJECTS_SKY_HEIGHT + objectPos.y - bitmap->height;
	add.w	point2DY(a4),d1
	sub.w	bitmapHeight(a2),d1
	tst.b	objectAnchorRight(a3)	; if (object->anchorRight) {
	beq.s	rO.anchorOk
	sub.w	d2,d0			; x1 -= bitmap->width;
rO.anchorOk:
	move.w	d0,d6			; int16_t x2 = x1 + bitmap->width;
	add.w	d2,d6
	move.w	d1,d7			; int16_t y2 = y1 + bitmap->height;
	add.w	bitmapHeight(a2),d7

	neg.w	d2			; if (x1 > -bitmap->width && x1 < OBJECTS_WIDTH && y1 < OBJECTS_HEIGHT) {
	cmp.w	d2,d0
	ble	rO.done
	cmp.w	#OBJECTS_WIDTH,d0
	bge	rO.done
	cmp.w	#OBJECTS_HEIGHT,d1
	bge	rO.done
	moveq	#0,d2			; uint16_t sourceX = 0;
	moveq	#0,d3			; uint16_t sourceY = 0;

	tst.w	d0			; if (x1 < 0) {
	bpl.s	rO.x1Positive
	sub.w	d0,d2			; sourceX -= x1;
	moveq	#0,d0			; x1 = 0;
	bra.s	rO.xOk
rO.x1Positive:
	cmp.w	#OBJECTS_WIDTH,d6	; } else if (x2 > OBJECTS_WIDTH) {
	ble.s	rO.xOk
	move.w	#OBJECTS_WIDTH,d6	; x2 = OBJECTS_WIDTH;
rO.xOk:

	tst.w	d1			; if (y1 < 0) {
	bge.s	rO.y1Positive
	sub.w	d1,d3			; sourceY -= y1;
	moveq	#0,d1			; y1 = 0;
	bra.s	rO.yOk
rO.y1Positive:
	cmp.w	#OBJECTS_HEIGHT,d7	; } else if (y2 > OBJECTS_HEIGHT) {
	ble.s	rO.yOk
	move.w	#OBJECTS_HEIGHT,d7	; y2 = OBJECTS_HEIGHT;
rO.yOk:

	cmp.w	d6,d0			; if (x1 < x2 && y1 < y2) {
	bge	rO.done
	cmp.w	d7,d1
	bge	rO.done

	move.w	d0,rO.boundingRectTopLeftX
	move.w	d1,rO.boundingRectTopLeftY
	subq	#1,d6
	subq	#1,d7
	move.w	d6,rO.boundingRectBottomRightX
	move.w	d7,rO.boundingRectBottomRightY

	move.l	a0,a5
	move.l	renderTargetObjectsBitmap(a0),a0	; renderTargetObjectsBitmap->copyWithMask(*bitmap, *mask, x1, y1, sourceX, sourceY, sourceX, sourceY, x2 - x1, y2 - y1);
	move.w	d2,d4
	move.w	d3,d5
	sub.w	d0,d6
	sub.w	d1,d7
	addq	#1,d6
	addq	#1,d7
	sub.l	a3,a3
	bsr	_copyWithMask__6BitmapFRC6BitmapRC6BitmapUsUsUsUsUsUsUsUsUc

	move.l	previousBoundingRect(a5),a0
	lea	rO.boundingRect,a1
	bsr	_unite__4RectFRC4Rect

	move.l	a5,a0
rO.done:
	movem.l	(sp)+,d2-d7/a2-a5
	rts

rO.boundingRect:
rO.boundingRectTopLeftX:	dc.w	0
rO.boundingRectTopLeftY:	dc.w	0
rO.boundingRectBottomRightX:	dc.w	0
rO.boundingRectBottomRightY:	dc.w	0

_updateSpeedText__8GamePartFv:
	move.l	d2,-(sp)

	move.w	zDelta(a0),d1	; uint16_t doubleDelta = (zDelta << 1);
	add.w	d1,d1
	move.w	d1,d0		; uint16_t speed = (doubleDelta + doubleDelta + doubleDelta) >> 4;
	add.w	d1,d0
	add.w	d1,d0
	lsr.w	#4,d0
	move.w	d0,d1		; uint16_t remaining = speed;
	move.l	_speedText,a1

	moveq	#0,d2		; int8_t value = 0;
	cmp.w	#100,d1		; if (speed >= 100) {
	bcc.s	uSpT.100sLoop
	move.b	#' ',(a1)+	; speedText[0] = ' ';
	bra.s	uSpT.100sDone
uSpT.100sLoop:
	cmp.w	#100,d0		; while (remaining >= 100) {
	bcs.s	uSpT.100sCounted
	addq	#1,d2		; value++;
	sub.w	#100,d0		; remaining -= 100;
	bra.s	uSpT.100sLoop
uSpT.100sCounted:
	add.b	#'0',d2		; speedText[0] = (char)('0' + value);
	move.b	d2,(a1)+
uSpT.100sDone:

	moveq	#0,d2
	cmp.w	#10,d1
	bcc.s	uSpT.10sLoop
	move.b	#' ',(a1)+
	bra.s	uSpT.10sDone
uSpT.10sLoop:
	cmp.w	#10,d0
	bcs.s	uSpT.10sCounted
	addq	#1,d2
	sub.w	#10,d0
	bra.s	uSpT.10sLoop
uSpT.10sCounted:
	add.b	#'0',d2
	move.b	d2,(a1)+
uSpT.10sDone:

	add.b	#'0',d0		; speedText[2] = (char)('0' + remaining);
	move.b	d0,(a1)

	move.l	(sp)+,d2
	rts

_updateScoreText__8GamePartFPcUl:
	move.l	d2,-(sp)

	move.l	d0,d1			; uint32_t remaining = score;

	moveq	#0,d2			; int8_t value = 0;
	cmp.l	#10000000,d1		; if (score >= 10000000) {
	bcc.s	uScT.10000000sLoop
	move.b	#' ',(a1)+		; scoreText[0] = ' ';
	bra.s	uScT.10000000sDone
uScT.10000000sLoop:
	cmp.l	#10000000,d0		; while (remaining >= 10000000) {
	bcs.s	uScT.10000000sCounted
	addq	#1,d2			; value++;
	sub.l	#10000000,d0		; remaining -= 10000000;
	bra.s	uScT.10000000sLoop
uScT.10000000sCounted:
	add.b	#'0',d2			; scoreText[0] = (char)('0' + value);
	move.b	d2,(a1)+
uScT.10000000sDone:

	moveq	#0,d2
	cmp.l	#1000000,d1
	bcc.s	uScT.1000000sLoop
	move.b	#' ',(a1)+
	bra.s	uScT.1000000sDone
uScT.1000000sLoop:
	cmp.l	#1000000,d0
	bcs.s	uScT.1000000sCounted
	addq	#1,d2
	sub.l	#1000000,d0
	bra.s	uScT.1000000sLoop
uScT.1000000sCounted:
	add.b	#'0',d2
	move.b	d2,(a1)+
uScT.1000000sDone:

	moveq	#0,d2
	cmp.l	#100000,d1
	bcc.s	uScT.100000sLoop
	move.b	#' ',(a1)+
	bra.s	uScT.100000sDone
uScT.100000sLoop:
	cmp.l	#100000,d0
	bcs.s	uScT.100000sCounted
	addq	#1,d2
	sub.l	#100000,d0
	bra.s	uScT.100000sLoop
uScT.100000sCounted:
	add.b	#'0',d2
	move.b	d2,(a1)+
uScT.100000sDone:

	moveq	#0,d2
	cmp.l	#10000,d1
	bcc.s	uScT.10000sLoop
	move.b	#' ',(a1)+
	bra.s	uScT.10000sDone
uScT.10000sLoop:
	cmp.l	#10000,d0
	bcs.s	uScT.10000sCounted
	addq	#1,d2
	sub.l	#10000,d0
	bra.s	uScT.10000sLoop
uScT.10000sCounted:
	add.b	#'0',d2
	move.b	d2,(a1)+
uScT.10000sDone:

	moveq	#0,d2
	cmp.l	#1000,d1
	bcc.s	uScT.1000sLoop
	move.b	#' ',(a1)+
	bra.s	uScT.1000sDone
uScT.1000sLoop:
	cmp.w	#1000,d0
	bcs.s	uScT.1000sCounted
	addq	#1,d2
	sub.w	#1000,d0
	bra.s	uScT.1000sLoop
uScT.1000sCounted:
	add.b	#'0',d2
	move.b	d2,(a1)+
uScT.1000sDone:

	moveq	#0,d2
	cmp.l	#100,d1
	bcc.s	uScT.100sLoop
	move.b	#' ',(a1)+
	bra.s	uScT.100sDone
uScT.100sLoop:
	cmp.w	#100,d0
	bcs.s	uScT.100sCounted
	addq	#1,d2
	sub.w	#100,d0
	bra.s	uScT.100sLoop
uScT.100sCounted:
	add.b	#'0',d2
	move.b	d2,(a1)+
uScT.100sDone:

	moveq	#0,d2
	cmp.l	#10,d1
	bcc.s	uScT.10sLoop
	move.b	#' ',(a1)+
	bra.s	uScT.10sDone
uScT.10sLoop:
	cmp.w	#10,d0
	bcs.s	uScT.10sCounted
	addq	#1,d2
	sub.w	#10,d0
	bra.s	uScT.10sLoop
uScT.10sCounted:
	add.b	#'0',d2
	move.b	d2,(a1)+
uScT.10sDone:

	move.l	(sp)+,d2
	rts

_writeText__8GamePartFPCcUsUsUs:
	movem.l	d2-d5/d7/a2-a5,-(sp)

	move.l	headerBitmap(a0),a2
	move.w	bitmapWidthInBytes(a2),d3	; uint16_t bytesPerPlaneRow = headerBitmap->widthInBytes;
	move.w	bitmapRowSizeInBytes(a2),d4	; uint16_t bytesPerRow = headerBitmap->rowSizeInBytes;
	move.l	bitmapData(a2),a2		; uint8_t* destStart = (uint8_t*)headerBitmap->data + y * bytesPerRow + (x >> 3) + 2;
	mulu	d4,d1
	lsr.w	#3,d0
	add.w	d1,d0
	addq	#2,d0
	add.w	d0,a2

	lea	writeTextFontCopiers,a5
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a5,d2.w),a5
wT.loop:					; for (const char* c = text; *c; c++) {
	moveq	#0,d0
	move.b	(a1)+,d0
	beq	wT.done

	lea	_font,a4
	sub.b	#' ',d0				; uint16_t fontOffset = (*c - ' ') << 4;
	lsl.w	#4,d0
	add.w	d0,a4
	move.l	a2,a3				; uint8_t* dest1 = destStart1++;
	addq	#1,a2
	jsr	(a5)
	bra	wT.loop

wT.done:
	movem.l	(sp)+,d2-d5/d7/a2-a5
	rts

writeScore:
	movem.l	d2-d7/a2-a5,-(sp)

	move.l	headerBitmap(a0),a2
	move.w	bitmapWidthInBytes(a2),d4	; uint16_t bytesPerPlaneRow = headerBitmap->widthInBytes;
	move.w	bitmapRowSizeInBytes(a2),d5	; uint16_t bytesPerRow = headerBitmap->rowSizeInBytes;
	move.l	bitmapData(a2),a2		; uint8_t* destStart = (uint8_t*)headerBitmap->data + y * bytesPerRow + (x >> 3) + 2;
	mulu	d5,d1
	lsr.w	#3,d0
	add.w	d1,d0
	addq	#2,d0
	add.w	d0,a2

	lea	writeTextFontCopiers,a5
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a5,d2.w),a5

	move.l	d3,d2
	move.l	d4,d3

	moveq	#7-1,d6
wS.loop:
	move.w	d2,d0
	and.w	#$f,d0
	add.w	#'0'-' ',d0
	lea	_font,a4
	lsl.w	#4,d0
	add.w	d0,a4
	move.l	a2,a3
	subq	#1,a2
	jsr	(a5)
	lsr.l	#4,d2
	beq	wS.done
	dbra	d6,wS.loop

wS.done:
	movem.l	(sp)+,d2-d7/a2-a5
	rts

writeTextFontCopiers:
	dc.l	writeTextCopyFont0
	dc.l	writeTextCopyFont1
	dc.l	writeTextCopyFont2
	dc.l	writeTextCopyFont3
	dc.l	writeTextCopyFont4
	dc.l	writeTextCopyFont5
	dc.l	writeTextCopyFont6
	dc.l	writeTextCopyFont7

writeTextCopyFont0:
	moveq	#8-1,d7				; for (uint16_t i = 0; i < 8; i++) {
wT.yLoop0:
	move.b	(a4)+,d4			; uint8_t fontBitplane1 = font[fontOffset++];
	move.b	(a4)+,d5			; uint8_t fontBitplane2 = font[fontOffset++];
	clr.b	(a3)				; *dest = bitplane1;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	move.b	d5,(a3)				; *dest = bitplane2;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	clr.b	(a3)				; *dest = bitplane3;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	dbra	d7,wT.yLoop0			; }
	rts

writeTextCopyFont1:
	moveq	#8-1,d7				; for (uint16_t i = 0; i < 8; i++) {
wT.yLoop1:
	move.b	(a4)+,d4			; uint8_t fontBitplane1 = font[fontOffset++];
	move.b	(a4)+,d5			; uint8_t fontBitplane2 = font[fontOffset++];
	move.b	d4,(a3)				; *dest = bitplane1;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	move.b	d5,(a3)				; *dest = bitplane2;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	clr.b	(a3)				; *dest = bitplane3;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	dbra	d7,wT.yLoop1
	rts

writeTextCopyFont2:
	moveq	#8-1,d7				; for (uint16_t i = 0; i < 8; i++) {
wT.yLoop2:
	move.b	(a4)+,d4			; uint8_t fontBitplane1 = font[fontOffset++];
	move.b	(a4)+,d5			; uint8_t fontBitplane2 = font[fontOffset++];
	clr.b	(a3)				; *dest = bitplane1;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	or.b	d4,d5
	move.b	d5,(a3)				; *dest = bitplane2;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	clr.b	(a3)				; *dest = bitplane3;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	dbra	d7,wT.yLoop2
	rts

writeTextCopyFont3:
	moveq	#8-1,d7				; for (uint16_t i = 0; i < 8; i++) {
wT.yLoop3:
	move.b	(a4)+,d4			; uint8_t fontBitplane1 = font[fontOffset++];
	move.b	(a4)+,d5			; uint8_t fontBitplane2 = font[fontOffset++];
	move.b	d4,(a3)				; *dest = bitplane1;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	or.b	d4,d5
	move.b	d5,(a3)				; *dest = bitplane2;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	clr.b	(a3)				; *dest = bitplane3;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	dbra	d7,wT.yLoop3
	rts

writeTextCopyFont4:
	moveq	#8-1,d7				; for (uint16_t i = 0; i < 8; i++) {
wT.yLoop4:
	move.b	(a4)+,d4			; uint8_t fontBitplane1 = font[fontOffset++];
	move.b	(a4)+,d5			; uint8_t fontBitplane2 = font[fontOffset++];
	clr.b	(a3)				; *dest = bitplane1;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	move.b	d5,(a3)				; *dest = bitplane2;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	move.b	d4,(a3)				; *dest = bitplane3;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	dbra	d7,wT.yLoop4			; }
	rts

writeTextCopyFont5:
	moveq	#8-1,d7				; for (uint16_t i = 0; i < 8; i++) {
wT.yLoop5:
	move.b	(a4)+,d4			; uint8_t fontBitplane1 = font[fontOffset++];
	move.b	(a4)+,d5			; uint8_t fontBitplane2 = font[fontOffset++];
	move.b	d4,(a3)				; *dest = bitplane1;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	move.b	d5,(a3)				; *dest = bitplane2;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	move.b	d4,(a3)				; *dest = bitplane3;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	dbra	d7,wT.yLoop5
	rts

writeTextCopyFont6:
	moveq	#8-1,d7				; for (uint16_t i = 0; i < 8; i++) {
wT.yLoop6:
	move.b	(a4)+,d4			; uint8_t fontBitplane1 = font[fontOffset++];
	move.b	(a4)+,d5			; uint8_t fontBitplane2 = font[fontOffset++];
	clr.b	(a3)				; *dest = bitplane1;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	or.b	d4,d5
	move.b	d5,(a3)				; *dest = bitplane2;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	move.b	d4,(a3)				; *dest = bitplane3;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	dbra	d7,wT.yLoop6
	rts

writeTextCopyFont7:
	moveq	#8-1,d7				; for (uint16_t i = 0; i < 8; i++) {
wT.yLoop7:
	move.b	(a4)+,d4			; uint8_t fontBitplane1 = font[fontOffset++];
	move.b	(a4)+,d5			; uint8_t fontBitplane2 = font[fontOffset++];
	or.b	d4,d5
	move.b	d4,(a3)				; *dest = bitplane1;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	move.b	d5,(a3)				; *dest = bitplane2;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	move.b	d4,(a3)				; *dest = bitplane3;
	add.w	d3,a3				; dest += bytesPerPlaneRow;
	dbra	d7,wT.yLoop7
	rts

_updateScroller__8GamePartFv:
	move.l	a2,-(sp)
	move.l	a0,a2

	move.w	scrollerXOffset(a2),d0
	add.w	#1,d0				; scrollerXOffset++;
	move.w	d0,scrollerXOffset(a2)
	lea	copperList1(a2),a0		; copperList1.setScrollerXOffset(~scrollerXOffset);
	bsr	@setScrollerXOffset__14GameCopperListFUs

	lea	copperList2(a2),a0		; copperList2.setScrollerXOffset(~scrollerXOffset);
	move.w	scrollerXOffset(a2),d0
	bsr	@setScrollerXOffset__14GameCopperListFUs

	move.l	(sp)+,a2
	rts

_updateCamera__8GamePartFv:
	move.w	d2,-(sp)

	move.w	zPosition(a0),d2		; zPosition += zDelta;
	add.w	zDelta(a0),d2
	move.w	d2,zPosition(a0)

	move.w	bottomRoadX(a0),d1		; int16_t oldBottomRoadX = bottomRoadX;
	move.l	roadLineZ(a0),a1		; uint16_t bottomZ = roadLineZ[ROAD_HEIGHT - 1] + zPosition;
	move.w	2*ROAD_HEIGHT-2(a1),d0
	add.w	d2,d0
	move.l	roadGeometry(a0),a1		; bottomRoadX = roadGeometry[bottomZ >> 7];
	lsr.w	#7,d0
	add.w	d0,d0
	move.w	(a1,d0.w),d0
	move.w	d0,bottomRoadX(a0)

	sub.w	d1,d0				; int16_t bottomRoadDelta = bottomRoadX - oldBottomRoadX;
	add.w	d0,xPosition(a0)		; xPosition += bottomRoadDelta;
	sub.w	d0,horizonBackX(a0)		; horizonBackX -= bottomRoadDelta;
	sub.w	d0,horizonFrontX(a0)		; horizonFrontX -= bottomRoadDelta << 1;
	sub.w	d0,horizonFrontX(a0)

    	move.w	(sp)+,d2
	rts					; return bottomRoadDelta;

_clearRenderTargetObjectsBitmap__8GamePartFv:
	move.l	previousBoundingRect(a0),a1	; if (!previousBoundingRect->isEmpty) {
	tst.b	rectIsEmpty(a1)
	beq.s	cRTOB.clear
	rts

cRTOB.clear:
	movem.l	d2-d3/a1,-(sp)

	move.w	rectTopLeftX(a1),d0		; uint16_t rectX = previousBoundingRect->topLeft.x & 0xfff0;
	and.w	#$fff0,d0
	move.w	rectTopLeftY(a1),d1		; uint16_t rectY = previousBoundingRect->topLeft.y;
	move.w	rectBottomRightX(a1),d2		; uint16_t rectWidth = ((previousBoundingRect->bottomRight.x + 16) & 0xfff0) - rectX;
	add.w	#16,d2
	and.w	#$fff0,d2
	sub.w	d0,d2
	move.w	rectHeight(a1),d3		; uint16_t rectHeight = previousBoundingRect->height;
	move.l	renderTargetObjectsBitmap(a0),a0	; renderTargetObjectsBitmap->clear(rectX, rectY, rectWidth, rectHeight);
	bsr	_clear__6BitmapFUsUsUsUs

	movem.l	(sp)+,d2-d3/a1

	move.l	#$7fff7fff,(a1)+		; *previousBoundingRect = Rect();
	move.l	#$80008000,(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	move.w	#$0101,(a1)+

	rts

	dc.l	0
abcdScoreAdd:
	dc.w	0

_updateScore__8GamePartFv:
	movem.l	d2-d3/a2,-(sp)

	lea	abcdScoreAdd,a2
	lea	2(a2),a1
	move.w	(a2),d0
	addq	#1,d0
	and.w	#3,d0
	move.w	d0,(a2)
	cmp.w	#1,d0
	bne.s	uS.scoreAddOk
	cmp.w	#$303,-2(a2)
	bcc.s	uS.scoreAddOk
	move.w	#0,ccr
	abcd	-(a1),-(a2)
	abcd	-(a1),-(a2)
	addq	#2,a2

uS.scoreAddOk:
	lea	score+4(a0),a0				; score += zDelta;
	move.w	#0,ccr
	abcd	-(a2),-(a0)
	abcd	-(a2),-(a0)
	abcd	-(a2),-(a0)
	abcd	-(a2),-(a0)
	lea	-score(a0),a0

	move.w	#224+6*8,d0
	moveq	#5,d1
	moveq	#6,d2
	move.l	score(a0),d3
	bsr	writeScore				; writeText(scoreText, 224, 5, 6);

	cmp.l	topScore(a0),d3				; if (score > topScore) {
	bls.s	uS.noTopScore
	move.l	d3,topScore(a0)				; topScore = score;
	move.w	#40+6*8,d0
	moveq	#5,d1
	moveq	#4,d2
	bsr	writeScore				; writeText(topScoreText, 40, 5, 4);

uS.noTopScore:
	movem.l	(sp)+,d2-d3/a2
	rts

_spawnRoadSideObjects__8GamePartFv:
	move.w	distanceToPreviousRoadsideObject(a0),d1	; distanceToPreviousRoadsideObject += zDelta;
	add.w	zDelta(a0),d1
	cmp.w	#ROADSIDE_OBJECT_DISTANCE,d1		; if (distanceToPreviousRoadsideObject >= ROADSIDE_OBJECT_DISTANCE) {
	bcc.s	sRSO.spawn
	move.w	d1,distanceToPreviousRoadsideObject(a0)
	rts

sRSO.spawn:
	sub.w	#ROADSIDE_OBJECT_DISTANCE,d1		; distanceToPreviousRoadsideObject -= ROADSIDE_OBJECT_DISTANCE;
	move.w	d1,distanceToPreviousRoadsideObject(a0)

	lea	objects(a0),a1				; for (uint16_t i = 0; i < MAX_OBJECTS; i++) {
	moveq	#MAX_OBJECTS-1,d1
sRSO.findUnusedObjectLoop:
	cmp.w	#Z_MIN,objectZ(a1)			; if (objects[i].z < Z_MIN) {
	bcs.s	sRSO.objectFound
	lea	objectSizeOf(a1),a1
	dbra	d1,sRSO.findUnusedObjectLoop
	rts

sRSO.objectFound:
	move.l	a2,-(sp)

	cmp.w	#-100,d0				; ; if (roadDelta > -100 && roadDelta < 100) {
	ble.s	sRSO.spawnSign
	cmp.w	#100,d0
	bhs.s	sRSO.spawnSign
	move.l	tree(a0),objectBitmapObjects(a1)	; objects[i].bitmapObjects[0] = tree;
	tst.w	d0					; objects[i].x = (int16_t)(roadDelta > 0 ? 224 : -224);
	bmi.s	sRSO.spawnTreeRight
	beq.s	sRSO.spawnTreeRight
	move.w	#224,objectX(a1)
	clr.b	objectAnchorRight(a1)
	bra.s	sRSO.objectSelected
sRSO.spawnTreeRight:
	move.w	#-224,objectX(a1)
	move.b	#1,objectAnchorRight(a1)
	bra.s	sRSO.objectSelected

sRSO.spawnSign:
	tst.w	d0					; objects[i].bitmapObjects[0] = roadDelta > 0 ? left : right;
	bmi.s	sRSO.spawnSignRight
	beq.s	sRSO.spawnSignRight
	move.l	left(a0),objectBitmapObjects(a1)
	move.w	#224,objectX(a1)
	clr.b	objectAnchorRight(a1)
	bra.s	sRSO.objectSelected
sRSO.spawnSignRight:
	move.l	right(a0),objectBitmapObjects(a1)
	move.w	#-224,objectX(a1)
	move.b	#1,objectAnchorRight(a1)

sRSO.objectSelected:
	move.w	#Z_MAX,objectZ(a1)			; objects[i].z = Z_MAX;
	clr.b	objectIsBike(a1)			; objects[i].isBike = false;

	move.l	(sp)+,a2
	rts

	end

; Turbo assembler-routines (originally for AmiHockey)
; Modified a little bit for Radiation...
; Date: 14-Aug-1998  Lennart Johannesson!
; 
	XDEF  _TurboBltBitMap

	incdir   'asminclude:'
	include  'graphics/gfx.i'
	section  code,code

; d0.l   ypos-source in bitmap
; a0  Source-BitMap(RAW DATA IN FASTMEM!)
; a1  Destination-BitMap

_TurboBltBitMap
TurboBltBitMap
	movem.l d2-d7/a2-a6,-(sp)

	moveq    #0, d1 ; Antalet Plan -1 skall läggas in i d1

	lsl.l    #3, d0 ; 4 rader replace:ar  mulu   #40, d0
	move.l   d0, d2
	lsl.l    #2, d0
	add.l    d2, d0

	add.l    d0, a0 ; Letar upp rätt rad i bitmappen in i a0

	add.l      #(4*7), a1 ; VI SKALL BARA ÅT SISTA PLANET I DETTA DEMO!!!

.newplane
	move.l   a0,a3  ; Pointer To Source-Plane!
	move.l   bm_Planes(a1),a4  ; Pointer To Dest-Plane!

	move.l   #2559, d3 ; Antalet longword per plan att kopiera
 
.process
;  move.l    (a3)+, (a4)+ ; Dessa 3 linjer är snabbare? än "move.l (a3)+, (a4)+"
  move.l    (a3), (a4)
  addq      #4, a3
  addq      #4, a4
  dbf       d3, .process

  addq      #4, a1
  add.l     #21840, a0 ; 320*546/8
  dbf       d1, .newplane

.exit movem.l  (sp)+,d2-d7/a2-a6
	rts


;addq
;move.l (a0)+, (a1+)

;<Azure> move.l d0,d1
;<Azure> lsl.l #2,d0
;<Azure> add.l d0,d1
;<Kalsu> yeah.. better to make it moveq #1,d0; moveq #16,d1; ror.l d1,d0
;<Azure> lsl.l #3,d1
;<Kalsu> :D
;<Azure> 12 cycles.. faster than that mulu on 030..

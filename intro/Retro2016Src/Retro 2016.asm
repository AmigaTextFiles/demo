;APSFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
* Retro Intro 2016, Coded by Legionary / Oldsk00l Crackers.

* For use as normal exe file, just assemble and write as object (WO in asmone).
* Don't forget to change "Incdir" to whatever you have the source data.

		Section	'OldSk00l Crackers Code',Code_c

		Incdir	'Dh0:OldSk00l Crackers/'

Start		Movem.l	d0-a6,-(a7)
		Move.l	#Prog,$80.w
		Trap	#0
		Movem.l	(a7)+,d0-a6
		Moveq	#0,d0
		Rts

Prog		Move.l	$4.W,a6
		Lea	Gfxname,a1
		Moveq	#33,d0
		Jsr	-552(a6)
		Move.l	d0,Gfxbase
		Move.l	Gfxbase,a1
		Jsr	-414(a6)
		Move.l	Gfxbase,a6
		Move.l	34(a6),Oldview
		Move.l	38(a6),Oldcop
		Sub.l	a1,a1
		Jsr	-222(a6)		; Loadview
		Jsr	-270(a6)		; WaitTOF
		Jsr	-270(a6)		; WaitTOF
		Move.l	#Copper,$dff080
		Move.w	#$DEAD,$dff088
		Move.w	#$c00,$dff106
		Move.w	#0,$dff1fc
		Move.w	#$11,$dff10c
		Lea	Bplpointers,a0
		Move.l	#Screen,d0
		Moveq	#4,d7

Setallplanes	Move.w	d0,6(a0)
		Swap	d0
		Move.w	d0,2(a0)
		Swap	d0
		Addq.w	#8,a0
		Add.l	#10240,d0
		Dbf	d7,Setallplanes
		Lea	Sprpointers,a0
		Move.l	Sprite,d0
		Moveq	#7,d7

Setallsprites	Move.w	d0,6(a0)
		Swap	d0
		Move.w	d0,2(a0)
		Swap	d0
		Addq.w	#8,a0
		Dbf	d7,Setallsprites
		Move.w	$dff002,OldDma
		Move.w	$dff010,OldAdk
		Move.w	$dff01c,OldInta
		Move.w	#$7fff,$dff09a
		Lea	Module,a0
		Bsr	Mt_Init
		Move.w	#$7fff,$dff096
		Move.l	$6c,OldInt
		Move.l	#MusicInt,$6c
		Move.w	#$7fff,$dff09c
		Move.w	#$83f0,$dff096
		Move.w	#$c020,$dff09a
		Bsr	SetBorders
		Bsr	SetCoderLogo
		Bsr	SetOSCLogo
		Bsr	SetSkull
		Bsr	Writer

Main		Btst	#6,$bfe001
		Bne	Main

		Bsr	Mt_End
		Move.w	#$7fff,$dff09a
		Move.w	#$7fff,$dff096
		Move.l	Oldint,$6c
		Move.w	OldDma,d0
		Or.w	#$8000,d0
		Move.w	d0,$dff096
		Move.w	OldAdk,d0
		Or.w	#$8000,d0
		Move.w	d0,$dff09e
		Move.w	Oldinta,d0
		Or.w	#$c000,d0
		Move.w	#$7fff,$dff09c
		Move.w	d0,$dff09a
		Move.l	Gfxbase,a6
		Move.l	Oldview,a1
		Jsr	-222(a6)		; Loadview
		Jsr	-270(a6)		; WaitTOF
		Jsr	-270(a6)		; WaitTOF
		Move.l	Oldcop,$dff080
		Rte

MusicInt	Movem.l	d0-a6,-(a7)
		Move.w	#$20,$dff09c
		Bsr	Mt_Music
		Movem.l	(a7)+,d0-a6
		Rte

Bltw		Btst	#14,$dff002
Bltw2		Btst	#14,$dff002
		Bne	Bltw2
		Rts

SetBorders	Lea	Borders,a0
		Lea	Screen+40*14,a1
		Move.l	a1,a2
		Bsr	Bltw
		Movem.l	a0/a1,$dff050
		Move.l	#0,$dff064
		Move.l	#$9f00000,$dff040
		Move.l	#-1,$dff044
		Move.w	#16*64+20,$dff058
		Lea	640(a0),a0
		Lea	40*216(a2),a2
		Bsr	Bltw
		Movem.l	a0/a2,$dff050
		Move.l	#0,$dff064
		Move.l	#$9f00000,$dff040
		Move.l	#-1,$dff044
		Move.w	#16*64+20,$dff058
		Rts

SetCoderLogo	Lea	LegionaryLogo,a0
		Lea	Screen+40*242,a1 ;234
		Moveq	#3,d7

NextPlane	Bsr	Bltw
		Movem.l	a0/a1,$dff050
		Move.l	#34,$dff064
		Move.l	#$9f00000,$dff040
		Move.l	#-1,$dff044
		Move.w	#4*64+3,$dff058
		Lea	6*4(a0),a0
		Lea	40*256(a1),a1
		Dbf	d7,NextPlane
		Rts

SetSkull	Lea	Skull,a0
		Lea	Screen+40*80+14,a2
		Moveq	#2,d7

NextSkullPlane	Bsr	Bltw
		Movem.l	a0/a2,$dff050
		Move.l	#30,$dff064
		Move.l	#$9f00000,$dff040
		Move.l	#-1,$dff044
		Move.w	#69*64+5,$dff058
		Lea	10*69(a0),a0
		Lea	40*256(a2),a2
		Dbf	d7,NextSkullPlane
		Rts

SetOSCLogo	Lea	OSCLogo,a0
		Lea	Screen+6,a1 ;40*20+6
		Moveq	#2,d7

NextPlane2	Bsr	Bltw
		Movem.l	a0/a1,$dff050
		Move.l	#12,$dff064
		Move.l	#$9f00000,$dff040
		Move.l	#-1,$dff044
		Move.w	#16*64+14,$dff058
		Lea	28*16(a0),a0
		Lea	40*256(a1),a1
		Dbf	d7,NextPlane2
		Rts

Writer		Lea	Text,a0
		Moveq	#0,d1
		Move.w	#40*36,d2
		Moveq	#18,d7

NextLine	Moveq	#39,d6

NextChar	Lea	Font,a1
		Lea	Screen+10240*4,a2
		Moveq	#0,d0
		Move.b	(a0)+,d0
		Sub.b	#32,d0
		Add.w	d0,a1
		Add.w	d1,a2
		Add.w	d2,a2
		Moveq	#7,d5

PrintChar	Move.b	(a1),(a2)
		Add.w	#96,a1
		Add.w	#40,a2
		Dbf	d5,PrintChar
		Addq.w	#1,d1
		Dbf	d6,NextChar
		Moveq	#0,d1
		Add.w	#40*10,d2
		Dbf	d7,NextLine
		Rts

		Include	'Replayers/Protracker v1.1a 100% PC.asm'

Copper		Dc.w	$0100,$5000,$008e,$2c81,$0090,$2cc1,$0092,$0038
		Dc.w	$0094,$00d0,$0096,$83f0,$0102,$0000,$0104,$0000
		Dc.w	$0106,$0000,$0108,$0000,$010a,$0000,$01fc,$0000
		Dc.w	$010c,$0011
;203,315
Colors
		Dc.w	$0180,$0203,$0182,$0fff,$0184,$0cae,$0186,$086c
		Dc.w	$0188,$053a,$018a,$0307,$018c,$0000,$018e,$0f0f
		Dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
		Dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
		Dc.w	$01a0,$086e,$01a2,$086e,$01a4,$086e,$01a6,$086e
		Dc.w	$01a8,$086e,$01aa,$086e,$01ac,$086e,$01ae,$086e
		Dc.w	$01b0,$086e,$01b2,$086e,$01b4,$086e,$01b6,$086e
		Dc.w	$01b8,$086e,$01ba,$086e,$01bc,$086e,$01be,$086e

Bplpointers	Dc.w	$00e0,$0000,$00e2,$0000,$00e4,$0000,$00e6,$0000
		Dc.w	$00e8,$0000,$00ea,$0000,$00ec,$0000,$00ee,$0000
		Dc.w	$00f0,$0000,$00f2,$0000

Sprpointers	Dc.w	$0120,$0000,$0122,$0000,$0124,$0000,$0126,$0000
		Dc.w	$0128,$0000,$012a,$0000,$012c,$0000,$012e,$0000
		Dc.w	$0130,$0000,$0132,$0000,$0134,$0000,$0136,$0000
		Dc.w	$0138,$0000,$013a,$0000,$013c,$0000,$013e,$0000

		Dc.w	$3a07,$fffe

		Dc.w	$0180,$0203,$0182,$063a,$0184,$0cae,$0186,$086c
		Dc.w	$0188,$053a,$018a,$0307,$018c,$0000,$018e,$0f0f

		Dc.w	$4907,$fffe

		Dc.w	$0180,$0203,$0182,$0417,$0184,$0444,$0186,$0666
		Dc.w	$0188,$0999,$018a,$0bbb,$018c,$0ddd,$018e,$0fff
;64
		Dc.w	$5007,$fffe,$0182,$0a15

LegCols		Dc.w	$ffdf,$fffe
		Dc.w	$0007,$fffe,$0182,$0417
		Dc.w	$1e07,$fffe

		Dc.w	$0180,$0203,$0182,$0417,$0184,$0cff,$0186,$0ace
		Dc.w	$0188,$08ac,$018a,$079b,$018c,$068a,$018e,$0bdf
		Dc.w	$0190,$09bd,$0192,$0357,$0194,$0246,$0196,$0135
		Dc.w	$0198,$0124,$019a,$0123,$019c,$0113,$019e,$0112

		Dc.l	-2

Gfxbase		Dc.l	0
Sprite		Dc.l	0
Oldcop		Dc.l	0
Oldview		Dc.l	0
Oldint		Dc.l	0
Oldinta		Dc.w	0
Olddma		Dc.w	0
Oldadk		Dc.w	0

Gfxname		Dc.b	'graphics.library',0

Text		Dc.b	' Retro Intros^Demos^Games In Our Minds! '
		Dc.b	'                                        '
		Dc.b	'                                        '
		Dc.b	'http://www.whdload.de (WHDLoad Homepage)'
		Dc.b	'I love "Maptapper v0.8.4" by Codetapper!'
		Dc.b	'                                        '
		Dc.b	'Legionary presents another Oldie^Goldie!'
		Dc.b	'from my Amiga ADF preservation archive. '
		Dc.b	'   Coded 2016-02-07. Freeware source!   '
		Dc.b	'<4 all kinda stuff, sources or whatever>'
		Dc.b	'                                        '
		Dc.b	'       -> legionary3@gmail.com <-       '
		Dc.b	'                                        '
		Dc.b	'Greetz to Flashtro Keep up the good work'
		Dc.b	'                                        '
		Dc.b	'^ My best regards to Wepl & Codetapper ^'
		Dc.b	'                                        '
		Dc.b	'                                        '
		Dc.b	'Coded to Perfection by Legionary (C)2016'

		Section	'OldSk00l Crackers Data',Data_c

Font		Incbin	'Gfx/Fonts/CrystalFont-768x8x1.raw'
Borders		Incbin	'Gfx/Misc/LineLeft-320x16x1.raw'
		Incbin	'Gfx/Misc/LineRight-320x16x1.raw'
Skull		Incbin	'Gfx/Misc/Skull-80x69x3.raw'
LegionaryLogo	Incbin	'Gfx/Logos/Legionary-48x4x4.raw'
OSCLogo		Incbin	'Gfx/Logos/OSCLogo-224x16x3.raw'
Module		Incbin	'Modules/Protracker/Monty/techno_chips.mod'

		Section	'OldSk00l Crackers Bss',Bss_c

Screen		Ds.b	10240*5

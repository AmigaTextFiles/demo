שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ* Retro Intro 2016, Coded by Legionary / Oldsk00l Crackers.

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
		Move.w	#$7fff,$dff096
		Move.l	$6c,OldInt
		Lea	Module,a0
		Bsr	Mt_Init
		Move.l	#MusicInt,$6c
		Move.w	#$7fff,$dff09c
		Move.w	#$83f0,$dff096
		Move.w	#$c020,$dff09a
		Bsr	Writer

Main		Cmp.b	#$ff,$dff006
		Bne	Main
Sync		Cmp.b	#$1f,$dff006
		Bne	Sync

		Bsr	SupAndCodedCol
		Bsr	LogoWriter

		Btst	#6,$bfe001
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

Writer		Lea	Text,a0
		Moveq	#0,d1
		Move.w	#40*10*6,d2
		Moveq	#18,d7

NextLine	Moveq	#39,d6

NextChar	Lea	Font,a1
		Lea	Screen,a2
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

LogoWriter	Lea	FrameWait,a0
		Subq.w	#1,(a0)
		Bne	NoReset
		Move.w	#2,(a0)

		Lea	Font2+307*150,a1
		Add.w	FrameCntF,a1
		Moveq	#8,d1
		Bsr	SetCharOnScr

		Lea	Font2+241*150,a1
		Add.w	FrameCntB,a1
		Moveq	#11,d1
		Bsr	SetCharOnScr

		Lea	Font2+66*150,a1
		Add.w	FrameCntF,a1
		Moveq	#14,d1
		Bsr	SetCharOnScr

		Lea	Font2+395*150,a1
		Add.w	FrameCntB,a1
		Moveq	#17,d1
		Bsr	SetCharOnScr

		Lea	Font2+220*150,a1
		Add.w	FrameCntF,a1
		Moveq	#20,d1
		Bsr	SetCharOnScr

		Lea	Font2+571*150,a1
		Add.w	FrameCntB,a1
		Moveq	#23,d1
		Bsr	SetCharOnScr

		Lea	Font2+571*150,a1
		Add.w	FrameCntF,a1
		Moveq	#26,d1
		Bsr	SetCharOnScr

		Lea	Font2+241*150,a1
		Add.w	FrameCntB,a1
		Moveq	#29,d1
		Bsr	SetCharOnScr

		Lea	Font2+44*150,a1
		Add.w	FrameCntF,a1
		Move.w	#40*22+8,d1
		Bsr	SetCharOnScr

		Lea	Font2+373*150,a1
		Add.w	FrameCntB,a1
		Move.w	#40*22+11,d1
		Bsr	SetCharOnScr

		Lea	Font2+150,a1
		Add.w	FrameCntF,a1
		Move.w	#40*22+14,d1
		Bsr	SetCharOnScr

		Lea	Font2+44*150,a1
		Add.w	FrameCntB,a1
		Move.w	#40*22+17,d1
		Bsr	SetCharOnScr

		Lea	Font2+220*150,a1
		Add.w	FrameCntF,a1
		Move.w	#40*22+20,d1
		Bsr	SetCharOnScr

		Lea	Font2+88*150,a1
		Add.w	FrameCntB,a1
		Move.w	#40*22+23,d1
		Bsr	SetCharOnScr

		Lea	Font2+373*150,a1
		Add.w	FrameCntF,a1
		Move.w	#40*22+26,d1
		Bsr	SetCharOnScr

		Lea	Font2+396*150,a1
		Add.w	FrameCntB,a1
		Move.w	#40*22+29,d1
		Bsr	SetCharOnScr

		Addq.w	#6,FrameCntF
		Subq.w	#6,FrameCntB
		Cmp.w	#-6,FrameCntB
		Bne	NoReset
		Move.w	#0,FrameCntF
		Move.w	#138,FrameCntB

NoReset		Rts

SetCharOnScr	Lea	Screen,a2
		Moveq	#20,d5

PrintLogoChar	Move.b	(a1),(a2,d1)
		Move.b	1(a1),1(a2,d1)
		Move.b	2(a1),2(a2,d1)
		Add.w	#150,a1
		Add.w	#40,a2
		Dbf	d5,PrintLogoChar
		Rts

SupAndCodedCol	Subq.w	#1,ColorWait
		Bne	NotNewColor
		Eor.w	#$00f,SupportWHDLoad+6
		Eor.w	#$aaa,CodedLine+6
		Move.w	#10,ColorWait
NotNewColor	Rts

		Include	'Replayers/Protracker v1.1a.asm'

Copper		Dc.w	$0100,$1000,$008e,$2c81,$0090,$2cc1,$0092,$0038
		Dc.w	$0094,$00d0,$0096,$83f0,$0102,$0000,$0104,$0000
		Dc.w	$0106,$0000,$0108,$0000,$010a,$0000,$01fc,$0000
		Dc.w	$010c,$0011

Colors		Dc.w	$0180,$0203

Bplpointers	Dc.w	$00e0,$0000,$00e2,$0000

Sprpointers	Dc.w	$0120,$0000,$0122,$0000,$0124,$0000,$0126,$0000
		Dc.w	$0128,$0000,$012a,$0000,$012c,$0000,$012e,$0000
		Dc.w	$0130,$0000,$0132,$0000,$0134,$0000,$0136,$0000
		Dc.w	$0138,$0000,$013a,$0000,$013c,$0000,$013e,$0000

		Dc.w	$2b07,$fffe,$0182,$0aaf,$2d07,$fffe,$0182,$099f
		Dc.w	$2f07,$fffe,$0182,$088f,$3107,$fffe,$0182,$077f
		Dc.w	$3307,$fffe,$0182,$066f,$3507,$fffe,$0182,$055f
		Dc.w	$3707,$fffe,$0182,$044f,$3907,$fffe,$0182,$033f
		Dc.w	$3b07,$fffe,$0182,$022f,$3d07,$fffe,$0182,$011f
		Dc.w	$3e07,$fffe,$0182,$000f,$4207,$fffe,$0182,$011f
		Dc.w	$4407,$fffe,$0182,$022f,$4607,$fffe,$0182,$033f
		Dc.w	$4807,$fffe,$0182,$044f,$4a07,$fffe,$0182,$055f
		Dc.w	$4c07,$fffe,$0182,$066f,$4e07,$fffe,$0182,$077f
		Dc.w	$5007,$fffe,$0182,$088f,$5207,$fffe,$0182,$099f
		Dc.w	$5407,$fffe,$0182,$0aaf,$5607,$fffe,$0182,$0bbf

		Dc.w	$5807,$fffe,$0180,$0203

		Dc.w	$6507,$fffe,$0180,$062a,$6607,$fffe,$0180,$0202

		Dc.w	$6807,$fffe,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8

		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8
		Dc.w	$0182,$08f9,$0182,$08fa,$0182,$08fb,$0182,$08fc
		Dc.w	$0182,$08fd,$0182,$08fe,$0182,$08ff,$0182,$08ef
		Dc.w	$0182,$08df,$0182,$08cf,$0182,$08bf,$0182,$08af
		Dc.w	$0182,$089f,$0182,$088f,$0182,$098f,$0182,$0a8f
		Dc.w	$0182,$0b8f,$0182,$0c8f,$0182,$0d8f,$0182,$0e8f
		Dc.w	$0182,$0f8f,$0182,$0f8e,$0182,$0f8d,$0182,$0f8c
		Dc.w	$0182,$0f8b,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8

		Dc.w	$6907,$fffe,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8
		Dc.w	$0182,$08f9,$0182,$08fa,$0182,$08fb,$0182,$08fc
		Dc.w	$0182,$08fd,$0182,$08fe,$0182,$08ff,$0182,$08ef
		Dc.w	$0182,$08df,$0182,$08cf,$0182,$08bf,$0182,$08af
		Dc.w	$0182,$089f,$0182,$088f,$0182,$098f,$0182,$0a8f
		Dc.w	$0182,$0b8f,$0182,$0c8f,$0182,$0d8f,$0182,$0e8f
		Dc.w	$0182,$0f8f,$0182,$0f8e,$0182,$0f8d,$0182,$0f8c
		Dc.w	$0182,$0f8b,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8

		Dc.w	$6a07,$fffe,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8
		Dc.w	$0182,$08f9,$0182,$08fa,$0182,$08fb,$0182,$08fc
		Dc.w	$0182,$08fd,$0182,$08fe,$0182,$08ff,$0182,$08ef
		Dc.w	$0182,$08df,$0182,$08cf,$0182,$08bf,$0182,$08af
		Dc.w	$0182,$089f,$0182,$088f,$0182,$098f,$0182,$0a8f
		Dc.w	$0182,$0b8f,$0182,$0c8f,$0182,$0d8f,$0182,$0e8f
		Dc.w	$0182,$0f8f,$0182,$0f8e,$0182,$0f8d,$0182,$0f8c
		Dc.w	$0182,$0f8b,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8

		Dc.w	$6b07,$fffe,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8
		Dc.w	$0182,$08f9,$0182,$08fa,$0182,$08fb,$0182,$08fc
		Dc.w	$0182,$08fd,$0182,$08fe,$0182,$08ff,$0182,$08ef
		Dc.w	$0182,$08df,$0182,$08cf,$0182,$08bf,$0182,$08af
		Dc.w	$0182,$089f,$0182,$088f,$0182,$098f,$0182,$0a8f
		Dc.w	$0182,$0b8f,$0182,$0c8f,$0182,$0d8f,$0182,$0e8f
		Dc.w	$0182,$0f8f,$0182,$0f8e,$0182,$0f8d,$0182,$0f8c
		Dc.w	$0182,$0f8b,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8

		Dc.w	$6c07,$fffe,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8
		Dc.w	$0182,$08f9,$0182,$08fa,$0182,$08fb,$0182,$08fc
		Dc.w	$0182,$08fd,$0182,$08fe,$0182,$08ff,$0182,$08ef
		Dc.w	$0182,$08df,$0182,$08cf,$0182,$08bf,$0182,$08af
		Dc.w	$0182,$089f,$0182,$088f,$0182,$098f,$0182,$0a8f
		Dc.w	$0182,$0b8f,$0182,$0c8f,$0182,$0d8f,$0182,$0e8f
		Dc.w	$0182,$0f8f,$0182,$0f8e,$0182,$0f8d,$0182,$0f8c
		Dc.w	$0182,$0f8b,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8

		Dc.w	$6d07,$fffe,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8
		Dc.w	$0182,$08f9,$0182,$08fa,$0182,$08fb,$0182,$08fc
		Dc.w	$0182,$08fd,$0182,$08fe,$0182,$08ff,$0182,$08ef
		Dc.w	$0182,$08df,$0182,$08cf,$0182,$08bf,$0182,$08af
		Dc.w	$0182,$089f,$0182,$088f,$0182,$098f,$0182,$0a8f
		Dc.w	$0182,$0b8f,$0182,$0c8f,$0182,$0d8f,$0182,$0e8f
		Dc.w	$0182,$0f8f,$0182,$0f8e,$0182,$0f8d,$0182,$0f8c
		Dc.w	$0182,$0f8b,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8

		Dc.w	$6e07,$fffe,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8
		Dc.w	$0182,$08f9,$0182,$08fa,$0182,$08fb,$0182,$08fc
		Dc.w	$0182,$08fd,$0182,$08fe,$0182,$08ff,$0182,$08ef
		Dc.w	$0182,$08df,$0182,$08cf,$0182,$08bf,$0182,$08af
		Dc.w	$0182,$089f,$0182,$088f,$0182,$098f,$0182,$0a8f
		Dc.w	$0182,$0b8f,$0182,$0c8f,$0182,$0d8f,$0182,$0e8f
		Dc.w	$0182,$0f8f,$0182,$0f8e,$0182,$0f8d,$0182,$0f8c
		Dc.w	$0182,$0f8b,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8

		Dc.w	$6f07,$fffe,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8
		Dc.w	$0182,$08f9,$0182,$08fa,$0182,$08fb,$0182,$08fc
		Dc.w	$0182,$08fd,$0182,$08fe,$0182,$08ff,$0182,$08ef
		Dc.w	$0182,$08df,$0182,$08cf,$0182,$08bf,$0182,$08af
		Dc.w	$0182,$089f,$0182,$088f,$0182,$098f,$0182,$0a8f
		Dc.w	$0182,$0b8f,$0182,$0c8f,$0182,$0d8f,$0182,$0e8f
		Dc.w	$0182,$0f8f,$0182,$0f8e,$0182,$0f8d,$0182,$0f8c
		Dc.w	$0182,$0f8b,$0182,$0f88,$0182,$0f98,$0182,$0fa8
		Dc.w	$0182,$0fb8,$0182,$0fc8,$0182,$0fd8,$0182,$0fe8
		Dc.w	$0182,$0ff8,$0182,$0ef8,$0182,$0df8,$0182,$0cf8
		Dc.w	$0182,$0bf8,$0182,$0af8,$0182,$09f8,$0182,$08f8

		Dc.w	$7207,$fffe,$0180,$062a,$7307,$fffe,$0180,$0203

		Dc.w	$8307,$fffe,$0180,$062a,$8407,$fffe,$0180,$0202

SupportWHDLoad	Dc.w	$8607,$fffe,$0182,$0fff,$8e07,$fffe,$0182,$0fff

		Dc.w	$ffdf,$fffe

		Dc.w	$0807,$fffe,$0180,$062a,$0907,$fffe,$0180,$0203
		Dc.w	$0182,$0f5a

		Dc.w	$1907,$fffe,$0180,$062a,$1a07,$fffe,$0180,$0202

CodedLine	Dc.w	$1c07,$fffe,$0182,$0f8f,$2407,$fffe,$0182,$0000

		Dc.w	$2607,$fffe,$0180,$062a,$2707,$fffe,$0180,$0203

		Dc.l	-2

FramePtr	Dc.l	0
Gfxbase		Dc.l	0
Sprite		Dc.l	0
Oldcop		Dc.l	0
Oldview		Dc.l	0
Oldint		Dc.l	0
Oldinta		Dc.w	0
Olddma		Dc.w	0
Oldadk		Dc.w	0
ColorWait	Dc.w	10
FrameWait	Dc.w	1
FrameCntF	Dc.w	0
FrameCntB	Dc.w	138

Gfxname		Dc.b	'graphics.library',0

Text		Dc.b	' Retro Intros^Demos^Games In Our Minds! '
		Dc.b	'                                        '
		Dc.b	'                                        '
		Dc.b	'http://www.whdload.de (WHDLoad Homepage)'
		Dc.b	'I love "Maptapper v0.8.4" by Codetapper!'
		Dc.b	'                                        '
		Dc.b	'Legionary presents another Oldie^Goldie!'
		Dc.b	'from my Amiga ADF preservation archive. '
		Dc.b	'   Coded 2016-01-10. Freeware source!   '
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
		Even

		Section	'OldSk00l Crackers Data',Data_c

Font		Incbin	'Gfx/Fonts/CrystalFont-768x8x1.raw'
Font2		Incbin	'Gfx/Fonts/EPRotFont-1200x1012x1.raw'
Module		Incbin	'Modules/Protracker/Monty/techno_chips.mod'

		Section	'OldSk00l Crackers Bss',Bss_c

Screen		Ds.b	10240

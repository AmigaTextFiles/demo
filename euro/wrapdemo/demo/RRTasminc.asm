  CODE, PUBLIC

_SILVERFOX::
     incbin    "ram:demo/fox_gfx.br"

  BSS, CHIP
_BM0::    ds.b      40000
_BM1::    ds.b      32000

     DATA,CHIP

**** ImageBall:
****   dc.w  0  X Offset from LeftEdge
****   dc.w  0  Y Offset from TopEdge
****   dc.w  31  Image Width
****   dc.w  31  Image Height
****   dc.w  3  Image Depth
****   dc.l  ImageDataBall  pointer to Image BitPlanes
****   dc.b  $07  PlanePick
****   dc.b  $00  PlaneOnOff
****   dc.l  NULL  next Image structure

_ImageDataBall::
  dc.w $003F,$F800,$00F0,$FE00,$03C0,$3380,$06CF,$33C0
  dc.w $0F00,$C8E0,$1B00,$CCF0,$3D3C,$EC78,$3F3C,$EC38
  dc.w $6B3C,$E63C,$433C,$E63C,$9300,$E63E,$B900,$CC3E
  dc.w $9CFF,$8C3E,$9E7F,$1C3E,$8F3C,$3C1E,$8F80,$3C0E
  dc.w $8FC0,$3E06,$87E0,$3F02,$C1F8,$1F82,$C0FC,$0FC2
  dc.w $E07C,$07C2,$703C,$03C0,$7838,$F1CC,$3C31,$F8C8
  dc.w $3C33,$0CF8,$1E33,$0CF0,$0E33,$0F20,$0733,$0B00
  dc.w $038D,$FC80,$00E6,$6800,$003E,$0800

  dc.w $003F,$F800,$00FF,$FE00,$0380,$0F80,$070F,$0FC0
  dc.w $0C7F,$C7E0,$1CFF,$C3F0,$31C3,$E3F8,$33C3,$E3F8
  dc.w $73C3,$E1FC,$73C3,$E1FC,$E3FF,$E1FE,$C1FF,$C3FE
  dc.w $E0FF,$83FE,$E07F,$03FE,$F03C,$03FE,$F000,$03FE
  dc.w $F000,$01FE,$F800,$00FE,$FE00,$007E,$FF00,$003E
  dc.w $FF80,$003E,$7FC0,$003C,$7FC0,$F03C,$3FC1,$F838
  dc.w $3FC3,$FC38,$1FC3,$FC30,$0FC3,$FCE0,$07C3,$F8C0
  dc.w $03F1,$F380,$00F8,$6600,$003F,$F800

  dc.w $003F,$F800,$00FF,$FE00,$03FF,$FF80,$07F0,$FFC0
  dc.w $0F80,$3FE0,$1F00,$3FF0,$3E00,$1FF8,$3C00,$1FF8
  dc.w $7C00,$1FFC,$7C00,$1FFC,$FC00,$1FFE,$FE00,$3FFE
  dc.w $FF00,$7FFE,$FF80,$FFFE,$FFC3,$FFFE,$FFFF,$FFFE
  dc.w $FFFF,$FFFE,$FFFF,$FFFE,$FFFF,$FFFE,$FFFF,$FFFE
  dc.w $FFFF,$FFFE,$7FFF,$FFFC,$7FFF,$0FFC,$3FFE,$07F8
  dc.w $3FFC,$03F8,$1FFC,$03F0,$0FFC,$03E0,$07FC,$07C0
  dc.w $03FE,$0F80,$00FF,$9E00,$003F,$F800

_ReflectPlane::
  ds.l 31

_NOMOUSE::
     dc.l 0,0,0

     END


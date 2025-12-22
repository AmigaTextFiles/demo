  CODE, PUBLIC

_SILVERFOX::
     incbin    "dh2:demo/fox_gfx.br"

  BSS, CHIP
_NOMOUSE::
          ds.l 3
_Sprite2_data::
          ds.w (31*2+4)
_Sprite3_data::
          ds.w (31*2+4)
_Sprite3a_data::
          ds.w (31*2+4)
_Sprite4_data::
          ds.w (31*2+4)
_Sprite5_data::
          ds.w (31*2+4)
_Sprite5a_data::
          ds.w (31*2+4)
_BM0::    ds.b 32000
_BM1::    ds.b 32000

     END


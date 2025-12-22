
;*****************************

 ;hardware/custom.i
custom   = $dff000
bltddat  = $000
dmaconr  = $002
vposr    = $004
vhposr   = $006
dskdatr  = $008
joy0dat  = $00a
joy1dat  = $00c
clxdat   = $00e

adkconr  = $010
pot0dat  = $012
pot1dat  = $014
potinp   = $016
serdatr  = $018
dskbytr  = $01a
intenar  = $01c
intreqr  = $01e 

dskpt    = $020
dsklen   = $024
dskdat   = $026
refptr   = $028
vposw    = $02a
vhposw   = $02c
copcon   = $02e
serdat   = $030
serper   = $032
potgo    = $034
joytest  = $036
strequ   = $038
strvbl   = $03a
strhor   = $03c
strlong  = $03e

bltcon0  = $040
bltcon1  = $042
bltafwm  = $044
bltalwm  = $046
bltcpt   = $048
bltbpt   = $04c
bltapt   = $050
bltdpt   = $054
bltsize  = $058
bltcon01 = $05b
bltsizv  = $05c
bltsizh  = $05e

bltcmod  = $060
bltbmod  = $062
bltamod  = $064
bltdmod  = $066
 
bltcdat  = $070
bltbdat  = $072
bltadat  = $074

deniseid = $07c
dsksync  = $07e

cop1lc   = $080
cop2lc   = $084
copjmp1  = $088
copjmp2  = $08a
copins   = $08c
diwstrt  = $08e
diwstop  = $090
ddfstrt  = $092
ddfstop  = $094 
dmacon   = $096
clxcon   = $098
intena   = $09a
intreq   = $09c
adkcon   = $09e

aud      = $0a0
aud0     = $0a0
aud1     = $0b0
aud2     = $0c0
aud3     = $0d0

 ; audio channel
ac_ptr    = $00
ac_len    = $04
ac_per    = $06
ac_vol    = $08
ac_dat    = $0a
ac_sizeof = $10

bplpt     = $0e0

bplcon0   = $100
bplcon1   = $102
bplcon2   = $104
bplcon3   = $106
bpl1mod   = $108
bpl2mod   = $10a
bplhmod   = $10c

bpldat    = $110

sprpt     = $120

spr       = $140

 ;sprite def
sd_pos    = $00
sd_ctl    = $02
sd_dataa  = $04
sd_datab  = $06
sd_sizeof = $08

color     = $180

htotal    = $1c0
hsstop    = $1c2
hbstrt    = $1c4
hbstop    = $1c6
vtotal    = $1c8
vsstop    = $1ca
vbstrt    = $1cc
vbstop    = $1ce
sprhstrt  = $1d0
sprhstop  = $1d2
bplhstrt  = $1d4
bplhdtop  = $1d6
hhposw    = $1d8
hhposr    = $1da
beamcom0  = $1dc
hsstrt    = $1de
vsstrt    = $1e0
hcenter   = $1e2
diwhigh   = $1e4

 ;extra extension

AUD0LC    = aud0
AUD0LCH   = aud0
AUD0LCL   = aud0+$02
AUD0LEN   = aud0+$04
AUD0PER   = aud0+$06
AUDOVOL   = aud0+$08
AUD0DAT   = aud0+$0A

AUD1LC    = aud1
AUD1LCH   = aud1
AUD1LCL   = aud1+$02
AUD1LEN   = aud1+$04 
AUD1PER   = aud1+$06
AUD1VOL   = aud1+$08
AUD1DAT   = aud1+$0A

AUD2LC    = aud2
AUD2LCH   = aud2
AUD2LCL   = aud2+$02 
AUD2LEN   = aud2+$04
AUD2PER   = aud2+$06
AUD2VOL   = aud2+$08
AUD2DAT   = aud2+$0A

AUD3LC    = aud3
AUD3LCH   = aud3
AUD3LCL   = aud3+$02
AUD3LEN   = aud3+$04
AUD3PER   = aud3+$06
AUD3VOL   = aud3+$08
AUD3DAT   = aud3+$0A

BPL1PT    = bplpt+$00
BPL1PTH   = bplpt+$00
BPL1PTL   = bplpt+$02
BPL2PT    = bplpt+$04
BPL2PTH   = bplpt+$04
BPL2PTL   = bplpt+$06
BPL3PT    = bplpt+$08
BPL3PTH   = bplpt+$08
BPL3PTL   = bplpt+$0A
BPL4PT    = bplpt+$0C
BPL4PTH   = bplpt+$0C
BPL4PTL   = bplpt+$0E
BPL5PT    = bplpt+$10
BPL5PTH   = bplpt+$10
BPL5PTL   = bplpt+$12
BPL6PT    = bplpt+$14
BPL6PTH   = bplpt+$14
BPL6PTL   = bplpt+$16 

DPL1DATA  = bpldat+$00
DPL2DATA  = bpldat+$02
DPL3DATA  = bpldat+$04
DPL4DATA  = bpldat+$06
DPL5DATA  = bpldat+$08
DPL6DATA  = bpldat+$0A

SPR0PT    = sprpt+$00
SPR0PTH   = SPR0PT+$00
SPR0PTL   = SPR0PT+$02
SPR1PT    = sprpt+$04 
SPR1PTH   = SPR1PT+$00
SPR1PTL   = SPR1PT+$02
SPR2PT    = sprpt+$08
SPR2PTH   = SPR2PT+$00
SPR2PTL   = SPR2PT+$02
SPR3PT    = sprpt+$0C
SPR3PTH   = SPR3PT+$00
SPR3PTL   = SPR3PT+$02
SPR4PT    = sprpt+$10
SPR4PTH   = SPR4PT+$00
SPR4PTL   = SPR4PT+$02
SPR5PT    = sprpt+$14
SPR5PTH   = SPR5PT+$00
SPR5PTL   = SPR5PT+$02
SPR6PT    = sprpt+$18
SPR6PTH   = SPR6PT+$00
SPR6PTL   = SPR6PT+$02
SPR7PT    = sprpt+$0C
SPR7PTH   = SPR7PT+$00
SPR7PTL   = SPR7PT+$02 

SPR0POS   = spr+$00
SPR0CTL   = SPR0POS+sd_ctl
SPR0DATA  = SPR0POS+sd_dataa
SPR0DATB  = SPR0POS+$06 

SPR1POS   = spr+$08
SPR1CTL   = SPR1POS+sd_ctl
SPR1DATA  = SPR1POS+sd_dataa
SPR1DATB  = SPR1POS+$06

SPR2POS   = spr+$10
SPR2CTL   = SPR2POS+sd_ctl
SPR2DATA  = SPR2POS+sd_dataa
SPR2DATB  = SPR2POS+$06

SPR3POS   = spr+$18
SPR3CTL   = SPR3POS+sd_ctl
SPR3DATA  = SPR3POS+sd_dataa
SPR3DATB  = SPR3POS+$06

SPR4POS   = spr+$20
SPR4CTL   = SPR4POS+sd_ctl
SPR4DATA  = SPR4POS+sd_dataa
SPR4DATB  = SPR4POS+$06
    
SPR5POS   = spr+$28
SPR5CTL   = SPR5POS+sd_ctl
SPR5DATA  = SPR5POS+sd_dataa
SPR5DATB  = SPR5POS+$06

SPR6POS   = spr+$30
SPR6CTL   = SPR6POS+sd_ctl 
SPR6DATA  = SPR6POS+sd_dataa
SPR6DATB  = SPR6POS+$06
 
SPR7POS   = spr+$38
SPR7CTL   = SPR7POS+sd_ctl
SPR7DATA  = SPR7POS+sd_dataa
SPR7DATB  = SPR7POS+$06

COLOR00   = color+$00
COLOR01   = color+$02
COLOR02   = color+$04
COLOR03   = color+$06
COLOR04   = color+$08
COLOR05   = color+$0A
COLOR06   = color+$0C
COLOR07   = color+$0E
COLOR08   = color+$10
COLOR09   = color+$12
COLOR10   = color+$14
COLOR11   = color+$16
COLOR12   = color+$18
COLOR13   = color+$1A
COLOR14   = color+$1C
COLOR15   = color+$1E
COLOR16   = color+420
COLOR17   = color+$22
COLOR18   = color+$24
COLOR19   = color+$26
COLOR20   = color+$28
COLOR21   = color+$2A
COLOR22   = color+$2C
COLOR23   = color+$2E
COLOR24   = color+$30
COLOR25   = color+$32
COLOR26   = color+$34
COLOR27   = color+$36
COLOR28   = color+$38
COLOR29   = color+$3A
COLOR30   = color+$3C
COLOR31   = color+$3E


octant1 = 16
octant2 = 0
octant3 = 8
octant4 = 20
octant5 = 28
octant6 = 12
octant7 = 4
octant8 = 24

linemode     = $1
fill_or      = $8
fill_xor     = $10
fill_carryin = $4
onedot       = $2
ovflag       = $20
signflag     = $40
blitreverse  = $2

sud = $10
sul = $8
aul = $4

dmab_setclr   = 15
dmab_aud0     = 0
dmab_aud1     = 1
dmab_aud2     = 2
dmab_aud3     = 3
dmab_disk     = 4
dmab_sprite   = 5
dmab_blitter  = 6
dmab_copper   = 7
dmab_raster   = 8
dmab_master   = 9
dmab_blithog  = 10
dmab_bltdone  = 14
dmab_bltnzero = 13


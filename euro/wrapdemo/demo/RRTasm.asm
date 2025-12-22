  CODE, PUBLIC
*****    VOID __regargs UnPackByteRun(UBYTE *from, UBYTE *to)
*****        calling from assembly:          a0   ,       a1
         XDEF @UnPackByteRun
@UnPackByteRun:
          move.l    d2,-(SP)
          moveq.l   #$7F,d2
          bra.s     upb_startit
upb_copyit
          and.w     d2,d0
upb_copy_loop
          move.b    (a0)+,(a1)+
          dbf       d0,upb_copy_loop
upb_startit
          move.b    (a0)+,d0
          bmi.s     upb_copyit
          beq.s     upb_out
          and.w     d2,d0
          move.b    (a0)+,d1
upb_repeatit
          move.b    d1,(a1)+
          dbf       d0,upb_repeatit
          bra.s     upb_startit
upb_out
          move.l    (SP)+,d2
          rts

  CODE,PUBLIC
     xref _LVOLoadRGB4
     xref _GfxBase
     xref _vport
*****  VOID __regargs ComputeInterColor(UWORD *from (a0), UWORD *to (a1), UWORD step (d0));
@ComputeInterColor::
     movem.l   a2/a6/d2-d7,-(SP)
     moveq.l   #15,d2
     lea       cic_intercolor(PC),a2

     moveq.l   #31,d1
cic_loop1:
     move.w    (a0)+,d3  ;color
     move.w    (a1)+,d4
     moveq.l   #0,d7
     move.w    d3,d5     ;red
     move.w    d4,d6
     lsr.w     #8,d5
     lsr.w     #8,d6
     sub.w     d5,d6
     muls      d0,d6
     asr.w     #4,d6
     add.w     d5,d6
     and.w     d2,d6
     move.w    d6,d7
     move.w    d3,d5     ;green
     move.w    d4,d6
     lsr.w     #4,d5
     lsr.w     #4,d6
     and.w     d2,d5
     and.w     d2,d6
     sub.w     d5,d6
     muls      d0,d6
     asr.w     #4,d6
     add.w     d5,d6
     and.w     d2,d6
     lsl.w     #4,d7
     add.w     d6,d7
     move.w    d3,d5     ;blue
     move.w    d4,d6
     and.w     d2,d5
     and.w     d2,d6
     sub.w     d5,d6
     muls      d0,d6
     asr.w     #4,d6
     add.w     d5,d6
     and.w     d2,d6
     lsl.w     #4,d7
     add.w     d6,d7
     move.w    d7,(a2)+  ;done

     dbf       d1,cic_loop1

     moveq.l   #32,d0  ;Load ### Colors into Active ViewPort
     BASEREG a4
     movea.l   _vport(a4),a0
     movea.l   _GfxBase(a4),a6
     BASEREG OFF
     lea       cic_intercolor(PC),a1
     jsr       _LVOLoadRGB4(a6)

     moveq.l   #3,d0
     jsr       @WaitFRAMES(PC)

     movem.l   (SP)+,a2/a6/d2-d7
     rts
cic_intercolor:
     ds.b      32*4  ;MaxKOLORs * 4


  CODE,PUBLIC
     xref      _LVOWaitTOF
*****  VOID __regargs WaitFRAMES(UWORD frames(d0));
@WaitFRAMES::
     movem.l   a6/d2,-(SP)
     BASEREG a4
     movea.l   _GfxBase(a4),a6
     BASEREG OFF
     move.l    d0,d2
     beq.s     wf_exit
wf_loop:
     jsr       _LVOWaitTOF(a6)
     subq.w    #1,d2
     bne.s     wf_loop
wf_exit:
     movem.l   (SP)+,a6/d2
     rts

*****  extern ULONG __regargs
*****     SLAM_BLITTER(struct custom *a0, BLIT_PARMS *a1);

@SLAM_BLITTER::

*** extern VOID __regargs SLAM_BLITTER(BLIT_PARMS *a0); ***

*****  Blitter begins at offset 64 (0x40)
*****  BLIT_PARMS;
*****     USHORT planes;              // 0
*****   /*** 96  (0x60) ***/
*****     SHORT  cmod,bmod,amod,dmod; // 2,4,6,8
*****   /*** 112 (0x70) ***/
*****     USHORT cdat,bdat,adat;      // 10,12,14
*****   /*** 64  (0x40) ***/
*****     USHORT con0, con1;          // 16,18
*****     USHORT afwm,alwm;           // 20,22
*****     USHORT *cpt,*bpt,*apt,*dpt; // 24,28,32,36
*****     USHORT size;                // 40
*****   /*** For MultiPlane Blits ***/
*****     SHORT  adda,addb,addcd;     // 42,44,46


     xref      _LVOOwnBlitter
     xref      _LVODisownBlitter
     xref      _LVOWaitBlit

     movem.l   a2/a6,-(SP)

     BASEREG a4
     movea.l   _GfxBase(a4),a6
     BASEREG OFF
     lea       (a0),a2

     jsr       _LVOOwnBlitter(a6)
     move.w    (a2)+,d1      ;Planes

sbloop:
     lea       $dff040,a0         ; HARDWARE (blitter)
     lea       (a2),a1

     jsr       _LVOWaitBlit(a6)   ; Doesn't modify d0,d1,a0,a1

     move.l    (a1)+,32(a0)    ;MODs
     move.l    (a1)+,36(a0)
     move.l    (a1)+,48(a0)    ;src Data
     move.w    (a1)+,52(a0)

     move.l    (a1)+,(a0)+     ;con0 + con1
     move.l    (a1)+,(a0)+     ;"a" word masks
     move.l    (a1)+,(a0)+     ;csrc
     move.l    (a1)+,(a0)+     ;bsrc
     move.l    (a1)+,(a0)+     ;asrc
     move.l    (a1)+,(a0)+     ;dest
     move.w    (a1)+,(a0)      ;size and begin blit!!!

     moveq.l   #0,d0           ;Add offset to next plane
     move.w    (a1)+,d0        ;a
     add.l     d0,30(a2)
     move.w    (a1)+,d0        ;b
     add.l     d0,26(a2)
     move.w    (a1)+,d0        ;cd
     add.l     d0,22(a2)
     add.l     d0,34(a2)

     subq.l    #1,d1           ;Decrement Plane counter
     bne.s     sbloop

     jsr       _LVODisownBlitter(a6)

     movem.l   (SP)+,a2/a6
     rts

     xref      _output
     xref      _RStartPlane

***** VOID __regargs ReadPoint(long int sX(d0), long int sY(d1));
@ReadPoint::
     move.l    d2,a1          ;Save d2 in a1
     BASEREG   a4

     move.l    d1,d2          ; d1*=MOD (40)
     lsl.l     #2,d2
     add.l     d2,d1
     lsl.l     #3,d1

     move.l    d0,d2
     andi.w    #15,d2         ;d0=sX-=(d2=(sx&15))

     sub.l     d2,d0
     lsr.l     #3,d0          ;d0=sX>>3
     add.l     d1,d0          ;d0=(sX>>3)+(MOD*sY)
     add.l     _RStartPlane(a4),d0 ;d0=StartPlane[d0]
     move.l    #$8000,d1      ;Pixel=(0x8000>>d1)
     lsr.l     d2,d1

     movea.l   d0,a0          ;Read(OffSet,Pixel)
     and.w     (a0),d1

     beq.s     rp_nopixel
     addq.l    #1,_output(a4)
rp_nopixel

     BASEREG   OFF
     move.l    a1,d2          ;Restore d2 from a1
     rts

	END

  CODE,PUBLIC
*****    VOID __regargs UnPackSLZ(UBYTE *from, UBYTE *to)
*****        calling from assembly:      a0   ,       a1
CS_MASK   EQU  31
CS_LSL    EQU  3

         XDEF @UnPackSLZ
@UnPackSLZ:

            movem.l d2-d3/a2,-(SP)  ; Save Registers
 
            bra.b   slz_start       ; Skip to entry point
 
slz_literal move.b  (a0)+,(a1)+     ; Copy 8 byte literal string FAST!
            move.b  (a0)+,(a1)+
            move.b  (a0)+,(a1)+
            move.b  (a0)+,(a1)+
            move.b  (a0)+,(a1)+
            move.b  (a0)+,(a1)+
            move.b  (a0)+,(a1)+
            move.b  (a0)+,(a1)+
 
slz_start   move.b  (a0)+,d0        ; Load compression TAG
            beq.b   slz_literal     ; 8-byte literal string?
 
            moveq   #7,d1           ; Loop thru 8 bits
slz_nxtloop add.b   d0,d0           ; Set flags for this compression TAG
            bcs.b   slz_comp        ; If bit is set then compress
            move.b  (a0)+,(a1)+     ; Otherwise copy a literal byte
            dbf     d1,slz_nxtloop  ; Check and loop through 8 iterations
            bra.b   slz_start       ; Get next TAG

slz_comp    moveq   #0,d2           ; Clear offset register
            move.b  (a0)+,d2        ; Load compression specifier (cs) into d2
            beq.b   slz_exit        ; If cs is 0, exit (decompression finished)
            moveq   #CS_MASK,d3     ; Copy cs into number reg and mask off bits
            and.w   d2,d3           ;   num = ( cs & CS_MASK ) [+ 2] ; {at least 3}
            lsl.w   #CS_LSL,d2      ; Multiply cs_or by (2^CS_LSL)
            move.b  (a0)+,d2        ;   and replace lsb with rest of cs
            movea.l a1,a2           ; Now compute the offset from the current
            suba.w  d2,a2           ;   output pointer

            add.w   d3,d3           ; Compute the unroll offset and begin
            neg.w   d3              ;   unrolled compressed data expansion
            jmp     slz_unroll(pc,d3.w)

slz_exit    movem.l (SP)+,d2-d3/a2  ; Restore Registers
            rts                     ; EXIT routine

            move.b  (a2)+,(a1)+     ; 33
            move.b  (a2)+,(a1)+     ; 32
            move.b  (a2)+,(a1)+     ; 31
            move.b  (a2)+,(a1)+     ; 30
            move.b  (a2)+,(a1)+     ; 29
            move.b  (a2)+,(a1)+     ; 28
            move.b  (a2)+,(a1)+     ; 27
            move.b  (a2)+,(a1)+     ; 26
            move.b  (a2)+,(a1)+     ; 25
            move.b  (a2)+,(a1)+     ; 24
            move.b  (a2)+,(a1)+     ; 23
            move.b  (a2)+,(a1)+     ; 22
            move.b  (a2)+,(a1)+     ; 21
            move.b  (a2)+,(a1)+     ; 20
            move.b  (a2)+,(a1)+     ; 19
            move.b  (a2)+,(a1)+     ; 18
            move.b  (a2)+,(a1)+     ; 17
            move.b  (a2)+,(a1)+     ; 16
            move.b  (a2)+,(a1)+     ; 15
            move.b  (a2)+,(a1)+     ; 14
            move.b  (a2)+,(a1)+     ; 13
            move.b  (a2)+,(a1)+     ; 12
            move.b  (a2)+,(a1)+     ; 11
            move.b  (a2)+,(a1)+     ; 10
            move.b  (a2)+,(a1)+     ;  9
            move.b  (a2)+,(a1)+     ;  8
            move.b  (a2)+,(a1)+     ;  7
            move.b  (a2)+,(a1)+     ;  6
            move.b  (a2)+,(a1)+     ;  5
            move.b  (a2)+,(a1)+     ;  4
            move.b  (a2)+,(a1)+     ;  3
slz_unroll  move.b  (a2)+,(a1)+     ;  2
            move.b  (a2)+,(a1)+     ;  1
 
            dbf     d1,slz_nxtloop  ; Check and loop through 8 iterations
            bra.s   slz_start       ; Process Next TAG
 
***** VOID __regargs BresenFold(UBYTE *from_a0, UBYTE *to_a1)
@BresenFold::
     move.l    (a0)+,(a1)+
     move.l    (a0)+,(a1)+
     move.l    (a0)+,(a1)+
     move.l    (a0)+,(a1)+
     move.l    (a0)+,(a1)+
     move.l    (a0)+,(a1)+
     move.l    (a0)+,(a1)+
     move.l    (a0)+,(a1)+
     move.l    (a0)+,(a1)+
     move.l    (a0)+,(a1)+
     rts

***** VOID __regargs ReverseIt(UBYTE *from_a0, UBYTE *to_a1);
@ReverseIt::
     lea       40(a0),a0
     moveq.l   #0,d0
     moveq.l   #7,d1
rvi_loop
     move.b    -(a0),d0
     move.b    REVDATA(PC,d0.w),(a1)+
     move.b    -(a0),d0
     move.b    REVDATA(PC,d0.w),(a1)+
     move.b    -(a0),d0
     move.b    REVDATA(PC,d0.w),(a1)+
     move.b    -(a0),d0
     move.b    REVDATA(PC,d0.w),(a1)+
     move.b    -(a0),d0
     move.b    REVDATA(PC,d0.w),(a1)+
     dbf.s     d1,rvi_loop

     rts

REVDATA:
     dc.b 0,128,64,192,32,160,96,224
     dc.b 16,144,80,208,48,176,112,240
     dc.b 8,136,72,200,40,168,104,232
     dc.b 24,152,88,216,56,184,120,248
     dc.b 4,132,68,196,36,164,100,228
     dc.b 20,148,84,212,52,180,116,244
     dc.b 12,140,76,204,44,172,108,236
     dc.b 28,156,92,220,60,188,124,252
     dc.b 2,130,66,194,34,162,98,226
     dc.b 18,146,82,210,50,178,114,242
     dc.b 10,138,74,202,42,170,106,234
     dc.b 26,154,90,218,58,186,122,250
     dc.b 6,134,70,198,38,166,102,230
     dc.b 22,150,86,214,54,182,118,246
     dc.b 14,142,78,206,46,174,110,238
     dc.b 30,158,94,222,62,190,126,254
     dc.b 1,129,65,193,33,161,97,225
     dc.b 17,145,81,209,49,177,113,241
     dc.b 9,137,73,201,41,169,105,233
     dc.b 25,153,89,217,57,185,121,249
     dc.b 5,133,69,197,37,165,101,229
     dc.b 21,149,85,213,53,181,117,245
     dc.b 13,141,77,205,45,173,109,237
     dc.b 29,157,93,221,61,189,125,253
     dc.b 3,131,67,195,35,163,99,227
     dc.b 19,147,83,211,51,179,115,243
     dc.b 11,139,75,203,43,171,107,235
     dc.b 27,155,91,219,59,187,123,251
     dc.b 7,135,71,199,39,167,103,231
     dc.b 23,151,87,215,55,183,119,247
     dc.b 15,143,79,207,47,175,111,239
     dc.b 31,159,95,223,63,191,127,255

***** VOID __regargs GoLine(WORD line_d0);
     xref _DOLINE
     xref _MASSIVE_STORAGE
@GoLine::
     movem.l   d2-d7,-(SP)
                              ; {
                              ;   WORD loop_d1,width_d1;  //free = d2
                              ;   WORD delta_stab_d3;
                              ;   WORD delta_d4,position_d5;
                              ;   WORD takeoff_d6;
                              ;   WORD *to_a0,write_word_d7;

                              ;   UBYTE DOLINE_a1[320];

                              ;   CreateMasque(&BM0_a0[line_d0],DOLINE_a1,40);
     BASEREG a4
     lea       _DOLINE(a4),a1
     BASEREG OFF
     lea       _BM0,a0
     adda.w    d0,a0

     moveq.l   #39,d4
     moveq.l   #1,d1
     moveq.l   #0,d2

cm_begin
     move.b    (a0)+,d3
     bpl.s     cm_c0
     move.b    d1,(a1)+
     bra.s     cm_s0
cm_c0
     move.b    d2,(a1)+
cm_s0
     add.b     d3,d3
     bpl.s     cm_c1
     move.b    d1,(a1)+
     bra.s     cm_s1
cm_c1
     move.b    d2,(a1)+
cm_s1
     add.b     d3,d3
     bpl.s     cm_c2
     move.b    d1,(a1)+
     bra.s     cm_s2
cm_c2
     move.b    d2,(a1)+
cm_s2
     add.b     d3,d3
     bpl.s     cm_c3
     move.b    d1,(a1)+
     bra.s     cm_s3
cm_c3
     move.b    d2,(a1)+
cm_s3
     add.b     d3,d3
     bpl.s     cm_c4
     move.b    d1,(a1)+
     bra.s     cm_s4
cm_c4
     move.b    d2,(a1)+
cm_s4
     add.b     d3,d3
     bpl.s     cm_c5
     move.b    d1,(a1)+
     bra.s     cm_s5
cm_c5
     move.b    d2,(a1)+
cm_s5
     add.b     d3,d3
     bpl.s     cm_c6
     move.b    d1,(a1)+
     bra.s     cm_s6
cm_c6
     move.b    d2,(a1)+
cm_s6
     add.b     d3,d3
     bpl.s     cm_c7
     move.b    d1,(a1)+
     bra.s     cm_s7
cm_c7
     move.b    d2,(a1)+
cm_s7

     dbf.s     d4,cm_begin

     BASEREG a4
     lea       _DOLINE(a4),a1
     BASEREG OFF
;     jmp       gl_out

     moveq.l   #0,d1          ;   for(loop_d1=0;loop_d1!=80;loop_d1++)
gl_ford1                      ;     {
     moveq.l   #0,d7          ;       write_word_d7=0;
     move.w    #160,d4        ;       delta_d4=160; position_d5=-1;
     moveq.l   #-1,d5

     lsl.w     #2,d1

     BASEREG a4               ;       to_a0=(WORD *)&MASSIVE_STORAGE_a0[loop_d1][line_d0];
     lea       _MASSIVE_STORAGE(a4),a0
     movea.l   0(a0,d1.w),a0
     adda.w    d0,a0
     BASEREG OFF

     addq.w    #4,d1          ;       width_d1=(loop_d1+1)*4;
     move.w    #320,d6        ;       takeoff_d6=(320-width_d1)/2;
     sub.w     d1,d6
     lsr.w     #1,d6
     move.w    d6,d2          ;       to_a0+=(takeoff_d6>>4);
     lsr.w     #4,d2
     add.w     d2,d2
     adda.w    d2,a0
     and.w     #15,d6         ;       takeoff_d6&=15;

     moveq.l   #0,d3          ;       for(delta_stab_d3=0; delta_stab_d3<width_d1; delta_stab_d3++)
                              ;         {
                              ;           while(delta_d4>=0)
gl_whld4                      ;             {
     addq.w    #1,d5          ;               position_d5++;
     sub.w     d1,d4          ;               delta_d4-=width_d1;
     bpl.s     gl_whld4       ;             }

     add.w     d7,d7          ;           write_word_d7=(write_word_d7*2)|DOLINE_a1[position_d5];
     or.b      0(a1,d5.w),d7
     addq.w    #1,d6          ;           if((++takeoff_d6)==16)
     cmp.w     #16,d6         ;             {
     bne.s     gl_skip1
     moveq.l   #0,d6          ;               takeoff_d6=0;
     move.w    d7,(a0)+       ;               *(to_a0++)=write_word_d7;
gl_skip1                      ;             }
     add.w     #320,d4        ;           delta_d4+=320;

     addq.w    #1,d3          ;         }
     cmp.w     d3,d1
     bne.s     gl_whld4

     move.w    d6,d2          ;       if(takeoff_d6)
     beq.s     gl_skip2       ;         {
     sub.w     #16,d2         ;           write_word_d7<<=(16-takeoff_d6);
gl_shloop
     add.w     d7,d7
     addq.w    #1,d2
     bne.s     gl_shloop
     move.w    d7,(a0)        ;           *to_a0=write_word_d7;
                              ;         }
gl_skip2
     lsr.w     #2,d1          ;     }
     cmp.w     #80,d1
     bne.s     gl_ford1
gl_out                        ; }
     movem.l   (SP)+,d2-d7
     rts

 SECTION __MERGED,DATA,PUBLIC
_SILVERFOX::
     incbin    "bin/FOX1.slz2"
     CNOP 0,2

  BSS, CHIP
_NOMOUSE::
          ds.l 3
_BM0::    ds.b 32000

    END

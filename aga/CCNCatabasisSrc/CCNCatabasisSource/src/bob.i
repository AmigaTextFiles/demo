
	include exec/types.i

    STRUCTURE   sBob,0
        APTR    bob_bm		;Bitmap *
        APTR    bob_mask
        UWORD   bob_bytesPerRowPlane ; byte width with extra column
        WORD    bob_pixelWidth   ;  of original Image
        ;old WORD   bob_dsizeY       ;  bm->Rows * bm->Flags
    LABEL   bob_SIZEOF

    STRUCTURE   sBobDest,0
        APTR    bod_background	;Bitmap *
        APTR    bod_dest			;Bitmap * can be same as sm_background
        ; note: following different if bm interleaved
        UWORD   bod_OnePlaneByteWidth
        WORD    bod_clipX1
        WORD    bod_clipX2
        WORD    bod_clipY1
        WORD    bod_clipY2
    LABEL   bod_SIZEOF


	; Compile geometry of an appliable blit for a bob
    STRUCTURE   BLTDESC,0
        ; bn_sizeof
        STRUCT bld_supr,18
        ; ---- 8+16+(2 bltsize) ->24b continuous movem.l 6x dx
        ; to dff+ $040
        USHORT  bld_bltcon0
        USHORT  bld_bltcon1
        USHORT  bld_bltafwm
        USHORT  bld_bltalwm
        APTR    bld_bltcpt
        APTR    bld_bltbpt
        APTR    bld_bltapt
        APTR    bld_bltdpt
        ;---  to dff+ $060
        USHORT  bld_bltcmod
        USHORT  bld_bltbmod
        USHORT  bld_bltamod
        USHORT  bld_bltdmod      
        
        ; - - - still continuous but .w
        USHORT  bld_dummy   ; to align .l
        USHORT  bld_bltsize
    LABEL   bld_sizeof




extern void __asm c2p1x1_8_c5_040_smcinit(register __d0 WORD chunkyx,
					  register __d1 WORD chunkyy,
                                          register __d2 WORD scroffsx,
                                          register __d3 WORD scroffsy,
                                          register __d4 WORD rowlen,
                                          register __d5 LONG bplsize);

extern void __asm c2p1x1_8_c5_040_init(register __d0 WORD chunkyx,
                                       register __d1 WORD chunkyy,
                                       register __d2 WORD scroffsx,
                                       register __d3 WORD scroffsy,
                                       register __d4 WORD rowlen,
                                       register __d5 LONG bplsize);

extern void __asm c2p1x1_8_c5_040(register __a0 UBYTE *c2pscreen,
                                  register __a1 UBYTE *bitplanes);

extern void __asm c2p2x1_8_c5_030_init(register __d0 WORD chunkyx,
                                       register __d1 WORD chunkyy,
                                       register __d2 WORD scroffsx,
                                       register __d3 WORD scroffsy,
                                       register __d4 WORD rowlen,
                                       register __d5 LONG bplsize);

extern void __asm c2p2x1_8_c5_030(register __a0 UBYTE *c2pscreen,
                                  register __a1 UBYTE *bitplanes);

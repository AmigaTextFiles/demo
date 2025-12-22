/*
  The Player Playroutine
  1) You need to convert the MOD to a P61 file with the converter found in the release package.
  2) Also you need to change the "usecode" value in the player source file to the one shown at the end of the conversion process.
     This is used for disabling some replayer features for optimal speed I guess.
*/
#ifndef P6112_H
#define P6112_H

extern __asm LONG P61_Init( register __a0 APTR* Module_p,
                            register __a1 APTR* Samples_p,
                            register __a2 APTR* Buffer_p );

extern __asm void P61_Music( void );

extern __asm void P61_End( void );

#endif

/* pragmas for MEDPlayer.library V2.0 - V6.0  Modified! */
LONG GetPlayer(UWORD midi);
void FreePlayer(void);
void PlayModule(struct MMD0 *module);
void ContModule(struct MMD0 *module);
void StopPlayer(void);
/* void DimOffPlayer(UWORD length); */
void SetTempo(UWORD tempo);
struct MMD0 *LoadModule(char *name);
void UnLoadModule(struct MMD0 *module);
struct MMD0 *GetCurrentModule(void);
void ResetMIDI(void);
void SetModnum(UWORD modnum);
void RelocModule(struct MMD0 *module);

/* for octaplayer.library */
LONG GetPlayer8(void);
void FreePlayer8(void);
void PlayModule8(struct MMD0 *module);
void ContModule8(struct MMD0 *module);
void StopPlayer8(void);
struct MMD0 *LoadModule8(char *name);
void UnLoadModule8(struct MMD0 *module);
void SetModnum8(UWORD modnum);
void RelocModule8(struct MMD0 *module);
void SetHQ(LONG hq);

#define OCTAPLR_LIB_PROTOS 1

#ifndef NO_PRAGMAS
/* (#pragma libcall(MEDPlayerBase,0x1e, GetPlayer() ---1---) */
#pragma amicall(MEDPlayerBase,0x1e, GetPlayer(d0))
#pragma amicall(MEDPlayerBase,0x24, FreePlayer())
#pragma amicall(MEDPlayerBase,0x2a, PlayModule(a0))
#pragma amicall(MEDPlayerBase,0x30, ContModule(a0))
#pragma amicall(MEDPlayerBase,0x36, StopPlayer())
/* #pragma libcall MEDPlayerBase DimOffPlayer 3c 1 --- REMOVED */

#pragma amicall(MEDPlayerBase,0x42, SetTempo(d0))

/* #pragma libcall MEDPlayerBase SetTempo 42 ---1--- */

#pragma amicall(MEDPlayerBase,0x48, LoadModule(a0))
#pragma amicall(MEDPlayerBase,0x4e, UnLoadModule(a0))
#pragma amicall(MEDPlayerBase,0x54, GetCurrentModule())
#pragma amicall(MEDPlayerBase,0x5a, ResetMIDI())
/* functions below in V2.0 or later*/
#pragma amicall(MEDPlayerBase,0x60, SetModnum(d0))
#pragma amicall(MEDPlayerBase,0x66, RelocModule(a0))

/* prototypes for OctaPlayer.library V2.0 - V6.0 */
//#pragma libcall OctaPlayerBase GetPlayer8 1E 0
//#pragma libcall OctaPlayerBase FreePlayer8 24 0
//#pragma libcall OctaPlayerBase PlayModule8 2A 801
//#pragma libcall OctaPlayerBase ContModule8 30 801
//#pragma libcall OctaPlayerBase StopPlayer8 36 0
//#pragma libcall OctaPlayerBase LoadModule8 3C 801
//#pragma libcall OctaPlayerBase UnLoadModule8 42 801
//#pragma libcall OctaPlayerBase SetModnum8 48 001
//#pragma libcall OctaPlayerBase RelocModule8 4E 801
//#pragma libcall OctaPlayerBase SetHQ 54 1
#endif
/* prototypes */

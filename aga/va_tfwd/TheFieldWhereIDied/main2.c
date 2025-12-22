/*
  The Field Where I Died 
  Venus Art Demo for Intel Outside 5

  ver. 1.0
  for both PPC and 68k
*/

#define NO_EXIT 1

//#define _NO_INTRO 1  
  /* intro was deleted from the demo (no time unfortunally;) */

//#define _DEBUG__

#include <stdlib.h>
#include <stdio.h>

#include <exec/types.h>
#include <dbplayer/dbplayerbase.h>
#include <dbplayer/dbplayer.h>
#include <proto/dbplayer.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/exec.h>
#include <exec/memory.h>
#include <utility/hooks.h>

#ifdef _DEBUG__
#include <powerup/gcclib/powerup_protos.h>
#endif

#include "/va3d_ppc/include/va3d/types.h"
#include "/va3d_ppc/include/va3d/tags.h"
#include "/va3d_ppc/include/va3d_protos.h"

#include "/va3d_support/va3d_display.h"
#include "/va3d_support/va3d_string.h"
#include "/va3d_support/va3d_xpk.h"
#include "/va3d_support/va3d_utility.h"
#include "/va3d_support/va3d_prefs.h"
#include "/va3d_support/va3d_timer.h"

VOID *Module = NULL;
struct DBPlayerBase *DBPlayerBase = NULL;
DVIEW *DView = NULL;
XVIEW *XView=NULL;
LONG Music=0;
LONG ModuleSize;

VOID *EndChunky=NULL;
VOID *EndPalette=NULL;

VOID *StartChunky=NULL;
VOID *StartPalette=NULL;

LONG CurrentTime;

/* render scenes functions */
VOID RenderFunc(SCENE *Scene);
VOID RenderIntroFunc(SCENE *Scene);
VOID PaletteFunc(PALETTE *Palette);

typedef struct Scene_2
          {
          SCENE *Scene;
          PALETTE *Palette;
          }SCENE_2;

SCENE_2 *UFO_Scene=NULL;
SCENE_2 *EXP1_Scene=NULL;
SCENE_2 *BAL_Scene=NULL;
SCENE_2 *PIR_Scene=NULL;
SCENE_2 *ALT1_Scene=NULL;
SCENE_2 *ALT2_Scene=NULL;
SCENE_2 *ALT3_Scene=NULL;
SCENE_2 *EXP2_Scene=NULL;
SCENE_2 *END_Scene=NULL;

PKEY_FRAME PKey[10];
PALETTE *BlackPal=NULL;
PALETTE *WhitePal=NULL;
PALETTE *RedPal=NULL;
PALETTE *tmpALTPalette=NULL;
VOID *tmpptr=NULL;
IMPORT ULONG BlackPalette[770];
ULONG WhitePalette[4000];
ULONG RedPalette[4000];

UBYTE tab[4] = {0xde, 0xad, 0xbe, 0xef};
#define BOUNDARY_SIZE 512

void *va3d_calloc(size_t nsize, size_t nnum)
{
#ifdef _DEBUG__
	return va3d_malloc(nsize*nnum);
#else
  return calloc(nsize,nnum);
#endif
}


void va3d_free(void *adr)
{
#ifdef _DEBUG__
UBYTE *tmp;
UBYTE *tmpl1, *tmpl2;
ULONG size;
LONG i;

	size = *(((ULONG *)adr)-1);
	tmp = ((UBYTE *)adr)-BOUNDARY_SIZE-4;
	tmpl1 = tmp;
	tmpl2 = tmp+BOUNDARY_SIZE+size+4;
	for(i=0; i<BOUNDARY_SIZE; i++)
	{
		if(tmpl1[i] != tab[i&3])
		{
			printf("pre boundary hit\n");
//			for(i=0; i<(BOUNDARY_SIZE>>2); i++)
//				printf("%#x\n", tmpl1[i]);

			PPCFreeVec(tmp);
			return;
		}

		if(tmpl2[i] != tab[i&3])
		{
			printf("post boundary hit\n");
//			for(i=0; i<(BOUNDARY_SIZE>>2); i++)
//				printf("%#x\n", tmpl2[i]);

			PPCFreeVec(tmp);
			return;
		}
	}

	PPCFreeVec(tmp);
#else
 if(adr != NULL)
   free(adr);
  
#endif
}


void *va3d_malloc(size_t size)
{
#ifdef _DEBUG__
UBYTE *tmp;
UBYTE *tmpl1, *tmpl2;
LONG i;

	tmp = PPCAllocVec(size+2*BOUNDARY_SIZE+4, MEMF_CLEAR|MEMF_ANY);

	tmpl1 = tmp;
	tmpl2 = tmp+BOUNDARY_SIZE+size+4;

	for(i=0; i<BOUNDARY_SIZE; i++)
	{
		tmpl1[i] = tab[i&3];
		tmpl2[i] = tab[i&3];
	}

	*((ULONG *)&tmpl1[BOUNDARY_SIZE]) = size;

	return (tmp+BOUNDARY_SIZE+4);
#else
  return malloc(size);
#endif
}

#ifndef __PPC__
STATIC TEXT VersionStr[] = "$VER: The Field Where I Died 1.0 68k " __AMIGADATE__;
#else
STATIC TEXT VersionStr[] = "$VER: The Field Where I Died 1.0 PPC " __AMIGADATE__;
#endif

#define myfree(ptr) \
        va3d_free(ptr);  \
        ptr = NULL;

/* local function definitions */
VOID CleanUP(VOID);
SCENE_2 *LoadAndRelocScene(STRPTR SceneName,STRPTR PaletteName);
VOID FreeScene(SCENE_2 *Scene);
VOID FillPKeyEntry(PKEY_FRAME *CurrentKey,PKEY_FRAME *NextKey,PALETTE *Palette,ULONG Time,ULONG Flags);

#define VISIBLE_ANGLE 45

#ifndef __PPC__
 LONG __near __stack = 100*1024;
#endif

 struct TagItem tmpTagList[20];

LONG LMBStatus(void)
{
 /* dirty hack - dont try this at home */
	return (((*(volatile unsigned char *)0xbfe001)&0x40)==0L);
}

/* main function */
int main(VOID)
{
  PREFS Prefs;
  LONG i;

  WhitePalette[0] = 0x01000000;
  RedPalette[0] = 0x01000000;

    for(i=0;i<256;i++)
	{
	  WhitePalette[3*i+1] = 0xffffffff;
	  WhitePalette[3*i+2] = 0xffffffff;
	  WhitePalette[3*i+3] = 0xffffffff;
	  RedPalette[3*i+1] = 0xffffffff;
	  RedPalette[3*i+2] = 0x0;
	  RedPalette[3*i+3] = 0x0;
	}

  if(!VA3D_LoadPrefs(&Prefs))
     {
        printf("Preference file not found\n");
        printf("Please run VA3D_Prefs.exe first\n");
        exit(0);
     }

	VA3D_InitFFBPpower2();

	VA3D_PrecalcArcSineTable();

	VA3D_InitGlow();

     if(!XPK_Init()) exit(0);
     if(!InitTimer(Prefs.PPCTimer)) 
      {
        printf("Creating timer object failed\n");
        CleanUP();
        exit(0);
      }

   if(Prefs.PlayMusic)
     if((DBPlayerBase = (struct DBPlayerBase *)OpenLibrary("dbplayer.library",DBPLAYER_VERSION)) == NULL)
      {
       printf("Cannot open dbplayer.library, version %d\n",DBPLAYER_VERSION);
       exit(0);
      }

	TAG_ITEM(tmpTagList[0],VA3DOV_DisplayID, Prefs.DisplayID);
	TAG_ITEM(tmpTagList[1],VA3DOV_Depth, 8);
	TAG_ITEM(tmpTagList[2],VA3DOV_Windowed, Prefs.Windowed);
	TAG_ITEM(tmpTagList[3],VA3DOV_DoubleBuffer, Prefs.DoubleBuffer);
	TAG_ITEM(tmpTagList[4],VA3DOV_FPSCounter, Prefs.FPS);
	TAG_ITEM(tmpTagList[5],TAG_DONE,0);

  if((DView = VA3D_OpenView(tmpTagList)) == NULL)
     {
      printf("Cant open view\n");
      CleanUP();
     }

   if(!VA3D_PrecalcPerspectiveTable(VISIBLE_ANGLE,DView->XView->Width,35000))
	{
       CleanUP();
	}

	TAG_ITEM(tmpTagList[0],VA3DAP_RGB32,BlackPalette);
	TAG_ITEM(tmpTagList[1],VA3DAP_CreateOctree,FALSE);
	TAG_ITEM(tmpTagList[2],TAG_DONE,0);
  if((BlackPal = VA3D_AllocPaletteA(tmpTagList)) == NULL) CleanUP();

	TAG_ITEM(tmpTagList[0],VA3DAP_RGB32,WhitePalette);
	TAG_ITEM(tmpTagList[1],VA3DAP_CreateOctree,FALSE);
	TAG_ITEM(tmpTagList[2],TAG_DONE,0);
  if((WhitePal = VA3D_AllocPaletteA(tmpTagList)) == NULL) CleanUP();

	TAG_ITEM(tmpTagList[0],VA3DAP_RGB32,RedPalette);
	TAG_ITEM(tmpTagList[1],VA3DAP_CreateOctree,FALSE);
	TAG_ITEM(tmpTagList[2],TAG_DONE,0);
  if((RedPal = VA3D_AllocPaletteA(tmpTagList)) == NULL) CleanUP();

  if((UFO_Scene = LoadAndRelocScene("Files/UFO.va3d","Files/UFO.palette")) == NULL) CleanUP();
  if((EXP1_Scene = LoadAndRelocScene("Files/experiment_1.va3d","Files/experiment_1.palette")) == NULL) CleanUP();
  if((BAL_Scene = LoadAndRelocScene("Files/Baloon.va3d","Files/Baloon.palette")) == NULL) CleanUP();
  if((PIR_Scene = LoadAndRelocScene("Files/Piramid.va3d","Files/Piramid.palette")) == NULL) CleanUP();
  if((ALT1_Scene = LoadAndRelocScene("Files/Altair_1.va3d","Files/Altair_1.palette")) == NULL) CleanUP();
  if((ALT2_Scene = LoadAndRelocScene("Files/altair_2.va3d","Files/Altair_2.palette")) == NULL) CleanUP();
  if((ALT3_Scene = LoadAndRelocScene("Files/altair_3.va3d","Files/Altair_3.palette")) == NULL) CleanUP();
  if((EXP2_Scene = LoadAndRelocScene("Files/experiment_2.va3d","Files/experiment_2.palette")) == NULL) CleanUP();
  if((END_Scene = LoadAndRelocScene("Files/PPCKiller.va3d","Files/PPCKiller.palette")) == NULL) CleanUP();

  if((tmpptr = XPK_UnPackFile("Files/altair_1_dark.palette")) == NULL) CleanUP();
  if((EndChunky = XPK_UnPackFile("Files/end.chunky")) == NULL) CleanUP();
  if((EndPalette = XPK_UnPackFile("Files/End.palette")) == NULL) CleanUP();
  if((StartChunky = XPK_UnPackFile("Files/Start.chunky")) == NULL) CleanUP();
  if((StartPalette = XPK_UnPackFile("Files/Start.palette")) == NULL) CleanUP();

/*   main part */

	TAG_ITEM(tmpTagList[0],VA3DAP_RGB32,tmpptr);
	TAG_ITEM(tmpTagList[1],VA3DAP_CreateOctree,TRUE);
	TAG_ITEM(tmpTagList[2],TAG_DONE,0);
  if((tmpALTPalette = VA3D_AllocPaletteA(tmpTagList)) == NULL) CleanUP();
	va3d_free(tmpptr);	
  

   if(Prefs.PlayMusic)
     if((Module = XPK_UnPackFile("Files/main.dbm")) == NULL)
      {
        CleanUP();
        exit(0);
      }
      ModuleSize = FileSize;

	TAG_ITEM(tmpTagList[0],VA3DSP_Chunky,(ULONG)StartChunky);
	TAG_ITEM(tmpTagList[1],VA3DSP_Width,640);
	TAG_ITEM(tmpTagList[2],VA3DSP_Height,400);
	TAG_ITEM(tmpTagList[3],VA3DSP_Palette,(ULONG)StartPalette);
	TAG_ITEM(tmpTagList[4],VA3DSP_FadeInColor,0x00000000);
	TAG_ITEM(tmpTagList[5],VA3DSP_FadeOutColor,0x00000000);
	TAG_ITEM(tmpTagList[6],VA3DSP_Fade,TRUE);
	TAG_ITEM(tmpTagList[7],TAG_DONE,0);
  VA3D_ShowPicture(DView,tmpTagList);
  Delay(300);
  VA3D_ClosePicture(TRUE);

   if(Prefs.PlayMusic)
    {
     if(DBM_StartModule(Module,ModuleSize,Prefs.AHIModeID,Prefs.AHIFrequency,DBF_AUTOBOOST) != DBM_OK)
      {
       printf("Can't play module\n");
       Music = 0;
       CleanUP();
       exit(0);
      }
      myfree(Module);
      Music = 1;
    }

/*main part starts here */

       FillPKeyEntry(&PKey[0],&PKey[1],BlackPal,0,0);
       FillPKeyEntry(&PKey[1],&PKey[2],UFO_Scene->Palette,SEC+(SEC/2),PKFF_INTERPOLATE);
       FillPKeyEntry(&PKey[2],NULL,UFO_Scene->Palette,98*SEC,PKFF_NOINTERPOLATE);
	TAG_ITEM(tmpTagList[0],VA3DAS_PKeyFrames,(ULONG)&PKey);
	TAG_ITEM(tmpTagList[1],VA3DAS_PaletteFunc,PaletteFunc);
	TAG_ITEM(tmpTagList[2],VA3DAS_TimerFunc, TimerFunc);
	TAG_ITEM(tmpTagList[3],VA3DAS_RenderFunc, (LONG)RenderFunc);
     TAG_ITEM(tmpTagList[4],TAG_DONE, 0);
	VA3D_AnimSequenceA(UFO_Scene->Scene,tmpTagList);

       FillPKeyEntry(&PKey[0],&PKey[1],WhitePal,0,0);
       FillPKeyEntry(&PKey[1],&PKey[2],EXP1_Scene->Palette,SEC+(SEC/2),PKFF_INTERPOLATE);
       FillPKeyEntry(&PKey[2],&PKey[3],EXP1_Scene->Palette,26*SEC,PKFF_NOINTERPOLATE);
       FillPKeyEntry(&PKey[3],NULL,WhitePal,27*SEC,PKFF_INTERPOLATE);
	TAG_ITEM(tmpTagList[0],VA3DAS_PKeyFrames,(ULONG)&PKey);
	TAG_ITEM(tmpTagList[1],VA3DAS_PaletteFunc,PaletteFunc);
	TAG_ITEM(tmpTagList[2],VA3DAS_TimerFunc, TimerFunc);
	TAG_ITEM(tmpTagList[3],VA3DAS_RenderFunc, (LONG)RenderFunc);
	TAG_ITEM(tmpTagList[4],TAG_DONE, 0);
	VA3D_AnimSequenceA(EXP1_Scene->Scene,tmpTagList);

       FillPKeyEntry(&PKey[0],&PKey[1],WhitePal,0,0);
       FillPKeyEntry(&PKey[1],&PKey[2],BAL_Scene->Palette,SEC,PKFF_INTERPOLATE);
       FillPKeyEntry(&PKey[2],&PKey[3],BAL_Scene->Palette,25*SEC,PKFF_NOINTERPOLATE);
       FillPKeyEntry(&PKey[3],NULL,BlackPal,26*SEC,PKFF_INTERPOLATE);
	TAG_ITEM(tmpTagList[0],VA3DAS_PKeyFrames,(ULONG)&PKey);
	TAG_ITEM(tmpTagList[1],VA3DAS_PaletteFunc,PaletteFunc);
	TAG_ITEM(tmpTagList[2],VA3DAS_TimerFunc, TimerFunc);
	TAG_ITEM(tmpTagList[3],VA3DAS_RenderFunc, (LONG)RenderFunc);
	TAG_ITEM(tmpTagList[4],TAG_DONE, 0);
	VA3D_AnimSequenceA(BAL_Scene->Scene,tmpTagList);

       FillPKeyEntry(&PKey[0],&PKey[1],BlackPal,0,0);
       FillPKeyEntry(&PKey[1],&PKey[2],PIR_Scene->Palette,SEC,PKFF_INTERPOLATE);
       FillPKeyEntry(&PKey[2],NULL,PIR_Scene->Palette,37*SEC,PKFF_NOINTERPOLATE);
	TAG_ITEM(tmpTagList[0],VA3DAS_PKeyFrames,(ULONG)&PKey);
	TAG_ITEM(tmpTagList[1],VA3DAS_PaletteFunc,PaletteFunc);
	TAG_ITEM(tmpTagList[2],VA3DAS_TimerFunc, TimerFunc);
	TAG_ITEM(tmpTagList[3],VA3DAS_RenderFunc, (LONG)RenderFunc);
	TAG_ITEM(tmpTagList[4],TAG_DONE, 0);
	VA3D_AnimSequenceA(PIR_Scene->Scene,tmpTagList);

       FillPKeyEntry(&PKey[0],&PKey[1],BlackPal,0,0);
       FillPKeyEntry(&PKey[1],&PKey[2],ALT1_Scene->Palette,SEC,PKFF_INTERPOLATE);
       FillPKeyEntry(&PKey[2],NULL,ALT1_Scene->Palette,37*SEC,PKFF_NOINTERPOLATE);
	TAG_ITEM(tmpTagList[0],VA3DAS_PKeyFrames,(ULONG)&PKey);
	TAG_ITEM(tmpTagList[1],VA3DAS_PaletteFunc,PaletteFunc);
	TAG_ITEM(tmpTagList[2],VA3DAS_TimerFunc, TimerFunc);
	TAG_ITEM(tmpTagList[3],VA3DAS_RenderFunc, (LONG)RenderFunc);
	TAG_ITEM(tmpTagList[4],TAG_DONE, 0);
	VA3D_AnimSequenceA(ALT1_Scene->Scene,tmpTagList);

       FillPKeyEntry(&PKey[0],&PKey[1],tmpALTPalette,0,0);
       FillPKeyEntry(&PKey[1],&PKey[2],ALT2_Scene->Palette,SEC+(SEC/2),PKFF_INTERPOLATE);
       FillPKeyEntry(&PKey[2],NULL,ALT2_Scene->Palette,37*SEC,PKFF_NOINTERPOLATE);
	TAG_ITEM(tmpTagList[0],VA3DAS_PKeyFrames,(ULONG)&PKey);
	TAG_ITEM(tmpTagList[1],VA3DAS_PaletteFunc,PaletteFunc);
	TAG_ITEM(tmpTagList[2],VA3DAS_TimerFunc, TimerFunc);
	TAG_ITEM(tmpTagList[3],VA3DAS_RenderFunc, (LONG)RenderFunc);
	TAG_ITEM(tmpTagList[4],TAG_DONE, 0);
	VA3D_AnimSequenceA(ALT2_Scene->Scene,tmpTagList);

       FillPKeyEntry(&PKey[0],&PKey[1],WhitePal,0,0);
       FillPKeyEntry(&PKey[1],&PKey[2],ALT3_Scene->Palette,SEC+(SEC/2),PKFF_INTERPOLATE);
       FillPKeyEntry(&PKey[2],NULL,ALT3_Scene->Palette,37*SEC,PKFF_NOINTERPOLATE);
	TAG_ITEM(tmpTagList[0],VA3DAS_PKeyFrames,(ULONG)&PKey);
	TAG_ITEM(tmpTagList[1],VA3DAS_PaletteFunc,PaletteFunc);
	TAG_ITEM(tmpTagList[2],VA3DAS_TimerFunc, TimerFunc);
	TAG_ITEM(tmpTagList[3],VA3DAS_RenderFunc, (LONG)RenderFunc);
	TAG_ITEM(tmpTagList[4],TAG_DONE, 0);
	VA3D_AnimSequenceA(ALT3_Scene->Scene,tmpTagList);

       FillPKeyEntry(&PKey[0],&PKey[1],BlackPal,0,0);
       FillPKeyEntry(&PKey[1],&PKey[2],EXP2_Scene->Palette,SEC+(SEC/2),PKFF_INTERPOLATE);
       FillPKeyEntry(&PKey[2],NULL,EXP2_Scene->Palette,37*SEC,PKFF_NOINTERPOLATE);
	TAG_ITEM(tmpTagList[0],VA3DAS_PKeyFrames,(ULONG)&PKey);
	TAG_ITEM(tmpTagList[1],VA3DAS_PaletteFunc,PaletteFunc);
	TAG_ITEM(tmpTagList[2],VA3DAS_TimerFunc, TimerFunc);
	TAG_ITEM(tmpTagList[3],VA3DAS_RenderFunc, (LONG)RenderFunc);
	TAG_ITEM(tmpTagList[4],TAG_DONE, 0);
	VA3D_AnimSequenceA(EXP2_Scene->Scene,tmpTagList);

       FillPKeyEntry(&PKey[0],&PKey[1],BlackPal,0,0);
       FillPKeyEntry(&PKey[1],&PKey[2],END_Scene->Palette,SEC+(SEC/2),PKFF_INTERPOLATE);
       FillPKeyEntry(&PKey[2],&PKey[3],END_Scene->Palette,34*SEC,PKFF_NOINTERPOLATE);
       FillPKeyEntry(&PKey[3],NULL,BlackPal,35*SEC,PKFF_INTERPOLATE);
	TAG_ITEM(tmpTagList[0],VA3DAS_PKeyFrames,(ULONG)&PKey);
	TAG_ITEM(tmpTagList[1],VA3DAS_PaletteFunc,PaletteFunc);
	TAG_ITEM(tmpTagList[2],VA3DAS_TimerFunc, TimerFunc);
	TAG_ITEM(tmpTagList[3],VA3DAS_RenderFunc, (LONG)RenderFunc);
	TAG_ITEM(tmpTagList[4],TAG_DONE, 0);
	VA3D_AnimSequenceA(END_Scene->Scene,tmpTagList);

/* end of demo. show end scroll ;) */

	TAG_ITEM(tmpTagList[0],VA3DSP_Chunky,(ULONG)EndChunky);
	TAG_ITEM(tmpTagList[1],VA3DSP_Width,640);
	TAG_ITEM(tmpTagList[2],VA3DSP_Height,400);
	TAG_ITEM(tmpTagList[3],VA3DSP_Palette,(ULONG)EndPalette);
	TAG_ITEM(tmpTagList[4],VA3DSP_FadeInColor,0x00000000);
	TAG_ITEM(tmpTagList[5],VA3DSP_FadeOutColor,0x00000000);
	TAG_ITEM(tmpTagList[6],VA3DSP_Fade,TRUE);
	TAG_ITEM(tmpTagList[7],TAG_DONE,0);

  VA3D_ShowPicture(DView,tmpTagList);

#ifdef NO_EXIT
  for(;;);
#else
  while(!LMBStatus());
#endif

	FreeScene(UFO_Scene);
	FreeScene(EXP1_Scene);
	FreeScene(BAL_Scene);
	FreeScene(PIR_Scene);
	FreeScene(ALT1_Scene);
	FreeScene(ALT2_Scene);
	FreeScene(ALT3_Scene);
	FreeScene(EXP2_Scene);
	FreeScene(END_Scene);
  va3d_free(EndPalette);
  va3d_free(EndChunky);

   for(i=0;i<64;i++)
     {
       DBM_SetVolume(64-i);
       Delay(3);
     }
       DBM_SetVolume(0);

   if(Prefs.PlayMusic)
    {
     DBM_StopModule();
     Music = 0;
    }

     CleanUP();
}

VOID CleanUP(VOID)
{
  printf("© 1998 Venus Art. All Rights Reserved.\n");
  if(UFO_Scene) FreeScene(UFO_Scene);
  if(EXP1_Scene) FreeScene(EXP1_Scene);
  if(BAL_Scene) FreeScene(BAL_Scene);
  if(PIR_Scene) FreeScene(PIR_Scene);
  if(ALT1_Scene) FreeScene(ALT1_Scene);
  if(ALT2_Scene) FreeScene(ALT2_Scene);
  if(ALT3_Scene) FreeScene(ALT3_Scene);
  if(EXP2_Scene) FreeScene(EXP2_Scene);
  if(END_Scene) FreeScene(END_Scene);

  if(Module) myfree(Module);
  if(Music) DBM_StopModule();
  if(BlackPal) VA3D_FreePalette(BlackPal);
  if(WhitePal) VA3D_FreePalette(WhitePal);
  if(RedPal) VA3D_FreePalette(RedPal);
  if(tmpALTPalette) VA3D_FreePalette(tmpALTPalette);
  if(DView) VA3D_CloseView(DView);
  XPK_Close();
  if(DBPlayerBase) CloseLibrary((struct Library *)DBPlayerBase);
  RemoveTimer();
  exit(0);
}

VOID RenderFunc(SCENE *Scene)
{
	VA3D_TransformScene(Scene, Scene->Camera, DView->XView);
	VA3D_ClearXView(Scene, DView->XView);
	VA3D_RenderScene(Scene, Scene->Camera, DView->XView, 0);
	VA3D_C2P(DView);
}

SCENE_2 *LoadAndRelocScene(STRPTR SceneName,STRPTR PaletteName)
{
 VOID *tmpSceneData;
 VOID *tmpPaletteData;
 SCENE_2 *Scene;

  if((tmpPaletteData = XPK_UnPackFile(PaletteName)) == NULL) return NULL;
    if((tmpSceneData = XPK_UnPackFile(SceneName)) == NULL) return NULL;
      if((Scene = va3d_malloc(sizeof(SCENE_2))) == NULL) return NULL;

	TAG_ITEM(tmpTagList[0],VA3DAP_RGB32, tmpPaletteData);
	TAG_ITEM(tmpTagList[1],VA3DAP_CreateOctree, TRUE);
	TAG_ITEM(tmpTagList[2],TAG_DONE, 0);
        if((Scene->Palette = VA3D_AllocPaletteA(tmpTagList)) == NULL) return NULL;

          va3d_free(tmpPaletteData);

	TAG_ITEM(tmpTagList[0],VA3DLS_FileAddress, tmpSceneData);
//	TAG_ITEM(tmpTagList[1],VA3DLS_LoadMapFunc, XPK_UnPackFile);
	TAG_ITEM(tmpTagList[1],VA3DLS_Palette, Scene->Palette);
	TAG_ITEM(tmpTagList[2],TAG_DONE, 0);

             if((Scene->Scene = VA3D_LoadSceneA(tmpTagList)) == NULL) return NULL;

          va3d_free(tmpSceneData);

 return Scene;
}

VOID FreeScene(SCENE_2 *Scene)
{
   if(Scene)
    {
    if(Scene->Scene) VA3D_FreeScene(Scene->Scene);
     if(Scene->Palette) VA3D_FreePalette(Scene->Palette);
    va3d_free(Scene);
    }     
}

VOID FillPKeyEntry(PKEY_FRAME *CurrentKey,PKEY_FRAME *NextKey,PALETTE *Palette,ULONG Time,ULONG Flags)
{
     CurrentKey->Next = NextKey;
     CurrentKey->Palette = Palette;
     CurrentKey->Flags = Flags;
     CurrentKey->Time = Time;
}

VOID PaletteFunc(PALETTE *Palette)
{
  SetPalette(DView,Palette->RGB32);
}

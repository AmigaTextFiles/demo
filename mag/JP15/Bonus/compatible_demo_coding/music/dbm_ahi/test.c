#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <exec/types.h>
#include <proto/utility.h>
#include <utility/hooks.h>

#include <proto/exec.h>
#include <devices/ahi.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/asl.h>
#include <proto/ahi.h>

#include <dbplayer/dbplayerbase.h>
#include <proto/dbplayer.h>

UBYTE *Mod;
ULONG ModSize;

struct DBPlayerBase *DBPlayerBase;

struct TagItem ModAttrTags[]=
     {
      {DBMATTR_InstNum,0},
      {DBMATTR_ChanNum,0},
      {DBMATTR_PattNum,0},
      {DBMATTR_ModName,0},
      {DBMATTR_InstNames,0},
      {TAG_DONE,0}
     };


void main(void)
{
 FILE *fp;
 struct FileRequester *FileReq;
 char FileName[256];
 ULONG InstrNum;
 ULONG ChanNum;
 ULONG PattNum;
 STRPTR ModName;
 STRPTR *InstNames;
 LONG i;

  if((DBPlayerBase = (struct DBPlayerBase *)OpenLibrary("dbplayer.library",DBPLAYER_VERSION)) == NULL)
     {
       printf("Cannot open dbplayer.library, version %d\n",DBPLAYER_VERSION);
       exit(0);
     }

  if((FileReq = AllocAslRequestTags(ASL_FileRequest, TAG_DONE)) == NULL)
     {
       printf("Cannot Init AslRequester!\n");
       CloseLibrary((struct Library *)DBPlayerBase);
       exit(0);
     }

	  if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
  	                           ASLFR_SleepWindow, TRUE,
    	                         ASLFR_TitleText, "Select #?.dbm module",
      	                       ASLFR_PositiveText, "Ok",
        	                     ASLFR_NegativeText, "Cancel",
          	                   TAG_DONE))
	  {
  	  strcpy(FileName, FileReq->fr_Drawer);
			AddPart(FileName, FileReq->fr_File, 256);
	  }
		else
		{
               FreeAslRequest(FileReq);
               CloseLibrary((struct Library *)DBPlayerBase);
               exit(0);
		}

     FreeAslRequest(FileReq);

     fp = fopen(FileName,"rb");
     fseek(fp,0,SEEK_END);
     ModSize = ftell(fp);
     fseek(fp,0,SEEK_SET);

     if((Mod = malloc(ModSize)) == NULL)
     {
          printf("Not enough memory\n");
          CloseLibrary((struct Library *)DBPlayerBase);
          exit(0);
     }

     fread(Mod,1,ModSize,fp);
     fclose(fp);


     DBM_StartModule(Mod,ModSize,0,3546895,DBF_AUTOBOOST);

     ModAttrTags[0].ti_Data = (ULONG)&InstrNum;
     ModAttrTags[1].ti_Data = (ULONG)&ChanNum;
     ModAttrTags[2].ti_Data = (ULONG)&PattNum;
     ModAttrTags[3].ti_Data = (ULONG)&ModName;
     ModAttrTags[4].ti_Data = (ULONG)&InstNames;
     DBM_GetModuleAttrA(ModAttrTags);
     printf("%d\n",InstrNum);
     printf("%d\n",ChanNum);
     printf("%d\n",PattNum);
     printf("%s\n",ModName);

     for(i=0;i<InstrNum;i++)
     {
      printf("%s\n",InstNames[i]);
     }

     Delay(1200);
     DBM_StopModule();
     free(Mod);

 if(DBPlayerBase) CloseLibrary((struct Library *)DBPlayerBase);

}

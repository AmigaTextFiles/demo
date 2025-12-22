// Includes
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/cybergraphics.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/asl.h>

#include <clib/Warp3D_protos.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define width  1024
#define height 768

#define M_PI 3.14


#include "math.h"

W3D_Scissor s = {0,0,width,height};

//
struct ScreenBuffer* buffer[2];
int drawBuffer;

void SwitchDisplay(W3D_Context *context,struct Screen *screen)
{

    buffer[drawBuffer]->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort=0;
    while (!ChangeScreenBuffer(screen, buffer[drawBuffer]));
    drawBuffer ^=1;
    W3D_SetDrawRegion(context, buffer[drawBuffer]->sb_BitMap,0, &s);
    WaitBOVP(&(screen)->ViewPort);

}


int esc=FALSE;
void GetInput(struct Window *window)
{

    struct IntuiMessage *imsg;    // used to handle the IDCMP messages through the window

    while(NULL != (imsg = (struct IntuiMessage *)GetMsg(window->UserPort)))
    {
        ReplyMsg((struct Message *)imsg);

        switch(imsg->Class)//ev)
        {
            case IDCMP_VANILLAKEY:

                switch(imsg->Code)
                {
                   case  27:
                   case 'q':        // exit. 27 = esc, and q/Q
                   case 'Q':
                       esc=TRUE;
                       break;
                   case '-':
                     //  z=z-50;
                       break;
                   case '+':
                     //  z=z+50;
                       break;
                   default:
                       break;
                 }

            default:
                break;

        }
    }
}



//protos
void getout(void);

//structs
struct Library             *Warp3DBase;

vertex  vert[10];
vertex  vert_t[10];


    struct Screen *screen;
    struct Window *window;

    W3D_Context *context;
    W3D_Lines line;
    W3D_Vertex lvert[10];


    ULONG CError;
    ULONG OpenErr;
    ULONG ModeID;

    struct BitMap *bm=NULL;

  //  float angle_x=0.0f;
    float angle_y=0.0f;
    int i;//=0;




main()

{
   

    Warp3DBase = OpenLibrary("Warp3D.library", 2L);
    if (!Warp3DBase) {
        printf("Error opening Warp3D library\n");
        getout();
    };



    // asl request can't work , becouse different .. pp mm .. just a different :)
    // so, i use W3D requester.

    ModeID = W3D_RequestModeTags(
            W3D_SMR_TYPE,         W3D_DRIVER_3DHW,
            W3D_SMR_SIZEFILTER,   TRUE,
            W3D_SMR_DESTFMT,      ~W3D_FMT_CLUT,
            ASLSM_MinWidth,       width,
            ASLSM_MinHeight,      height, // min screenmode

            ASLSM_MaxWidth,       width,
            ASLSM_MaxHeight,      height, // max screenmode
            ASLSM_MaxDepth,       32,

    TAG_DONE);


    // open screen

    screen = OpenScreenTags(NULL,
                SA_Depth,     32,
                SA_DisplayID, ModeID,
                SA_ErrorCode, &OpenErr,
                SA_ShowTitle, FALSE,
                SA_Draggable, FALSE,
    TAG_DONE,0);

    if (!screen) {
          fprintf(stderr,"Unable to open screen. Reason: Error code %d\n", OpenErr);
           getout();
    }


    window = OpenWindowTags(NULL,
        WA_CustomScreen,    (ULONG)screen,
        WA_Activate,        TRUE,
        WA_Width,           width,
        WA_Height,          height,
        WA_Left,            0,
        WA_Top,             0,
        WA_Title,           NULL,
        WA_CloseGadget,     FALSE,
        WA_Backdrop,        TRUE,
        WA_Borderless,      TRUE,
        WA_IDCMP,           IDCMP_CLOSEWINDOW|IDCMP_VANILLAKEY|IDCMP_RAWKEY|IDCMP_MOUSEBUTTONS|IDCMP_MOUSEMOVE|IDCMP_DELTAMOVE,
        WA_Flags,           WFLG_REPORTMOUSE|WFLG_RMBTRAP,
    TAG_DONE);


  buffer[0] = AllocScreenBuffer(screen,NULL, SB_SCREEN_BITMAP);
  buffer[1] = AllocScreenBuffer(screen,NULL, 0);
   // bitmap

  bm = screen->RastPort.BitMap;



  // create context
  context = W3D_CreateContextTags(&CError,
          W3D_CC_MODEID,      ModeID,             // Mandatory for non-pubscreen
          W3D_CC_BITMAP,      bm,                 // The bitmap we'll use
          W3D_CC_YOFFSET,     0,                  // We don't do dbuffering
          W3D_CC_DRIVERTYPE,  W3D_DRIVER_BEST,    // Let Warp3D decide
       //   W3D_CC_DOUBLEHEIGHT,TRUE,               // Double height screen
          W3D_CC_FAST,        TRUE,               // Fast drawing
       //   W3D_CC_INDIRECT,    TRUE,
  TAG_DONE);
  if(CError==W3D_SUCCESS){printf("create context success!\n");};
  if(CError==W3D_ILLEGALINPUT){printf("Illigal input!\n");};
  if(CError==W3D_NOMEMORY){printf("no memory\n");};
  if(CError==W3D_NODRIVER){printf("no driver\n");};
  if(CError==W3D_UNSUPPORTEDFMT){printf("usupportedfmt\n");};
  if(CError==W3D_ILLEGALBITMAP){printf("illegal bitmap\n");};


  W3D_LockHardware(context);
  W3D_ClearDrawRegion(context,0xffffffff);  // fill screen with black color
  W3D_UnLockHardware(context);



  W3D_SetState(context, W3D_GOURAUD, W3D_ENABLE);
  W3D_SetState(context, W3D_BLENDING, W3D_ENABLE);
  W3D_SetBlendMode(context, W3D_ONE, W3D_SRC_ALPHA);

while(!esc)
{


  angle_y+=0.001f;
  if(angle_y=1.0f){angle_y=0.0f;};
/*
  angle_x+=0.02f;
  if(angle_x=0.5f){angle_x=0.0f;};
 */

  BuildTransMatrix(0.02f,angle_y, 0.02f);

  vert[0].x =-50; vert[0].y= 50; vert[0].z = 0;
  vert[1].x = 50; vert[1].y= 50; vert[1].z = 0;
  vert[2].x = 50; vert[2].y=-50; vert[2].z = 0;
  vert[3].x =-50; vert[3].y=-50; vert[3].z = 0;
  vert[4].x =-50; vert[4].y= 50; vert[4].z = 0;


  vert[5].x = -50; vert[5].y= 50; vert[5].z = -100;
  vert[6].x =  50; vert[6].y= 50; vert[6].z = -100;
  vert[7].x =  50; vert[7].y=-50; vert[7].z = 100;
  vert[8].x = -50; vert[8].y=-50; vert[8].z = -100;
  vert[9].x = -50; vert[9].y= 50; vert[9].z = 100;





  for(i=0;i<10;i++)
  {
  TransformPoint(&vert_t[i],&vert[i]);
  project(&vert_t[i]);
  }



  lvert[0].x = vert_t[0].sx; lvert[0].y = vert_t[0].sy; lvert[0].color.r = 1.0; lvert[0].color.g=0.0; lvert[0].color.b=0.0;
  lvert[1].x = vert_t[1].sx; lvert[1].y = vert_t[1].sy; lvert[1].color.r = 1.0; lvert[1].color.g=0.0; lvert[1].color.b=0.0;
  lvert[2].x = vert_t[2].sx; lvert[2].y = vert_t[2].sy; lvert[2].color.r = 1.0; lvert[2].color.g=0.0; lvert[2].color.b=0.0;
  lvert[3].x = vert_t[3].sx; lvert[3].y = vert_t[3].sy; lvert[3].color.r = 1.0; lvert[3].color.g=0.0; lvert[3].color.b=0.0;
  lvert[4].x = vert_t[4].sx; lvert[4].y = vert_t[4].sy; lvert[4].color.r = 1.0; lvert[4].color.g=0.0; lvert[4].color.b=0.0;

  lvert[5].x = vert_t[5].sx; lvert[5].y = vert_t[5].sy; lvert[5].color.r = 1.0; lvert[5].color.g=0.0; lvert[5].color.b=0.0;
  lvert[6].x = vert_t[6].sx; lvert[6].y = vert_t[6].sy; lvert[6].color.r = 1.0; lvert[6].color.g=0.0; lvert[6].color.b=0.0;
  lvert[7].x = vert_t[7].sx; lvert[7].y = vert_t[7].sy; lvert[7].color.r = 1.0; lvert[7].color.g=0.0; lvert[7].color.b=0.0;
  lvert[8].x = vert_t[8].sx; lvert[8].y = vert_t[8].sy; lvert[8].color.r = 1.0; lvert[8].color.g=0.0; lvert[8].color.b=0.0;
  lvert[9].x = vert_t[9].sx; lvert[9].y = vert_t[9].sy; lvert[9].color.r = 1.0; lvert[9].color.g=0.0; lvert[9].color.b=0.0;


  line.vertexcount = 10;
  line.v = lvert;


  W3D_LockHardware(context);
  W3D_ClearDrawRegion(context,0xffffffff);
  W3D_DrawLineStrip(context,&line);
  W3D_UnLockHardware(context);

  SwitchDisplay(context,screen);
  GetInput(window);




}





 // do you not want to destroy context ?:) try it.
  W3D_DestroyContext(context);

    if (buffer[0])
    {
        buffer[0]->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = NULL;
        while (!ChangeScreenBuffer(screen, buffer[0])){Delay(1);}
    }

    for (i=0; i<2; i++)
    {
        if (buffer[i])
        {
            FreeScreenBuffer(screen, buffer[i]);
            buffer[i] = NULL;
        }
    }


  CloseWindow(window);
  CloseScreen(screen);


  getout();


}

void getout(void)
{

    if (Warp3DBase)    CloseLibrary(Warp3DBase);
    exit(0);

}

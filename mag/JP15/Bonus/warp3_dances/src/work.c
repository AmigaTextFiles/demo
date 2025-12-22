// Includes
#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/asl.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/cybergraphics.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <clib/Warp3D_protos.h>

#include <cybergraphx/cybergraphics.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define width  1024
#define height 768

#include "texture.h"
#include "math.h"

W3D_Scissor s = {0,0,width,height};
W3D_Scissor up = {0,0,1024,150};
W3D_Scissor down = {0,618,1024,150};

struct IntuitionBase *IntuitionBase;
struct GfxBase       *GfxBase;
struct Library       *Warp3DBase;

struct Screen  *screen;
struct Window *window;

int z=0;
//
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
                       z=z-50;
                       break;
                   case '+':
                       z=z+50;
                       break;
                   default:
                       break;
                 }

             case IDCMP_RAWKEY:

                 switch(imsg->Code)
                 {
                    case 0x4f:       // left
                        break;
                    case 0x4e:       // right
                        break;
                    case 0x4c:       // up
                        break;
                    case 0x4d:       // down
                        break;
                    default:
                        break;
                 }

  
            default:
                break;

        }
    }
}

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



vertex  vert[10];
vertex  vert_t[10];


// main
void main(int argc, char **argv)
{
    ULONG ModeID;
    ULONG OpenErr, CError;
    struct BitMap *bm = NULL;

    W3D_Context *context = NULL;

    W3D_Triangles tris;
    W3D_Vertex verts[10];

    float angle_y=0.0f;
    int i=0;

    static UWORD *pointer = 0;


    if(!(IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 0L)))
    {
        printf("Error: failed to open intuition.library\n");
        goto panic;
    }

    if(!(GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 0L)))
    {
        printf("Error: failed to open graphics.library\n");
        goto panic;
    }

    Warp3DBase = OpenLibrary("Warp3D.library", 2L);
    if (!Warp3DBase) {
        printf("Error opening Warp3D library\n");
        goto panic;
    };



    ModeID = W3D_RequestModeTags(
            W3D_SMR_TYPE,         W3D_DRIVER_3DHW,
            W3D_SMR_SIZEFILTER,   TRUE,
            W3D_SMR_DESTFMT,      ~W3D_FMT_CLUT,
            ASLSM_MinWidth,       width,
            ASLSM_MinHeight,      height, // min screenmode

            ASLSM_MaxWidth,       width,
            ASLSM_MaxHeight,      height, // max screenmode
            ASLSM_MaxDepth,       16,

    TAG_DONE);


    // open screen

    screen = OpenScreenTags(NULL,
                SA_Depth,     16,
                SA_DisplayID, ModeID,
                SA_ErrorCode, &OpenErr,
                SA_ShowTitle, FALSE,
                SA_Draggable, FALSE,
    TAG_DONE,0);

    if (!screen) {
          fprintf(stderr,"Unable to open screen. Reason: Error code %d\n", OpenErr);
           goto panic;
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


  //bm = window->RPort->BitMap;

    buffer[0] = AllocScreenBuffer(screen,NULL, SB_SCREEN_BITMAP);
    buffer[1] = AllocScreenBuffer(screen,NULL, 0);
   // bitmap

   bm = screen->RastPort.BitMap;
   //bm=buffer[1]->sb_BitMap;


// --------Create Context

  context = W3D_CreateContextTags(&CError,
          W3D_CC_MODEID,      ModeID,             // Mandatory for non-pubscreen
          W3D_CC_BITMAP,      bm,                 // The bitmap we'll use
          W3D_CC_YOFFSET,     0,
          W3D_CC_DRIVERTYPE,  W3D_DRIVER_BEST,    // Let Warp3D decide
          W3D_CC_FAST,        TRUE,               // Fast drawing
  TAG_DONE);
  if(CError==W3D_SUCCESS){printf("create context success!\n");};
  if(CError==W3D_ILLEGALINPUT){printf("Illigal input!\n");goto panic;};
  if(CError==W3D_NOMEMORY){printf("no memory\n");goto panic;};
  if(CError==W3D_NODRIVER){printf("no driver\n");goto panic;};
  if(CError==W3D_UNSUPPORTEDFMT){printf("usupportedfmt\n");goto panic;};
  if(CError==W3D_ILLEGALBITMAP){printf("illegal bitmap\n");goto panic;};
 


     // set drawing region
   //W3D_SetDrawRegion(context, buffer[1]->sb_BitMap, 0, &s);


// Auto Texture Management
    W3D_SetState(context, W3D_AUTOTEXMANAGEMENT, W3D_ENABLE);

    MyLoad(context);

// The texture color is used for the triangle.
    W3D_SetTexEnv(context, tex, W3D_MODULATE, NULL);

// Allow texmapping
    W3D_SetState(context, W3D_TEXMAPPING, W3D_ENABLE);


// Set States for Alpha Blend
    W3D_SetState(context, W3D_GOURAUD, W3D_ENABLE);
    W3D_SetState(context, W3D_BLENDING, W3D_ENABLE);
//    W3D_SetBlendMode(context, W3D_SRC_ALPHA, W3D_DST_ALPHA);
    W3D_SetState(context, W3D_SCISSOR, W3D_ENABLE);

 // Set liner filter
    W3D_SetFilter(context,tex,W3D_LINEAR,W3D_LINEAR);

 //  W3D_SetState(context,W3D_CULLFACE,W3D_ENABLE);

 // Set Screen to BLACK
//    W3D_LockHardware(context);
//    W3D_ClearDrawRegion(context,0xffffffff);
//    W3D_UnLockHardware(context);


// ........ Comon ! ......


//  buffer[0]->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = NULL;
//  while (!ChangeScreenBuffer(screen, buffer[0]));


  // clear mouse pointer
 pointer = AllocVec(12, MEMF_CLEAR|MEMF_CHIP);printf("clear mouse pointer\n");
 if(pointer) SetPointer(window, pointer, 1, 16, 0, 0);



while(!esc)

{

  GetInput(window);  // escape ?


  angle_y+=0.001f;
  if(angle_y>0.01f) {angle_y=0.0f;};
  BuildTransMatrix(0.02f,angle_y, 0.02f);


  vert[0].x =   0; vert[0].y=  170; vert[0].z = z;//0;
  vert[1].x =  150; vert[1].y= -150; vert[1].z =z;// 0;
  vert[2].x = -150; vert[2].y=  150; vert[2].z =z;// 0;

  vert[3].x = -150;  vert[3].y = 170; vert[3].z = -200;
//  vert[4].x =  150;  vert[4].y = -150; vert[4].z = 100;

//  vert[3].x =  0;  vert[3].y = 170; vert[3].z = -50;

 /*
  vert[3].x = 100;  vert[3].y = -20; vert[3].z = -100;
  vert[3].x = 100;  vert[3].y = -20; vert[3].z = -100;
  vert[3].x = 100;  vert[3].y = -20; vert[3].z = -100;
  */


  for(i=0;i<10;i++)
  {
  TransformPoint(&vert_t[i],&vert[i]);
  project(&vert_t[i]);
  }



  verts[0].x = vert_t[0].sx; verts[0].y = vert_t[0].sy;  verts[0].u = Square[3].u;  verts[0].v = Square[3].v;   verts[0].color.r=1.0; verts[0].color.g=1.0;verts[0].color.b=1.0; verts[0].color.a =1;
  verts[1].x = vert_t[1].sx; verts[1].y = vert_t[1].sy;  verts[1].u = Square[1].u;  verts[1].v = Square[1].v;   verts[1].color.r=1.0; verts[1].color.g=1.0;verts[1].color.b=1.0; verts[1].color.a =1;
  verts[2].x = vert_t[2].sx; verts[2].y = vert_t[2].sy;  verts[2].u = Square[0].u;  verts[2].v = Square[0].v;   verts[2].color.r=1.0; verts[2].color.g=1.0;verts[2].color.b=1.0; verts[2].color.a =1;

  verts[3].x = vert_t[3].sx; verts[3].y = vert_t[3].sy;  verts[3].u = Square[3].u;  verts[3].v = Square[3].v;   verts[3].color.r=1.0; verts[3].color.g=1.0;verts[3].color.b=1.0; verts[3].color.a =1;
//  verts[4].x = vert_t[4].sx; verts[4].y = vert_t[4].sy;  verts[4].u = Square[3].u;  verts[4].v = Square[3].v;

//  verts[5].x = vert_t[5].sx; verts[5].y = vert_t[5].sy;  verts[5].u = Square[0].u;  verts[5].v = Square[0].v;
 /*
  verts[3].x = vert_t[3].sx; verts[3].y = vert_t[3].sy;  verts[3].u = Square[3].u;  verts[3].v = Square[0].v;
  verts[3].x = vert_t[3].sx; verts[3].y = vert_t[3].sy;  verts[3].u = Square[3].u;  verts[3].v = Square[0].v;
  verts[3].x = vert_t[3].sx; verts[3].y = vert_t[3].sy;  verts[3].u = Square[3].u;  verts[3].v = Square[0].v;
  */


  tris.tex = tex;
  tris.vertexcount = 4;
  tris.v = verts;


  W3D_LockHardware(context);

  W3D_SetScissor(context,&s);
  W3D_ClearDrawRegion(context,0xffffffff);  // fill screen with black color
  W3D_DrawTriStrip(context,&tris);

  W3D_SetScissor(context,&up);
  W3D_ClearDrawRegion(context,0x00000000);  // fill screen with black color

  W3D_SetScissor(context,&down);     // down line
  W3D_ClearDrawRegion(context,0x00000000);

  W3D_UnLockHardware(context);

  SwitchDisplay(context,screen);


}




 
panic:
    printf("Closing down...\n");
    if (tex)            W3D_FreeTexObj(context, tex);
    if (context)        W3D_DestroyContext(context);

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

    FreeVec(pointer);

    if (window)         CloseWindow(window);
    if (screen)         CloseScreen(screen);
    if (Warp3DBase)     CloseLibrary(Warp3DBase);
    if(IntuitionBase) CloseLibrary((struct Library *)IntuitionBase);
    if(GfxBase)       CloseLibrary((struct Library *)GfxBase);
    exit(0);
}
//

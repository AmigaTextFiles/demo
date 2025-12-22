#include <stdio.h>

#include <dos/dos.h>
#include <exec/types.h>

#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/cybergraphics_protos.h>
#include <clib/intuition_protos.h>

#include <pragmas/dos_pragmas.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/cybergraphics_pragmas.h>

#include <cybergraphx/cybergraphics.h>

#include <jpeg/jpeg.h>
#include <jpeg/jpeg_protos.h>
#include <jpeg/jpeg_pragmas.h>


extern struct Library *DOSBase;
struct Library *JpegBase, *IntuitionBase;
struct CyberGfxBase *CyberGfxBase = NULL;


int main(int argc, char* argv[])
{
        ULONG DisplayID;
        struct Screen *scr;
        struct Window *win;
        struct JPEGDecHandle *jph;
        UBYTE *buffer;
        BPTR fp;

        JpegBase = OpenLibrary( "jpeg.library", 5 );
        if (!JpegBase) {
            printf("Error opening jpeg library\n");
            goto panic;
        };


        IntuitionBase = OpenLibrary( "intuition.library", 0L );
        if (!IntuitionBase) {
            printf("Error opening Intuition library\n");
            goto panic;
        };


        CyberGfxBase = (struct CyberGfxBase *)OpenLibrary( "cybergraphics.library", 0L );
        if (!CyberGfxBase) {
            printf("Error opening cybergraphics library\n");
            goto panic;
        };



        fp = Open( argv[1], MODE_OLDFILE );
        if(fp==0){printf("can't open file\n");goto panic;};



        AllocJPEGDecompress( &jph,
                            JPG_SrcFile, fp,
                            TAG_DONE );


        buffer = AllocBufferFromJPEG( jph,
                            //JPG_ScaleNum, 1, JPG_ScaleDenom, 2,
                            TAG_DONE );


        DecompressJPEG( jph,
                        JPG_DestRGBBuffer, buffer,
                         //  JPG_ProgressHook, progressFunc,
                         //  JPG_ScaleNum, 1, JPG_ScaleDenom, 2,
                         //  JPG_DCTMethod, DCT_FLOAT,
                         TAG_DONE );


       DisplayID = BestCModeIDTags( CYBRBIDTG_NominalWidth, 640,
                                    CYBRBIDTG_NominalHeight, 480,
                                    CYBRBIDTG_Depth, 24,
                                    TAG_DONE );

       scr = OpenScreenTags( NULL,
                                        SA_Title, "Proof",
                                        SA_DisplayID, DisplayID,
                                        SA_Depth, GetCyberIDAttr( CYBRIDATTR_DEPTH, DisplayID ),
                                        TAG_DONE );

       win = OpenWindowTags( NULL,
                                            WA_Title, "Proof",
                                            WA_Flags, WFLG_ACTIVATE | WFLG_SIMPLE_REFRESH |
                                                WFLG_SIZEGADGET | WFLG_RMBTRAP | WFLG_DRAGBAR |
                                                WFLG_DEPTHGADGET | WFLG_CLOSEGADGET,
                                            WA_IDCMP, IDCMP_CLOSEWINDOW | IDCMP_REFRESHWINDOW |
                                                IDCMP_SIZEVERIFY | IDCMP_NEWSIZE | IDCMP_RAWKEY,
                                            WA_Left, 16,
                                            WA_Top, scr->BarHeight+16,
                                            WA_Width, 640,
                                            WA_Height, 480,
                                            WA_CustomScreen, scr,
                                            TAG_DONE );


       WritePixelArray( buffer, 0, 0, 1920, win->RPort, 0, 0, 640, 480, RECTFMT_RGB);

       Delay(200);


       CloseWindow( win );
       CloseScreen( scr );
       FreeJPEGBuffer( buffer );
       FreeJPEGDecompress( jph );


       Close(fp);


       panic:
       if ( JpegBase) CloseLibrary( JpegBase );
       if ( IntuitionBase ) CloseLibrary ( IntuitionBase );
       if ( CyberGfxBase ) CloseLibrary ( (struct Library *)CyberGfxBase );


       return 0;
}


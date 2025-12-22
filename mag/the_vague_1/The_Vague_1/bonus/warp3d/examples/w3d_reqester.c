// Includes
#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/asl.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <clib/Warp3D_protos.h>
#include <clib/asl_protos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//protos
void getout(void);

//structs
struct Library             *Warp3DBase;


main()

{
    ULONG ModeID;




    Warp3DBase = OpenLibrary("Warp3D.library", 2L);
    if (!Warp3DBase) {
        printf("Error opening Warp3D library\n");
        goto panic;
    };


    ModeID = W3D_RequestModeTags(
            W3D_SMR_TYPE,         W3D_DRIVER_3DHW,
            W3D_SMR_SIZEFILTER,   TRUE,
            W3D_SMR_DESTFMT,      ~W3D_FMT_CLUT,
            ASLSM_MinWidth,       640,
            ASLSM_MinHeight,      480, // min screenmode

            ASLSM_MaxWidth,       640,
            ASLSM_MaxHeight,      480, // max screenmode
            ASLSM_MaxDepth,       16,

    TAG_DONE);


panic:
  if (Warp3DBase)    CloseLibrary(Warp3DBase);
  exit(0);

}

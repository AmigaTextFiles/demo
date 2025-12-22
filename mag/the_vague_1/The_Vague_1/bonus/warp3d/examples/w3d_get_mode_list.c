#include <proto/exec.h>
#include <proto/dos.h>

#include <clib/Warp3D_protos.h>
#include <proto/intuition.h>
#include <proto/gadtools.h>

#include <stdio.h>


struct Library *Warp3DBase;

int main (void)

{
W3D_ScreenMode *list;
W3D_ScreenMode *node;

Warp3DBase = OpenLibrary ("Warp3D.library",3);
if (!Warp3DBase)
{
Printf ("cannot open Warp3D.library version 3\n");
return (20);
}


//-------
if (list = W3D_GetScreenmodeList())
{

  for (node = list; node != NULL; node = node->Next)
  {

      if (node->Width == 640 && node->Height == 480 &&  node->Depth == 16
       && node->Driver->swdriver == FALSE)


        { printf("mode: %3ldx%3ld %2ldbit\n", node->Width, node->Height, node->Depth);};
  }

W3D_FreeScreenmodeList (list);
}
//-------



else
Printf ("no screen mode found\n");

CloseLibrary (Warp3DBase);

return (0);
}

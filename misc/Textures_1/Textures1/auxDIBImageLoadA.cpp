// dtimage support by Stefan Haubenthal

#include <proto/exec.h>
#include <proto/dtimage.h>
#include "Textures.h"

_AUX_RGBImageRec *auxDIBImageLoadA(const char *filename)
{
static struct _AUX_RGBImageRec AUX_RGBImageRec;
static unsigned char defimg[] = {0, 255, 255, 0};
struct DTImageBase *DTImageBase = (struct DTImageBase *) OpenLibrary("dtimage.library", 1);
ULONG w, h, retval=0;
UBYTE *image;

 if (DTImageBase)
  {
   retval = DTI_ReadPic32((char *) filename, &image, &w, &h, 0L);
   CloseLibrary((Library *) DTImageBase);
  }
 if (!retval)
  {
   w = h = 2;
   image = defimg;
  }
 AUX_RGBImageRec.sizeX = w;
 AUX_RGBImageRec.sizeY = h;
 AUX_RGBImageRec.data = image;
// gluBuild2DMipmaps(GL_TEXTURE_2D, channels, w, h, asAlpha ? GL_ALPHA : GL_RGBA, GL_UNSIGNED_BYTE, image);
// FreeVec(image);
return &AUX_RGBImageRec;
}

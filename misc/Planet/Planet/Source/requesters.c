/*  requesters.h
 *
 *  Author: Norman Walter
 *  Date: 5.2.2006
 */

#include "requesters.h"

void MessageBox(char *title, char *message)
{
   struct EasyStruct MsgWindow =
   {
      sizeof(struct EasyStruct),
      0,
      title,     // Window title
      "%s",      // Requester text string
      "Ok",      // Button text
   };

   EasyRequest(NULL,&MsgWindow,NULL,message);
}

void TextureInfo(char *title, char *name, int width, int height)
{
   struct EasyStruct MsgWindow =
   {
      sizeof(struct EasyStruct),
      0,
      title,                                        // Window title
      "Texture name: %s\nWidth: %ld\nHeight: %ld",  // Requester text string
      "Ok",                                         // Button text
   };

   EasyRequest(NULL,&MsgWindow,NULL,name,width,height);
}

void LoadError(char *title, char *name)
{
   struct EasyStruct MsgWindow =
   {
      sizeof(struct EasyStruct),
      0,
      title,                // Window title
      "Unable to load %s",  // Requester text string
      "Ok",                 // Button text
   };

   EasyRequest(NULL,&MsgWindow,NULL,name);
}

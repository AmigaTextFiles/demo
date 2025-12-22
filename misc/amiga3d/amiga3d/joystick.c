#include <exec/types.h>
#include <exec/memory.h>
#include <graphics/gfx.h>
#include <devices/gameport.h>
#include <devices/inputevent.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include "joystick.h"

/*#define DEBUG*/
/*#define DEBUGSTATE*/

#define MAXNUMEVENTS 2

extern LONG IntuitionBase;

struct IntuiText ErrorText= {   /* text for error-requester */
    0, 1, JAM1,   /* FrontPen, BackPen, DrawMode */
    10, 10,      /* LeftEdge, TopEdge */
    NULL,      /* ITextFont */
    "3D:   Software Error:", /* IText */
    NULL       /* NextText */
};

struct IntuiText AbortMessage= {   /* more text for error-message requester */
    0, 1, JAM1,   /* FrontPen, BackPen, DrawMode */
    11, 45,      /* LeftEdge, TopEdge */
    NULL,      /* ITextFont */
    "Select ABORT to exit", /* IText */
    NULL      /* NextText */
};

struct IntuiText ResumeMessage= {   /* more text for error-message requester */
    0, 1, JAM1,   /* FrontPen, BackPen, DrawMode */
    11, 45,      /* LeftEdge, TopEdge */
    NULL,      /* ITextFont */
    "Select RESUME to continue", /* IText */
    NULL      /* NextText */
};

struct IntuiText AbortText= {   /* more text for error-requester */
    0, 1, JAM1,   /* FrontPen, BackPen, DrawMode */
    6, 4,      /* LeftEdge, TopEdge */
    NULL,      /* ITextFont */
    "ABORT",      /* IText */
    NULL      /* NextText */ 
};

struct IntuiText ResumeText= {   /* more text for error-requester */
    0, 1, JAM1,   /* FrontPen, BackPen, DrawMode */
    6, 4,      /* LeftEdge, TopEdge */
    NULL,      /* ITextFont */
    "RESUME",      /* IText */
    NULL      /* NextText */ 
};

extern struct MsgPort *CreatePort();
extern DeletePort();
extern struct IOStdReq *CreateStdIO();      
extern DeleteStdIO();      

/******************************************************************************/

ULONG set_flags(joystick_data,flags)      
struct InputEvent *joystick_data;
ULONG flags;
{
   SHORT xmove, ymove;

   xmove = joystick_data->ie_X;
   ymove = joystick_data->ie_Y;

   switch(ymove)
   {
       case(-1):   flags |=  BUTTON_FORWARD;
             flags &= ~BUTTON_BACK;
         break;
       case( 0):   flags &= ~BUTTON_FORWARD;
             flags &= ~BUTTON_BACK;
         break;
       case( 1):   flags &= ~BUTTON_FORWARD;
             flags |=  BUTTON_BACK;
         break;
       default:   break;
   }

   switch(xmove)
   {
       case(-1):   flags |=  BUTTON_LEFT;
             flags &= ~BUTTON_RIGHT;
         break;
       case( 0):   flags &= ~BUTTON_LEFT;
             flags &= ~BUTTON_RIGHT;
         break;
       case( 1):   flags &= ~BUTTON_LEFT;
             flags |=  BUTTON_RIGHT;
         break;
       default:   break;
   }

   if(joystick_data->ie_Code != IECODE_NOBUTTON)
   {
       if(joystick_data->ie_Code == IECODE_LBUTTON) 
       {
      if (!(flags & ACTION))
      {
          flags |=  BUTTON_DOWN;
          flags &= ~NO_BUTTON;
      }
       }
       if(joystick_data->ie_Code == (IECODE_LBUTTON + IECODE_UP_PREFIX))
       {
      if (!(flags & BUTTON_DOWN))
      {
          flags |=  BUTTON_UP;
          flags &= ~NO_BUTTON; 
      }
      else
      {
          if (!(flags & ACTION))
          {
         flags |=  ACTION;
         flags |=  BUTTON_UP; 
         flags &= ~NO_BUTTON;
          }
          else
          {
         flags |=  BUTTON_UP;
         flags &= ~NO_BUTTON; 
          }
      }
       }
   }
   else
   {
       if (!(flags & ACTION))
       {
      if (!(flags & (BUTTON_DOWN | BUTTON_UP)))
      {
          flags |=  NO_BUTTON;
      }
       }
   }

   if (flags & ACTION)
   {
       UBYTE actioncount;

       actioncount = ((flags & 0xFF00) >> 8 );
       actioncount += 1;
       flags = ( (flags & 0xFFFF00FF) | (actioncount<<8) );
       flags &= ~BUTTON_DOWN;
       flags &= ~BUTTON_UP;
       flags &= ~ACTION;
   }

#ifdef DEBUG
   switch(ymove) 
   {
       case (-1):  switch(xmove)
         {
             case(-1):   
#ifdef DEBUG
               printf("NW");
#endif
               break;
             case( 0):   
#ifdef DEBUG
               printf("N ");
#endif
               break;
             case( 1):   
#ifdef DEBUG
               printf("NE");
#endif
               break;
             default:   break;
         }
         break;
       case ( 0):  switch(xmove)
         {
             case(-1):   
#ifdef DEBUG
               printf(" W");
#endif
               break;
             case( 0):   
#ifdef DEBUG
               printf("  ");
#endif
               break;
             case( 1):   
#ifdef DEBUG
               printf(" E");
#endif
               break;
             default:   break;
         }
         break;
       case ( 1):  switch(xmove)
         {
             case(-1):   
#ifdef DEBUG
                   printf("SW");
#endif
               break;
             case( 0):   
#ifdef DEBUG
               printf("S ");
#endif
               break;
             case( 1):   
#ifdef DEBUG
               printf("SE");
#endif
               break;
             default:   break;
         }
         break;
       default:   break;
   }
#endif

#ifdef DEBUG
   if(joystick_data->ie_Code != IECODE_NOBUTTON)
   {
       if(joystick_data->ie_Code == IECODE_LBUTTON) 
#ifdef DEBUG
       printf("!");
#endif
       if(joystick_data->ie_Code == (IECODE_LBUTTON + IECODE_UP_PREFIX))
#ifdef DEBUG
       printf("#");
#endif
   }
   else
   {
#ifdef DEBUG
       /* printf(" "); */
#endif
   }
#endif

   return(flags);
}

struct IOStdReq *open_joystick()
{
    struct MsgPort *joystick_msg_port;
    struct IOStdReq *joystick_io_request;
    BYTE *joystick_eventbuf;
    struct Message *message;
    LONG error = FALSE;

#ifdef DEBUG
    printf("joystick...entering\n");
#endif

    if ( (IntuitionBase = OpenLibrary("intuition.library", 31)) == NULL)
    {
   ErrorText.NextText = &AbortMessage;
   AutoRequest(NULL, &ErrorText, NULL, &AbortText, 0, 0, 330, 75);
   exit(0);
    }

    /* allocate memory for the joystick event buffer */

    if ( (joystick_eventbuf = (BYTE *)AllocMem(sizeof(struct InputEvent)*MAXNUMEVENTS,MEMF_PUBLIC|MEMF_CLEAR)) == NULL)
    {
   ErrorText.NextText = &AbortMessage;
   AutoRequest(NULL, &ErrorText, NULL, &AbortText, 0, 0, 330, 75);
   exit(0);
    }

    /* provide a port for the IO request/response */

    joystick_msg_port = CreatePort("joystickport",0);   

    if(joystick_msg_port == 0)
    {
   ErrorText.NextText = &AbortMessage;
   AutoRequest(NULL, &ErrorText, NULL, &AbortText, 0, 0, 330, 75);
   exit(-1);
    }

    /* make an io request block for communicating with the joystick device */

    joystick_io_request = CreateStdIO(joystick_msg_port);     

    if(joystick_io_request == 0)
    {
   ErrorText.NextText = &AbortMessage;
   AutoRequest(NULL, &ErrorText, NULL, &AbortText, 0, 0, 330, 75);
   DeletePort(joystick_msg_port);
   exit(-2);
    }

    /* open the gameport device for access, unit 1 is right port */

    if(OpenDevice("gameport.device",1,joystick_io_request,0))
    {
   ErrorText.NextText = &AbortMessage;
   AutoRequest(NULL, &ErrorText, NULL, &AbortText, 0, 0, 330, 75);
   FreeMem(joystick_eventbuf,sizeof(struct InputEvent) * MAXNUMEVENTS);
   DeleteStdIO(joystick_io_request);
   DeletePort(joystick_msg_port);
   exit(-4);
    }

    /* set the device type to absolute joystick */

    if (set_controller_type(joystick_io_request,GPCT_ABSJOYSTICK) != 0)
    {
   ErrorText.NextText = &AbortMessage;
   AutoRequest(NULL, &ErrorText, NULL, &AbortText, 0, 0, 330, 75);
   FreeMem(joystick_eventbuf,sizeof(struct InputEvent) * MAXNUMEVENTS);
   DeleteStdIO(joystick_io_request);
   DeletePort(joystick_msg_port);
   exit(-4);
    }

    /* trigger on button-down, button-up, front, back, left, right, center  */

    if (set_controller_trigger(joystick_io_request,GPTF_UPKEYS+GPTF_DOWNKEYS,1,1,1) != 0)
    {
   ErrorText.NextText = &AbortMessage;
   AutoRequest(NULL, &ErrorText, NULL, &AbortText, 0, 0, 330, 75);
   FreeMem(joystick_eventbuf,sizeof(struct InputEvent) * MAXNUMEVENTS);
   DeleteStdIO(joystick_io_request);
   DeletePort(joystick_msg_port);
   exit(-4);
    }

    /* SETUP THE IO MESSAGE BLOCK FOR THE ACTUAL DATA READ */

    /* gameport.device replies to this task */
    joystick_io_request->io_Message.mn_ReplyPort = joystick_msg_port;

    /* from now on, just read input events */
    joystick_io_request->io_Command = GPD_READEVENT;   
    
    /* into the input buffer, one at a time. */
    joystick_io_request->io_Data = joystick_eventbuf;      

    /* read num events each time we go back to the joystickport */
    joystick_io_request->io_Length = sizeof(struct InputEvent)* MAXNUMEVENTS;   

    return(joystick_io_request);

}


ULONG test_joystick(joystick_io_request,state)
struct IOStdReq *joystick_io_request;
ULONG state;
{
    ULONG flags;
    struct InputEvent *joystick_data;

    /* test the joystick */
   
    if (DoIO(joystick_io_request)) return(state);

    flags = state;

    for (joystick_data = joystick_io_request->io_Data; joystick_data; joystick_data = joystick_data->ie_NextEvent)
    {
   flags = set_flags(joystick_data,flags);   
    }
    state = flags;

#ifdef DEBUGSTATE
    printf("\nstate: %4lx",state);
#endif

    return(state);

}


close_joystick(joystick_io_request)
struct IOStdReq *joystick_io_request;
{

    /* close up joystick device */
    
    CloseDevice(joystick_io_request);

    /* clean up */

    FreeMem(joystick_io_request->io_Data,sizeof(struct InputEvent) * MAXNUMEVENTS);
    
    DeletePort(joystick_io_request->io_Message.mn_ReplyPort);

    DeleteStdIO(joystick_io_request);


}


int set_controller_type(ior,type)
struct IOStdReq *ior;
BYTE type;
{
   ior->io_Command = GPD_SETCTYPE;   
   ior->io_Length = 1;

   /* set type of controller to "type" */
   ior->io_Data = &type;

#ifdef DEBUG
   printf("joystick:set_controller_type\n");
#endif
   return(DoIO(ior));
}

int set_controller_trigger(ior,keys,timeout,xdelta,ydelta)
struct IOStdReq *ior;
UWORD keys,timeout,xdelta,ydelta;
{
   struct GamePortTrigger gpt;

   ior->io_Command = GPD_SETTRIGGER;   
   ior->io_Length = sizeof(gpt);
   ior->io_Data = &gpt;
   gpt.gpt_Keys = keys;
   gpt.gpt_Timeout = timeout;
   gpt.gpt_XDelta = xdelta;
   gpt.gpt_YDelta = ydelta;

#ifdef DEBUG
   printf("joystick:set_controller_trigger\n");
#endif
   return(DoIO(ior));
}

/*
main()
{
    ULONG state = 0;
    struct IOStdReq *ior;

    if ((ior = open_joystick()) == NULL)
    {
   exit(-1);
    }
    else
    {
       while ( ( (state & 0xFF00) >> 8 ) != 0xF )
       {
       state = test_joystick(ior,state);      
       }
       close_joystick(ior);
    }
    exit(0);
}
*/

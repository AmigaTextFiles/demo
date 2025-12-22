#include <exec/types.h>

const int pixeldepth = 8; // Number of bits/pixel
const int screenwidth  = 320; // Screenwidth = Winwidth
const int screenheight = 256; // Screenheight = Winheight
const int palettecolors = 256;
const int music=1;

void message(char *inputmess);
void shutdown(char *mess);    // Shut down program and return system resources...
void startup(void);  // Open libraries, screen etc. etc. etc.

extern struct Library *ExecBase;
extern struct Library *IntuitionBase;
extern struct Library *GfxBase;
extern struct Library *AslBase;
extern struct Library *MEDPlayerBase;

extern struct Window *demowindow;
extern struct Screen *demoscreen;
extern struct RastPort *demorport;

extern struct ScreenBuffer *screenbuffers[];
extern struct MsgPort *screenbufferports[];
extern int screennr;


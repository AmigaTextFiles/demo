#include <exec/types.h>

const int chunkywidth = 256;
const int chunkyheight = 256;
const int picwidth = 320;
const int picheight = 256;

extern struct BitMap *bitmap1;

void deinitchunky(int width, int height, UBYTE **chunkyptr);
UBYTE *initchunky(int width, int height);
//void deinitchunky(void);
//void initchunky(void);
void deinitbitmap(void);
void initbitmap(void);
int loadchunkypic(char filename[], void *dest, int picwidth, int picheight);
int loadtable(char filename[], UBYTE dest[], int tabwidth, int tabheight);
int loadbmap(char filename[], struct BitMap *dest, int width, int height);
int loadilbmap(char filename[], struct BitMap *dest, int width, int height);


#include <exec/types.h>

extern unsigned long int newpalette[]; // Maximum 256 colors!
extern UBYTE *palette;

void maketpalette(UBYTE *chgpalette, int level);
void setpalen(UBYTE colortable[], int colors); // Can handle maximum 256 colors!
int loadpalette(char filename[], UBYTE dest[], int colors);
void fadedownpal(UBYTE *chgpalette, UBYTE *srcpalette, int colors);
void fadeuppal(UBYTE *chgpalette, UBYTE *srcpalette, int colors);


#include "i_main.h"
#include "m_main.h"

unsigned char *mouse=(unsigned char *)0xbfe001;

void    i_init(void)
{

}


void    i_shutdown(void)
{

}

char    i_getkey(void)
{
        if (!(*mouse&64)) return i_esc;
        else return 0;

}


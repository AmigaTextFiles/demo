
#define XS 320
#define YS 192

static unsigned lookup[XS*YS];

void mosaic_init(int tilesize)
{
    int x,y,tx,ty,sx,sy;

    for(ty=0;ty<YS;ty+=tilesize)
        for(tx=0;tx<XS;tx+=tilesize)
        {
            sx=(tx-XS/2)*50/100+XS/2;
            sy=(ty-YS/2)*50/100+YS/2;

            for(y=0;y<tilesize;y++)
                for(x=0;x<tilesize;x++)
                {
                    if(x+tx>=XS || y+ty>=YS)
                        continue;
                    lookup[(ty+y)*XS+tx+x]=(sy+y)*XS+sx+x;
                }
        }
}

void mosaic(char *buf1,char *buf2)
{
    int i;

    for(i=0;i<XS*YS;i++)
        *buf2++=buf1[lookup[i]];
}

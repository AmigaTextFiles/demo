/* Horizontal moving average filter 
   by Yzi/Fit 2000-07-23
*/

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 192

#define MAXBLUR (SCREEN_WIDTH*2)

static int 
  maf_divtable[MAXBLUR+1][256];

void init_maf(void)
{
    int i, j;

    for (i=0; i<256; i++)
        for (j=0; j<MAXBLUR; j++)
            maf_divtable[j][i] = (j ? i/j : 255);
} /* init maf */

void horiz_maf(unsigned char *srcbuf,unsigned char *destbuf,
               int srcx1, int srcy1,
               int destx1, int desty1, 
               int width, int height,
			   int bufwidth, int bufheight,
			   int filterwidth)
{
	int y,av,*divtable;
        unsigned char
        srcpix1, srcpix2,
        *_src, *src1, *src2, 
        *_dest, *dest;

    divtable = maf_divtable[filterwidth];
        
    _src = srcbuf + srcx1 + srcy1 * bufwidth;
    _dest = destbuf + destx1 + desty1 * bufwidth;

    for (y=desty1; y<desty1+height; y++)
    {
        src1 = _src - filterwidth;
        src2 = _src;
        dest = _dest - (filterwidth >> 1);

        /* Initialize the moving average */
        av=0;

        /* Build the average for the leftmost pixel */
        for (; dest<_dest; src1++, src2++, dest++)
        {
            srcpix2 = *src2;
            av += divtable[srcpix2];
        }

        /* Start outputting, add to avg only */
        for (; src1<_src; src1++, src2++, dest++)
        {
            srcpix2 = *src2;
            av += divtable[srcpix2];
            *dest = av;
        }

        /* Now add and subtract */
        for (; src2<(_src+width); src1++, src2++, dest++)
        {
            srcpix1 = *src1;
            srcpix2 = *src2;
            av += divtable[srcpix2] - divtable[srcpix1];
            *dest = av;
        }

        /* Subtract only*/
        for (; dest<(_dest+width); src1++, dest++)
        {
            srcpix1 = *src1;
            av -= divtable[srcpix1];
            *dest = av;
        }

        /* Go to next line */
        _src += bufwidth;
        _dest += bufwidth;
        
    } /* for y*/

} /* horiz_maf */

void vert_maf(unsigned char *srcbuf, unsigned char *destbuf,
              int srcx1, int srcy1, 
              int destx1, int desty1, 
              int width, int height,
			  int bufwidth, int bufheight,
			  int filterheight)
{
	int x,av,*divtable;
        unsigned char srcpix1, srcpix2,
        *_src, *src1, *src2, 
        *_dest, *dest;

    _src = srcbuf + srcx1 + srcy1 * bufwidth;
    _dest = destbuf + destx1 + desty1 * bufwidth;

    divtable = maf_divtable[filterheight];
        
    for (x=destx1; x<destx1+width; x++)
    {
        src1 = _src - filterheight * bufwidth;
        src2 = _src;
        dest = _dest - (filterheight >> 1) * bufwidth;

        /* Initialize the moving average */
        av=0;

        /* Build the average for the first pixel */
        for (; dest<_dest; src1+=bufwidth, src2+=bufwidth, dest+=bufwidth)
        {
            srcpix2 = *src2;
            av += divtable[srcpix2];
        }            

        /* Start outputting, add to avg only */
        for (; src1<_src; src1+=bufwidth, src2+=bufwidth, dest+=bufwidth)
        {
            srcpix2 = *src2;
            av += divtable[srcpix2];
            *dest = av;
        }

        /* Now add and subtract */
        for (; src2<(_src+height*bufwidth); src1+=bufwidth, src2+=bufwidth, dest+=bufwidth)
        {
            srcpix1 = *src1;
            srcpix2 = *src2;
            av += divtable[srcpix2] - divtable[srcpix1];
            *dest = av;
        }

        /* Subtract only*/
        for (; dest<(_dest+height*bufwidth); src1+=bufwidth, dest+=bufwidth)
        {
            srcpix1 = *src1;
            av -= divtable[srcpix1];
            *dest = av;
        }

        /* Go to next column */
        _src++;
        _dest++;

    } /* for x */

} /* vert_maf */

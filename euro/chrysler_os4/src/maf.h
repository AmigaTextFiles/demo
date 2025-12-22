
#ifndef MAF_H
#define MAF_H

void init_maf(void);

void horiz_maf(unsigned char *srcbuf,unsigned char *destbuf,
               int srcx1, int srcy1,
               int destx1, int desty1, 
               int width, int height,
			   int bufwidth, int bufheight,
			   int filterwidth);

void vert_maf(unsigned char *srcbuf, unsigned char *destbuf,
              int srcx1, int srcy1, 
              int destx1, int desty1, 
              int width, int height,
			  int bufwidth, int bufheight,
			  int filterheight);

#endif

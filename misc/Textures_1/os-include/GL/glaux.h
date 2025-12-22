#warning Unsupported TinyGL header
#ifndef GLAUX_H
#define GLAUX_H

#include <stdlib.h>/* malloc, free */
#include <proto/tinygl.h>
#define PostQuitMessage(x)

struct _AUX_RGBImageRec {
	GLsizei sizeX, sizeY;
	void *data;
};
_AUX_RGBImageRec *auxDIBImageLoadA(const char *filename);

#endif /* GLAUX_H */

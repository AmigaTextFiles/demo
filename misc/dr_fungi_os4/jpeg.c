// A little wrapper for the jpeglib
// -Marq

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <jpeglib.h>

unsigned char *loadJPG(char *path,int *width,int *height)
{
    FILE    *f;
    JSAMPARRAY  buffer;
    struct  jpeg_decompress_struct cinfo;
    struct  jpeg_error_mgr jerr;
    int     row_stride;
    unsigned char   *pixels;

    if((f=fopen(path,"rb"))==NULL)
        return(NULL);

    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_decompress(&cinfo);
    jpeg_stdio_src(&cinfo,f);
    jpeg_read_header(&cinfo, TRUE);

    *width=cinfo.image_width;
    *height=cinfo.image_height;

    row_stride=cinfo.image_width*3;
    buffer = (*cinfo.mem->alloc_sarray)
             ((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);

    pixels=malloc(row_stride*(cinfo.image_height+1));

    jpeg_start_decompress(&cinfo);

    while (cinfo.output_scanline < cinfo.image_height)
    {
        jpeg_read_scanlines(&cinfo, buffer, 1);
        memcpy(&pixels[(cinfo.output_scanline-1)*row_stride],buffer[0],row_stride);
    }

    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);

    fclose(f);

    return(pixels);
}

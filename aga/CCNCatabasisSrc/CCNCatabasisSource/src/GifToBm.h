
#ifndef _AMIGAGIFTOBM_
#define _AMIGAGIFTOBM_

#define LZ_MAX_CODE         4095    /* Biggest code possible in 12 bits. */

typedef int GifBooleanType;
typedef unsigned char GifPixelType;
typedef unsigned char *GifRowType;
typedef unsigned char GifByteType;

typedef unsigned short GifPrefixType;
typedef short GifWord;

#define GIF_ERROR   0
#define GIF_OK      1

typedef struct GifColorType {
    GifByteType Red, Green, Blue;
} GifColorType;

typedef struct ColorMapObject {
    int ColorCount;
    int BitsPerPixel;
    GifColorType *Colors;    /* on malloc(3) heap */
} ColorMapObject;

typedef struct GifImageDesc {
    GifWord Left, Top, Width, Height,   /* Current image dimensions. */
      Interlace;                    /* Sequential/Interlaced lines. */

    ColorMapObject *ColorMap;       /* The local color map */
} GifImageDesc;

/* This is the in-core version of an extension record */
typedef struct {
    int ByteCount;
    char *Bytes;    /* on malloc(3) heap */
    int Function;   /* Holds the type of the Extension block. */
} ExtensionBlock;

/* This holds an image header, its unpacked raster bits, and extensions */
typedef struct SavedImage {
    GifImageDesc ImageDesc;
    unsigned char *RasterBits;  /* on malloc(3) heap */
    int Function;   /* DEPRECATED: Use ExtensionBlocks[x].Function instead */
    int ExtensionBlockCount;
    ExtensionBlock *ExtensionBlocks;    /* on malloc(3) heap */
} SavedImage;


typedef struct GifFilePrivateType {
	char *UData;           /* hook to attach user data (TVT) */
    int DataLeft;

	//GifFileType pub;
    GifWord SWidth, SHeight,        /* Screen dimensions. */
      SColorResolution,         /* How many colors can we generate? */
      SBackGroundColor;         /* I hope you understand this one... */
//vf bye bye    ColorMapObject *SColorMap;  
    /* NULL if not exists. */
    int ImageCount;             /* Number of current image */
    GifImageDesc Image;         /* Block describing current image */
    struct SavedImage *SavedImages; /* Use this to accumulate file state */
   
    char *fimage;
     //old   VoidPtr Private;  
	int m_GifError;	
	
	// - - - - - - - - -
    GifWord  /*FileHandle,*/  /* Where all this data goes to! */
      BitsPerPixel,     /* Bits per pixel (Codes uses at least this + 1). */
      ClearCode,   /* The CLEAR LZ code. */
      EOFCode,     /* The EOF LZ code. */
      RunningCode, /* The next code algorithm can generate. */
      RunningBits, /* The number of bits required to represent RunningCode. */
      MaxCode1,    /* 1 bigger than max. possible code, in RunningBits bits. */
      LastCode,    /* The code before the current code. */
      CrntCode,    /* Current algorithm code. */
      StackPtr,    /* For character stack (see below). */
      CrntShiftState;    /* Number of bits in CrntShiftDWord. */
    unsigned long CrntShiftDWord;   /* For bytes decomposition into codes. */
    unsigned long PixelCount;   /* Number of pixels in image. */
//    FILE *File;    /* File as stream. */
//    InputFunc Read;     /* function to read gif input (TVT) */
//    OutputFunc Write;   /* function to write gif output (MRB) */

	// vf adds for chunky->planar and 16b alignment buffer
	unsigned short _alwidth; //pixel width 16b aligned, possible +16 empty when bob flag
	unsigned short _readHeight; // if use c2p, use temp chunky with 16 lines height, else real height in pure chunky decode
	unsigned short _nbPlanes;
	// end vf adds
    GifByteType Buf[256];   /* Compressed input is buffered here. */
    GifByteType Stack[LZ_MAX_CODE]; /* Decoded pixels are stacked here. */
    GifByteType Suffix[LZ_MAX_CODE + 1];    /* So we can trace the codes. */
    GifPrefixType Prefix[LZ_MAX_CODE + 1];
    //GifHashTableType *HashTable;
} GifFilePrivateType;

/*
	Flags for GifBinToBm():
*/
/*
	G2BMFLAGS_INTERLEAVEDPLANES
	will return line-interleaved planes, just like AllocBitmap()'s BMF_INTERLEAVED
*/
#define G2BMFLAGS_INTERLEAVEDPLANES	4
/*
	G2BMFLAGS_ADD_EMPTY_RIGHT_COLUMN16
	real bitamp is always aligned to 16 pixels width for blitter use.
	this option extends the width again of 16 pixels with a 0-filled column.
	It is done both on returned outputBM and outputMask.
	This is a common technique, to be able to use bitmap or Blitter Object
	when you scroll horizontally per pixels. (to work with asm funcs like MBobI()
	in the asm blitter project)
*/
#define G2BMFLAGS_ADD_EMPTY_RIGHT_COLUMN16	8


// no align flag= align16 (1word)
// want align on 4bytes (some aga blitter mode)
#define G2BMFLAGS_Align32 16
// want align on 8bytes (some aga blitter mode)
#define G2BMFLAGS_Align64 32


/*
	if outputBM not null, must be closed by GifToBm_FreeBitMap()
	if outputMask  not null, must be closed by GifToBm_FreeBitMap()
*/

// use private asm struct

typedef struct
{
    unsigned short   BytesPerRow;
    unsigned short   Rows;
    unsigned char   Flags;
    unsigned char   Depth;
    unsigned short   pad;
    char * Planes[8];
    // legal OS struct still here, extend this:
    unsigned int	PlaneSize;
	char	*	ChipAlloc;
} sBitMap;


typedef struct {
    unsigned short ColorCount;
    unsigned short BitsPerPixel;
	unsigned char sColors[256*3];    /* on malloc(3) heap */
} sPalette;


// data from ASM with pre-alloc stuff
typedef struct {
	char			*_GifBin;
	unsigned int 	_FileSize;
	unsigned int    _Flags;
	sBitMap			*_pSBitmap;
	sBitMap			*_pSBmMask;
	sPalette		**_ppPalette;
	GifFilePrivateType	_gifp;
} sGifParams;


int GifBinToSBm(sGifParams *gifParams);

//no need, mem private managed: void GifToBm_FreeBitMap(struct BitMap *pbm);


#endif

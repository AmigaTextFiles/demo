/*
	Gif Reader To Amiga Bitmap
*/

typedef unsigned int UINT32;

#include "GifToBm.h"

#include <proto/exec.h>
#include <exec/memory.h>
// for AllocRaster and struct Bitmap:
#include <proto/graphics.h>
#include <graphics/gfxbase.h>
#include <proto/dos.h>

//#define MDEBUG  1
// redirect malloc/calloc on out own pre-alloc management

extern unsigned int debugv;


extern  char *  __asm __regargs InAlloc(
					register __d0 unsigned int bsize,
					register __d1 int prefs
					);
extern void __asm __regargs InFree(
					register __a0 char *pmem
					);

void memset(void *pt,char mm,unsigned int bs){
	unsigned int ii;
	char *pcd=pt;
	for(ii=0;ii<bs;ii++) {
		*pcd++=mm;
	}	
}

void *malloc(unsigned int bs,int usecase){

	char *ptr=InAlloc(bs,0);
	/*
	{
		int vt[3];
		vt[0]=bs; vt[1]=(int)ptr; vt[2]=usecase;
		VPrintf("malloc size:%ld ptr:%lx use:%ld\n",&vt[0]);
	}
	*/
	return(ptr);
}

void *calloc(unsigned int bs,unsigned int n, int usecase){
	char *ptr=InAlloc(bs*n,0);
/*
	{
		int vt[3];
		vt[0]=bs*n; vt[1]=(int)ptr; vt[2]=usecase;
		VPrintf("malloc size:%ld ptr:%lx use:%ld\n",&vt[0]);
	}
	*/
	return(ptr);
}

void free(void *ptr){
/*	  {
		int vt[1];
		vt[0]=(int)ptr;

		VPrintf("free:%lx\n",&vt[0]);
	}
*/
	InFree(ptr);
}

void memcpy(void *pd,void *po,unsigned int bs){
	unsigned int ii;
	char *pcd=pd;
	char *pco=po;
	for(ii=0;ii<bs;ii++) {
		*pcd++=*pco++;
	}	
}
void *realloc(void *ptr,unsigned int ns,int usecase){
	unsigned int ors,crs;
	unsigned int *iptr,*nptr;

#ifdef MDEBUG
	int vt[3];
	vt[0]=(int)ptr;
	vt[1]=ns+4;
	vt[2]=usecase;	
	VPrintf("realloc() ptr:%lx size:%ld case:%ld\n",&vt[0]);
#endif
	
	if(ptr==0L) {
		return malloc(ns,0);
	}		
	iptr=(unsigned int *)ptr;
	iptr--;
	ors=*iptr-4;
	if(ns==ors) return ptr;
	nptr=malloc(ns,0);
	if(nptr==0L) return 0L;
	crs=ors;
	if(ns<crs) crs=ns;
	memcpy(nptr,ptr,crs);
	free(ptr);
	return nptr;
}

#ifndef TRUE
#define TRUE        1
#endif /* TRUE */
#ifndef FALSE
#define FALSE       0
#endif /* FALSE */

typedef enum {
    UNDEFINED_RECORD_TYPE,
    SCREEN_DESC_RECORD_TYPE,
    IMAGE_DESC_RECORD_TYPE, /* Begin with ',' */
    EXTENSION_RECORD_TYPE,  /* Begin with '!' */
    TERMINATE_RECORD_TYPE   /* Begin with ';' */
} GifRecordType;


#define LZ_BITS             12

#define FLUSH_OUTPUT        4096    /* Impossible code, to signal flush. */
#define FIRST_CODE          4097    /* Impossible code, to signal first. */
#define NO_SUCH_CODE        4098    /* Impossible code, to signal empty. */

#define FILE_STATE_WRITE    0x01
#define FILE_STATE_SCREEN   0x02
#define FILE_STATE_IMAGE    0x04
#define FILE_STATE_READ     0x08

#define GRAPHICS_EXT_FUNC_CODE    0xf9    /* graphics control */

#define GIF_STAMP "GIFVER"          /* First chars in file - GIF stamp.  */
#define GIF_STAMP_LEN sizeof(GIF_STAMP) - 1
/* return smallest bitfield size n will fit in */
int BitSize(int n) {
    
    register int i;

    for (i = 1; i <= 8; i++)
        if ((1 << i) >= n)
            break;
    return (i);
}

/******************************************************************************
 * Setup the LZ decompression for this image:
 *****************************************************************************/

// static memory reader:
__inline void READ1( GifFilePrivateType *pReader,char *pBuf)
{
	*pBuf= *(pReader->UData++);
	pReader->DataLeft--;
}
int
DGifGetWord( GifFilePrivateType *pReader,
            GifWord *Word) {

	register unsigned char  *pp=(unsigned char *)pReader->UData;
    *Word = (((unsigned int)pp[1]) << 8) + pp[0];
    pReader->UData+=2;
    pReader->DataLeft-=2;
    return GIF_OK;
}
extern int __asm __regargs gifRead(
					register __a0 GifFilePrivateType *pReader,
					register __a1 char *pBuf,
					register __d0 int len
					);
//#define READ    gifRead


static int READ( GifFilePrivateType *pReader,char *pBuf,int len)
{
	int ii;
	char *pread;
	int dtl= pReader->DataLeft;
	if(dtl<=0) return 0;
	if(len>dtl) len=dtl;
	pread = pReader->UData;
	for(ii=0;ii<len;ii++) *pBuf++=*pread++;
	pReader->UData=pread;
	pReader->DataLeft-=len;
	return len;
}
 
static int DGifSetupDecompress(GifFilePrivateType * GifFile) {

    int i, BitsPerPixel;
    GifByteType CodeSize;
    GifPrefixType *Prefix;
    GifFilePrivateType *Private = (GifFilePrivateType *)GifFile;


	READ1(GifFile, &CodeSize);
	
	BitsPerPixel = CodeSize;

    Private->Buf[0] = 0;    /* Input Buffer empty. */
    Private->BitsPerPixel = BitsPerPixel;
    Private->ClearCode = (1 << BitsPerPixel);
    Private->EOFCode = Private->ClearCode + 1;
    Private->RunningCode = Private->EOFCode + 1;
    Private->RunningBits = BitsPerPixel + 1;    /* Number of bits per code. */
    Private->MaxCode1 = 1 << Private->RunningBits;    /* Max. code + 1. */
    Private->StackPtr = 0;    /* No pixels on the pixel stack. */
    Private->LastCode = NO_SUCH_CODE;
    Private->CrntShiftState = 0;    /* No information in CrntShiftDWord. */
    Private->CrntShiftDWord = 0;

    Prefix = Private->Prefix;
    for (i = 0; i <= LZ_MAX_CODE; i++)
        Prefix[i] = NO_SUCH_CODE;

    return GIF_OK;
}


/*
 * Allocate a color map of given size; initialize with contents of
 * ColorMap if that pointer is non-NULL.
 */
ColorMapObject *
MakeMapObject(int ColorCount,
              const GifColorType * ColorMap) {
    
    ColorMapObject *cmObject;

    /*** FIXME: Our ColorCount has to be a power of two.  Is it necessary to
     * make the user know that or should we automatically round up instead? */
    if (ColorCount != (1 << BitSize(ColorCount))) {
        return ((ColorMapObject *) NULL);
    }
    
    cmObject = (ColorMapObject *) malloc(sizeof(ColorMapObject),1);
    if (cmObject == (ColorMapObject *) NULL) {
        return ((ColorMapObject *) NULL);
    }

    cmObject->Colors = (GifColorType *)calloc(ColorCount, sizeof(GifColorType),10);
    if (cmObject->Colors == (GifColorType *) NULL) {
        return ((ColorMapObject *) NULL);
    }

    cmObject->ColorCount = ColorCount;
    cmObject->BitsPerPixel = BitSize(ColorCount);

    if (ColorMap) {
        memcpy((char *)cmObject->Colors,
               (char *)ColorMap, ColorCount * sizeof(GifColorType));
    }

    return (cmObject);
}

/*
 * Free a color map object
 */
void FreeMapObject(ColorMapObject * Object) {

    if (Object != NULL) {
        free(Object->Colors);
        free(Object);
        /*** FIXME:
         * When we are willing to break API we need to make this function
         * FreeMapObject(ColorMapObject **Object)
         * and do this assignment to NULL here:
         * *Object = NULL;
         */
    }
}

/******************************************************************************
 * This routine should be called before any attempt to read an image.
 * Note it is assumed the Image desc. header (',') has been read.
 *****************************************************************************/
static int
DGifGetImageDesc(GifFilePrivateType *pReader) {

    int i, BitsPerPixel;
    GifByteType Buf[4];
    SavedImage *sp;

    if (DGifGetWord(pReader, &pReader->Image.Left) == GIF_ERROR ||
        DGifGetWord(pReader, &pReader->Image.Top) == GIF_ERROR ||
        DGifGetWord(pReader, &pReader->Image.Width) == GIF_ERROR ||
        DGifGetWord(pReader, &pReader->Image.Height) == GIF_ERROR)
        return GIF_ERROR;
	READ1(pReader, Buf);

    BitsPerPixel = (Buf[0] & 0x07) + 1;
    pReader->Image.Interlace = (Buf[0] & 0x40);
    if (Buf[0] & 0x80) {    /* Does this image have local color map? */
        /*** FIXME: Why do we check both of these in order to do this? 
         * Why do we have both Image and SavedImages? */
        if (pReader->Image.ColorMap && pReader->SavedImages == NULL)
            FreeMapObject(pReader->Image.ColorMap);

        pReader->Image.ColorMap = MakeMapObject(1 << BitsPerPixel, NULL);
        if (pReader->Image.ColorMap == NULL) {
           // _GifError = D_GIF_ERR_NOT_ENOUGH_MEM;
            return GIF_ERROR;
        }

        /* Get the image local color map: */
        for (i = 0; i < pReader->Image.ColorMap->ColorCount; i++) {
            if (READ(pReader, Buf, 3) != 3) {
                FreeMapObject(pReader->Image.ColorMap);
               // _GifError = D_GIF_ERR_READ_FAILED;
                pReader->Image.ColorMap = NULL;
                return GIF_ERROR;
            }
            pReader->Image.ColorMap->Colors[i].Red = Buf[0];
            pReader->Image.ColorMap->Colors[i].Green = Buf[1];
            pReader->Image.ColorMap->Colors[i].Blue = Buf[2];
        }
    } else if (pReader->Image.ColorMap) {
        FreeMapObject(pReader->Image.ColorMap);
        pReader->Image.ColorMap = NULL;
    }

    if (pReader->SavedImages) {
    //	printf(" REALLOC SavedImages:%d\n",pReader->ImageCount);
        if ((pReader->SavedImages = (SavedImage *)realloc(pReader->SavedImages,
                                      sizeof(SavedImage) *
                                      (pReader->ImageCount + 1),20)) == NULL) {
          //  _GifError = D_GIF_ERR_NOT_ENOUGH_MEM;
            return GIF_ERROR;
        }
    } else {
        if ((pReader->SavedImages =
             (SavedImage *) malloc(sizeof(SavedImage),2)) == NULL) {
           // _GifError = D_GIF_ERR_NOT_ENOUGH_MEM;
            return GIF_ERROR;
        }
    }

    sp = &pReader->SavedImages[pReader->ImageCount];
    memcpy(&sp->ImageDesc, &pReader->Image, sizeof(GifImageDesc));
    if (pReader->Image.ColorMap != NULL) {
        sp->ImageDesc.ColorMap = MakeMapObject(
                                 pReader->Image.ColorMap->ColorCount,
                                 pReader->Image.ColorMap->Colors);
        if (sp->ImageDesc.ColorMap == NULL) {
            //_GifError = D_GIF_ERR_NOT_ENOUGH_MEM;
            return GIF_ERROR;
        }
    }
    sp->RasterBits = (unsigned char *)NULL;
    sp->ExtensionBlockCount = 0;
    sp->ExtensionBlocks = (ExtensionBlock *) NULL;

    pReader->ImageCount++;

    pReader->PixelCount = (long)pReader->Image.Width *
       (long)pReader->Image.Height;

    DGifSetupDecompress(pReader);  /* Reset decompress algorithm parameters. */

    return GIF_OK;
}
static int DGifBufferedInput(GifFilePrivateType * GifFile,
                  GifByteType * Buf,
                  GifByteType * NextByte) {

    if (Buf[0] == 0) {
        /* Needs to read the next buffer - this one is empty: */
		READ1(GifFile, Buf);

        /* There shouldn't be any empty data blocks here as the LZW spec
         * says the LZW termination code should come first.  Therefore we
         * shouldn't be inside this routine at that point.
         */
#ifdef DOTEST
		if (Buf[0] == 0) {
            return GIF_ERROR;
        }
		if (READ(GifFile, &Buf[1], Buf[0]) != Buf[0]) {

			return GIF_ERROR;
		}
#endif
		READ(GifFile, &Buf[1], Buf[0]);
        *NextByte = Buf[1];
        Buf[1] = 2;    /* We use now the second place as last char read! */
        Buf[0]--;
    } else {
        *NextByte = Buf[Buf[1]++];
        Buf[0]--;
    }

    return GIF_OK;
}
static int DGifDecompressInput(GifFilePrivateType * GifFile,
                    int *Code) {

    GifByteType NextByte;
    static unsigned short CodeMasks[] = {
        0x0000, 0x0001, 0x0003, 0x0007,
        0x000f, 0x001f, 0x003f, 0x007f,
        0x00ff, 0x01ff, 0x03ff, 0x07ff,
        0x0fff
    };
#ifdef DOTEST
    /* The image can't contain more than LZ_BITS per code. */
    if (GifFile->RunningBits > LZ_BITS) {
        //_GifError = D_GIF_ERR_IMAGE_DEFECT;
        return GIF_ERROR;
    }
    while (GifFile->CrntShiftState < GifFile->RunningBits) {
        /* Needs to get more bytes from input stream for next code: */
        if (DGifBufferedInput(GifFile, GifFile->Buf, &NextByte) == GIF_ERROR) {
            return GIF_ERROR;
        }
        GifFile->CrntShiftDWord |=
           ((unsigned long)NextByte) << GifFile->CrntShiftState;
        GifFile->CrntShiftState += 8;
    }
#endif
    while (GifFile->CrntShiftState < GifFile->RunningBits) {
        /* Needs to get more bytes from input stream for next code: */
		DGifBufferedInput(GifFile, GifFile->Buf, &NextByte);

        GifFile->CrntShiftDWord |=
           ((unsigned long)NextByte) << GifFile->CrntShiftState;
        GifFile->CrntShiftState += 8;
    }


    *Code = GifFile->CrntShiftDWord & CodeMasks[GifFile->RunningBits];

    GifFile->CrntShiftDWord >>= GifFile->RunningBits;
    GifFile->CrntShiftState -= GifFile->RunningBits;

    /* If code cannot fit into RunningBits bits, must raise its size. Note
     * however that codes above 4095 are used for special signaling.
     * If we're using LZ_BITS bits already and we're at the max code, just
     * keep using the table as it is, don't increment Private->RunningCode.
     */
    if (GifFile->RunningCode < LZ_MAX_CODE + 2 &&
            ++GifFile->RunningCode > GifFile->MaxCode1 &&
            GifFile->RunningBits < LZ_BITS) {
        GifFile->MaxCode1 <<= 1;
        GifFile->RunningBits++;
    }
    return GIF_OK;
}
static int DGifGetPrefixChar(GifPrefixType *Prefix,
                  int Code,
                  int ClearCode) {

	register int i = 0;
    while (Code > ClearCode && i++ <= LZ_MAX_CODE) {
#ifdef	DOTEST
		if (Code > LZ_MAX_CODE) {
            return NO_SUCH_CODE;
        }
#endif
        Code = Prefix[Code];
    }
    return Code;
}

static int DGifDecompressLine(GifFilePrivateType * GifFile,
                   GifPixelType * Line,
                   int LineLen) {

    int i = 0;
    int j, CrntCode, EOFCode, ClearCode, CrntPrefix, LastCode, StackPtr;
    GifByteType *Stack, *Suffix;
    GifPrefixType *Prefix;
   
    StackPtr = GifFile->StackPtr;
    Prefix = GifFile->Prefix;
    Suffix = GifFile->Suffix;
    Stack = GifFile->Stack;
    EOFCode = GifFile->EOFCode;
    ClearCode = GifFile->ClearCode;
    LastCode = GifFile->LastCode;
#ifdef DOTEST
    if (StackPtr > LZ_MAX_CODE) {
        return GIF_ERROR;
    }
#endif
    if (StackPtr != 0) {
        /* Let pop the stack off before continueing to read the gif file: */
        while (StackPtr != 0 && i < LineLen)
            Line[i++] = Stack[--StackPtr];
    }
#ifdef	DOTEST
    while (i < LineLen) {    /* Decode LineLen items. */

        if (DGifDecompressInput(GifFile, &CrntCode) == GIF_ERROR)
            return GIF_ERROR;

        if (CrntCode == EOFCode) {
            /* Note however that usually we will not be here as we will stop
             * decoding as soon as we got all the pixel, or EOF code will
             * not be read at all, and DGifGetLine/Pixel clean everything.  */
            if (i != LineLen - 1 || GifFile->PixelCount != 0) {
              //  _GifError = D_GIF_ERR_EOF_TOO_SOON;
                return GIF_ERROR;
            }
            i++;
        } else if (CrntCode == ClearCode) {
            /* We need to start over again: */
            for (j = 0; j <= LZ_MAX_CODE; j++)
                Prefix[j] = NO_SUCH_CODE;
            GifFile->RunningCode = GifFile->EOFCode + 1;
            GifFile->RunningBits = GifFile->BitsPerPixel + 1;
            GifFile->MaxCode1 = 1 << GifFile->RunningBits;
            LastCode = GifFile->LastCode = NO_SUCH_CODE;
        } else {
            /* Its regular code - if in pixel range simply add it to output
             * stream, otherwise trace to codes linked list until the prefix
             * is in pixel range: */
            if (CrntCode < ClearCode) {
                /* This is simple - its pixel scalar, so add it to output: */
                Line[i++] = CrntCode;
            } else {
                /* Its a code to needed to be traced: trace the linked list
                 * until the prefix is a pixel, while pushing the suffix
                 * pixels on our stack. If we done, pop the stack in reverse
                 * (thats what stack is good for!) order to output.  */
                if (Prefix[CrntCode] == NO_SUCH_CODE) {
                    /* Only allowed if CrntCode is exactly the running code:
                     * In that case CrntCode = XXXCode, CrntCode or the
                     * prefix code is last code and the suffix char is
                     * exactly the prefix of last code! */
                    if (CrntCode == GifFile->RunningCode - 2) {
                        CrntPrefix = LastCode;
                        Suffix[GifFile->RunningCode - 2] =
                           Stack[StackPtr++] = DGifGetPrefixChar(Prefix,
                                                                 LastCode,
                                                                 ClearCode);
                    } else {
                        //_GifError = D_GIF_ERR_IMAGE_DEFECT;
                        return GIF_ERROR;
                    }
                } else
                    CrntPrefix = CrntCode;

                /* Now (if image is O.K.) we should not get an NO_SUCH_CODE
                 * During the trace. As we might loop forever, in case of
                 * defective image, we count the number of loops we trace
                 * and stop if we got LZ_MAX_CODE. obviously we can not
                 * loop more than that.  */
                j = 0;
                while (j++ <= LZ_MAX_CODE &&
                       CrntPrefix > ClearCode && CrntPrefix <= LZ_MAX_CODE) {
                    Stack[StackPtr++] = Suffix[CrntPrefix];
                    CrntPrefix = Prefix[CrntPrefix];
                }
                if (j >= LZ_MAX_CODE || CrntPrefix > LZ_MAX_CODE) {
                    //_GifError = D_GIF_ERR_IMAGE_DEFECT;
                    return GIF_ERROR;
                }
                /* Push the last character on stack: */
                Stack[StackPtr++] = CrntPrefix;

                /* Now lets pop all the stack into output: */
                while (StackPtr != 0 && i < LineLen)
                    Line[i++] = Stack[--StackPtr];
            }
            if (LastCode != NO_SUCH_CODE) {
                Prefix[GifFile->RunningCode - 2] = LastCode;

                if (CrntCode == GifFile->RunningCode - 2) {
                    /* Only allowed if CrntCode is exactly the running code:
                     * In that case CrntCode = XXXCode, CrntCode or the
                     * prefix code is last code and the suffix char is
                     * exactly the prefix of last code! */
                    Suffix[GifFile->RunningCode - 2] =
                       DGifGetPrefixChar(Prefix, LastCode, ClearCode);
                } else {
                    Suffix[GifFile->RunningCode - 2] =
                       DGifGetPrefixChar(Prefix, CrntCode, ClearCode);
                }
            }
            LastCode = CrntCode;
        }
    }
#endif
    while (i < LineLen) {    /* Decode LineLen items. */
		DGifDecompressInput(GifFile, &CrntCode);

        if (CrntCode == EOFCode) {
            i++;
        } else if (CrntCode == ClearCode) {
            /* We need to start over again: */
            for (j = 0; j <= LZ_MAX_CODE; j++)
                Prefix[j] = NO_SUCH_CODE;
            GifFile->RunningCode = GifFile->EOFCode + 1;
            GifFile->RunningBits = GifFile->BitsPerPixel + 1;
            GifFile->MaxCode1 = 1 << GifFile->RunningBits;
            LastCode = GifFile->LastCode = NO_SUCH_CODE;
        } else {
            /* Its regular code - if in pixel range simply add it to output
             * stream, otherwise trace to codes linked list until the prefix
             * is in pixel range: */
            if (CrntCode < ClearCode) {
                /* This is simple - its pixel scalar, so add it to output: */
                Line[i++] = CrntCode;
            } else {
                /* Its a code to needed to be traced: trace the linked list
                 * until the prefix is a pixel, while pushing the suffix
                 * pixels on our stack. If we done, pop the stack in reverse
                 * (thats what stack is good for!) order to output.  */
                if (Prefix[CrntCode] == NO_SUCH_CODE) {
                    /* Only allowed if CrntCode is exactly the running code:
                     * In that case CrntCode = XXXCode, CrntCode or the
                     * prefix code is last code and the suffix char is
                     * exactly the prefix of last code! */
                    if (CrntCode == GifFile->RunningCode - 2) {
                        CrntPrefix = LastCode;
                        Suffix[GifFile->RunningCode - 2] =
                           Stack[StackPtr++] = DGifGetPrefixChar(Prefix,
                                                                 LastCode,
                                                                 ClearCode);
                    } else {
                        //_GifError = D_GIF_ERR_IMAGE_DEFECT;
                        return GIF_ERROR;
                    }
                } else
                    CrntPrefix = CrntCode;

                /* Now (if image is O.K.) we should not get an NO_SUCH_CODE
                 * During the trace. As we might loop forever, in case of
                 * defective image, we count the number of loops we trace
                 * and stop if we got LZ_MAX_CODE. obviously we can not
                 * loop more than that.  */
                j = 0;
                while (j++ <= LZ_MAX_CODE &&
                       CrntPrefix > ClearCode && CrntPrefix <= LZ_MAX_CODE) {
                    Stack[StackPtr++] = Suffix[CrntPrefix];
                    CrntPrefix = Prefix[CrntPrefix];
                }
                /* Push the last character on stack: */
                Stack[StackPtr++] = CrntPrefix;

                /* Now lets pop all the stack into output: */
                while (StackPtr != 0 && i < LineLen)
                    Line[i++] = Stack[--StackPtr];
            }
            if (LastCode != NO_SUCH_CODE) {
                Prefix[GifFile->RunningCode - 2] = LastCode;

                if (CrntCode == GifFile->RunningCode - 2) {
                    /* Only allowed if CrntCode is exactly the running code:
                     * In that case CrntCode = XXXCode, CrntCode or the
                     * prefix code is last code and the suffix char is
                     * exactly the prefix of last code! */
                    Suffix[GifFile->RunningCode - 2] =
                       DGifGetPrefixChar(Prefix, LastCode, ClearCode);
                } else {
                    Suffix[GifFile->RunningCode - 2] =
                       DGifGetPrefixChar(Prefix, CrntCode, ClearCode);
                }
            }
            LastCode = CrntCode;
        }
    }


    GifFile->LastCode = LastCode;
    GifFile->StackPtr = StackPtr;

    return GIF_OK;
}
static int DGifGetCodeNext(GifFilePrivateType * GifFile,
                GifByteType ** CodeBlock) {

    GifByteType Buf;
  
	READ1(GifFile, &Buf);

    if (Buf > 0) {
        *CodeBlock = GifFile->Buf;    /* Use private unused buffer. */
        (*CodeBlock)[0] = Buf;  /* Pascal strings notation (pos. 0 is len.). */
        if (READ(GifFile, &((*CodeBlock)[1]), Buf) != Buf) {
           // _GifError = D_GIF_ERR_READ_FAILED;
            return GIF_ERROR;
        }
    } else {
        *CodeBlock = NULL;
        GifFile->Buf[0] = 0;    /* Make sure the buffer is empty! */
        GifFile->PixelCount = 0;    /* And local info. indicate image read. */
    }

    return GIF_OK;
}

/******************************************************************************
 * Get one full scanned line (Line) of length LineLen from GIF file.
 *****************************************************************************/
int DGifGetLine(GifFilePrivateType *GifFile, GifPixelType * Line, int LineLen) {

    GifByteType *Dummy;
 //   GifFilePrivateType *Private = (GifFilePrivateType *) GifFile->Private;

    if (!LineLen)
        LineLen = GifFile->Image.Width;

//#if defined(__MSDOS__) || defined(WINDOWS32) || defined(__GNUC__)
    if ((GifFile->PixelCount -= LineLen) > (unsigned int)0xffff0000 /*UL*/) {

      //  _GifError = D_GIF_ERR_DATA_TOO_BIG;
        return GIF_ERROR;
    }

    if (DGifDecompressLine(GifFile, Line, LineLen) == GIF_OK) {
        if (GifFile->PixelCount == 0) {
            /* We probably would not be called any more, so lets clean
             * everything before we return: need to flush out all rest of
             * image until empty block (size 0) detected. We use GetCodeNext. */
            do
                if (DGifGetCodeNext(GifFile, &Dummy) == GIF_ERROR)
                    return GIF_ERROR;
            while (Dummy != NULL) ;
        }
        return GIF_OK;
    } else
        return GIF_ERROR;
}


/******************************************************************************
 * This routine should be called before any attempt to read an image.
 *****************************************************************************/
static int DGifGetRecordType( GifFilePrivateType *pReader,
                  GifRecordType * Type) {
    GifByteType Buf;

	READ1(pReader, &Buf);

    switch (Buf) {
      case ',':
          *Type = IMAGE_DESC_RECORD_TYPE;
          break;
      case '!':
          *Type = EXTENSION_RECORD_TYPE;
          break;
      case ';':
          *Type = TERMINATE_RECORD_TYPE;
          break;
      default:
          *Type = UNDEFINED_RECORD_TYPE;
        //  _GifError = D_GIF_ERR_WRONG_RECORD;
          return GIF_ERROR;
    }
    return GIF_OK;
}

static int DGifGetExtensionNext(GifFilePrivateType * GifFile,
                     GifByteType ** Extension) {
    
    GifByteType Buf;
   
	READ1(GifFile, &Buf);

    if (Buf > 0) {
        *Extension = GifFile->Buf;    /* Use private unused buffer. */
        (*Extension)[0] = Buf;  /* Pascal strings notation (pos. 0 is len.). */
        if (READ(GifFile, &((*Extension)[1]), Buf) != Buf) {
           // _GifError = D_GIF_ERR_READ_FAILED;
            return GIF_ERROR;
        }
    } else
        *Extension = NULL;

    return GIF_OK;
}
static int DGifGetExtension(GifFilePrivateType * GifFile,
                 int *ExtCode,
                 GifByteType ** Extension) {

    GifByteType Buf;
 
	READ1(GifFile, &Buf);
    *ExtCode = Buf;

    return DGifGetExtensionNext(GifFile, Extension);
}


int
AddExtensionBlock(SavedImage * New,
                  int Len,
                  unsigned char ExtData[]) {

    ExtensionBlock *ep;

    if (New->ExtensionBlocks == NULL)
        New->ExtensionBlocks=(ExtensionBlock *)malloc(sizeof(ExtensionBlock),3);
    else
    {
   // printf("REALLOC ext block:%d\n",New->ExtensionBlockCount);
        New->ExtensionBlocks = (ExtensionBlock *)realloc(New->ExtensionBlocks,
                                      sizeof(ExtensionBlock) *
                                      (New->ExtensionBlockCount + 1),21);
    }

    if (New->ExtensionBlocks == NULL)
        return (GIF_ERROR);

    ep = &New->ExtensionBlocks[New->ExtensionBlockCount++];

    ep->ByteCount=Len;
    ep->Bytes = (char *)malloc(ep->ByteCount,4);
    if (ep->Bytes == NULL)
        return (GIF_ERROR);

    if (ExtData) {
        memcpy(ep->Bytes, ExtData, Len);
        ep->Function = New->Function;
    }

    return (GIF_OK);
}


// sas c like asm call
extern void __asm c2p1x1_8_16b_68k_bm(
	register __d0 int width,
	register __d1 int height, 
	register __d2 int widthExt, // +16border or == 	width
	register __a0 char *chunky,
	register __a1 struct BitMap *bitmap
	);
extern void __asm FindMask(
	register __d0 int color,
	register __d1 int pixelwidth,
	register __d2 int rows, 	 
	register __a0 char *chunk,
	register __a1 struct BitMap *mask,
	register __a3 int hasExtColumn
	);

struct BitMap *GifToBm_AllocBitMap(ULONG sizex,ULONG sizey,
								ULONG depth,ULONG flags, struct BitMap *friend_bitmap);


//  readGif from memory - no streaming... pReader to 0.
// return result 0 ok

/*
// use private asm struct
typedef struct {
	unsigned short	_BytesPerRow;
	unsigned short	_Rows;
	unsigned short	_Depth;
	void	*_PlaneStart;
	unsigned int	_PlaneDelta;
	unsigned int	_PlaneSize;
} sBitMap; 

typedef struct {
    unsigned short ColorCount;
    unsigned short BitsPerPixel;
	unsigned char sColors[256*3];  
} sPalette;

// data from ASM with pre-alloc stuff
typedef struct {
	char			*_GifBin;
	unsigned int 	_FileSize;
	unsigned int	_Flags;
	sBitMap			*_pSBitmap;
	sBitMap			*_pSBmMask;
	sPalette	*_ppPalette;
	GifFilePrivateType	_gifp;
} sGifParams;
*/

/* allocs avant pour comparer:
4.Data:Code/cdm> demo.exe 
malloc() size:16 case:1    MakeMapObject(nbc,NULL) struct
calloc() size:196 case:10
malloc() size:34 case:2
malloc() size:68100 case:5 -> alloc du bitmap
*/


int commonDecodeInit(sGifParams *gifp){
    GifByteType Buf[4]; // was 3 krb
	GifFilePrivateType *pReader=&gifp->_gifp;
	unsigned short	BitsPerPixel,nbc;
//olde	  gTempMem = gifp->_MemTemp;// pre-alloc mem

	//  memset to zero now
    memset(pReader, '\0', sizeof(GifFilePrivateType));
	
    pReader->UData = gifp->_GifBin;
	pReader->DataLeft = gifp->_FileSize;
 
	// note: don't verify stamp
    pReader->UData += GIF_STAMP_LEN;
    pReader->DataLeft -= GIF_STAMP_LEN;

	// Put the screen descriptor into the file: 
    if (DGifGetWord(pReader, &pReader->SWidth) == GIF_ERROR ||
        DGifGetWord(pReader, &pReader->SHeight) == GIF_ERROR)
        return GIF_ERROR;


    if (READ(pReader, Buf, 3) != 3) {
        return GIF_ERROR;
    }
	BitsPerPixel = (Buf[0] & 0x07) + 1;
	pReader->_nbPlanes=BitsPerPixel;

	if(gifp->_ppPalette) {
		sPalette *pPal; //gifp->_pPalette;
		int palsize;
   
    	pReader->SColorResolution = (((Buf[0] & 0x70) + 1) >> 4) + 1;
        	nbc=1 << BitsPerPixel;
    	pReader->SBackGroundColor = Buf[1];
		palsize=(4+(nbc*3)+3) & 0xfffffffc;
    	if (Buf[0] & 0x80) {    /* Do we have global color map? */
			//
			pPal=(sPalette *)InAlloc(palsize,0);
			*(gifp->_ppPalette)=pPal;
			pPal->ColorCount=nbc;
        	// Get the global color map: 
        	READ(pReader, &pPal->sColors[0], 3*nbc);
		}
	} else // end parag
	{	// no pal , need to stream
		nbc=(1 << BitsPerPixel)*3;
		pReader->UData += nbc;
		pReader->DataLeft -= nbc;
	}
	if(pReader->Image.Interlace) return(GIF_ERROR);

	return(GIF_OK);
}

void FreeSavedImages(GifFilePrivateType * GifFile) {

    SavedImage *sp;

    if ((GifFile == NULL) || (GifFile->SavedImages == NULL)) {
        return;
    }
    for (sp = GifFile->SavedImages;
         sp < GifFile->SavedImages + GifFile->ImageCount; sp++) {
		/*if (sp->ImageDesc.ColorMap) {
            FreeMapObject(sp->ImageDesc.ColorMap);
            sp->ImageDesc.ColorMap = NULL;
		}*/

        if (sp->RasterBits)
            free((char *)sp->RasterBits);

		/*if (sp->ExtensionBlocks)
			FreeExtension(sp);
		*/
    }
    free((char *)GifFile->SavedImages);
    GifFile->SavedImages=NULL;
}



// allows to read gif as chunky possibly in fast ram...
// in that case, memtemp shouldnt be trashed?
// -> have to choose special parameters...
// still TODO: return chunky bm to proper fast buffer in gifp
int GifBinToChunky(sGifParams *gifp){
	GifFilePrivateType *pReader=&gifp->_gifp;
	SavedImage temp_save;
	GifRecordType RecordType;	
//	unsigned short flags=gifp->_Flags;
	unsigned char *pcbm=NULL;
	// decode palette, file hunks
	if(commonDecodeInit(gifp)!=GIF_OK) {
		return(GIF_ERROR);
	}
	// - - - -  read whole bitmap as byte=pixels.
	// - - - - - - - - - - - - - end of DGifGetScreenDesc()
	//  - -- - - - - - - - - - - - -here begin slurps:

    temp_save.ExtensionBlocks = NULL;
    temp_save.ExtensionBlockCount = 0;

    do {   

        if (DGifGetRecordType(pReader, &RecordType) == GIF_ERROR)
            return (GIF_ERROR);
  
        switch (RecordType) {

          case IMAGE_DESC_RECORD_TYPE:{			        
          	SavedImage *sp;
			unsigned short fwidth,fheight;          
			unsigned int DecodeSize;
			/*
			VPrintf("IMAGE_DESC_RECORD_TYPE:\n",NULL);
			*/
              if (DGifGetImageDesc(pReader) == GIF_ERROR)
                  return (GIF_ERROR);

	sp = &pReader->SavedImages[pReader->ImageCount - 1];
			              
	// chunky: use whole image chunk
	fwidth = sp->ImageDesc.Width;
	fheight = sp->ImageDesc.Height;

	pReader->_alwidth = fwidth ;
	pReader->_readHeight = fheight;
	
	DecodeSize = fwidth * fheight;

	pcbm = (unsigned char *)
					InAlloc(DecodeSize+4,0);
	gifp->_pSBitmap = (sBitMap *)pcbm;
	(*((unsigned short *)pcbm))=fwidth;
	(*((unsigned short *)(pcbm+2)))=fheight;

			  sp->RasterBits = pcbm+4;
              if (sp->RasterBits == NULL) {
                  return GIF_ERROR;
              }
              if (DGifGetLine(pReader, sp->RasterBits,DecodeSize ) ==
                  GIF_ERROR)
                  return (GIF_ERROR);
                  
              if (temp_save.ExtensionBlocks) {
                  sp->ExtensionBlocks = temp_save.ExtensionBlocks;
                  sp->ExtensionBlockCount = temp_save.ExtensionBlockCount;

                  temp_save.ExtensionBlocks = NULL;
                  temp_save.ExtensionBlockCount = 0;

                  /* FIXME: The following is wrong.  It is left in only for
                   * backwards compatibility.  Someday it should go away. Use 
                   * the sp->ExtensionBlocks->Function variable instead. */
                  sp->Function = sp->ExtensionBlocks[0].Function;
              }
              
              } break;
 			// CONTINUE CHANGE HERE
          case EXTENSION_RECORD_TYPE:{
          	GifByteType *ExtData;  

		// VPrintf("EXTENSION_RECORD_TYPE:\n",NULL);
              if (DGifGetExtension(pReader, &temp_save.Function, &ExtData) ==
                  GIF_ERROR)
                  return (GIF_ERROR);
              while (ExtData != NULL) {
	//VPrintf("AddExtensionBlock\n",NULL);
                  /* Create an extension block with our data */
                  if (AddExtensionBlock(&temp_save, ExtData[0], &ExtData[1])
                      == GIF_ERROR)
                      return (GIF_ERROR);

                  if (DGifGetExtensionNext(pReader, &ExtData) == GIF_ERROR)
                      return (GIF_ERROR);
                  temp_save.Function = 0;
              }
              }break;

          case TERMINATE_RECORD_TYPE:
		// VPrintf("TERMINATE_RECORD_TYPE:\n",NULL);
              break;

          default:    /* Should be trapped by DGifGetRecordType */
              break;
        }
    } while (RecordType != TERMINATE_RECORD_TYPE);
	

	return GIF_OK; // 1 means OK	
} // end chunky decode


/*
// use private asm struct
typedef struct {
	unsigned short	_BytesPerRow;
	unsigned short	_Rows;
	unsigned short	_Depth;
	void	*_PlaneStart;
	unsigned int	_PlaneDelta;
	unsigned int	_PlaneSize;
} sBitMap; 

typedef struct {
    unsigned short ColorCount;
    unsigned short BitsPerPixel;
	unsigned char sColors[256*3];  
} sPalette;

// data from ASM with pre-alloc stuff
typedef struct {
	char			*_GifBin;
	unsigned int 	_FileSize;
	unsigned short	_nbPlanes;
	unsigned short	_Flags;
	char			*_AvailableChipPtr;
	char			*_MemTemp;
	sBitMap			*_pSBitmap;
	sBitMap			*_pSBmMask;
	sPalette	*_pPalette;
	GifFilePrivateType	_gifp;
} sGifParams;
*/


int GifBinToSBm(sGifParams *gifp) {
	GifFilePrivateType *pReader=&gifp->_gifp;
	SavedImage temp_save;
	GifRecordType RecordType;

//	char transparent = -1;
  unsigned short flags=gifp->_Flags;

	// decode palette, file hunks
	if(commonDecodeInit(gifp)!=GIF_OK) {
		return(GIF_ERROR);
	}

	// - - - - - - - - - - - - - end of DGifGetScreenDesc()
	//  - -- - - - - - - - - - - - -here begin slurps:

    temp_save.ExtensionBlocks = NULL;
    temp_save.ExtensionBlockCount = 0;

    do {   

       if (DGifGetRecordType(pReader, &RecordType) == GIF_ERROR)
            return (GIF_ERROR);

        switch (RecordType) {

          case IMAGE_DESC_RECORD_TYPE:{
          	SavedImage *sp;
			unsigned short width,fwidth,height,fheight;          
			unsigned int DecodeSize;
		//	  VPrintf("IMAGE_DESC_RECORD_TYPE:\n",NULL);
              if (DGifGetImageDesc(pReader) == GIF_ERROR)
                  return (GIF_ERROR);

			if(pReader->Image.Interlace) return(GIF_ERROR);


	sp = &pReader->SavedImages[pReader->ImageCount - 1];
	// align 
	width=sp->ImageDesc.Width;
	fwidth=((width+15)&0xfffffff0);	
// optional +16 column managed by c2p
//old	 if(flags & G2BMFLAGS_ADD_EMPTY_RIGHT_COLUMN16) {
//old		 fwidth+=16;
//old	 }
	height=sp->ImageDesc.Height;
	fheight=16;
	if(height<fheight) fheight=height;

	pReader->_alwidth = fwidth;
	pReader->_readHeight = fheight;
	// for 640 width gif, has just 10kb to decode...	
	DecodeSize = fwidth * fheight;
              sp->RasterBits = (unsigned char *)
              	calloc(DecodeSize,1,5);
              if (sp->RasterBits == NULL) {
                  return GIF_ERROR;
              }

	// - - -  alloc final planar here...
	{ // start: planar decode	
	char	*pPlanar;
	//gifp->_AvailableChipPtr;
	sBitMap *pbm = gifp->_pSBitmap;
	unsigned int planeSize;
	unsigned short ii;

	// init planarbitmap struct
	pbm->BytesPerRow = (fwidth>>3)+(((flags&8)!=0)?2:0);
	pbm->Rows = height;
	planeSize = pbm->BytesPerRow * height;
	pbm->PlaneSize = planeSize;
	pbm->Depth = pReader->_nbPlanes;
	pPlanar=InAlloc(pbm->PlaneSize*pbm->Depth+8 ,1); // chip
	pbm->ChipAlloc=pPlanar;

	// align
	pPlanar = (char *)(((unsigned int)pPlanar) & 0xfffffff8) ;
	for(ii=0;ii<pReader->_nbPlanes;ii++) {
		pbm->Planes[ii]=pPlanar;
		pPlanar += planeSize ;
	}

	while(height>0) {
		char *pRast=sp->RasterBits;
		unsigned short dh=16;
		if(height<dh) dh=height;
		height-=dh;
		// - -  decode gif to aligned little fastchunky buffer
// too slow...
//		  for(ii=0;ii<dh;ii++) {
//			  if (DGifGetLine(pReader,pRast,width ) ==
//				  GIF_ERROR) return (GIF_ERROR);
//			  pRast+=fwidth;
//		  }


		if (DGifGetLine(pReader,pRast,width*dh ) ==
          		GIF_ERROR) return (GIF_ERROR);


		// - - c2p to chip planar 16b aligned bitmap

		c2p1x1_8_16b_68k_bm( fwidth,dh,
							(flags&8)?1:0,
							sp->RasterBits,(struct BitMap *)pbm );
		// get down...
		for(ii=0;ii<pReader->_nbPlanes;ii++) {
			pbm->Planes[ii]+=(pbm->BytesPerRow<<4); //*16 for 16 lines
		}
	} // end while(height>0)
	// reset plane pointers at start

	pPlanar = (char *)(((unsigned int)pbm->ChipAlloc) & 0xfffffff8) ;
	for(ii=0;ii<pReader->_nbPlanes;ii++) {
		pbm->Planes[ii]=pPlanar;
		pPlanar += planeSize ; // this does alloc
	}
	//VF add:
	free(sp->RasterBits);
	sp->RasterBits=NULL;

  
	} // end paragraph stream planar decode

                  
              if (temp_save.ExtensionBlocks) {
                  sp->ExtensionBlocks = temp_save.ExtensionBlocks;
                  sp->ExtensionBlockCount = temp_save.ExtensionBlockCount;

                  temp_save.ExtensionBlocks = NULL;
                  temp_save.ExtensionBlockCount = 0;

                  /* FIXME: The following is wrong.  It is left in only for
                   * backwards compatibility.  Someday it should go away. Use 
                   * the sp->ExtensionBlocks->Function variable instead. */
                  sp->Function = sp->ExtensionBlocks[0].Function;
              }
              
              } break;
 			// CONTINUE CHANGE HERE
          case EXTENSION_RECORD_TYPE:{
				GifByteType *ExtData;    
		// VPrintf("EXTENSION_RECORD_TYPE:\n",NULL);
              if (DGifGetExtension(pReader, &temp_save.Function, &ExtData) ==
                  GIF_ERROR)
                  return (GIF_ERROR);
              while (ExtData != NULL) {
//	  VPrintf("AddExtensionBlock\n",NULL);
                  /* Create an extension block with our data */
                  if (AddExtensionBlock(&temp_save, ExtData[0], &ExtData[1])
                      == GIF_ERROR)
                      return (GIF_ERROR);

                  if (DGifGetExtensionNext(pReader, &ExtData) == GIF_ERROR)
                      return (GIF_ERROR);
                  temp_save.Function = 0;
              }
              }break;

          case TERMINATE_RECORD_TYPE:
		// VPrintf("TERMINATE_RECORD_TYPE:\n",NULL);
              break;

          default:    /* Should be trapped by DGifGetRecordType */
              break;
        }
    } while (RecordType != TERMINATE_RECORD_TYPE);


	// was dgifclosefile(), keep model:

/*	  if(GifFile->fimage) // our chunky aligned version
    {
    	free(GifFile->fimage);
    	GifFile->fimage=NULL;
    }

    if (GifFile->Image.ColorMap) {
        FreeMapObject(GifFile->Image.ColorMap);
        GifFile->Image.ColorMap = NULL;
    }

    if (GifFile->SColorMap) {
        FreeMapObject(GifFile->SColorMap);
        GifFile->SColorMap = NULL;
    }
*/
	// have to free this:
	if (pReader->SavedImages) {
		FreeSavedImages(pReader);
		pReader->SavedImages = NULL;
    }
// pReader->SavedImages
	
	return GIF_OK;
}

// - - - - -  -

int GifBinToChip(sGifParams *gifp) {
	GifFilePrivateType *pReader=&gifp->_gifp;
	SavedImage temp_save;
	GifRecordType RecordType;

	// decode palette, file hunks
	if(commonDecodeInit(gifp)!=GIF_OK) {
		return(GIF_ERROR);
	}

	//  - -- - - - - - - - - - - - -here begin slurps:

    temp_save.ExtensionBlocks = NULL;
    temp_save.ExtensionBlockCount = 0;

    do {

       if (DGifGetRecordType(pReader, &RecordType) == GIF_ERROR)
            return (GIF_ERROR);

        switch (RecordType) {

          case IMAGE_DESC_RECORD_TYPE:{
          	SavedImage *sp;
			unsigned short width,height;
			unsigned int DecodeSize;
		//	  VPrintf("IMAGE_DESC_RECORD_TYPE:\n",NULL);
              if (DGifGetImageDesc(pReader) == GIF_ERROR)
                  return (GIF_ERROR);

			if(pReader->Image.Interlace) return(GIF_ERROR);


	sp = &pReader->SavedImages[pReader->ImageCount - 1];

	width=sp->ImageDesc.Width;
	height=sp->ImageDesc.Height;

	// for 640 width gif, has just 10kb to decode...
	DecodeSize = width * height;
	sp->RasterBits = (unsigned char *)gifp->_pSBitmap;
			//	  InAlloc(DecodeSize,1); // chip

		if (DGifGetLine(pReader,sp->RasterBits,width*height ) ==
			GIF_ERROR) return (GIF_ERROR);


              if (temp_save.ExtensionBlocks) {
                  sp->ExtensionBlocks = temp_save.ExtensionBlocks;
                  sp->ExtensionBlockCount = temp_save.ExtensionBlockCount;

                  temp_save.ExtensionBlocks = NULL;
                  temp_save.ExtensionBlockCount = 0;

                  /* FIXME: The following is wrong.  It is left in only for
                   * backwards compatibility.  Someday it should go away. Use
                   * the sp->ExtensionBlocks->Function variable instead. */
                  sp->Function = sp->ExtensionBlocks[0].Function;
              }

              } break;
 			// CONTINUE CHANGE HERE
          case EXTENSION_RECORD_TYPE:{
				GifByteType *ExtData;
		// VPrintf("EXTENSION_RECORD_TYPE:\n",NULL);
              if (DGifGetExtension(pReader, &temp_save.Function, &ExtData) ==
                  GIF_ERROR)
                  return (GIF_ERROR);
              while (ExtData != NULL) {
//	  VPrintf("AddExtensionBlock\n",NULL);
                  /* Create an extension block with our data */
                  if (AddExtensionBlock(&temp_save, ExtData[0], &ExtData[1])
                      == GIF_ERROR)
                      return (GIF_ERROR);

                  if (DGifGetExtensionNext(pReader, &ExtData) == GIF_ERROR)
                      return (GIF_ERROR);
                  temp_save.Function = 0;
              }
              }break;

          case TERMINATE_RECORD_TYPE:
	//	   VPrintf("TERMINATE_RECORD_TYPE:\n",NULL);
              break;

          default:    /* Should be trapped by DGifGetRecordType */
              break;
        }
    } while (RecordType != TERMINATE_RECORD_TYPE);


	// was dgifclosefile(), keep model:

	// have to free this:
	if (pReader->SavedImages) {
		FreeSavedImages(pReader);
		pReader->SavedImages = NULL;
    }
// pReader->SavedImages

	return GIF_OK;
}

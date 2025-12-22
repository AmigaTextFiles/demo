W3D_Texture *tex;

ULONG CurrentBlend = 0;
ULONG BlendModes[] = {W3D_REPLACE, W3D_DECAL, W3D_MODULATE, W3D_BLEND};

typedef struct {
    float x,y,z;
    float u,v;
    float iz;
} Vector3;


Vector3 Square[4] = {
    // x     y    z      u      v
    {-1.f,  1.f, 0.f,   0.f,   0.f},
    { 1.f,  1.f, 0.f,   1.f,   0.f},
    { 1.f, -1.f, 0.f,   1.f,   1.f},
    {-1.f, -1.f, 0.f,   0.f,   1.f}
};



BOOL MyLoad(W3D_Context* context)
{

    int i;
    ULONG error;
    int size_image=64*64*3;
    int off=0;

    char *image=NULL;
    FILE *fp_filename;


    image=malloc(64*64*4);


   if((fp_filename = fopen("PROGDIR:texture.raw","rb")) == NULL)
     { printf("can't open file\n");};


while (size_image >0)
{

    memset(image+off,0xFF,1);
    off=off+1;
    fread(image+off,3,1,fp_filename);
    off=off+3;
    


    size_image=(size_image-3);
}


    fclose(fp_filename);

// ----- !!! -----
    for (i=0;i<4; i++) {
        Square[i].u *= (64-1);      //  -1
        Square[i].v *= (64-1);      //  -1
     }
//------ !!! -----



    tex = W3D_AllocTexObjTags(context, &error,
        W3D_ATO_IMAGE,      image,        // The image data
        W3D_ATO_FORMAT,     W3D_A8R8G8B8,   // 24 bit image
        W3D_ATO_WIDTH,      64,           // 64 x
        W3D_ATO_HEIGHT,     64,           //      64
        W3D_ATO_MIPMAP,     0xffff,       // Mipmap mask - see autodocs (get fuckup)
    TAG_DONE);

    printf("Texture created\n");

    if (!tex || error != W3D_SUCCESS) {
        printf("Error generating texture: ");
        switch(error) {
        case W3D_ILLEGALINPUT:
            printf("Illegal input\n");
            break;
        case W3D_NOMEMORY:
            printf("Out of memory\n");
            break;
        case W3D_UNSUPPORTEDTEXSIZE:
            printf("Unsupported texture size\n");
            break;
        case W3D_NOPALETTE:
            printf("Chunky texture without palette specified\n");
            break;
        case W3D_UNSUPPORTEDTEXFMT:
            printf("Texture format not supported\n");
            break;
        default:
            printf("ahem... An error has occured\n");
        }
        return FALSE;
    }

    // --- UPLOAD TEXTURE

    W3D_UploadTexture(context, tex);
    free(image);

}


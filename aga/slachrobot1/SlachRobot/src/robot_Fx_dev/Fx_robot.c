/*----------- general include ----------*/

#include <exec/libraries.h>
#include <exec/memory.h>

#include <devices/narrator.h>

#include <clib/exec_protos.h>

#include <clib/translator_protos.h>

#include    <proto/dos.h>

#include "//KScriptReader.h"
#include "//KarateHardInfo.h"

#include    "SimpleRexx.h"

#include    <stdio.h>
#include    <string.h>
/*----------- self effect include ----------*/

char *VersionString="$VER: Robot.Fx v1 karate plugin 2004";
extern struct KarateHardInfo *KHardInfo;

//-----------------------------
struct Library      *SysBase=NULL;
struct DosLibrary   *DOSBase=NULL;
extern  struct Library      *TranslatorBase;
AREXXCONTEXT    rexxcontext=NULL;


//-------- robot state type flags:
#define     rstf_Quiet

//------------------------
typedef enum {
    rnse_VeryQuiet=0,
    rnse_Quiet,
    rnse_Normal,
    rnse_Nervous,
    rnse_VeryNervous
} RobotNervousState ;
//-------------------------
typedef struct  _RobotStringCell {
    STRPTR                      rsc_sentence;
    unsigned int                rsc_allocsize;
    struct  _RobotStringCell   *rsc_next;
    unsigned int                rsc_stringnumber;
    unsigned int                rsc_sentenceLength;
} RobotStringCell ;

//--------------------------------
#define phoneticBufferLength    8192
typedef struct _RobotBrain {
    //--------------- IA database
    RobotNervousState    rb_NervousState;
    unsigned int        rb_NumberOfString;
    RobotStringCell     *rb_StringBase;
    unsigned int        rb_minGapBetweenAction;
    unsigned int        rb_maxGapBetweenAction;


    //--------------- face cinematic automats:
    RobotStringCell    *rb_LastStringSaid;
    unsigned int        rb_LastStringStartDate;
    unsigned int        rb_LastStringEndDate;
    unsigned int        rb_NextFreeDate;
    unsigned int        rb_CurrentDate;
    //-------
    UBYTE               rb_mouthWidth;
    UBYTE               rb_mouthHeight;
    short               rb_hmf;
    int                 rb_LastEyeClicStartDate;
    int                 rb_NextEyeClicFreeDate;
    int                 rb_eyeMode;
    //------ phonetic output buffer:
    UBYTE               rb_Phoneticbuffer[ phoneticBufferLength ];
} RobotBrain  ;

//------------ narrator device stuffs: (to read mouth)
#ifndef NDF_READMOUTH                        /* Already defined ? */
#define NDF_READMOUTH   0x01                 /* No, define here   */
#define NDF_READWORD    0x02
#define NDF_READSYL     0x04
#endif


struct  MsgPort         *VoicePort = NULL;
struct  MsgPort         *MouthPort = NULL;

struct  narrator_rb     *VoiceIO = NULL;
struct  mouth_rb        *MouthIO = NULL;
BYTE chans[4] = {3, 5, 10, 12};
int     NarratorDeviceIsOK=1; // 1 not present

/*-------------------------------------------------------*/
/*-----                                             -----*/
/*-----  Get Hard Info                              -----*/
/*-----  (IntuitionWindow,Lib Bases,useful fctn...  -----*/
/*-------------------------------------------------------*/
/*///-------------------------------- FxMod_Init ----------*/
int    FxMod_Init()
{
    SysBase = KHardInfo->KHI_Execbase ; // get execbase a good way.
    rexxcontext = InitARexx("krobot","test");
/*
    {
        char str[64];
        sprintf(str,"rexxcontext: %08x :\n",rexxcontext);
        (*KHardInfo->KHI_outprint)(str);
    }
*/
    if (rexxcontext)
    {
        char str[64];
        sprintf(str,"arexxname:%s:\n",ARexxName(rexxcontext));
        (*KHardInfo->KHI_outprint)(str);

    }

    //---------------------
    if( DOSBase == NULL ) DOSBase = OpenLibrary("dos.library",NULL);

    //----------- try to open narrator device:
    VoicePort = CreatePort(NULL,0);
    if (VoicePort == NULL) (*KHardInfo->KHI_outprint)("Can't get write port");
    else
    {
        VoiceIO = (struct narrator_rb *) CreateExtIO(VoicePort,sizeof(struct narrator_rb)) ;
        if( VoiceIO == NULL ) (*KHardInfo->KHI_outprint)("Can't get write IORB");
        else
        {
            VoiceIO->ch_masks            = &chans[0];
            VoiceIO->nm_masks            = sizeof(chans);
            VoiceIO->message.io_Command = CMD_WRITE;
            VoiceIO->flags               = NDF_NEWIORB;
            // NULL is OK:
            NarratorDeviceIsOK = OpenDevice("narrator.device", 0, VoiceIO, 0) ;
            if( NarratorDeviceIsOK == 0 )
                (*KHardInfo->KHI_outprint)("narrator open for mouth.");
            //if ( != NULL)
            //Cleanup("OpenDevice failed");
        }


    }

    if(NarratorDeviceIsOK == 0 )
    {
        MouthPort = CreatePort(NULL,0);
        if (MouthPort == NULL) (*KHardInfo->KHI_outprint)("can't create mouth port");
        else
        {
            MouthIO = (struct mouth_rb *) CreateExtIO(MouthPort,sizeof(struct mouth_rb)) ;
            if( MouthIO == NULL ) (*KHardInfo->KHI_outprint)("can't create iorb");
            else
            {
                MouthIO->voice.message.io_Device = VoiceIO->message.io_Device;
                MouthIO->voice.message.io_Unit   = VoiceIO->message.io_Unit;
                MouthIO->voice.message.io_Message.mn_ReplyPort = MouthPort;
                MouthIO->voice.message.io_Command = CMD_READ;
                MouthIO->voice.message.io_Error = 0;

                (*KHardInfo->KHI_outprint)("all narrator stuffs opened OK.\n");
            }
        }
    }
    // try to open translator lib:
    if( TranslatorBase == NULL ) TranslatorBase = OpenLibrary("translator.library",NULL);


    return( 0 );
}
/*///*/
/*-------------------------------------------------------*/
/*-----                                             -----*/
/*-----  Get Hard Info                              -----*/
/*-----  (IntuitionWindow,Lib Bases,             -----*/
/*-------------------------------------------------------*/
/*///-------------------------------- FxMod_End ----------*/
int    FxMod_End()
{

    if( TranslatorBase != NULL ) CloseLibrary( TranslatorBase );

    //------------------ narrator device things:
    if (VoiceIO && VoiceIO->message.io_Device)
        CloseDevice(VoiceIO);
    if (VoiceIO)
        DeleteExtIO(VoiceIO);
    if (VoicePort)
        DeletePort(VoicePort);
    if (MouthIO)
        DeleteExtIO(MouthIO);
    if (MouthPort)
        DeletePort(MouthPort);

    //------------------
    if( rexxcontext != NULL )
    {
        FreeARexx(rexxcontext);
    }
    //---------------------
    if( DOSBase != NULL ) CloseLibrary( DOSBase );


    return(0);
}
/*///*/
/*===================================================================*/
/*========================== End of FxMod Appliance =================*/
/*===================================================================*/
///------------- rb_rnd
static unsigned int rndnb = 0x79daf45e;
unsigned int    rb_rnd()
{
    rndnb = rndnb * 0x7674a789 + 0x79048ee1 ;
    return(rndnb);
}
///
///------------- rndmix
unsigned int    rndmix(int aa,int bb)
{
    int mm = ((rb_rnd()>>8) & 0x0000ffff );

    return( aa + ((mm*(bb-aa))>>16)  );
}
///


///---------------- AddOneSentence
RobotStringCell *AddOneSentence(RobotBrain *probot, STRPTR pstr )
{
    RobotStringCell *cell;
    int allocsize;
    // - ------------- -

    allocsize = sizeof( RobotStringCell ) + strlen(pstr) + 1 ;

    cell = ( RobotStringCell * )
       (*KHardInfo->KHI_AllocMem)( allocsize , MEMF_CLEAR );
    if( cell == NULL ) return(NULL);

    cell->rsc_next      = probot->rb_StringBase ;
    cell->rsc_sentenceLength =  strlen(pstr) ;
    cell->rsc_allocsize = allocsize ;
    cell->rsc_sentence  = (STRPTR) &(cell[1]);
    strcpy( cell->rsc_sentence , pstr );

    cell->rsc_stringnumber = probot->rb_NumberOfString ;

    probot->rb_StringBase = cell ;

    probot->rb_NumberOfString++;

    return(cell);
/*
    APTR     (*KHI_AllocMem)( ULONG byteSize , int memtypes );
    void     (*KHI_FreeMem)( APTR memoryBlock, ULONG byteSize );
*/

}
///
///-------------- GetSentenceByNumber
RobotStringCell *GetSentenceByNumber(RobotBrain *probot, unsigned int nb )
{
    RobotStringCell *cell;

    cell = probot->rb_StringBase ;
    while( cell != NULL  )
    {
        if( cell->rsc_stringnumber == nb ) return(cell);
        cell = cell->rsc_next ;
    }
    return(NULL);

}
///
///---------------- SubOneSentence
void    SubOneSentence(RobotBrain *probot, unsigned int number )
{

}
///
///---------------- ClearAllSentences
void    ClearAllSentences( RobotBrain *probot )
{
    RobotStringCell *cell,*cell2;

    cell = probot->rb_StringBase ;
    while( cell != NULL  )
    {
        cell2 = cell->rsc_next ;
        (*KHardInfo->KHI_FreeMem)( cell , cell->rsc_allocsize );
        cell = cell2;
    }


}
///

///---------------- StartToSaySentence()
int    StartToSaySentence( RobotBrain *probot, RobotStringCell *cell )
{
//old    char str[512];
//    char *phoneticStr;
    int enddate;
    //----------------------
    // test if action possible:
    if( probot->rb_CurrentDate < probot->rb_NextFreeDate  ) return(0);

     /*
     *    Send the write request to the device.  This is an
     *         asynchronous write, the device will return immediately.
     */
    //Translate( CONST_STRPTR inputString, LONG inputLength, STRPTR outputBuffer, LONG bufferSize );


     if(VoiceIO)
     {
        Translate( cell->rsc_sentence,strlen(cell->rsc_sentence),
                   &(probot->rb_Phoneticbuffer[0]), phoneticBufferLength-1
                    );
// Translate( CONST_STRPTR inputString, LONG inputLength, STRPTR outputBuffer, LONG bufferSize );

        VoiceIO->message.io_Data   = &(probot->rb_Phoneticbuffer[0]) ;
        VoiceIO->message.io_Length = strlen( &(probot->rb_Phoneticbuffer[0]) );

        VoiceIO->pitch = rndmix(90,130); //70->110->

         //VoiceIO->message.io_Data   = "KAA1RDIYOWMAYAA5PAXTHIY";
         //VoiceIO->message.io_Length = strlen("KAA1RDIYOWMAYAA5PAXTHIY");
         VoiceIO->flags             = NDF_NEWIORB /* | NDF_WORDSYNC */;
         VoiceIO->mouths            = 1;

         SendIO(VoiceIO);
     }


//old    sprintf(str,"run say %s", cell->rsc_sentence );
//old    Execute(str,NULL,NULL);



    probot->rb_LastStringSaid = cell ;
    probot->rb_LastStringStartDate = probot->rb_CurrentDate ;


    probot->rb_LastStringEndDate = enddate =  probot->rb_CurrentDate
                        +( 5* cell->rsc_sentenceLength
                           - (cell->rsc_sentenceLength>>2)
                        ) ;

    probot->rb_NextFreeDate = enddate
                            + rndmix(   probot->rb_minGapBetweenAction,
                                    probot->rb_maxGapBetweenAction
                                    )

                                    ;
    // eye blit when sentence finish:
    probot->rb_NextEyeClicFreeDate = enddate ;
/*    {
            sprintf(str,"nextdate:%d:   currentdate:%d\n",
            
            probot->rb_NextFreeDate,
            probot->rb_CurrentDate
            );
            (*KHardInfo->KHI_outprint)(str);
    }
*/

    return(1); //OK
}
///
///---------------- AddRobotString
void    AddRobotString( RobotBrain *probot, STRPTR command )
{
    RobotStringCell *cell;
    //----------- add sentence to base:
    cell = AddOneSentence(probot,command );
    if(cell == NULL) return;

    // try to say it now:
    // re StartToSaySentence(probot,cell);
 

}
///
///---------------- ChangeTimeLapse
 void    ChangeTimeLapse( RobotBrain *probot, STRPTR command )
{
    unsigned int    min,max,ii,length;
    char            *ptr;
    //----------- get
    length = strlen(command);
    ii=0;
    while( command[ii] != ' ' && ii<length ) ii++;
    command[ii]=0;

    min=atoi(command);

    if( ii != length ) command[ii]=' ';
    max = atoi( &(command[ii]) );


    if(max<min)
    {
        ii=max;
        max=min;
        min=ii;
    }
    if(min<150) min = 150;
    if(max<200) max = 200;
    {
        char str[128];
        sprintf(str,"time min:%d: max:%d:\n",min,max);
        (*KHardInfo->KHI_outprint)(str);
    }

    probot->rb_minGapBetweenAction = min ;
    probot->rb_maxGapBetweenAction = max ;

}
///
///---------------- ProcessRobotCommand
void    ProcessRobotCommand( RobotBrain *probot, STRPTR command )
{
    if( strnicmp( command,"add",3) == 0  )
    {
        AddRobotString( probot, &(command[3])  );
    }else
    if( strnicmp( command,"time ",5) == 0  )
    {
        ChangeTimeLapse( probot, &(command[5])  );
        //AddRobotString( probot, &(command[3])  );
    }

}
///
///-------------- ComputeIA
void    ComputeIA( RobotBrain *probot )
{
    int nbsentence;
    RobotStringCell *cell;
    // test if action possible:
    if( probot->rb_CurrentDate >= probot->rb_NextFreeDate  )
    {
        // take a sentence:
        nbsentence =  rndmix( 0 , probot->rb_NumberOfString );

        cell = GetSentenceByNumber( probot, nbsentence );
        if( cell != NULL ) StartToSaySentence( probot , cell );
    }
    //------ eye blitting:
    if( probot->rb_CurrentDate >= probot->rb_NextEyeClicFreeDate  )
    {
        probot->rb_LastEyeClicStartDate = probot->rb_CurrentDate ;

        probot->rb_NextEyeClicFreeDate = probot->rb_CurrentDate +
                                        100 + rndmix( 0 ,500);




    }




}
///
/*///-------------------------------- ProcessRobot ----------*/
/*========================================================*/
/*====                  Structure to add effect       ====*/
/*========================================================*/
char    *plistprocessrobot[];
char    *plistprocessrobotname[];
void    ProcessRobot( struct  KEfParam *Pa );
struct  KEffectModuleDescription    KMD_processrobot=
{
        "processrobot",       /*  command to use */
        &ProcessRobot, // NO MORE &KFX_processrobot,    /*  function to redirect */
        2,              /*  nb param */
        plistprocessrobot,
        plistprocessrobotname,
        "Put this in a frame to make the robot live.",
        KMDFlag_IsGraphicalEffect
};
char    *plistprocessrobot[]=
{
            "hrobot",
            "fixedfloat"
};
char    *plistprocessrobotname[]=
{
            "hrobot",
            "date"
};
//------------------------------------------------------
void    ProcessRobot( struct  KEfParam *Pa )
{
    RobotBrain *probot = (RobotBrain *) Pa->KEfp_Result ;
    if( probot == NULL) return;
    Pa++;
    probot->rb_CurrentDate = (Pa->KEfp_Result) ;
  
    //--------- treat arexx signal if needed: (input)
    if( rexxcontext )
    {
        ULONG   signals;
        signals=ARexxSignal( rexxcontext );
        if (signals)
        {
            struct  RexxMsg     *rmsg;
            struct  IntuiMessage    *msg;

            //? signals=Wait(signals);
            /*
            * Process the ARexx messages...
            */
            while (rmsg=GetARexxMsg(rexxcontext))
            {
                //char    cBuf[24];
                char str[512];
                char    *nextchar;
                char    *error=NULL;
                char    *result=NULL;
                long    errlevel=0;
                str[0]=0;
                /*
                nextchar=stptok(ARG0(rmsg),
                            cBuf,24," ,");
                if (*nextchar) nextchar++;
                    */
                nextchar = ARG0(rmsg) ;
                if( nextchar )
                {
                    
                    //sprintf(str,"arg0:%s:\n",nextchar);
                    (*KHardInfo->KHI_outprint)("arg0:");
                    strncpy(str,nextchar,510);
                    (*KHardInfo->KHI_outprint)(str);
                    (*KHardInfo->KHI_outprint)("\n");
                }
                if (error)
                {
                    SetARexxLastError(rexxcontext,rmsg,error);
                }
                ReplyARexxMsg(rexxcontext,rmsg,result,errlevel);

                if( str[0] != 0 ) ProcessRobotCommand( probot ,&str[0] );
            }

        }

    }
    // look narrator device for mouth:
    if( MouthIO != NULL )
    {
        DoIO(MouthIO);
        if (MouthIO->sync & NDF_READMOUTH)
        { 
            probot->rb_mouthWidth = MouthIO->width ;
            probot->rb_mouthHeight= MouthIO->height ;

        }
    }

    // ----------- make IA and outputs:
    ComputeIA(probot);


}
/*///*/

///     kMMD_robot
/*
 these structs and functions manage a player module object
 by handling a constructor and a destructor.
 the object then can be used by parameters and effects through karate.
*/

/*----------- kcam DATAMAKER MODULE DESCRIPTION ---------*/
char    *robot_New( char *parameters, UBYTE *ObjectChunk, struct MemStackStruct **DBRoot );
void    robot_Delete( UBYTE *ObjectChunkToDestroy );
struct  KDataMakerModuleDescription kMMD_robot=
{
        "hrobot",      // xml-like mnemonique.
        "hrobot",     // datatype returned.
        sizeof( RobotBrain ), // sizeof chunk that is auto-allocated.
        16, // weight
        &robot_New,
        &robot_Delete, /* destructor */
        " <Hrobot> label </Hrobot>",
       NULL, // private
        NULL    // private !!

};

/*-----------------------------------------------------------------*/
//     robot_new
char    *robot_New( char *parameters, UBYTE *ObjectChunk, struct MemStackStruct **DBRoot )
{
/*    struct  KHI_FileLoader   *FL = ( struct  KHI_FileLoader  *)ObjectChunk ;
    struct  KHI_ParsedString *pstr;

     if ( DBPlayerBase == NULL ) return("couldn't open dbplayer.library");

    if( parameters == NULL ) return("no parameter");

    pstr = (*KHardInfo->KHI_ParseString)( parameters  ,'|',ObjectChunk );
    (*KHardInfo->KHI_LoadFile)(  FL, pstr->kps_string );

    if( FL->KFL_FileChunk == NULL  ) return("couldn't load robot file.");
*/
    RobotBrain *probot = (RobotBrain *) ObjectChunk ;
    probot->rb_StringBase = NULL ;
    probot->rb_LastStringSaid = NULL ;
    probot->rb_LastStringEndDate =
    probot->rb_NumberOfString = 0;

    probot->rb_minGapBetweenAction = 200 ;
    probot->rb_maxGapBetweenAction = 500 ;

//    AddOneSentence( probot,"coocoo,");
//    AddOneSentence( probot,"woogadoo,");



    return(NULL);   // OK
}
/*-----------------------------------------------------------------*/
//     robot_Delete
void    robot_Delete( UBYTE *ObjectChunkToDestroy )
{
/*    struct  KHI_FileLoader   *FL = ( struct  KHI_FileLoader  *)ObjectChunkToDestroy ;
    if( FL->KFL_FileChunk != NULL )
         (*KHardInfo->KHI_FreeMem )( FL->KFL_FileChunk   , FL->KFL_chunksize );
*/
    RobotBrain *probot = (RobotBrain *) ObjectChunkToDestroy ;

    ClearAllSentences( probot );

}
///

/*///--------------------------------- face param---------------ø-*/
/*========================================================*/
/*====      rbspksin Module                              ======*/
/*========================================================*/
int     plrbspksin[];
char   *nameplrbspksin[];
void     KPF_Find_rbspksin( int *Pu,int Date , struct KEfParam *PaResultlist );
char    *returntypecte[]={ "fixedfloat" };
struct  KParamModuleDescription     KPM_rbspksin=
{
        "rbmouth",           /* used by karate */
        &KPF_Find_rbspksin,  /* fonction to use  */
        4,               /* number of underp' */
        1,              /* number of param filled. */
        returntypecte,
        plrbspksin,

      (char **) nameplrbspksin,
        "<Pa> rbmouth1 | robot | val1 | val2 | widthheight </Pa> make vary a mouth when speaking "
};
/*------------------------------------description--------*/
int     plrbspksin[]=
{
        KU_DataBase,(int)"hrobot",
        KU_FixedFloat,0,
        KU_FixedFloat,0,
        KU_FixedFloat,0
};
char   *nameplrbspksin[]={ "robot","v1","v2","widthheight" };

/*========================================================*/
/*====      rbspksin Function                            ======*/
/*========================================================*/
/*-------------------------------------------------------------------*/
void     KPF_Find_rbspksin( int *Pu,int Date , struct KEfParam *PaResultlist )
{
    int     aa,bb,cc,rate;
    RobotBrain *probot = (RobotBrain *) *Pu ;
    //---------
    Pu++;
    aa= *Pu;
    Pu++;
    bb= *Pu;
    Pu++;
    cc= *Pu;
    //------- if not speaking:
   /* if( probot->rb_CurrentDate < probot->rb_LastStringEndDate  )
    {
        PaResultlist->KEfp_Result = aa;
        return;
    }*/
    if(cc == 0)
        rate = ((unsigned int)(probot->rb_mouthHeight))<<12 ;
    else
        rate = ((unsigned int)(probot->rb_mouthWidth ))<<11 ;

    if(rate>65536) rate=65536;
    if(rate<0) rate=0;

    //------
    PaResultlist->KEfp_Result = bb + (((aa-bb)*rate)>>16);

    return;
}


/*========================================================*/
/*====      rbeye Module                              ======*/
/*========================================================*/
int     plrbeye[];
char   *nameplrbeye[];
void     KPF_Find_rbeye( int *Pu,int Date , struct KEfParam *PaResultlist );

struct  KParamModuleDescription     KPM_rbeye=
{
        "rbeye",           /* used by karate */
        &KPF_Find_rbeye,  /* fonction to use  */
        4,               /* number of underp' */
        1,              /* number of param filled. */
        returntypecte,
        plrbeye,

      (char **) nameplrbeye,
        "<Pa> rbeye | robot | val1 | val2 | leftright </Pa> make vary the eyes. "
};
/*------------------------------------description--------*/
int     plrbeye[]=
{
        KU_DataBase,(int)"hrobot",
        KU_FixedFloat,0,
        KU_FixedFloat,0,
        KU_FixedFloat,0
};
char   *nameplrbeye[]={ "robot","v1","v2","widthheight" };

/*========================================================*/
/*====      rbeye Function                            ======*/
/*========================================================*/
/*-------------------------------------------------------------------*/
void     KPF_Find_rbeye( int *Pu,int Date , struct KEfParam *PaResultlist )
{
    int     aa,bb,cc,rate=0;
    RobotBrain *probot = (RobotBrain *) *Pu ;
    //---------
    Pu++;
    aa= *Pu;
    Pu++;
    bb= *Pu;
    Pu++;
    cc= *Pu;
    //------- if not speaking: eye cliking.
//    int                 rb_LastEyeClicStartDate;
//    int                 rb_NextEyeClicFreeDate;

    if( probot->rb_CurrentDate< (probot->rb_LastEyeClicStartDate +32)  )
    {
        if( probot->rb_CurrentDate < (probot->rb_LastEyeClicStartDate+16)   )
        {
            rate = probot->rb_CurrentDate -(probot->rb_LastEyeClicStartDate);
            // rate [0,25] -> 0,65536
            rate<<=8;
            rate>>=4;
        }else
        {
            rate = (probot->rb_CurrentDate -(probot->rb_LastEyeClicStartDate))-16;
            rate = 16-rate;
            // rate [0,25] -> 0,65536
            rate<<=8;
            rate>>=4;;
        }

        // eye is blitting:


    }  else
    {
        // eyes follow a behaviour:

        rate = 0;
    }
/*    if(cc == 0)
        rate = ((unsigned int)(probot->rb_mouthHeight))<<12 ;
    else
        rate = ((unsigned int)(probot->rb_mouthWidth ))<<11 ;
*/
    if(rate>65536) rate=65536;
    if(rate<0) rate=0;

    //------
    PaResultlist->KEfp_Result = aa + (((bb-aa)*rate)>>8);

    return;
}



/*========================================================*/
/*====      re Module                              ======*/
/*========================================================*/
int     plre[];
char   *nameplre[];
void     KPF_Find_re( int *Pu,int Date , struct KEfParam *PaResultlist );

struct  KParamModuleDescription     KPM_re=
{
        "re",           /* used by karate */
        &KPF_Find_re,  /* fonction to use  */
        1,               /* number of underp' */
        1,              /* number of param filled. */
        returntypecte,
        plre,

      (char **) nameplre,
        "<Pa> re | v </Pa> time>>16. "
};
/*------------------------------------description--------*/
int     plre[]=
{
        KU_FixedFloat,0
};
char   *nameplre[]={ "n" };

/*========================================================*/
/*====      re Function                            ======*/
/*========================================================*/
/*-------------------------------------------------------------------*/
void     KPF_Find_re( int *Pu,int Date , struct KEfParam *PaResultlist )
{
    PaResultlist->KEfp_Result = Date;
    return;
}



/*///*/


/*===================================================================*/
/*==========================  Effect List to provide ================*/

/*===================================================================*/
struct  KEffectModuleDescription    *FxList[]=
{
    &KMD_processrobot,
    NULL

};
/*===================================================================*/
/*==========================  Param List to provide ================*/

struct  KParamModuleDescription     *PaList[]=
{
    &KPM_rbspksin,
    &KPM_rbeye,
    &KPM_re,
    NULL
};

/*===================================================================*/
/*==========================  DataMaker List to provide =============*/

struct  KDataMakerModuleDescription     *DataMakerList[]=
{
    &kMMD_robot,
    NULL
};
//------------- stuff created because amiga.lib was not enjoyed by the startup:
void _exit(void ){}
void _cleanup(void ){}

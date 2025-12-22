
#include "global.h"
#include "entries.h"
#include "audio.h"

#include <string.h>
#include <proto/ahi.h>
#include <proto/exec.h>
#include <exec/memory.h>
#include <dos/dostags.h>

#define AHIBase a->dev.ahi.ahiBase

#ifdef __amigaos4__
struct AHIIFace *IAHI;
#endif

/**************************************************************************
**
**  audio callback
*/

static ULONG SoundFunc(struct Hook *hook, struct AHIAudioCtrl *actrl, struct AHISoundMessage *smsg)
{
    struct Audio *a = actrl->ahiac_UserData;
    struct AHIAudioBuffer *buf;

    buf = a->doub[0];
    a->doub[0] = a->doub[1];
    a->doub[1] = buf;
    
    AHI_SetSound(0, buf->soundNum, 0, 0, actrl, NULL);
    a->flags |= AFL_REFILL;
    Signal((struct Task *) a->childProc, 1L << a->playSig);
    
    return 0;
}

/**************************************************************************
** 
**  success = openahi(g, a, freq, chans, depth, scale)
*/

static BOOL openahi(global *g, audio *a, LONG desired_freq, LONG chans, LONG depth, LONG scale)
{
    a->msgPort = CreateMsgPort();
    if (a->msgPort)
    {
        struct AHIDev *ahi = &a->dev.ahi;
    
        ahi->ahiReq = CreateIORequest(a->msgPort, sizeof(struct AHIRequest));
        if (ahi->ahiReq)
        {
            ahi->ahiReq->ahir_Version = 4;
            if (OpenDevice(AHINAME, AHI_NO_UNIT, (struct IORequest *) ahi->ahiReq, NULL) == 0)
            {
                LONG index;
            
                ahi->ahiBase = (struct Library *) ahi->ahiReq->ahir_Std.io_Device;

            #ifdef __amigaos4__
                if ((IAHI = (struct AHIIFace *)GetInterface(ahi->ahiBase, "main", 1, NULL)) != 0)
                {
            #endif
            
                if (chans == 2)
                {
                    ahi->modeID = AHI_BestAudioID(
                        AHIDB_Panning, TRUE,
                        AHIDB_Stereo, TRUE,
                        AHIDB_MaxChannels, 2,
                        AHIDB_MinMixFreq, 11025,
                        AHIDB_MaxMixFreq, 44100,
                       // AHIDB_Bits, depth,
                        TAG_DONE);
                }
                else
                {
                    ahi->modeID = AHI_BestAudioID(
                        AHIDB_MinMixFreq, 11025,
                        AHIDB_MaxMixFreq, 44100,
                       // AHIDB_Bits, depth,
                        TAG_DONE);
                }
                    
                if (ahi->modeID != AHI_INVALID_ID)
                {
                    AHI_GetAudioAttrs(ahi->modeID, NULL, AHIDB_IndexArg, desired_freq, AHIDB_Index, (ULONG) &index, TAG_DONE);
                    AHI_GetAudioAttrs(ahi->modeID, NULL, AHIDB_FrequencyArg, index, AHIDB_Frequency, (ULONG) &a->outFreq, TAG_DONE);

                    ahi->ahiCtrl = AHI_AllocAudio(AHIA_AudioID, ahi->modeID,
                        AHIA_MixFreq, a->outFreq, AHIA_Channels, 1, AHIA_Sounds, 2,
                        AHIA_SoundFunc, (ULONG) &ahi->soundHook, AHIA_UserData, (ULONG) a, TAG_DONE);
                
                    if (ahi->ahiCtrl)
                    {
                        ULONG fmt;
                    
                        AHI_GetAudioAttrs(AHI_INVALID_ID, ahi->ahiCtrl, AHIDB_MaxPlaySamples, (ULONG) &a->numSmp, TAG_DONE);

                        a->bufLen = a->numSmp * (depth >> 3) * chans;
                        a->mixFreq = a->outFreq * scale;
                        a->fScale = scale;
                        a->numChan = chans;
                        a->bitDepth = depth;
                        
                        switch (((chans-1)<<1)+(depth>>3)-1)
                        {   
                            default:
                                fmt = AHIST_M8S;
                                break;
                            case 1:
                                fmt = AHIST_M16S;
                                break;
                            case 2:
                                fmt = AHIST_S8S;
                                break;
                            case 3:
                                fmt = AHIST_S16S;
                                break;
                        }

                        a->flags = 0;

                        InitHook(&ahi->soundHook, (HOOKENTRY) SoundFunc, NULL);
                        
                        a->doub[0] = &ahi->buffer[0];
                        a->doub[1] = &ahi->buffer[1];
                        
                        ahi->buffer[0].soundNum = 0;
                        ahi->buffer[1].soundNum = 1;
                    
                        ahi->buffer[0].sampleInfo.ahisi_Type = fmt;
                        ahi->buffer[1].sampleInfo.ahisi_Type = fmt;
                        ahi->buffer[0].sampleInfo.ahisi_Length = a->numSmp;
                        ahi->buffer[1].sampleInfo.ahisi_Length = a->numSmp;

                        ahi->buffer[0].sampleInfo.ahisi_Address = AllocMem(a->bufLen, MEMF_PUBLIC | MEMF_CLEAR);
                        if (ahi->buffer[0].sampleInfo.ahisi_Address)
                        {
                            ahi->buffer[1].sampleInfo.ahisi_Address = AllocMem(a->bufLen, MEMF_PUBLIC | MEMF_CLEAR);
                            if (ahi->buffer[1].sampleInfo.ahisi_Address)
                            {
                                if (AHI_LoadSound(0, AHIST_DYNAMICSAMPLE, &ahi->buffer[0].sampleInfo, ahi->ahiCtrl) == 0)
                                {
                                    if (AHI_LoadSound(1, AHIST_DYNAMICSAMPLE, &ahi->buffer[1].sampleInfo, ahi->ahiCtrl) == 0)
                                    {
                                        return TRUE;
                                    }
                                    AHI_UnloadSound(0, ahi->ahiCtrl);
                                }
                                FreeMem(ahi->buffer[1].sampleInfo.ahisi_Address, a->bufLen);
                            }
                            FreeMem(ahi->buffer[0].sampleInfo.ahisi_Address, a->bufLen);
                        }
                        AHI_FreeAudio(ahi->ahiCtrl);
                    }
                }
            
            #ifdef __amigaos4__
                DropInterface((struct Interface *) IAHI);
                }
            #endif
            
                CloseDevice((struct IORequest *) ahi->ahiReq);
            }
            DeleteIORequest((struct IORequest *) ahi->ahiReq);
        }
        DeleteMsgPort(a->msgPort);
    }

    return FALSE;
}

/**************************************************************************
** 
**  closeahi(g, a)
*/

static void closeahi(global *g, audio *a)
{
    struct AHIDev *ahi = &a->dev.ahi;
    AHI_UnloadSound(1, ahi->ahiCtrl);
    AHI_UnloadSound(0, ahi->ahiCtrl);
    FreeMem(ahi->buffer[1].sampleInfo.ahisi_Address, a->bufLen);
    FreeMem(ahi->buffer[0].sampleInfo.ahisi_Address, a->bufLen);
    AHI_FreeAudio(ahi->ahiCtrl);
#ifdef __amigaos4__
    DropInterface((struct Interface *) IAHI);
#endif
    CloseDevice((struct IORequest *) ahi->ahiReq);
    DeleteIORequest((struct IORequest *) ahi->ahiReq);
    DeleteMsgPort(a->msgPort);
}

/**************************************************************************
**
**  childfunc
*/

static void childfunc(void)
{
    struct Process *self = (struct Process *) FindTask(NULL);
    global *g;
    audio *a;

    /* init message */

    WaitPort(&self->pr_MsgPort);

    a = (audio *) GetMsg(&self->pr_MsgPort);
    g = a->global;

    a->devOpen = openahi(g, a, 
        *(LONG *) g->args[ARG_FREQ], 
        g->args[ARG_STEREO]? 2 : 1, 
        16, 
        g->args[ARG_HIQ]? 2 : 1);

    if (a->devOpen)
    {
        a->playSig = AllocSignal(-1);
    }
    else
    {
        /* failure must be synchronized properly, too. send the reply in
        ** forbid state, so that the child process is gone when it arrives */

        Forbid();
    }

    ReplyMsg((struct Message *) a);

    if (a->devOpen)
    {
        LONG oldpri = SetTaskPri((struct Task *) a->childProc, 30);

        do
        {
            if (a->flags & AFL_REFILL)
            {
                if (a->fillFunc)
                {
                    struct AHIAudioBuffer *buf = a->doub[1];
                    LONG bpc = a->bitDepth >> 3;

                    (*a->fillFunc)(a->fillData, 
                        buf->sampleInfo.ahisi_Address, (BYTE *) buf->sampleInfo.ahisi_Address + bpc, bpc * a->numChan,
                        a->numSmp, a->fScale, a->bitDepth, a->numChan);

                }
                a->flags &= ~AFL_REFILL;
            }
            else if (a->flags & AFL_START)
            {
                if (!(a->flags & AFL_PLAY))
                {
                    struct AHIAudioBuffer *buf = a->doub[1];
                //  memset(buf->sampleInfo.ahisi_Address, 0, a->bufLen);
                    AHI_ControlAudio(a->dev.ahi.ahiCtrl, AHIC_Play, TRUE, TAG_DONE);
                    AHI_Play(a->dev.ahi.ahiCtrl,
                        AHIP_BeginChannel, 0,
                        AHIP_Freq, a->outFreq,
                        AHIP_Vol, 0x10000L,
                        AHIP_Pan, 0x8000L,
                        AHIP_Sound, buf->soundNum,
                        AHIP_Offset, 0, AHIP_Length, 0, AHIP_EndChannel, NULL, TAG_DONE);
                    a->flags |= AFL_PLAY | AFL_REFILL;
                }
                a->flags &= ~AFL_START;
            }
            else if (a->flags & AFL_STOP)
            {
                if (a->flags & AFL_PLAY)
                {
                    AHI_ControlAudio(a->dev.ahi.ahiCtrl, AHIC_Play, FALSE, TAG_DONE);
                }
                a->flags &= ~(AFL_STOP | AFL_PLAY);
            }
            else if (a->flags & AFL_EXIT)
            {
                if (a->flags & AFL_PLAY) a->flags |= AFL_STOP;
            }
            else
            {
                Wait(1L << a->playSig);
            }

        } while (a->flags != AFL_EXIT);
        
        SetTaskPri((struct Task *) a->childProc, oldpri);

        closeahi(g, a);

        Forbid();

        FreeSignal(a->playSig);

        /* signal that we are gone. since we are in forbid state, the
        ** parent can synchronize on exitsig reliably */

        Signal((struct Task *) g->self, 1L << a->exitSig);
    }
}

/**************************************************************************
** 
**  mixfreq = InitAudio(global, audio)
**      Initialize audio structure
*/

LIBAPI LONG InitAudio(global *g, audio *a)
{
    struct MsgPort *iniport;
    
    memset(a, 0, sizeof(audio));
    a->global = g;
    
    iniport = CreateMsgPort();  
    if (iniport)
    {
        a->exitSig = AllocSignal(-1);
        if (a->exitSig != -1)
        {
            a->procEntry = AllocProcEntry(childfunc);
            if (a->procEntry)
            {
                a->childProc = CreateNewProcTags(NP_Entry, (ULONG) a->procEntry, TAG_DONE);
                if (a->childProc)
                {
                    a->iniMsg.mn_ReplyPort = iniport;
                    a->iniMsg.mn_Length = sizeof(audio);
        
                    PutMsg(&a->childProc->pr_MsgPort, (struct Message *) a);
                    WaitPort(iniport);
                    GetMsg(iniport);
        
                    if (a->devOpen) 
                    {
                        /* success */
                        DeleteMsgPort(iniport);
                        return a->outFreq;
                    }
                }
                FreeProcEntry(a->procEntry);
            }
            FreeSignal(a->exitSig);
        }
        DeleteMsgPort(iniport);
    }
    return 0;
}

/**************************************************************************
**
**  ExitAudio(global, audio)
**      Closedown audio
*/

LIBAPI void ExitAudio(global *g, audio *a)
{
    a->flags |= AFL_EXIT;
    Signal((struct Task *) a->childProc, 1L << a->playSig);
    Wait(1L << a->exitSig);
    FreeProcEntry(a->procEntry);
    FreeSignal(a->exitSig);
}

/**************************************************************************
**
**  PlayAudio(global, audio, boolean)
*/

LIBAPI void PlayAudio(global *g, audio *a, BOOL play)
{
    Forbid();
    if (play)
    {
        a->flags |= AFL_START;
    }
    else
    {
        a->flags |= AFL_STOP;
    }
    Signal((struct Task *) a->childProc, 1L << a->playSig);
    Permit();
}

/**************************************************************************
**
**  SetAudioFunc(global, audio, func, data)
*/

LIBAPI void SetAudioFunc(global *g, audio *a, FILLFUNC func, APTR data)
{
    Forbid();
    a->fillFunc = func;
    a->fillData = data;
    Permit();
}


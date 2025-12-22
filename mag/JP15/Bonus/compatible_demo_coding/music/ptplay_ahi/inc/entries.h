
#ifndef _ENTRIES_H
#define _ENTRIES_H

#include "global.h"

typedef ULONG (*HOOKENTRY)(APTR data, APTR object, APTR message);
LIBAPI void InitHook(struct Hook *hook, HOOKENTRY func, APTR data);
LIBAPI APTR AllocProcEntry(void (*func)(void));
LIBAPI void FreeProcEntry(APTR procEntry);

#endif


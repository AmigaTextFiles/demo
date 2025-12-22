
#include <utility/hooks.h>
#include "entries.h"

#ifdef __SASC
	#define HOOKENT			__asm
	#define REG(reg,arg)	register __ ## reg arg
#endif

#ifdef __GNUC__
	#define HOOKENT
	#define REG(reg,arg)	arg __asm( #reg )
#endif

static HOOKENT ULONG HookStub(
	REG(a0, struct Hook *hook),
	REG(a2, APTR object),
	REG(a1, APTR message))
{
	HOOKENTRY func = hook->h_SubEntry;
	return (*func)(hook->h_Data, object, message);
}

LIBAPI void InitHook(struct Hook *hook, HOOKENTRY func, APTR data)
{
	hook->h_Entry = (ULONG (*)()) HookStub;
	hook->h_SubEntry = func;
	hook->h_Data = data;
}

LIBAPI APTR AllocProcEntry(void (*func)(void))
{
	return func;
}

LIBAPI void FreeProcEntry(APTR procEntry)
{
}


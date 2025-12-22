#include <time.h>
#include <exec/types.h>

extern clock_t starttime; // Time when timerinitstart were called!
extern clock_t stoptime;
extern clock_t funkctime;
extern clock_t funketime;
extern clock_t fdifftime;

void timerinitstart(ULONG frames);
void newfunctimer(ULONG frames);
void timerdiff(void);


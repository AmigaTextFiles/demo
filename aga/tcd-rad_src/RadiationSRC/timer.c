#include "timer.h"
#include <time.h>

clock_t starttime=0, stoptime=0, funkctime=0, funketime=0, fdifftime=0;

void timerinitstart(ULONG frames)
{
	starttime = clock(); // Startvärdet skall vi ha, det är bra! (är==0 ?)
	funkctime = clock(); // Nuvarande tid variabel...
	funketime = funkctime+frames-fdifftime; // Hur länge skall vi hålla på?
}

void newfunctimer(ULONG frames)
{
	fdifftime = clock() - funketime; // Skillnaden i tid från den beräknade funktiden...
	funkctime = clock(); // Nuvarande tid variabel...
	funketime = funkctime+frames-fdifftime; // Hur länge skall vi hålla på?
}

void timerdiff(void)
{
	fdifftime = clock() - funketime; // Skillnaden i tid från den beräknade funktiden...
}


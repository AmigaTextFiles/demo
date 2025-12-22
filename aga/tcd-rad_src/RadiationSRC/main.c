#include "startup.h"
#include "demo.h"

void main(void)
{
	startup();
	startdemo();
	shutdown(NULL);
}

void wbmain(void)
{
	startup();
	startdemo();
	shutdown(NULL);
}


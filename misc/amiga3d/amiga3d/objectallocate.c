#include <exec/types.h>
#include <exec/memory.h>
#include "threed.h"


allocateobjectinfolist(view,screen,window,firstobjectinfo,firstobject)
struct View *view;
struct Screen *screen;
struct Window *window;
struct Objectinfo **firstobjectinfo;
struct Object *firstobject;
{
	struct Object *ob;
	int error = FALSE;

	/* allocate objectinfo structures */

	/* for all the objects in this objectsegment */

	for (ob = firstobject; ob; ob = ob->nextobject)
	{
	    struct Objectinfo *thisobjectinfo;

#ifdef CAMERADEBUG
	    printf("test3d: allocate objectinfo for object(%lx) ",ob);
#endif

	    /* allocate an objectinfo structure for the current object */

	    if ((thisobjectinfo = (struct Objectinfo *)AllocMem(sizeof(struct Objectinfo),MEMF_PUBLIC|MEMF_CLEAR)) == NULL) 
	    {
		error = TRUE;
		return(error); 
	    }

#ifdef CAMERADEBUG
	    printf("= %lx\n",thisobjectinfo);
#endif
	    /* initialize the buffers for the current 3d object */

	    if(!objectinit(view,screen,window,thisobjectinfo,ob))
	    {
		error = TRUE;
	        return(error);
	    }

	    /* make this objectinfo last on the objectinfo list */
	    {
		struct Objectinfo **oipp;

		oipp =  firstobjectinfo;
		while (*oipp)
		{
		    oipp = &((*oipp)->nextobjectinfo);
		}
		*oipp = thisobjectinfo;
		 thisobjectinfo->nextobjectinfo = NULL;
	    }

	}

}


deallocateobjectinfolist(view,screen,window,firstobjectinfo)
struct View *view;
struct Screen *screen;
struct Window *window;
struct Objectinfo **firstobjectinfo;
{

    /* deallocate objectinfo structures */

#ifdef ODEBUG
    printf("test3d: deallocate the active objectinfo structures...\n");
#endif

    while( (*firstobjectinfo) )
    {
	struct Objectinfo *oip;

	/* delink the first objectinfo from the objectinfo list */

	oip = *firstobjectinfo;

	(*firstobjectinfo) = (*firstobjectinfo)->nextobjectinfo;

	/* deallocate the buffers dependent on the current objectinfo */

#ifdef ODEBUG
    printf("    deallocate objectinfo(%lx)\n",oip);
#endif

	objectdeallocate(view,screen,window,oip);

	/* deallocate this objectinfo structure itself */

	FreeMem(oip,sizeof(struct Objectinfo));
    }

}

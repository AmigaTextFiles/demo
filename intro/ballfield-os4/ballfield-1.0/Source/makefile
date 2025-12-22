#
# Try this one ('make  -f makefile.old') if you don't want to use autotools.
#

CC =		gcc
CPATH =		-I/sdk/local/newlib/include/SDL -I/sdk/local/common/include/SDL 

CLIBS =		$(shell sdl-config --libs) -lSDL_image -ljpeg -lpng -lz
CFLAGS =	-g -O3 -Wall -mcrt=newlib $(shell sdl-config --cflags)

HEADERS =	ballfield.h
SOURCES =	ballfield.c

all:		ballfield

clean:
		-rm -f *.o
		-rm ballfield

ballfield:	${HEADERS} ${SOURCES}
		${CC} ${CFLAGS} -o ballfield ${CPATH} ${SOURCES} ${CLIBS}

# makefile for Virtual-kend

# (Based on Agendaroids)

# by Bill Kendrick
# bill@newbreedsoftware.com
# http://www.newbreedsoftware.com/virtual-kend/

# June 3, 2002 - June 3, 2002

CC=GCC -mcrt=newlib
PREFIX=/PROGDIR/
DATA_PREFIX=$(PREFIX)Data/

TARGET_DEF=LINUX

SDL_LIB=-lSDL_gfx -lSDL_net -lSDL_image -lpng -ljpeg -lz -lSDL_mixer -lvorbisfile -lvorbis -logg -lSDL_ttf -lfreetype -lz -lsdlmain -lsdl -lauto -lpthread -lm -lunix

CFLAGS=-Wall -Wno-long-long -pedantic -ansi -O2 -mcrt=newlib -Wall -O2 -I/sdk/local/newlib/include/SDL -I/sdk/local/common/include/SDL \
	$(shell sdl-config --cflags) \
	-DDATA_PREFIX=\"$(DATA_PREFIX)\" -D$(TARGET_DEF)


all:	virtual-kend

embedded:
	make virtual-kend \
		DATA_PREFIX=/opt/QtPalmtop/share/virtual-kend/ \
		SDL_LIB="/usr/local/arm/lib/libSDL.a -L/usr/local/arm/lib/ -lpthread -L/opt/Qtopia/sharp/lib -lqpe -lqte" \
		CC=/usr/local/arm/bin/arm-linux-gcc
	/usr/local/arm/bin/arm-linux-strip virtual-kend


nosound:
	make virtual-kend

install:
	install -d $(DATA_PREFIX)
	cp -R data/* $(DATA_PREFIX)
	chmod -R a+rX,g-w,o-w $(DATA_PREFIX)
	cp virtual-kend $(BIN_PREFIX)
	chmod a+rx,g-w,o-w $(BIN_PREFIX)/virtual-kend


clean:
	-rm virtual-kend
	-rm *.o


virtual-kend:	virtual-kend.o
	$(CC) $(CFLAGS) virtual-kend.o -o virtual-kend $(SDL_LIB)


virtual-kend.o:	virtual-kend.c

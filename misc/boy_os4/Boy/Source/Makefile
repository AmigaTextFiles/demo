ARCH = 
#win32
#osx-x86
#osx-ppc

# Generic settings for Unix-like platforms
CC = gcc
RANLIB = ranlib
AR = ar
MAKE = make
TARGET = boy

CFLAGS = -Wall -O2 -ffast-math `sdl-config --cflags` -DMINIGL -fPIC -I/sdk/local/newlib/include/SDL -I/sdk/local/newlib/include/ -I/sdk/local/common/include/
LDFLAGS = `sdl-config --libs` -lGL -lm
OBJ = main.o gl_render.o wavefront.o tga.o cgm.o cgm_gl.o writer.o \
catmull-rom.o stripe.o stiks.o houses.o vecmat.o 

# MinGW cross-compile on Linux
ifeq ($(ARCH),win32)
 TARGET = boy.exe

 CC = i586-mingw32msvc-gcc
 RANLIB = i586-mingw32msvc-ranlib
 AR = i586-mingw32msvc-ar

 CFLAGS = -Wall -O2 -ffast-math `i586-mingw32msvc-sdl-config --cflags`\
 -DNOSTRSEP
 LDFLAGS = `i586-mingw32msvc-sdl-config --libs` -lopengl32
endif

# Mac OS X x86
ifeq ($(ARCH),osx-x86)
 CFLAGS = -arch i386 -Wall -O2 -ffast-math `sdl-config --cflags`
 LDFLAGS = -arch i386 `sdl-config --static-libs` -lm
endif

# Mac OS X PPC
ifeq ($(ARCH),osx-ppc)
 CFLAGS = -arch ppc -Wall -O2 -ffast-math `/usr/ppc/bin/sdl-config --cflags`
 LDFLAGS = -arch ppc `/usr/ppc/bin/sdl-config --static-libs` -lm
endif

# Sound with mpglib
OBJ += mp3.o mpglib/libmpg.a

# Sound with fmod (Needed only for Windoze because mpglib fails)
#OBJ += mp3fmod.o
#LDFLAGS += -lfmod

export

$(TARGET): $(OBJ)
	$(CC) -o $(TARGET) $(OBJ) $(LDFLAGS)
	strip $(TARGET)

mpglib/libmpg.a:
	cd mpglib && $(MAKE)

clean:
	-(cd mpglib && $(MAKE) clean)
	rm *.o $(TARGET) *~

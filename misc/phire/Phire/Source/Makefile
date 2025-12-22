CC      = gcc
CPP     = g++
RM      = /bin/rm
STRIP   = /bin/strip
CDEF = -DVER=\"$(VER)\"
CFLAGS	= -O2 -fomit-frame-pointer -mcrt=clib2 -W -Wall -O2 -I/sdk/local/clib2/include/SDL -I/sdk/local/common/include/SDL 
CXXFLAGS = $(CDEF) $(COPT) $(CWARN)
LDFLAGS	= -lSDL_image -lpng -ljpeg -lz -lSDL_mixer -lvorbisfile -lvorbis -logg -lSDL_ttf -lfreetype -lsdlmain -lsdl -lauto -lpthread -lm
OBJS	= app.o  app_cmdl.o  app_video.o  fire.o  keys.o  phire.o  node.o  prng.o
OUTPUT	= Phire.exe

all: $(OBJS)
		$(CPP) $(CFLAGS) -o $(OUTPUT) $(OBJS) $(LDFLAGS)

main.o:
		app.cpp
		$(CPP) ${CFLAGS} -c app.cpp

		app_cmdl.cpp
		$(CPP) ${CFLAGS} -c app_cmdl.cpp

		app_video.cpp
		$(CPP) ${CFLAGS} -c app_video.cpp

		fire.cpp
		$(CPP) ${CFLAGS} -c fire.cpp

		keys.cpp
		$(CPP) ${CFLAGS} -c keys.cpp

		phire.cpp
		$(CPP) ${CFLAGS} -c phire.cpp

		node.cpp
		$(CPP) ${CFLAGS} -c node.cpp

		prng.cpp
		$(CPP) ${CFLAGS} -c prng.cpp

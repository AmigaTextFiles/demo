
CC      = gcc
CPP     = g++
RM      = /bin/rm
STRIP   = /bin/strip
CFLAGS	= -mcrt=newlib -Wall -O2 -I/sdk/local/newlib/include/SDL -I/sdk/local/common/include/SDL 
LDFLAGS	= -mcrt=newlib -lSDL_image -lpng -ljpeg -lz -lSDL_mixer -lvorbisfile -lvorbis -logg -lSDL_ttf -lfreetype -lsdlmain -lsdl -lauto -lpthread -lm
OBJS	= lightning.o
OUTPUT	= Lightning.exe

all: $(OBJS)
		$(CC) $(CFLAGS) $(OBJS) -o $(OUTPUT) $(LDFLAGS)

main.o:		lightning.cpp 
		$(CPP) ${CFLAGS} -c lightning.cpp



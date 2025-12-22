
TARGET=NoddingChod.exe

all: $(TARGET)

CC	= gcc
CFLAGS	= -mcrt=newlib -Wall -O2 -I/sdk/local/newlib/include/SDL -I/sdk/local/common/include/SDL  -O2 -D_REENTRANT -DDATA_PREFIX=data/
LDFLAGS = -mcrt=newlib -lSDL_image -lpng -ljpeg -lz -lSDL_mixer -lvorbisfile -lvorbis -logg -lSDL_ttf -lfreetype -lsdlmain -lsdl -lauto -lpthread -lm 

$(TARGET): main.o
	$(CC) -o $(TARGET) main.o $(LDFLAGS) 

main.o: main.c 

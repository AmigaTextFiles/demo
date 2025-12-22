# Bouncing Makefile
# type 'make' to compile
# 'make clean' to remove compilation results (ie. for packaging)

CC = gcc
CFLAGS = -mcrt=newlib -Wall -I/sdk/local/newlib/include/SDL -I/sdk/local/common/include/SDL `sdl-config --cflags` 
CXXFLAGS = -mcrt=newlib -Wall -I/sdk/local/newlib/include/SDL -I/sdk/local/common/include/SDL `sdl-config --cflags`
LIBS  = `sdl-config --libs` -mcrt=newlib -lSDL_image -lpng -ljpeg -lz -lSDL_mixer -lvorbisfile -lvorbis -logg -lSDL_ttf -lfreetype -lsdlmain -lsdl -lauto -lpthread -lm
SRC = bouncing.c
OBJ = bouncing.o
TARGET = bouncing

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) -o $(TARGET) $(OBJ) $(LIBS) 

clean:
	rm -f $(TARGET) $(OBJ) core

# Ricardo Cruz <rick2@aiou.pt>

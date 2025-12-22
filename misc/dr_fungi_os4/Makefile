# Dr. Fungii Makefile
# GNU make syntax

# Change this... ATM known are OSX or empty for generic Unix/Linux
TARGET = 

# General defaults
CC = gcc
COPT = -O2 -ffast-math -DMSB -mcrt=newlib
INC = 
LIB = -lSDL -lGL -lGLU -lGLUT -ljpeg -lm -mcrt=newlib
MZX = cool_mzx/cool_mzx.a
OBJ = main.o jpeg.o kukat.o mcubes.o halftone.o tolppa.o

export

dr_fungi: $(OBJ) $(MZX)
	$(CC) -o dr_fungi $(OBJ) $(MZX) $(LIB)
	strip dr_fungi

$(MZX):
	cd cool_mzx && make

%.o: %.c
	$(CC) $(COPT) $(INC) -c $<

clean:
	rm *.o dr_fungi
	cd cool_mzx && make clean

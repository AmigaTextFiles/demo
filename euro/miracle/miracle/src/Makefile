# Endianness: LITTLE/BIG (x86,Alpha/MIPS,PPC,SPARC etc.)
ENDIAN = BIG

MAKE = make
RANLIB = ranlib
EXE = miracle.exe

INC = -Ivecsys
SDL = -lsdl_mixer -lvorbisfile -lvorbis -logg -lsdl_image -ljpeg -lpng -lz -lsdl
CC = gcc

#LIB = -lauto -lm -newlib
LIB = -lauto -lm
#OPT = -ffast-math -D$(ENDIAN) -newlib
OPT = -O2 -ffast-math -D$(ENDIAN)
COOL = cool_mzx/cool_mzx.a cool_gfx/cool_gfx.a
OBJ = main.o venkula.o data.o maf.o feidi.o panorama.o suumi.o halftone.o \
      flarex.o ranta.o

export CC
export RANLIB

miracle.exe: $(OBJ) vecsys/vecsys.a $(COOL)
	$(CC) -o $@ $(OBJ) vecsys/vecsys.a $(COOL) $(SDL) $(LIB)
	strip miracle.exe

%.o: %.c
	$(CC) $(OPT) $(INC) -c $<

clean:
	delete #?.o $(EXE)


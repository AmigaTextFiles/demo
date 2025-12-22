CC = gcc
CFLAGS = -ffast-math
#LDFLAGS = `sdl-config --libs` -lm
LDFLAGS = -lsdl_mixer -lvorbisfile -lvorbis -logg -lsdl_image -ljpeg -lpng -lz -lsdl -lauto -lm
OBJ = data.o kirjaimet2.o kokko.o maf.o main.o mosaic.o pallot.o plasma.o\
ratas.o stripes.o video.o cool_mzx/cool_mzx.a

# Sound buffer size (default=1024)
#CFLAGS += -DBUFSIZE=8192
# True 8 bit display?
#CFLAGS += -DTRUE8BIT

export

chrysler: $(OBJ)
	$(CC) -o $@ $(OBJ) $(LDFLAGS)
	strip $@

%.o: %.c
	$(CC) $(CFLAGS) -c $<

cool_mzx/cool_mzx.a:
	cd cool_mzx
	make

clean:
	delete #?.o


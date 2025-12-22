CC=GCC

CFLAGS = -O2 -Wall -newlib -ISDK:local/newlib/include/SDL 
LDFLAGS = -newlib -lSDL -lauto -lpthread 

all: timeless gensprites

timeless: timeless.o data.o sprites.o

timeless.o:	timeless.c timeless.h

data.o: data.c timeless.h

sprites.o: sprites.c

clean:
	rm -f *.o timeless

test:	all
	./timeless

gensprites: gensprites.c

nsprites.c: gensprites
	gensprites > nsprites.c
	echo Actually you\'d want to rename nsprites.c to sprites.c

#
# Makefile
#
# http://aminet.net/dev/lib/chunky.lha
#

CPU = -m68000
#CPU = -m68020-60
CC = gcc
CFLAGS = $(CPU) -msoft-float -O3 -Wall -I. -noixemul -funroll-all-loops \
-fforce-addr -fforce-mem -fomit-frame-pointer -fstrength-reduce
PROGS = acidwarp 
OSOURCES = bit_map.o palinit.o rolnfade.o lut.o amiga.o acidwarp.o

all: $(PROGS)

$(PROGS): $(OSOURCES)
	$(CC) -s $(CFLAGS) $(OSOURCES) -o $(PROGS) -lchunky

bit_map.o: 
palinit.o:
lut.o:
amiga.o:
acidwarp.o:
rolnfade.o: rolnfade.c
	$(CC) $(CFLAGS) -fno-rerun-loop-opt -c rolnfade.c -o $@

clean:
	rm -f $(PROGS) *.o

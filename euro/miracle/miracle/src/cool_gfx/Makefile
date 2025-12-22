COPT=-O2 -ffast-math
AR=ar
OWNOBJ=blit32a.o


# SDL specific

CC=gcc
ASM=
CDEF=-DSDL
OWNOBJ= gfx_sdl.o blit32c.o
KOE=-lSDL -lpthread
ASMOPT=-f coff -dUNDERSCORE -dSELECTOR


cool_gfx.a: blit32.o $(OWNOBJ)
	ar rc cool_gfx.a blit32.o $(OWNOBJ)
	ranlib cool_gfx.a

gfx_x.o: gfx_x.c gfx_x.h
	$(CC) $(COPT) -c gfx_x.c $(CDEF)

gfx_svga.o: gfx_svga.c gfx_svga.h blit32.o
	$(CC) $(COPT) -c gfx_svga.c $(CDEF)

gfx_sdl.o: gfx_sdl.c gfx_sdl.h
	$(CC) $(COPT) -c gfx_sdl.c $(CDEF)

gfx_dos.o: vesa.o gfx_dos.c gfx_dos.h
	$(CC) $(COPT) -c gfx_dos.c $(CDEF)

tweak.o: tweak.c tweak.h
	$(CC) $(COPT) -c tweak.c $(CDEF)

vesa.o: vesa.c vesa.h
	$(CC) $(COPT) -c vesa.c $(CDEF)

blit32.o: blit32.c blit32.h
	$(CC) $(COPT) -c blit32.c $(CDEF)

blit32c.o: blit32c.c
	$(CC) $(COPT) -c blit32c.c $(CDEF)

blit32a.o: blit32a.asm
	$(ASM) $(ASMOPT) blit32a.asm

clean:
	delete #?.o
	delete #?.a

#
# type "make" to build,
# type "make clean" to erase objs and exe.

#devpac's genam asm flags. "alink" is to produce a ".o"
#this is copied from a devpac's genam.opts
GENAMFLAGS = incdir include -vp=68020 -vow-,o+,o2-,ow3+,o7-,o8-,o9- alink bdw inconce nocase
GENAMFLAGS += -eDDEBUG=1 -eFILETEMP=32768 -eDOMUSIC=1

PHXFLAGS = M=68020 I=include,src
#PHXFLAGS += SET="DDEBUG=1,FILETEMP=32768,DOMUSIC=1"

SRCDIR = src

# important: startup first in link
SRC = $(SRCDIR)/startupWithShuntAGA.s \
$(SRCDIR)/demo.s \
$(SRCDIR)/copperCompiler.s \
$(SRCDIR)/tripleBuffer.s \
$(SRCDIR)/spriteTools.s \
$(SRCDIR)/DatLoader.s \
$(SRCDIR)/p61Link.s \
$(SRCDIR)/c2p1x1_8_16b_68k_bm.s \
$(SRCDIR)/fxStart.s \
$(SRCDIR)/fxLoad.s \
$(SRCDIR)/fxLoadGo.s \
$(SRCDIR)/fxDual3D.s \
$(SRCDIR)/fx3D_ext1.s \
$(SRCDIR)/fx3D_ext2.s \
$(SRCDIR)/fx3D_ext3.s \
$(SRCDIR)/fxRidgedNoise.s \
$(SRCDIR)/fxDualLisa.s \
$(SRCDIR)/fxTitle.s \
$(SRCDIR)/bob.s \
$(SRCDIR)/moves.s \
$(SRCDIR)/k3d.s \
$(SRCDIR)/k2d.s \
$(SRCDIR)/inmem.s \
$(SRCDIR)/blitGrid.s \
$(SRCDIR)/GifToBm.c \
\

OBJS = obj/startupWithShuntAGA.o \
obj/demo.o \
obj/inmem.o \
obj/fxStart.o \
obj/fxLoad.o \
obj/fxLoadGo.o \
obj/fxDual3D.o \
obj/fx3D_ext1.o \
obj/fx3D_ext2.o \
obj/fx3D_ext3.o \
obj/fxRidgedNoise.o \
obj/fxDualLisa.o \
obj/fxTitle.o \
obj/blitGrid.o \
obj/copperCompiler.o \
obj/tripleBuffer.o \
obj/spriteTools.o \
obj/DatLoader.o \
obj/p61Link.o \
obj/c2p1x1_8_16b_68k_bm.o \
obj/bob.o \
obj/moves.o \
obj/k3d.o \
obj/k2d.o \
cobj/GifToBm.o \
\

EXE=Catabasis.exe
DAT=Catabasis.dat

all: $(EXE) $(DAT)

clean:
	delete all force obj $(DAT) $(EXE) $(EXE).info

$(EXE): obj $(OBJS)
#devpac linker
#	blink FROM $(OBJS) TO $@
# sasc linker (better, merge hunks):
#	 slink FROM $(OBJS) TO $@ sc nd
#	 phxlnk  $(OBJS) TO $@ nd
	blink FROM $(OBJS) TO $@ sc nd
	Copy res/Catabasis.exe.info $@.info


$(DAT): res/dat.s res/dat.i
#	 genam res/dat.s TO $@
	phxass FROM res/dat.s TO $@ I=res

obj:
	makedir obj

obj/%.o: src/%.s src/demoData.i src/bob.i
	phxass $(PHXFLAGS) FROM $< TO $@
#	 genam $(GENAMFLAGS) $< TO $@



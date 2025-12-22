#################################
#								#
# SAS C 6.x makefile			#
#								#
#								#
#								#
#								#
#################################

LIBS   = lib:sc.lib lib:amiga.lib
START  = lib:c.o

CC = SC
LINK = SLINK

CFLAGS = GST /AmigaGST/amiga.gst
LFLAGS = NOICONS QUIET

#################################

all: agatunnel

#################################

agatunnel.o:	agatunnel.c

#################################

agatunnel:		agatunnel.o
	$(LINK) FROM $(START) agatunnel.o TO $@ LIB $(LIBS) $(LFLAGS)

#################################

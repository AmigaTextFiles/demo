#
# Makefile for AROS demos, using MorphOS SDK (gcc 2.95.3)
#

CFLAGS =	-c						\
		-pipe						\
		-O2						\
		-Wall						\
		-noixemul

PRG =		MicroEmacs
LIBS =		-noixemul
CC =		gcc
LD =		gcc

.c.o:
	${CC} ${CFLAGS} $< -o $@

SRC =	ansi.c		basic.c		buffer.c		\
	display.c	file.c		fileio.c		\
	line.c		main.c		random.c		\
	region.c	search.c	spawn.c			\
	tcap.c		termio.c	vt52.c			\
	window.c	word.c

OBJ =	$(SRC:.c=.o)

$(PRG): $(OBJ)
	${LD} -o $(PRG) $(OBJ) $(LIBS)

clean:
	rm -fv *.o $(PRG)

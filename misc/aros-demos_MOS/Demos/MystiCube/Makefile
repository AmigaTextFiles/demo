#
# Makefile for AROS demos, using MorphOS SDK (gcc 2.95.3)
#

CFLAGS =	-c						\
		-pipe						\
		-O2						\
		-Wall						\
		-noixemul

PRG =		MystiCube
LIBS =		-noixemul
CC =		gcc
LD =		gcc

.c.o:
	${CC} ${CFLAGS} $< -o $@

SRC =	mysticube.c	logo.c

OBJ =	$(SRC:.c=.o)

$(PRG): $(OBJ)
	${LD} -o $(PRG) $(OBJ) $(LIBS)

clean:
	rm -fv *.o $(PRG)

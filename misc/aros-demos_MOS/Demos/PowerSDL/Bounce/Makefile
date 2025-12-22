#
# Makefile for SDL demos, using MorphOS SDK (gcc 2.95.3)
#

CFLAGS =	-c						\
		-pipe						\
		-O2						\
		-Wall						\
		-noixemul

PRG =		Bounce
LIBS =		-noixemul -lSDLshared
CC =		gcc
LD =		gcc

.c.o:
	${CC} ${CFLAGS} $< -o $@

SRC =	main.c

OBJ =	$(SRC:.c=.o)

$(PRG): $(OBJ)
	${LD} -o $(PRG) $(OBJ) $(LIBS)

clean:
	rm -fv *.o $(PRG)

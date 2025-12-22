# :ts=8 bk=0
##
# Makefile for EuroStars.
# Written for the SAS assembler (because I don't have anything else, that's
# why).
#
OBJ =		es.o

.asm.o:
	asm -iINCLUDE: $*.asm

es: $(OBJ)
	blink $(OBJ) LIB LIB:amiga2.0.lib to ES SC SD ND NOICONS

es.doc: es
	autodoc >es.doc -a ES.asm


CFLAGS += -DLAYER1 -DLAYER2 -DLAYER3

all: libmpg.a

*.o: mpg123.h mpglib.h

libmpg.a: layer1.o layer2.o common.o dct64_i386.o decode_i386.o layer3.o \
	tabinit.o interface.o
	$(AR) rc libmpg.a \
		common.o dct64_i386.o decode_i386.o layer3.o \
		tabinit.o interface.o layer2.o layer1.o
	$(RANLIB) libmpg.a

# ranlib might not be needed on your system

clean:
	rm *.o libmpg.a

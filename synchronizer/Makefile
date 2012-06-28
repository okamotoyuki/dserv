CC = gcc
CLANG = clang
CFLAGS = -g0 -O2 -Wall
LDLIB = -llogpool
SRC = src
BUILD = build
OBJ = $(BUILD)/sync.o
TAR = $(BUILD)/sync
MOD1 = $(BUILD)/mod_sync1.bc
MOD2 = $(BUILD)/mod_sync2.bc

all : $(TAR) $(MOD1) $(MOD2)

$(TAR) : $(SRC)/sync.c
	$(CC) $(CFLAGS) $^ -o $@ $(LDLIB)

$(MOD1) : $(SRC)/mod_sync1.c
	$(CLANG) $^ -o $@ -c -g0

$(MOD2) : $(SRC)/mod_sync2.c
	$(CLANG) $^ -o $@ -c -g0

./PHONY : clean

clean :
	rm $(TAR) $(MOD1) $(MOD2)

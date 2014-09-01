GHC_VERSION := $(shell ghc --numeric-version)
GHC_PREFIX := $(shell dirname $(shell dirname $(shell which ghc)))
GHC_INCLUDE := $(GHC_PREFIX)/lib/ghc-$(GHC_VERSION)/include
GHC_THREADED := HSrts_thr-ghc$(GHC_VERSION)

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
LIBFIB_SHARED := libfib.dylib
endif
ifeq ($(UNAME_S),Linux)
LIBFIB_SHARED := libfib.so
endif


all: test


.PHONY: build clean test

build: dist/main dist/$(LIBFIB_SHARED)

clean:
	rm -rf dist

test: dist/main build
	dist/main dist/$(LIBFIB_SHARED)

dist/main: src/libfib/libfib.h src/main.c
	@mkdir -p dist
	cc -Isrc/libfib -O2 -Wall -o dist/main src/main.c -std=c99 -ldl -lpthread

dist/Fib.o dist/Fib_stub.h: src/libfib/Fib.hs
	@mkdir -p dist
	ghc -O2 -c -dynamic -outputdir=dist src/libfib/Fib.hs

dist/libfib.o: src/libfib/libfib.h src/libfib/libfib.c dist/Fib_stub.h
	cc -DLIBFIB_SHARED=$(LIBFIB_SHARED) -I$(GHC_INCLUDE) -Idist -O2 -Wall -c -fPIC -o dist/libfib.o -std=c99 src/libfib/libfib.c

dist/$(LIBFIB_SHARED): dist/Fib.o dist/libfib.o
	ghc -O2 -dynamic -outputdir=dist -o dist/$(LIBFIB_SHARED) -shared dist/Fib.o dist/libfib.o -l$(GHC_THREADED)

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

build: dist/main dynamic-build static-build

clean:
	rm -rf dist

test: dist/main dynamic-test static-test

dist/main: src/libfib/libfib.h src/main.c
	@mkdir -p dist
	cc -Isrc/libfib -O2 -Wall -o dist/main src/main.c -std=c99 -ldl -lpthread


.PHONY: dynamic dynamic-build dynamic-clean dynamic-test

dynamic-build: dist/dynamic/$(LIBFIB_SHARED)

dynamic-clean:
	rm -rf dist/dynamic

dynamic-test: dist/main dynamic-build
	dist/main dist/dynamic/$(LIBFIB_SHARED)

dist/dynamic/Fib.o dist/dynamic/Fib_stub.h: src/libfib/Fib.hs
	@mkdir -p dist
	ghc -O2 -c -dynamic -outputdir=dist/dynamic src/libfib/Fib.hs

dist/dynamic/libfib.o: src/libfib/libfib.h src/libfib/libfib.c dist/dynamic/Fib_stub.h
	cc -DLIBFIB_FLAVOUR=dynamic -DLIBFIB_SHARED=$(LIBFIB_SHARED) -I$(GHC_INCLUDE) -Idist/dynamic -O2 -Wall -c -fPIC -o dist/dynamic/libfib.o -std=c99 src/libfib/libfib.c

dist/dynamic/$(LIBFIB_SHARED): dist/dynamic/Fib.o dist/dynamic/libfib.o
	ghc -O2 -dynamic -outputdir=dist/dynamic -o dist/dynamic/$(LIBFIB_SHARED) -shared dist/dynamic/Fib.o dist/dynamic/libfib.o -l$(GHC_THREADED)


.PHONY: static static-build static-clean static-test

static-build: dist/static/$(LIBFIB_SHARED)

static-clean:
	rm -rf dist/static

static-test: dist/main static-build
	dist/main dist/static/$(LIBFIB_SHARED)

dist/static/Fib.o dist/static/Fib_stub.h: src/libfib/Fib.hs
	@mkdir -p dist
	ghc -O2 -c -outputdir=dist/static -static src/libfib/Fib.hs

dist/static/libfib.o: src/libfib/libfib.h src/libfib/libfib.c dist/static/Fib_stub.h
	cc -DLIBFIB_FLAVOUR=static -DLIBFIB_SHARED=$(LIBFIB_SHARED) -I$(GHC_INCLUDE) -Idist/static -O2 -Wall -c -fPIC -o dist/static/libfib.o -std=c99 src/libfib/libfib.c

dist/static/$(LIBFIB_SHARED): dist/static/Fib.o dist/static/libfib.o
	ghc -O2 -outputdir=dist/static -o dist/static/$(LIBFIB_SHARED) -shared -static dist/static/Fib.o dist/static/libfib.o \
	  $(GHC_PREFIX)/lib/ghc-$(GHC_VERSION)/base-*/libHSbase-*.a \
	  $(GHC_PREFIX)/lib/ghc-$(GHC_VERSION)/ghc-prim-*/libHSghc-prim-*.a \
	  $(GHC_PREFIX)/lib/ghc-$(GHC_VERSION)/integer-gmp-*/libHSinteger-gmp-*.a \
	  $(GHC_PREFIX)/lib/ghc-$(GHC_VERSION)/rts-*/libCffi_thr.a \
	  $(GHC_PREFIX)/lib/ghc-$(GHC_VERSION)/rts-*/libHSrts_thr.a

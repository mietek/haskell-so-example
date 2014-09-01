system := $(shell uname -s)

so_name := libfib.so
ifeq ($(system),Darwin)
so_name := libfib.dylib
endif


ghc_version := $(shell ghc --numeric-version)
ghc_prefix  := $(shell dirname $(shell dirname $(shell which ghc)))
ghc_include := $(ghc_prefix)/lib/ghc-$(ghc_version)/include

ghc_flags            := -O2 -Wall
dynamic_ghc_flags    := $(ghc_flags) -dynamic -outputdir=dist/dynamic
static_ghc_flags     := $(ghc_flags) -static -outputdir=dist/static
dynamic_so_ghc_flags := $(dynamic_ghc_flags) -shared
static_so_ghc_flags  := $(static_ghc_flags) -shared
ifeq ($(system),Darwin)
static_so_ghc_flags  += -optl-Wl,-no_compact_unwind
endif

ghc_rts_pkg_version         := $(shell ghc-pkg field --simple-output rts version)
dynamic_so_ghc_rts_pkg_libs := -lHSrts_thr-ghc$(ghc_version)
static_so_ghc_rts_pkg_libs  := rts-$(ghc_rts_pkg_version)/libHSrts_thr.a \
                               rts-$(ghc_rts_pkg_version)/libCffi_thr.a

dynamic_so_ghc_libs := $(dynamic_so_ghc_rts_pkg_libs)


cc_flags := -O2
ifeq ($(system),Darwin)
cc_flags += -Weverything
else
cc_flags += -Wall -fPIC
endif

test_cc_flags      := $(cc_flags) -Isrc/libfib
o_cc_flags         := $(cc_flags) -I$(ghc_include) -DSO_NAME=$(so_name)
dynamic_o_cc_flags := $(o_cc_flags) -DSO_FLAVOUR=dynamic -Idist/dynamic
static_o_cc_flags  := $(o_cc_flags) -DSO_FLAVOUR=static -Idist/static

ifneq ($(system),Darwin)
test_cc_libs := -ldl -lpthread
endif


all: test


.PHONY: build clean test

build: dist/test dynamic-build static-build

clean:
	rm -rf dist

test: dist/test dynamic-test static-test

dist:
	mkdir dist

dist/test: src/test.c src/libfib/libfib.h | dist
	cc $(test_cc_flags) -o $@ $< $(test_cc_libs)


.PHONY: dynamic-build dynamic-clean dynamic-test

dynamic-build: dist/dynamic/$(so_name)

dynamic-clean:
	rm -rf dist/dynamic

dynamic-test: dist/test dynamic-build
	dist/test dist/dynamic/$(so_name)

dist/dynamic: | dist
	mkdir dist/dynamic

dist/dynamic/Fib.o dist/dynamic/Fib_stub.h: src/libfib/Fib.hs | dist/dynamic
	ghc -c $(dynamic_ghc_flags) $^

dist/dynamic/libfib.o: src/libfib/libfib.c src/libfib/libfib.h dist/dynamic/Fib_stub.h
	cc -c $(dynamic_o_cc_flags) -o $@ $<

dist/dynamic/$(so_name): dist/dynamic/libfib.o dist/dynamic/Fib.o
	ghc $(dynamic_so_ghc_flags) -o $@ $^ $(dynamic_so_ghc_libs)


dist/ghc_pkgs: dist/dynamic/libfib.o dist/dynamic/Fib.o
	$(eval ghc_pkgs := \
	  $(patsubst -lHS%-ghc$(ghc_version),%,\
	    $(filter -lHS%-ghc$(ghc_version),\
	      $(shell ghc $(dynamic_so_ghc_flags) -pgml echo $^ 2>&1))))
	echo $(ghc_pkgs) >dist/ghc_pkgs


.PHONY: static-build static-clean static-test

static-build: dist/static/$(so_name)

static-clean:
	rm -rf dist/static

static-test: dist/test static-build
	dist/test dist/static/$(so_name)

dist/static: | dist
	mkdir dist/static

dist/static/Fib.o dist/static/Fib_stub.h: src/libfib/Fib.hs | dist/static
	ghc -c $(static_ghc_flags) $^

dist/static/libfib.o: src/libfib/libfib.c src/libfib/libfib.h dist/static/Fib_stub.h
	cc -c $(static_o_cc_flags) -o $@ $<

dist/static/$(so_name): dist/static/libfib.o dist/static/Fib.o dist/ghc_pkgs
	$(eval libs := \
	  $(patsubst %,$(ghc_prefix)/lib/ghc-$(ghc_version)/%,\
	    $(static_so_ghc_rts_pkg_libs) \
	      $(join $(patsubst %,%/libHS,$(ghc_pkgs)),\
	        $(patsubst %,%.a,$(ghc_pkgs)))))
	ghc $(static_so_ghc_flags) -o $@ $(filter-out dist/ghc_pkgs,$^) $(libs)

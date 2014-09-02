haskell-shared-example
======================

How to call Haskell shared libraries from C.  Runtime loading.  Dynamic and shared flavours.


Usage
-----

Tested on OS X with GHC 7.8.3.  On Linux, the dynamic flavour works out of the box, but the static flavour requires rebuilding GHC packages as position-independent code.

    $ make dist/test
    mkdir dist
    cc -O2 -Weverything -Isrc/libfib -o dist/test src/test.c


### Dynamic flavour

*Entrée:*  A shared library with a pure Haskell centre, linked with dynamic Haskell libraries.

    $ make dynamic-build
    mkdir dist/dynamic
    ghc -c -O2 -Wall -dynamic -outputdir=dist/dynamic src/libfib/Fib.hs
    cc -c -O2 -Weverything -I/opt/lib/ghc-7.8.3/include
            -DSO_NAME=libfib.dylib -DSO_FLAVOUR=dynamic -Idist/dynamic
            -o dist/dynamic/libfib.o src/libfib/libfib.c
    ghc -O2 -Wall -dynamic -outputdir=dist/dynamic -shared
            -o dist/dynamic/libfib.dylib dist/dynamic/libfib.o dist/dynamic/Fib.o
            -lHSrts_thr-ghc7.8.3

    $ make dynamic-test
    dist/test dist/dynamic/libfib.dylib
    Testing dynamic flavour
      Simple test:    PASS
      Threaded test:  PASS


### Static flavour

*Plat principal:*  A shared library with a pure Haskell centre, linked with static Haskell libraries.

    $ make static-build
    mkdir dist/static
    ghc -c -O2 -Wall -static -outputdir=dist/static src/libfib/Fib.hs
    cc -c -O2 -Weverything -I/opt/lib/ghc-7.8.3/include
            -DSO_NAME=libfib.dylib -DSO_FLAVOUR=static -Idist/static
            -o dist/static/libfib.o src/libfib/libfib.c
    echo base-4.7.0.1 integer-gmp-0.5.1.0 ghc-prim-0.3.1.0 >dist/ghc_pkgs
    ghc -O2 -Wall -static -outputdir=dist/static -shared
            -optl-Wl,-no_compact_unwind
            -o dist/static/libfib.dylib dist/static/libfib.o dist/static/Fib.o
            /opt/lib/ghc-7.8.3/rts-1.0/libHSrts_thr.a
            /opt/lib/ghc-7.8.3/rts-1.0/libCffi_thr.a
            /opt/lib/ghc-7.8.3/base-4.7.0.1/libHSbase-4.7.0.1.a
            /opt/lib/ghc-7.8.3/integer-gmp-0.5.1.0/libHSinteger-gmp-0.5.1.0.a
            /opt/lib/ghc-7.8.3/ghc-prim-0.3.1.0/libHSghc-prim-0.3.1.0.a

    $ make static-test
    dist/test dist/static/libfib.dylib
    Testing static flavour
      Simple test:    PASS
      Threaded test:  PASS


References
----------

* Albert Y. C. Lai, *[Calling Haskell Shared Libraries from C](http://www.vex.net/~trebla/haskell/so.xhtml)*


License
-------

[MIT](https://github.com/mietek/embed-hs/blob/master/LICENSE.md) © [Miëtek Bak](http://mietek.io/)

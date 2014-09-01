haskell-shared-example
======================

How to call Haskell shared libraries from C.

Thanks to [Albert Lai](http://www.vex.net/~trebla/haskell/so.xhtml).


Usage
-----

Tested on OS X with GHC 7.8.3.  The dynamic flavour also works on Linux, but the static flavour requires rebuilding all packages statically, with `-fPIC`.


### Dynamic

    $ make dynamic-test
    cc -Isrc/libfib -O2 -Wall -o dist/main src/main.c -std=c99 -ldl -lpthread
    ghc -O2 -c -dynamic -outputdir=dist/dynamic src/libfib/Fib.hs
    cc -DLIBFIB_FLAVOUR=dynamic -DLIBFIB_SHARED=libfib.dylib -I/opt/lib/ghc-7.8.3/include -Idist/dynamic -O2 -Wall -c -fPIC -o dist/dynamic/libfib.o -std=c99 src/libfib/libfib.c
    ghc -O2 -dynamic -outputdir=dist/dynamic -o dist/dynamic/libfib.dylib -shared dist/dynamic/Fib.o dist/dynamic/libfib.o -lHSrts_thr-ghc7.8.3
    dist/main dist/dynamic/libfib.dylib
    Testing libfib-dynamic
      Simple test:    PASS
      Threaded test:  PASS


### Static

    $ make static-test
    cc -Isrc/libfib -O2 -Wall -o dist/main src/main.c -std=c99 -ldl -lpthread
    ghc -O2 -c -outputdir=dist/static -static src/libfib/Fib.hs
    cc -DLIBFIB_FLAVOUR=static -DLIBFIB_SHARED=libfib.dylib -I/opt/lib/ghc-7.8.3/include -Idist/static -O2 -Wall -c -fPIC -o dist/static/libfib.o -std=c99 src/libfib/libfib.c
    ghc -O2 -outputdir=dist/static -o dist/static/libfib.dylib -shared -static dist/static/Fib.o dist/static/libfib.o \
      /opt/lib/ghc-7.8.3/base-*/libHSbase-*.a \
      /opt/lib/ghc-7.8.3/ghc-prim-*/libHSghc-prim-*.a \
      /opt/lib/ghc-7.8.3/integer-gmp-*/libHSinteger-gmp-*.a \
      /opt/lib/ghc-7.8.3/rts-*/libCffi_thr.a \
      /opt/lib/ghc-7.8.3/rts-*/libHSrts_thr.a
    ld: warning: could not create compact unwind for _ffi_call_unix64: does not use RBP or RSP based frame
    dist/main dist/static/libfib.dylib
    Testing libfib-static
      Simple test:    PASS
      Threaded test:  PASS


License
-------

[MIT](https://github.com/mietek/embed-hs/blob/master/LICENSE.md) © [Miëtek Bak](http://mietek.io/)

haskell-shared-example
======================

How to call Haskell shared libraries from C.

Thanks to [Albert Lai](http://www.vex.net/~trebla/haskell/so.xhtml).


Usage
-----

Tested on OS X 10.9.4 with GHC 7.8.3:

    $ make
    cc -Isrc/libfib -O2 -Wall -o dist/main src/main.c -std=c99 -ldl -lpthread
    ghc -O2 -c -dynamic -outputdir=dist src/libfib/Fib.hs
    cc -DLIBFIB_SHARED=libfib.dylib -I/opt/lib/ghc-7.8.3/include -Idist -O2 -Wall -c -fPIC -o dist/libfib.o -std=c99 src/libfib/libfib.c
    ghc -O2 -dynamic -outputdir=dist -o dist/libfib.dylib -shared dist/Fib.o dist/libfib.o -lHSrts_thr-ghc7.8.3
    dist/main dist/libfib.dylib
      Simple test:    PASS
      Threaded test:  PASS

Also tested on Ubuntu 14.04 LTS and with GHC 7.6.3.


License
-------

[MIT](https://github.com/mietek/embed-hs/blob/master/LICENSE.md) © [Miëtek Bak](http://mietek.io/)

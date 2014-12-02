_haskell-so-example_
====================

Example C program, showing to to call Haskell shared libraries.  Also demonstrates how to build a dynamically- and statically-linked Haskell shared library.


Usage
-----

```
$ make test
...
PASS
```


### Dynamic

*Entrée:*  A shared library with a pure Haskell centre, linked with dynamic Haskell libraries.

```
$ make dynamic-build
...
$ make dynamic-test
...
Testing dynamic flavour
  Simple test:    PASS
  Threaded test:  PASS
```


### Static

*Plat principal:*  A shared library with a pure Haskell centre, linked with static Haskell libraries.

```
$ make static-build
...
$ make static-test
...
Testing static flavour
  Simple test:    PASS
  Threaded test:  PASS
```

**Note:**  On Linux, the static flavour requires rebuilding GHC packages as position-independent code.


About
-----

Made by [Miëtek Bak](https://mietek.io/).  Published under the [MIT X11 license](https://mietek.io/license/).


### Acknowledgements

Thanks to [Albert Lai](http://www.vex.net/~trebla/) for an illuminating series of articles, including [“Calling Haskell Shared Libraries from C”](http://www.vex.net/~trebla/haskell/so.xhtml).

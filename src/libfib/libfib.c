#include <HsFFI.h>
#include <stdio.h>

#include "Fib_stub.h"
#include "libfib.h"

#define xstr(s) str(s)
#define str(s) #s

static void lf_init(void) __attribute__((constructor));
static void lf_exit(void) __attribute__((destructor));

static void lf_init(void) {
	static char *args[] = { xstr(SO_NAME), 0 };
	static char **args_ = args;
	static int num_args = 1;

	printf("Testing %s flavour\n", xstr(SO_FLAVOUR));
	hs_init(&num_args, &args_);
}

static void lf_exit(void) {
	hs_exit();
}

int lf_fib(int n) {
	return fib(n);
}

void lf_thread_done(void) {
	hs_thread_done();
}

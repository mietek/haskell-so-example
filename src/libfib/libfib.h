#ifndef __LIBFIB__
#define __LIBFIB__

int lf_fib(int n);
void lf_thread_done(void);

typedef int(*lf_fib_ptr_t)(int);
typedef void(*lf_thread_done_ptr_t)();

#endif

#define _POSIX_C_SOURCE 199309L

#include <dlfcn.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "libfib.h"


#define FNORD        42
#define FIB_42       267914296
#define SUM_FIB_0_41 433494436


static lf_fib_ptr_t g_lf_fib;
static lf_thread_done_ptr_t g_lf_thread_done;


static int simple_test(void) {
	int result;

	printf("  Simple test:    ");
	fflush(stdout);
	result = g_lf_fib(FNORD);
	if (result == FIB_42) {
		printf("PASS\n");
		return 0;
	}
	printf("FAIL\n");
	return 1;
}


static int g_results[FNORD];
static int g_count = 0;
static pthread_mutex_t g_count_mx;
static pthread_cond_t g_count_cv;


static void *worker_main(void *arg) {
	int *index = arg;

	nanosleep(&(struct timespec){ 0, rand() }, NULL);
	pthread_mutex_lock(&g_count_mx);
	g_results[*index] = g_lf_fib(*index);
	g_count++;
	if (g_count == FNORD) {
		pthread_cond_signal(&g_count_cv);
	}
	pthread_mutex_unlock(&g_count_mx);
	g_lf_thread_done();
	pthread_exit(NULL);
}


static void *supervisor_main(void *arg __attribute__((__unused__))) {
	pthread_mutex_lock(&g_count_mx);
	while (g_count < FNORD) {
		pthread_cond_wait(&g_count_cv, &g_count_mx);
	}
	pthread_mutex_unlock(&g_count_mx);
	pthread_exit(NULL);
}


static int threaded_test(void) {
	pthread_attr_t attr;
	pthread_t supervisor;
	pthread_t workers[FNORD];
	static int indices[FNORD];
	int result = 0;
	int i;

	printf("  Threaded test:  ");
	fflush(stdout);
	srand((unsigned int)time(NULL));
	pthread_mutex_init(&g_count_mx, NULL);
	pthread_cond_init(&g_count_cv, NULL);
	pthread_attr_init(&attr);
	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
	pthread_create(&supervisor, &attr, supervisor_main, NULL);
	for (i = 0; i < FNORD; i++) {
		indices[i] = i;
		g_results[i] = 0;
		pthread_create(&workers[i], &attr, worker_main, &indices[i]);
	}
	pthread_join(supervisor, NULL);
	for (i = 0; i < FNORD; i++) {
		pthread_join(workers[i], NULL);
	}
	pthread_attr_destroy(&attr);
	pthread_cond_destroy(&g_count_cv);
	pthread_mutex_destroy(&g_count_mx);
	for (i = 0; i < FNORD; i++) {
		result += g_results[i];
	}
	if (result == SUM_FIB_0_41) {
		printf("PASS\n");
		return 0;
	}
	printf("FAIL\n");
	return 1;
}


int main(int num_args, char **args) {
	void *libfib;
	int status;

	if (num_args != 2) {
		fprintf(stderr, "Usage: %s PATH\n", args[0]);
		exit(EXIT_FAILURE);
	}
	if (!(libfib = dlopen(args[1], RTLD_LAZY))
	||  !(g_lf_fib = (lf_fib_ptr_t)dlsym(libfib, "lf_fib"))
	||  !(g_lf_thread_done = (lf_thread_done_ptr_t)dlsym(libfib, "lf_thread_done"))) {
		fprintf(stderr, "Error loading shared library: %s\n", dlerror());
		exit(EXIT_FAILURE);
	}
	status = simple_test() || threaded_test();
	dlclose(libfib);
	return status;
}

#ifndef CLASSIFY_H
#define CLASSIFY_H
#ifdef __cplusplus
extern "C" {
#endif
const char *classify(int n);
const char *size(int n);
int total(int a, int b, int c);
int never_called(int n);
int excluded(int n);
int both(int a, int b, int c);
int big_run(void);
#ifdef __cplusplus
}
#endif
#endif

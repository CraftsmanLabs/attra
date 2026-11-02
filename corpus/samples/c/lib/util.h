#ifndef UTIL_H
#define UTIL_H
#ifdef __cplusplus
extern "C" {
#endif
/* Defined in a header, so it is compiled into every unit that calls it. */
static inline int add(int a, int b) { return a + b; }
int util_unused(int n);
#ifdef __cplusplus
}
#endif
#endif

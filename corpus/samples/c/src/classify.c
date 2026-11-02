#include "classify.h"
#include "util.h"

#define TWICE(x) ((x) + (x))

/* Branches: the tests only take the "negative even" and "positive" arms. */
const char *classify(int n) {
    if (n < 0 && n % 2 == 0) {
        return "negative even";
    } else if (n < 0) {
        return "negative odd";
    } else if (n == 0) {
        return "zero";
    }
    return "positive";
}

/* Partial line: only the "small" side of the ternary runs. */
const char *size(int n) { return n > 100 ? "big" : "small"; }

/* One statement spread over several lines, with a macro expansion. */
int total(int a,
          int b,
          int c) {
    return add(a,
               add(b, TWICE(c)));
}

/* Never called. */
int never_called(int n) {
    return n * 2;
}

/* Excluded by the user. The tests never call it. */
/* LCOV_EXCL_START */
int excluded(int n) {
    return n * 3;
}
/* LCOV_EXCL_STOP */

/* Three conditions for MC/DC: the tests leave c's independence unshown. */
int both(int a, int b, int c) {
    if ((a && b) || c) {
        return 1;
    }
    return 0;
}

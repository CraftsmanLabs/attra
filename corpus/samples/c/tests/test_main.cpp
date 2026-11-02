#include <cstdio>
#include <cstring>
#include "classify.h"

int max_int(int a, int b);
double max_double(double a, double b);

static int failures = 0;
#define CHECK(cond) do { if (!(cond)) { std::printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #cond); failures++; } } while (0)

int main() {
    CHECK(std::strcmp(classify(-2), "negative even") == 0);
    CHECK(std::strcmp(classify(5), "positive") == 0);
    CHECK(std::strcmp(size(3), "small") == 0);
    CHECK(total(1, 2, 3) == 9);
    CHECK(both(1, 1, 0) == 1);
    CHECK(both(0, 1, 0) == 0);
    CHECK(max_int(1, 2) == 2);
    CHECK(max_double(2.0, 1.0) == 2.0);
    CHECK(big_run() > 0);
    return failures != 0;
}

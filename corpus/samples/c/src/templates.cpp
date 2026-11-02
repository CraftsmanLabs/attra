// Instantiated twice (int and double), once never (long).
template <typename T>
T max_of(T a, T b) {
    if (a > b) {
        return a;
    }
    return b;
}

int max_int(int a, int b) { return max_of(a, b); }
double max_double(double a, double b) { return max_of(a, b); }

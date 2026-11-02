package attra.util;

/** A second source root. */
public final class Util {
    private Util() {}

    public static int add(int a, int b) {
        return a + b;
    }

    public static int unused(int n) {
        return add(n, 1);
    }
}

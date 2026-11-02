package attra.sample;

import attra.util.Util;

public final class Classify {
    private Classify() {}

    /** Branches: the tests only take the "negative even" and "positive" arms. */
    public static String classify(int n) {
        if (n < 0 && n % 2 == 0) {
            return "negative even";
        } else if (n < 0) {
            return "negative odd";
        } else if (n == 0) {
            return "zero";
        }
        return "positive";
    }

    /** Partial line: only the "small" side of the ternary runs. */
    public static String size(int n) { return n > 100 ? "big" : "small"; }

    /** One statement spread over several lines. */
    public static int total(int a,
                            int b,
                            int c) {
        return Util.add(a,
                        Util.add(b, c));
    }

    /** Never called. */
    public static int neverCalled(int n) {
        return n * 2;
    }

    /** A switch with a case the tests never reach, and a lambda. */
    public static int kind(String s) {
        switch (s) {
            case "a": return 1;
            case "b": return 2;
            default: return 0;
        }
    }

    public static java.util.function.IntSupplier anon() {
        return () -> 1;
    }

    /** A record: the compiler generates its accessors, equals, hashCode and toString. */
    public record Point(int x, int y) {}
}

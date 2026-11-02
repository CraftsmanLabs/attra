import Util

/// Branches: the tests only take the "negative even" and "positive" arms.
public func classify(_ n: Int) -> String {
    if n < 0 && n % 2 == 0 {
        return "negative even"
    } else if n < 0 {
        return "negative odd"
    } else if n == 0 {
        return "zero"
    }
    return "positive"
}

/// Partial line: only the "small" side of the ternary runs.
public func size(_ n: Int) -> String { n > 100 ? "big" : "small" }

/// One statement spread over several lines.
public func total(_ a: Int,
                  _ b: Int,
                  _ c: Int) -> Int {
    add(a,
        add(b, c))
}

/// Never called.
public func neverCalled(_ n: Int) -> Int {
    n * 2
}

/// Generic: instantiated for Int and Double.
public func maxOf<T: Comparable>(_ a: T, _ b: T) -> T {
    if a > b { return a }
    return b
}

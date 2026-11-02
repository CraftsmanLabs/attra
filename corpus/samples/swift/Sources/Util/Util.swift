/// A second target: a second source root.
public func add(_ a: Int, _ b: Int) -> Int {
    a + b
}

public func unused(_ n: Int) -> Int {
    add(n, 1)
}

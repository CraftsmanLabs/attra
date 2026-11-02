//! A second crate: a second source root.

pub fn add(a: i64, b: i64) -> i64 {
    a + b
}

pub fn unused(n: i64) -> i64 {
    add(n, 1)
}

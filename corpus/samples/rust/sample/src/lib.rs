mod big;
pub use big::big_run;

macro_rules! twice {
    ($x:expr) => {
        $x + $x
    };
}

/// Branches: the tests only take the "negative even" and "positive" arms.
pub fn classify(n: i64) -> &'static str {
    if n < 0 && n % 2 == 0 {
        "negative even"
    } else if n < 0 {
        "negative odd"
    } else if n == 0 {
        "zero"
    } else {
        "positive"
    }
}

/// Partial line: only the "small" side runs.
pub fn size(n: i64) -> &'static str { if n > 100 { "big" } else { "small" } }

/// One statement spread over several lines, with a macro expansion.
pub fn total(a: i64,
             b: i64,
             c: i64) -> i64 {
    util::add(a,
              util::add(b, twice!(c)))
}

/// Never called.
pub fn never_called(n: i64) -> i64 {
    n * 2
}

/// Excluded by the user for tarpaulin. The tests never call it.
#[cfg(not(tarpaulin_include))]
pub fn excluded(n: i64) -> i64 {
    n * 3
}

/// Generic: instantiated for i64 and f64, never for u8.
pub fn max_of<T: PartialOrd>(a: T, b: T) -> T {
    if a > b { a } else { b }
}

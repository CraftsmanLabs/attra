use sample::*;

#[test]
fn sample() {
    assert_eq!(classify(-2), "negative even");
    assert_eq!(classify(5), "positive");
    assert_eq!(size(3), "small");
    assert_eq!(total(1, 2, 3), 9);
    assert_eq!(max_of(1i64, 2), 2);
    assert_eq!(max_of(2.0f64, 1.0), 2.0);
    assert!(big_run() > 0);
}

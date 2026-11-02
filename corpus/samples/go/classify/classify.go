package classify

import "example.com/attra/sample/util"

// Classify has branches: the tests only take the "negative even" and "positive" arms.
func Classify(n int) string {
	if n < 0 && n%2 == 0 {
		return "negative even"
	} else if n < 0 {
		return "negative odd"
	} else if n == 0 {
		return "zero"
	}
	return "positive"
}

// Size is a partial line: only the "small" side runs.
func Size(n int) string { if n > 100 { return "big" }; return "small" }

// Total spreads one statement over several lines.
func Total(a,
	b,
	c int) int {
	return util.Add(a,
		util.Add(b, c))
}

// NeverCalled is never called.
func NeverCalled(n int) int {
	return n * 2
}

// Anon returns a closure that the tests call once.
func Anon() func() int {
	return func() int { return 1 }
}

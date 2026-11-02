// Package util is a second package; util has no tests of its own.
package util

// Add is called from classify.
func Add(a, b int) int { return a + b }

// Unused is never called.
func Unused(n int) int {
	return Add(n, 1)
}

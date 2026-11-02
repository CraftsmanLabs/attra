// Package internal is never imported by a test, so it is absent unless -coverpkg names it.
package internal

func Lonely() int { return 42 }

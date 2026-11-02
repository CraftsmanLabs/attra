package classify

import "testing"

func TestClassify(t *testing.T) {
	if Classify(-2) != "negative even" || Classify(5) != "positive" {
		t.Fatal("classify")
	}
	if Size(3) != "small" {
		t.Fatal("size")
	}
	if Total(1, 2, 3) != 6 {
		t.Fatal("total")
	}
	if Anon()() != 1 {
		t.Fatal("anon")
	}
	for i := 0; i < 3; i++ {
		if BigRun() <= 0 {
			t.Fatal("big")
		}
	}
}

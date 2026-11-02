import sys

from sample.classify import classify, loop, size, total
from sample.big import big_run

part = sys.argv[1] if len(sys.argv) > 1 else "all"
if part in ("a", "all"):
    assert classify(-2) == "negative even"
    assert size(3) == "small"
if part in ("b", "all"):
    assert classify(5) == "positive"
    assert total(1, 2, 3) == 6
    assert loop([0, 1]) == [0, 1]
    assert big_run() > 0

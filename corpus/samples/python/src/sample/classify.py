from helpers.util import add


def classify(n):
    """Branches: the tests only take the "negative even" and "positive" arms."""
    if n < 0 and n % 2 == 0:
        return "negative even"
    elif n < 0:
        return "negative odd"
    elif n == 0:
        return "zero"
    return "positive"


def size(n): return "big" if n > 100 else "small"  # partial line


def total(a,
          b,
          c):
    return add(a,
               add(b, c))


def never_called(n):
    return n * 2


def excluded(n):  # pragma: no cover
    return n * 3


def loop(xs):
    for x in xs:
        if x:
            break
    return xs

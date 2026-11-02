<?php
namespace Attra\Sample;

use Attra\Util\Util;

final class Classify
{
    /** Branches: the tests only take the "negative even" and "positive" arms. */
    public static function classify(int $n): string
    {
        if ($n < 0 && $n % 2 === 0) {
            return "negative even";
        } elseif ($n < 0) {
            return "negative odd";
        } elseif ($n === 0) {
            return "zero";
        }
        return "positive";
    }

    /** Partial line: only the "small" side of the ternary runs. */
    public static function size(int $n): string { return $n > 100 ? "big" : "small"; }

    /** One statement spread over several lines. */
    public static function total(int $a,
                                 int $b,
                                 int $c): int
    {
        return Util::add($a,
                         Util::add($b, $c));
    }

    /** Never called. */
    public static function neverCalled(int $n): int
    {
        return $n * 2;
    }

    /** Excluded by the user. The tests never call it. */
    /** @codeCoverageIgnore */
    public static function excluded(int $n): int
    {
        return $n * 3;
    }

    public static function anon(): \Closure
    {
        return fn () => 1;
    }
}

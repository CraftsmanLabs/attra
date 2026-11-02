<?php
namespace Attra\Util;

/** A second source root. */
final class Util
{
    public static function add(int $a, int $b): int
    {
        return $a + $b;
    }

    public static function unused(int $n): int
    {
        return self::add($n, 1);
    }
}

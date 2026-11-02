<?php
use Attra\Sample\Big;
use Attra\Sample\Classify;
use PHPUnit\Framework\TestCase;

final class ClassifyTest extends TestCase
{
    public function testNegative(): void
    {
        $this->assertSame("negative even", Classify::classify(-2));
        $this->assertSame("small", Classify::size(3));
    }

    public function testRest(): void
    {
        $this->assertSame("positive", Classify::classify(5));
        $this->assertSame(6, Classify::total(1, 2, 3));
        $this->assertSame(1, (Classify::anon())());
        $this->assertGreaterThan(0, Big::run());
    }
}

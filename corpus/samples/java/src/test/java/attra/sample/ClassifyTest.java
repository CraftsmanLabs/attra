package attra.sample;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class ClassifyTest {
    @Test
    void sample() {
        assertEquals("negative even", Classify.classify(-2));
        assertEquals("positive", Classify.classify(5));
        assertEquals("small", Classify.size(3));
        assertEquals(6, Classify.total(1, 2, 3));
        assertEquals(1, Classify.kind("a"));
        assertEquals(1, Classify.anon().getAsInt());
        assertEquals(1, new Classify.Point(1, 2).x());
        assertTrue(Big.run() > 0);
    }
}

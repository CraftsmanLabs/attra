namespace Attra.Util;

// A second source root, in its own assembly.
public static class Helpers
{
    public static int Add(int a, int b)
    {
        return a + b;
    }

    public static int Unused(int n)
    {
        return Add(n, 1);
    }
}

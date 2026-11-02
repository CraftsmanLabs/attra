using System.Diagnostics.CodeAnalysis;
using Attra.Util;

namespace Attra.Sample;

public static class Classify
{
    // Branches: the tests only take the "negative even" and "positive" arms.
    public static string Kind(int n)
    {
        if (n < 0 && n % 2 == 0)
        {
            return "negative even";
        }
        else if (n < 0)
        {
            return "negative odd";
        }
        else if (n == 0)
        {
            return "zero";
        }
        return "positive";
    }

    // Partial line: only the "small" side of the ternary runs.
    public static string Size(int n) => n > 100 ? "big" : "small";

    // One statement spread over several lines.
    public static int Total(int a,
                            int b,
                            int c)
    {
        return Helpers.Add(a,
                           Helpers.Add(b, c));
    }

    // Never called.
    public static int NeverCalled(int n)
    {
        return n * 2;
    }

    // Excluded by the user. The tests never call it.
    [ExcludeFromCodeCoverage]
    public static int Excluded(int n)
    {
        return n * 3;
    }

    // An async method: the compiler generates a state machine.
    public static async System.Threading.Tasks.Task<int> LaterAsync(int n)
    {
        await System.Threading.Tasks.Task.Yield();
        return n + 1;
    }
}

using Attra.Sample;
using Xunit;

public class ClassifyTests
{
    [Fact]
    public async System.Threading.Tasks.Task Sample()
    {
        Assert.Equal("negative even", Classify.Kind(-2));
        Assert.Equal("positive", Classify.Kind(5));
        Assert.Equal("small", Classify.Size(3));
        Assert.Equal(6, Classify.Total(1, 2, 3));
        Assert.Equal(2, await Classify.LaterAsync(1));
        Assert.True(Big.Run() > 0);
    }
}

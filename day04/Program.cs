using System.IO;
using System.Linq;

namespace day04;

class Program
{
    private static readonly (int dx, int dy)[] Directions =
    {
        (-1, -1),
        (0, -1),
        (1, -1),
        (1, 0),
        (1, 1),
        (0, 1),
        (-1, 1),
        (-1, 0)
    };

    private static int width;
    private static int height;
    private static char[][] lines = null!;

    private static bool InBounds(int x, int y)
        => x >= 0 && x < width && y >= 0 && y < height;

    private static long CountRolls(int x, int y)
    {
        long count = 0;

        foreach (var (dx, dy) in Directions)
        {
            var nx = x + dx;
            var ny = y + dy;

            if (InBounds(nx, ny) && lines[ny][nx] == '@')
                count++;
        }

        return count;
    }

    private static (int count, bool changed) Scan(bool mutate)
    {
        var changed = false;
        int result = Enumerable.Range(0, height)
            .SelectMany(y =>
                Enumerable
                    .Range(0, width)
                    .Select(x => (x, y))
                    .Where(p => lines[p.y][p.x] == '@' && CountRolls(p.x, p.y) < 4)
                    .Select(p =>
                    {
                        if (mutate)
                        {
                            lines[p.y][p.x] = 'x';
                            changed = true;
                        }

                        return p;
                    })
                    ).Count();

        return (result, changed);
    }


    private static int PartOne()
    {
        return Scan(mutate: false).count;
    }

    private static int PartTwo()
    {
        var total = 0;
        bool changed;

        do
        {
            var step = Scan(mutate: true);
            total += step.count;
            changed = step.changed;
        } while (changed);

        return total;
    }

    private static void Main(string[] args)
    {
        lines = File
            .ReadAllLines("input.txt")
            .Select(s => s.ToCharArray())
            .ToArray();

        height = lines.Length;
        width = lines[0].Length;

        Console.WriteLine("partOne: {0}", PartOne());
        Console.WriteLine("partTwo: {0}", PartTwo());
    }
}
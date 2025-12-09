// At this point, I'm basically a god
import java.io.IOException;
import java.lang.Character;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.function.BinaryOperator;

public class Main {

    private static <T> T getOrDefault(List<T> list, int index, T defaultValue) {
        if (index >= 0 && index < list.size()) {
            return list.get(index);
        } else {
            return defaultValue;
        }
    }

    private static List<Integer> getColmunsWidth(List<Character> operations) {
        List<Integer> result = new ArrayList<>();
        var width = 1;
    
        for (char c : operations) {
            if (c == ' ') {
                width++;
            } else if (width != 1) {
                // for the first op
                result.add(width);
                width = 1;
            }
        }

        result.add(width + 1);
        return result;
    }

    private static List<List<Character>> splitLine(
        List<Character> line,
        List<Integer> widths
    ) {
        List<List<Character>> result = new ArrayList<>();

        var totalOffset = 0;
        for (var w : widths) {
            result.add(line.subList(totalOffset, totalOffset + w - 1));
            totalOffset += w;
        }
        return result;
    }

    private static List<List<List<Character>>> transpose(
        List<List<List<Character>>> lists
    ) {
        List<List<List<Character>>> transposed = new ArrayList<>();
        for (int i = 0; i < lists.getFirst().size(); i++) {
            int finalI = i;
            transposed.add(
                lists
                    .stream()
                    .map(row -> row.get(finalI))
                    .toList()
            );
        }
        return transposed;
    }

    private static List<List<Character>> transposeString(
        List<List<Character>> list
    ) {
        List<List<Character>> transposed = new ArrayList<>();

        int maxLength = list.stream().mapToInt(List::size).max().orElse(0);

        for (int j = 0; j < maxLength; j++) {
            List<Character> column = new ArrayList<>();

            for (int i = 0; i < list.size(); i++) {
                column.add(getOrDefault(list.get(i), j, '0'));
            }

            transposed.add(column);
        }

        return transposed;
    }

    private static long solve(
        List<List<Character>> numbers,
        Character operation
    ) {
        long identity;
        BinaryOperator<Long> reducer;

        switch (operation) {
            case '+' -> {
                identity = 0L;
                reducer = Long::sum;
            }
            case '*' -> {
                identity = 1L;
                reducer = (a, b) -> a * b;
            }
            default -> throw new IllegalArgumentException(
                "Unknown operation: " + operation
            );
        }

        return numbers
            .stream()
            .map(list ->
                list
                    .stream()
                    .map(String::valueOf)
                    .collect(java.util.stream.Collectors.joining())
            )
            .map(String::trim)
            .map(Long::parseLong)
            .reduce(identity, reducer);
    }

    public static void main(String[] args) {
        String filePath = "input.txt";

        List<List<List<Character>>> numbers = new ArrayList<>();
        List<Character> operations;

        try {
            var lines = Files.readAllLines(Paths.get(filePath));
            operations = lines
                .removeLast()
                .chars()
                .mapToObj(c -> (char) c)
                .toList();

            var colmunsWidth = getColmunsWidth(operations);

            for (String line : lines) {
                if (line.isBlank()) continue;
                numbers.add(
                    splitLine(
                        line
                            .chars()
                            .mapToObj(c -> (char) c)
                            .toList(),
                        colmunsWidth
                    )
                );
            }

            numbers = transpose(numbers);
        } catch (IOException e) {
            System.err.println("Error reading file: " + e.getMessage());
            return;
        }
        operations = operations
            .stream()
            .filter(c -> c != ' ')
            .toList();

        long totalOne = 0L;
        long totalTwo = 0L;

        for (int i = 0; i < operations.size(); i++) {
            totalOne += solve(numbers.get(i), operations.get(i));
        }

        for (int i = 0; i < operations.size(); i++) {
            totalTwo += solve(
                transposeString(numbers.get(i)),
                operations.get(i)
            );
        }

        System.out.println("partOne: " + totalOne);
        System.out.println("partTwo: " + totalTwo);
    }
}

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.function.BinaryOperator;

public class Main {

    private static final String PATTERN = "\\s+";

    private static List<Long> splitLine(String line) {
        return Arrays.stream(line.trim().split(PATTERN))
                .filter(s -> !s.isEmpty())
                .map(Long::parseLong)
                .toList();
    }

    private static List<List<Long>> transpose(List<List<Long>> lists) {
        List<List<Long>> transposed = new ArrayList<>();
        for (int i = 0; i < lists.getFirst().size(); i++) {
            int finalI = i;
            transposed.add(lists.stream().map(row -> row.get(finalI)).toList());
        }
        return transposed;
    }

    private static long solve(List<Long> numbers,
                              String operation) {
        long identity;
        BinaryOperator<Long> reducer;

        switch (operation) {
            case "+" -> {
                identity = 0L;
                reducer = Long::sum;
            }
            case "*" -> {
                identity = 1L;
                reducer = (a, b) -> a * b;
            }
            case "-" -> {
                identity = 0L;
                reducer = (a, b) -> a - b;
            }
            case "/" -> {
                identity = 1L;
                reducer = (a, b) -> a / b;
            }
            default -> throw new IllegalArgumentException("Unknown operation: " + operation);
        }

        return numbers.stream()
                .reduce(identity, reducer);
    }

    public static void main(String[] args) {

        String filePath = "input.txt";

        List<List<Long>> numbers = new ArrayList<>();
        List<String> operations;

        try {
            var lines = Files.readAllLines(Paths.get(filePath));
            operations = Arrays.stream(lines.removeLast().trim().split(PATTERN))
                    .toList();

            for (String line : lines) {
                if (line.isBlank()) continue;
                numbers.add(splitLine(line));
            }

            numbers = transpose(numbers);
        } catch (IOException e) {
            System.err.println("Error reading file: " + e.getMessage());
            return;
        }

        long result = 0L;

        for (int i = 0; i < operations.size(); i++) {
            result += solve(numbers.get(i), operations.get(i));
        }

        System.out.println("partOne: " + result);
    }
}

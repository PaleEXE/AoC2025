#include "part2.h"
#include <cstdio>

static char input[1024 * 5];

int main(void) {
    FILE *f = fopen("input.txt", "r");
    if (!f) {
        perror("fopen");
        return 1;
    }

    size_t bytes = fread(input, 1, sizeof(input) - 1, f);
    fclose(f);
    
    input[bytes] = '\0';
    fclose(f);

    char *index = input;
    unsigned long long total_1 = 0;
    unsigned long long total_2 = 0;

    while (*index) {
        Range range = range_get_next(&index);
        total_1 += get_invalid_id(range, &part1_is_invalid);
        total_2 += get_invalid_id(range, &part2_is_invalid);
    }

    printf("part1: %llu\n", total_1);
    printf("part2: %llu\n", total_2);

    return 0;
}

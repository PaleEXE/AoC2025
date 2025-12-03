#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    unsigned long long min, max;
} Range;

Range range_get_next(char **index);

bool part1_is_invalid(const unsigned long long id);

unsigned long long get_invalid_id(Range range, bool(*is_invalid)(unsigned long long));

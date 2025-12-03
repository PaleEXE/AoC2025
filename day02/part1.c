#include "part1.h"

Range range_get_next(char **index) {
    unsigned long long result[2] = {0};

    for (size_t i = 0; i < 2; i++) {
        char num_buf[32] = {0};
        size_t j = 0;

        while (**index != '-' && **index != ',' && **index != '\0') {
            num_buf[j++] = **index;
            (*index)++;
        }

        result[i] = strtoull(num_buf, NULL, 10);

        if (**index == '\0') {
            break;
        }

        (*index)++;
    }

    return (Range){result[0], result[1]};
}

bool part1_is_invalid(const unsigned long long id) {
    char str[64];
    snprintf(str, sizeof(str), "%llu", id);

    size_t id_len = strlen(str);

    if (id_len & 1) {
        return false;
    }

    for (size_t i = 0; i < id_len / 2; i++) {
        if (str[i] != str[id_len / 2 + i]) {
            return false;
        }
    }

    return true;
}

unsigned long long get_invalid_id(Range range, bool (*is_invalid)(unsigned long long)) {
    unsigned long long result = 0;

    for (unsigned long long i = range.min; i <= range.max; i++) {
        if (is_invalid(i)) {
            result += i;
        }
    }

    return result;
}

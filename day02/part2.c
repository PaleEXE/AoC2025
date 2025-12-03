#include "part2.h"

bool part2_is_invalid(const unsigned long long id) {
    char str[64];
    snprintf(str, sizeof(str), "%llu", id);

    size_t id_len = strlen(str);

    for (size_t pattern_len = 1; pattern_len <= id_len / 2; pattern_len++) {
        if (id_len % pattern_len != 0)
            continue;

        bool repeated = true;

        for (size_t i = 1; i < id_len / pattern_len; i++) {
            for (size_t j = 0; j < pattern_len; j++) {
                if (str[j] != str[i * pattern_len + j]) {
                    repeated = false;
                    break;
                }
            }
            if (!repeated)
                break;
        }

        if (repeated)
            return true;
    }

    return false;
}

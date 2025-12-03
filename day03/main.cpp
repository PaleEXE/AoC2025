#include <algorithm>
#include <cmath>
#include <cstddef>
#include <fstream>
#include <iostream>
#include <string>
#include <utility>
#include <vector>


// LOL FUCK C++
std::pair<std::basic_string<char>::const_iterator, char>
get_max_element_with_iterator(std::basic_string<char>::const_iterator begin,
                              std::basic_string<char>::const_iterator end) {
    auto max_it = begin;
    char max_dig = *begin;

    auto ptr = begin + 1;

    while (ptr != end) {
        if (*ptr > max_dig) {
            max_dig = *ptr;
            max_it = ptr;
        }
        ptr++;
    }

    return std::pair<std::basic_string<char>::const_iterator, char>(max_it, max_dig);
}

unsigned long long get_max_num(const std::string &num, size_t dig_num) {
    auto last_ptr = num.begin();
    unsigned long long result = 0;

    for (size_t i = 0; i < dig_num; i++) {
        auto begin_it = last_ptr;

        size_t remaining_to_skip = dig_num - 1 - i;
        auto end_it = num.end() - remaining_to_skip;
        if (begin_it == end_it) {
            if (i == dig_num - 1) {
                result += *begin_it - '0';
                break;
            }
        }
        auto max_pair = get_max_element_with_iterator(begin_it, end_it);
        auto max_it = max_pair.first;
        char max_dig = max_pair.second;

        result += (max_dig - '0') * pow(10, dig_num - i - 1);
        last_ptr = max_it + 1;
    }
    return result;
}

int main() {
    std::ifstream inFile("input.txt");
    if (!inFile.is_open()) {
        std::cerr << "Error opening file 'input.txt'!" << std::endl;
        return 1;
    }

    std::string line;
    std::vector<std::string> lines;

    while (std::getline(inFile, line)) {
        lines.push_back(std::move(line));
    }

    unsigned long long total_1 = 0;
    unsigned long long total_2 = 0;

    for (const auto &num : lines) {
        total_1 += get_max_num(num, 2);
        total_2 += get_max_num(num, 12);
    }

    std::cout << "---" << std::endl;
    std::cout << "part1: " << total_1 << std::endl;
    std::cout << "part2: " << total_2 << std::endl;
    return 0;
}

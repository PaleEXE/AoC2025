from typing import List


def shift_left(cells: List[int]) -> List[int]:
    return cells[1:] + [0]


def shift_right(cells: List[int]) -> List[int]:
    return [0] + cells[:-1]


with open("input.txt", "r") as f:
    grid = f.read().splitlines()


width = len(grid[0])

prev = [0] * width
curr = [0] * width

source = grid[0].index("S")
prev[source] = 1
curr[source] = 1

total_one = 0
total_two = 0

for row in grid:
    splitter = [c != "." for c in row]

    if not any(splitter):
        continue

    hits = [s & b for s, b in zip(splitter, prev)]

    left = shift_left(hits)
    right = shift_right(hits)

    prev = [h ^ b for h, b in zip(hits, prev)]
    prev = [lb | pb | rb for lb, pb, rb in zip(left, prev, right)]
    new_beams = sum(p != c and c == 1 for c, p in zip(curr, prev))
    total_one += new_beams

    curr = prev.copy()


prev = [0] * width
prev[source] = 1

for row in grid[1:]:
    splitter = [int(c != ".") for c in row]

    if not any(splitter):
        continue

    hits = [t if s else 0 for t, s in zip(prev, splitter)]
    left = shift_left(hits)
    right = shift_right(hits)
    stay = [t if not s else 0 for t, s in zip(prev, splitter)]

    prev = [lb + rb + sb for lb, rb, sb in zip(left, right, stay)]

total_two = sum(prev)

print(f"part_one: {total_one}")
print(f"part_one: {total_two}")

# “To defeat evil, I must become a greater evil”
# ― Lelouch Vi Britannia

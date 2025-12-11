local points = {}

for line in io.lines("input.txt") do
    if line ~= "" then
        local x, y = line:match("(%-?%d+),(%-?%d+)")
        table.insert(points, { tonumber(x), tonumber(y) })
    end
end

local max_area = 0

for i, p in ipairs(points) do
    for j = 1, i - 1 do
        local area = (math.abs(p[1] - points[j][1]) + 1) * (math.abs(p[2] - points[j][2]) + 1)
        if area > max_area then
            max_area = area
        end
    end
end

print("part_1: ", max_area)

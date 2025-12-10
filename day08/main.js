// Fuck them Algorithms, I am stealing this shit
const fs = require("fs");

const rawData = fs.readFileSync("input.txt", "utf8").trim();

const points = [];
for (const line of rawData.split("\n")) {
  if (!line.trim()) continue;
  const [x, y, z] = line.split(",").map(Number);
  points.push([x, y, z]);
}

const distances = [];
for (let i = 0; i < points.length; i++) {
  const [x1, y1, z1] = points[i];
  for (let j = 0; j < points.length; j++) {
    if (i <= j) continue;
    const [x2, y2, z2] = points[j];
    const distSq = (x1 - x2) ** 2 + (y1 - y2) ** 2 + (z1 - z2) ** 2;
    distances.push([distSq, i, j]);
  }
}

distances.sort((a, b) => a[0] - b[0]);

// Union-Find
const UF = {};
for (let i = 0; i < points.length; i++) {
  UF[i] = i;
}

function find(x) {
  if (x === UF[x]) return x;
  UF[x] = find(UF[x]);
  return UF[x];
}

function mix(x, y) {
  UF[find(x)] = find(y);
}

let connections = 0;

for (let t = 0; t < distances.length; t++) {
  const [, i, j] = distances[t];

  if (t === 1000) {
    const SZ = {};
    for (let x = 0; x < points.length; x++) {
      const root = find(x);
      SZ[root] = (SZ[root] || 0) + 1;
    }
    const sizes = Object.values(SZ).sort((a, b) => a - b);
    console.log(
      "partOne:",
      sizes[sizes.length - 1] *
        sizes[sizes.length - 2] *
        sizes[sizes.length - 3],
    );
  }

  if (find(i) !== find(j)) {
    connections++;
    mix(i, j);

    if (connections === points.length - 1) {
      console.log("partTwo:", points[i][0] * points[j][0]);
      break;
    }
  }
}

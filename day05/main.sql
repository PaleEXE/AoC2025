DROP TABLE IF EXISTS files;
CREATE TABLE files (name TEXT, content TEXT);

DROP TABLE IF EXISTS vars;
CREATE TABLE vars (key TEXT, val INTEGER);

.separator |

DROP TABLE IF EXISTS tmp;
CREATE TABLE tmp (content TEXT);
.import input.txt tmp

INSERT INTO files (name, content)
SELECT 'input.txt', content FROM tmp;

DROP TABLE tmp;

INSERT INTO vars (key, val)
SELECT 'sep_idx', MIN(rowid)
FROM files
WHERE content = '';

DROP VIEW IF EXISTS ranges_txt;
CREATE VIEW ranges_txt AS
SELECT content
FROM files
WHERE rowid < (SELECT val FROM vars WHERE key = 'sep_idx');

DROP TABLE IF EXISTS ranges;
CREATE TABLE ranges (min INTEGER, max INTEGER);

INSERT INTO ranges (min, max)
SELECT
    CAST(SUBSTR(content, 1, INSTR(content, '-') - 1) AS INTEGER) AS min,
    CAST(SUBSTR(content, INSTR(content, '-') + 1) AS INTEGER) AS max
FROM ranges_txt;

DROP VIEW IF EXISTS ingredient;
CREATE VIEW ingredient AS
SELECT content
FROM files
WHERE rowid > (SELECT val FROM vars WHERE key = 'sep_idx');

CREATE INDEX idx_ranges ON ranges(min, max);

SELECT 'PART ONE: ' ||COUNT(DISTINCT ingredient_id) AS ingredients_in_ranges
FROM (
    SELECT CAST(content AS INTEGER) AS ingredient_id
    FROM ingredient
    WHERE content != ''
) AS ingredients
WHERE EXISTS (
    SELECT 1
    FROM ranges r
    WHERE ingredients.ingredient_id BETWEEN r.min AND r.max
);

-- Claude carry NGL
WITH RECURSIVE
sorted_ranges AS (
    SELECT min, max, ROW_NUMBER() OVER (ORDER BY min, max) AS rn
    FROM ranges
),
merged(min, max, rn) AS (
    SELECT min, max, 1
    FROM sorted_ranges
    WHERE rn = 1
    UNION ALL
    SELECT
        CASE
            WHEN s.min <= m.max + 1 THEN m.min
            ELSE s.min
        END,
        CASE
            WHEN s.min <= m.max + 1 THEN MAX(s.max, m.max)
            ELSE s.max
        END,
        m.rn + 1
    FROM merged m
    JOIN sorted_ranges s ON s.rn = m.rn + 1
),
final_ranges AS (
    SELECT DISTINCT min, max
    FROM merged
    WHERE NOT EXISTS (
        SELECT 1 FROM merged m2
        WHERE m2.min = merged.min
          AND m2.max > merged.max
    )
)
SELECT 'PART TWO: ' ||SUM(max - min + 1) AS total_distinct_numbers
FROM final_ranges;

DROP TABLE IF EXISTS files;

CREATE TABLE files (
    name    TEXT,
    content TEXT
);

DROP TABLE IF EXISTS vars;

CREATE TABLE vars (
    key TEXT,
    val INTEGER
);

.mode text
.separator |


DROP TABLE IF EXISTS tmp;
CREATE TABLE tmp (content TEXT);

.import input.txt tmp

INSERT INTO files (name, content)
SELECT 'input.txt', content
FROM tmp;

DROP TABLE tmp;

INSERT INTO vars (key, val)
SELECT 'sep_idx', idx
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY rowid) AS idx, content
    FROM files
)
WHERE content == '';

DROP VIEW IF EXISTS ranges_txt;

CREATE VIEW ranges_txt AS
SELECT content
FROM (
    SELECT
        ROW_NUMBER() OVER (ORDER BY rowid) AS idx,
        content
    FROM files
)
WHERE idx < (
    SELECT val FROM vars WHERE key == 'sep_idx'
);

DROP TABLE IF EXISTS ranges;

CREATE TABLE ranges (
    min INTEGER,
    max INTEGER
);

INSERT INTO ranges (min, max)
SELECT
    CAST(substr(content, 1, instr(content, '-') - 1) AS INTEGER) AS min,
    CAST(substr(content, instr(content, '-') + 1) AS INTEGER) AS max
FROM ranges_txt
WHERE content LIKE '%-%';

DROP VIEW IF EXISTS ingredient;

CREATE VIEW ingredient AS
SELECT * FROM (
    SELECT
        ROW_NUMBER() OVER (ORDER BY rowid) AS idx,
        content
    FROM files
)
WHERE idx > (
    SELECT val FROM vars WHERE key == 'sep_idx'
);

SELECT COUNT(DISTINCT idx)
FROM (
    SELECT CAST(content AS INTEGER) AS id, idx
    FROM ingredient
) AS i
JOIN ranges r
  ON i.id >= r.min AND i.id <= r.max
ORDER BY idx;

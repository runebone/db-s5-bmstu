WITH q AS (
    SELECT generate_series(1, 8)
)
DROP TABLE IF EXISTS f;
CREATE TEMPORARY TABLE f AS
SELECT * FROM
q as a, q as b, q as c, q as d,
q as e, q as f, q as g, q as h;
--
SELECT * FROM f WHERE
a <> b AND
a <> c AND
a <> d AND
a <> e AND
a <> f AND
a <> g AND
a <> h AND
b <> c and
b <> d AND
b <> e AND
b <> f AND
b <> g AND
b <> h AND
c <> d AND
c <> e AND
c <> f AND
c <> g AND
c <> h AND
d <> e AND
d <> f AND
d <> g AND
d <> h AND
e <> f AND
e <> g AND
e <> h AND
f <> g AND
f <> h AND
g <> h;
--
/* SELECT DISTINCT a, b, c, d, e, f, g, h */
/* FROM f */
/* ORDER BY a, b, c, d, e, f, g, h; */

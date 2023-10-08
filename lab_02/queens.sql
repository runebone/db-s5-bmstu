DROP TABLE IF EXISTS q;
CREATE TEMPORARY TABLE IF NOT EXISTS q (r INTEGER);
--
INSERT INTO q values (1);
INSERT INTO q values (2);
INSERT INTO q values (3);
INSERT INTO q values (4);
INSERT INTO q values (5);
INSERT INTO q values (6);
INSERT INTO q values (7);
INSERT INTO q values (8);
--
DROP TABLE IF EXISTS f;
CREATE TEMPORARY TABLE f AS
SELECT
a.r as a,
b.r as b,
c.r as c,
d.r as d,
e.r as e,
f.r as f,
g.r as g,
h.r as h
FROM
q as a, q as b, q as c, q as d,
q as e, q as f, q as g, q as h;
--
SELECT * FROM f WHERE
a <> b AND a <> c AND a <> d AND
a <> e AND a <> f AND a <> g AND a <> h AND
b <> c and b <> d AND b <> e AND b <> f AND b <> g AND b <> h AND
c <> d AND c <> e AND c <> f AND c <> g AND c <> h AND
d <> e AND d <> f AND d <> g AND d <> h AND
e <> f AND e <> g AND e <> h AND
f <> g AND f <> h AND
g <> h
;

DROP TABLE emps CASCADE;
DROP TABLE in_out CASCADE;

CREATE TABLE IF NOT EXISTS emps (
    id   SERIAL NOT NULL PRIMARY KEY,
    fio  TEXT,
    bd   DATE,
    dept TEXT
);

CREATE TABLE IF NOT EXISTS in_out (
    id     SERIAL NOT NULL PRIMARY KEY,
    emp_id INT  NOT NULL REFERENCES emps(id),
    cdate  DATE NOT NULL,
    cday   TEXT NOT NULL,
    ctime  TIME NOT NULL,
    ctype  INT  NOT NULL CHECK (ctype = 1 OR ctype = 2)
);

INSERT INTO emps(fio, bd, dept) VALUES
('fio1', '1994-12-12', 'd1'),
('fio2', '1995-12-12', 'd1'),
('fio3', '1996-12-12', 'd2'),
('fio4', '1997-12-12', 'd2'),
('fio5', '1998-12-12', 'd3');

INSERT INTO in_out(emp_id, cdate, cday, ctime, ctype) VALUES
(1, '2023-12-12', 'Mon', '09:00:00', 1),
(1, '2023-12-12', 'Mon', '09:05:00', 2),
(1, '2023-12-12', 'Mon', '09:35:00', 1),
(1, '2023-12-12', 'Mon', '19:25:00', 2),
(2, '2023-12-12', 'Mon', '09:00:00', 1),
(2, '2023-12-12', 'Mon', '21:00:00', 2),
(1, '2023-12-13', 'Tue', '09:01:00', 1),
(1, '2023-12-13', 'Tue', '18:00:00', 2),
(2, '2023-12-13', 'Tue', '08:00:00', 1),
(2, '2023-12-13', 'Tue', '23:00:00', 2),
(3, '2023-12-12', 'Mon', '10:00:00', 1),
(3, '2023-12-12', 'Mon', '22:00:00', 2);

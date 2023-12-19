-- Task 1
CREATE OR REPLACE FUNCTION fn_task1()
RETURNS INT AS $$
    SELECT MAX(age) AS max_age
    FROM (
        SELECT *, EXTRACT(YEAR FROM NOW()) - EXTRACT(YEAR FROM bd) AS age, late
        FROM emps
        JOIN (
            SELECT emp_id, ctime - '09:00:00' AS late
            FROM in_out
            WHERE ctype = 1
        ) AS foo
        ON emps.id = foo.emp_id
        WHERE late > '00:15:00'
        ORDER BY age DESC
    ) AS bar;
$$ LANGUAGE SQL;

SELECT fn_task1();

-- Task 2
-- Task 2.1
WITH xxx AS (
    SELECT MIN(age) AS min_age_in_days, dept
    FROM (
        SELECT *, NOW() - bd AS age
        FROM emps
    ) AS foo
    GROUP BY dept
)
SELECT dept
FROM xxx
WHERE min_age_in_days = (
    SELECT MIN(min_age_in_days)
    FROM xxx
);

-- Task 2.2
CREATE OR REPLACE FUNCTION fn_get_not_work_time(x_emp_id INT)
RETURNS TIME AS $$
$$ LANGUAGE SQL;

SELECT fn_get_not_work();



-- Task 2.3
WITH xxx AS (
    SELECT *
    FROM emps
    JOIN in_out
    ON emps.id = in_out.emp_id
)
SELECT emp_id
FROM (
    SELECT emp_id, MIN(ctime) AS mct
    FROM xxx
    GROUP BY emp_id
    ORDER BY emp_id
) AS foo
WHERE mct - '09:00:00' < '00:10:00';

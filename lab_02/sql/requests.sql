/* 1. Инструкция SELECT, использующая предикат сравнения */
/*/1* */
/* Выбираем пользователей, у которых больше двух постов */
SELECT id, username
FROM user_main AS t
WHERE (
    SELECT COUNT(*)
    FROM user_post
    WHERE user_id = t.id
) > 2;
/* */ */

/* 2. Инструкция SELECT, использующая предикат BETWEEN */
/*/1* */
SELECT id, username
FROM user_main AS t
WHERE (
    SELECT COUNT(*)
    FROM user_post
    WHERE user_id = t.id
) BETWEEN 1 AND 5;
/* */ */

/* 3. Инструкция SELECT, использующая предикат LIKE */
/*/1* */
SELECT id, username
FROM user_main
WHERE username
LIKE '%john%';
/* */ */

/* 4. Инструкция SELECT, использующая предикат IN со вложенным подзапросом */
/*/1* */
SELECT *
FROM user_main
WHERE id IN (
    SELECT id
    FROM user_main
    WHERE username
    LIKE '%john%'
);
/* */ */

/* 5. Инструкция SELECT, использующая предикат EXISTS со вложенным подзапросом */
/* SQL Exists is a conditional operator that checks the existence of rows in a subquery. */
/* Вывести количество пользователей, у которых есть хотя бы один подписчик */
/*/1* */
SELECT COUNT(*)
FROM user_main AS t
WHERE EXISTS (
    SELECT following_id
    FROM user_subscription
    WHERE following_id = t.id 
);
/* */ */

/* 6. Инструкция SELECT, использующая предикат сравнения с квантором */
/* Получить пользователей, кто старше всех тех, у кого более 2х подписчиков */
/*/1* */
WITH user_age AS (
    SELECT id, EXTRACT(YEAR FROM NOW()) - EXTRACT(YEAR FROM birthday) AS age
    FROM user_main
),
user_subscriber_count AS (
    SELECT following_id AS id, COUNT(follower_id) AS subscriber_count
    FROM user_subscription
    GROUP BY following_id
)
SELECT username, age, subscriber_count
FROM user_main AS t
JOIN (SELECT * FROM user_age) AS tt ON tt.id = t.id
JOIN (SELECT * FROM user_subscriber_count) AS ttt ON ttt.id = t.id
WHERE age > ALL (
    SELECT age
    FROM user_age AS tttt
    WHERE tttt.id = ANY (
        SELECT id
        FROM user_subscriber_count
        WHERE subscriber_count > 2
    )
)

/* Проверка (список пользователей, по убыванию возраста, у кого больше 2х подписчиков): */
ORDER BY age DESC, subscriber_count DESC;
WITH user_age AS (
    SELECT id, EXTRACT(YEAR FROM NOW()) - EXTRACT(YEAR FROM birthday) AS age
    FROM user_main
),
user_subscriber_count AS (
    SELECT following_id AS id, COUNT(follower_id) AS subscriber_count
    FROM user_subscription
    GROUP BY following_id
)
SELECT username, age, subscriber_count
FROM user_main AS t
JOIN (SELECT * FROM user_age) AS tt ON tt.id = t.id
JOIN (SELECT * FROM user_subscriber_count) AS ttt ON ttt.id = t.id
WHERE subscriber_count > 2
ORDER BY age DESC, subscriber_count DESC;
/* */ */

/* 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов */
/* Вывод ников пользователей и количества их подписчиков по убыванию sub_count */
/*/1* */
SELECT username, COUNT(follower_id) AS subscriber_count
FROM user_main AS t
JOIN (
    SELECT *
    FROM user_subscription
) AS tt
ON id = tt.following_id
GROUP BY username
ORDER BY subscriber_count DESC;
/* */ */

/* 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов */
/* Вывод пользователей и количества загруженных ими файлов по убыванию кол-ва */
/*/1* */
SELECT id, username, (
    SELECT COUNT(id)
    FROM file
    WHERE uploaded_by = t.id
) AS files_uploaded
FROM user_main AS t
ORDER BY files_uploaded DESC;
/* */ */

/* 9. Инструкция SELECT, использующая простое выражение CASE */
/*/1* */
SELECT username,
    CASE
        WHEN files_uploaded.count < 2 THEN 'Little to no files uploaded'
        WHEN files_uploaded.count < 5 THEN 'Normal amount of files uploaded'
        ELSE 'A lot of files uploaded'
    END AS files_uploaded_text,
    files_uploaded.count AS files_uploaded_count
FROM user_main AS t
JOIN (
    SELECT uploaded_by AS by_id, COUNT(id) AS count
    FROM file
    GROUP BY uploaded_by
) AS files_uploaded
ON id = files_uploaded.by_id
ORDER BY files_uploaded.count DESC;
/* */ */

/* 10. Инструкция SELECT, использующая поисковое выражение CASE */
/*/1* */
SELECT username,
    CASE
        WHEN channel.subscriber_count < 2 THEN 'Small'
        WHEN channel.subscriber_count < 5 THEN 'Medium'
        ELSE 'Large'
    END AS audience_size
FROM user_main AS t
JOIN (
    SELECT following_id AS id, COUNT(follower_id) AS subscriber_count
    FROM user_subscription
    GROUP BY id
) AS channel
ON t.id = channel.id
ORDER BY channel.subscriber_count DESC;
/* */ */

/* 11. Создание новой временной локальной таблицы из резальтирующего набора данных инструкции SELECT */
/*/1* */
DROP TABLE info IF EXISTS;
SELECT t.id AS user_id, channel.subscriber_count, aoaoa.files_uploaded
INTO info
FROM user_main AS t
JOIN (
    SELECT following_id AS id, COUNT(follower_id) AS subscriber_count
    FROM user_subscription
    GROUP BY id
) AS channel
ON t.id = channel.id
JOIN (
    SELECT uploaded_by, COUNT(id) AS files_uploaded
    FROM file
    GROUP BY uploaded_by
) AS aoaoa
ON t.id = aoaoa.uploaded_by;
SELECT * FROM info ORDER BY subscriber_count DESC;
/* */ */

/* 12. Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM */
/* Вывод пользователей с количеством подписчиков больше среднего */
/*/1* */
SELECT username, channel.subscriber_count
FROM user_main AS t
JOIN (
    SELECT following_id AS id, COUNT(follower_id) AS subscriber_count
    FROM user_subscription
    GROUP BY id
) AS channel
ON t.id = channel.id /* <-- Корреляция */
WHERE channel.subscriber_count > (
    SELECT AVG(subscriber_count)
    FROM (
        SELECT following_id AS id, COUNT(follower_id) AS subscriber_count
        FROM user_subscription
        GROUP BY id
    ) AS foo
);
/* */ */

/* 13. Инстркуция SELECT, использующая вложенные подзапросы с уровнем вложенности 3 */
/* Вывод никнеймов людей с наибольшим количеством подписчиков */
/*/1* */
SELECT username
FROM user_main
WHERE id IN (
    SELECT following_id
    FROM user_subscription
    GROUP BY following_id
    HAVING COUNT(follower_id) = (
        SELECT MAX(sub_count)
        FROM (
            SELECT COUNT(follower_id) AS sub_count
            FROM user_subscription
            GROUP BY following_id
        ) AS counts
    )
);
/* */ */

/* 14. Инстркуция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING */
/*/1* */
/* NOTE: См. 7, 9, 10, 11 */
/* */ */

/* 15. Инстркуция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING */
/*/1* */
/* NOTE: См. 13 */
/* */ */

/* 16. Однострочная INSERT, выполняющая вставку в таблицу одной строки значений */
/*/1* */
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
INSERT INTO file (
    id,
    url,
    filetype,
    filesize,
    uploaded_by,
    creation_date
)
VALUES
(
    uuid_generate_v4(),
    'https://website.com',
    'video',
    123123,
    (SELECT id FROM user_main LIMIT 1),
    NOW()
);
/* */ */

/* 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса */
/*/1* */
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
INSERT INTO file (
    id,
    url,
    filetype,
    filesize,
    uploaded_by,
    creation_date
)
SELECT uuid_generate_v4(),
    (SELECT url FROM file LIMIT 1),
    (SELECT filetype FROM file LIMIT 1),
    (SELECT filesize FROM file LIMIT 1),
    (SELECT uploaded_by FROM file LIMIT 1),
    NOW();
/* */ */

/* 18. Простая инструкция UPDATE */
/*/1* */
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
DROP TABLE IF EXISTS temp_human;
CREATE TABLE IF NOT EXISTS temp_human (
    id                UUID,
    blink_count       INT,
    blinks_per_second INT
    );
INSERT INTO temp_human
(
    id,
    blink_count,
    blinks_per_second
)
VALUES
(
    uuid_generate_v4(),
    0,
    10
);
SELECT * FROM temp_human;
UPDATE temp_human
SET blink_count = blink_count + (
    SELECT blinks_per_second
    FROM temp_human AS t
    WHERE id = t.id
)
WHERE id = (SELECT id FROM temp_human LIMIT 1);
SELECT * FROM temp_human;
/* */ */

/* 19. Инструкция UPDATE со скалярным подзапросом в предложении SET */
/*/1* */
/* NOTE: См. 18 */
/* */ */

/* 20. Простая инструкция DELETE */
/*/1* */
DELETE FROM user_main WHERE id = (SELECT id FROM user_main LIMIT 1);
/* */ */

/* 21. Инструкция DELETE со вложенным коррелированным подзапросом в предложении WHERE */
/*/1* */
/* NOTE: См. 20 */
/* */ */

/* 22. Инструкция SELECT, использующая простое обобщённое табличное выражение */
/*/1* */
WITH user_age AS (
    SELECT id, EXTRACT(YEAR FROM NOW()) - EXTRACT(YEAR FROM birthday) AS age
    FROM user_main
),
user_subscriber_count AS (
    SELECT following_id AS id, COUNT(follower_id) AS subscriber_count
    FROM user_subscription
    GROUP BY following_id
)
SELECT username, age, subscriber_count
FROM user_main AS t
JOIN (SELECT * FROM user_age) AS tt ON tt.id = t.id
JOIN (SELECT * FROM user_subscriber_count) AS ttt ON ttt.id = t.id
ORDER BY subscriber_count DESC, age DESC;
/* */ */

/* 23. Инструкция SELECT, использующая рекурсивное обобщённое табличное выражение */
/*/1* */
CREATE TEMPORARY TABLE IF NOT EXISTS manager (
    id INT PRIMARY KEY,
    name TEXT NOT NULL
);
--
CREATE TEMPORARY TABLE IF NOT EXISTS employee (
    id INT PRIMARY KEY,
    manager_id INT REFERENCES manager(id) ON DELETE CASCADE,
    name TEXT NOT NULL
);
--
INSERT INTO manager VALUES (1, 'Репка');
INSERT INTO manager VALUES (2, 'Дедка');
INSERT INTO manager VALUES (3, 'Бабка');
INSERT INTO manager VALUES (4, 'Внучка');
INSERT INTO manager VALUES (5, 'Жучка');
INSERT INTO manager VALUES (6, 'Кошка');
INSERT INTO manager VALUES (7, 'Мышка');
--
INSERT INTO employee VALUES (1, NULL, 'Репка');
INSERT INTO employee VALUES (2, 1, 'Дедка');
INSERT INTO employee VALUES (3, 2, 'Бабка');
INSERT INTO employee VALUES (4, 3, 'Внучка');
INSERT INTO employee VALUES (5, 4, 'Жучка');
INSERT INTO employee VALUES (6, 5, 'Кошка');
INSERT INTO employee VALUES (7, 6, 'Мышка');
--
WITH RECURSIVE RepkaIncorporated (manager_id, employee_id, employee_name, lvl) AS (
    SELECT e.manager_id, e.id, e.name, 0 AS lvl
    FROM employee AS e
    WHERE manager_id IS NULL
    UNION ALL
    --
    SELECT e.manager_id, e.id, e.name, w.lvl + 1
    FROM employee AS e
    INNER JOIN RepkaIncorporated AS w
    ON e.manager_id = w.employee_id
)
--
SELECT manager_id, employee_id, employee_name, lvl
FROM RepkaIncorporated;
/* */ */

/* 24. Оконные функции. Использование конструкция MIN/MAX/AVG/OVER() */
/*/1* */
/* DROP TABLE IF EXISTS product; */
CREATE TABLE IF NOT EXISTS product (
    id         INT,
    name       TEXT,
    class      TEXT,
    price      INT
    );
--
/* DROP TABLE IF EXISTS order_details; */
CREATE TABLE IF NOT EXISTS order_details (
    id           INT,
    product_id   INT,
    wanted_price INT
    );
--
INSERT INTO product VALUES (1, 'Orange', 'food', 10);
INSERT INTO product VALUES (2, 'Apple', 'food', 10);
INSERT INTO product VALUES (3, 'Cake', 'food', 100);
INSERT INTO product VALUES (4, 'Skateboard', 'vehicle', 1000);
INSERT INTO product VALUES (5, 'Subaru XV', 'vehicle', 1000000);
INSERT INTO product VALUES (6, 'Black Hawk', 'vehicle', 1000000000);
INSERT INTO product VALUES (7, 'Bird', 'animal', 0);
--
INSERT INTO order_details VALUES (1,  1, 0);
INSERT INTO order_details VALUES (2,  1, 1);
INSERT INTO order_details VALUES (3,  1, 6);
INSERT INTO order_details VALUES (4,  1, 7);
INSERT INTO order_details VALUES (5,  6, 0);
INSERT INTO order_details VALUES (6,  6, 1000000);
INSERT INTO order_details VALUES (7,  6, 5000000);
INSERT INTO order_details VALUES (8,  6, 100500000);
INSERT INTO order_details VALUES (9,  5, 0);
INSERT INTO order_details VALUES (10, 5, 400000);
INSERT INTO order_details VALUES (11, 5, 800000);
INSERT INTO order_details VALUES (12, 3, 99);
--
SELECT p.id, p.price, p.name, od.wanted_price,
    AVG(od.wanted_price) OVER(PARTITION BY p.id) AS AvgPrice,
    MIN(od.wanted_price) OVER(PARTITION BY p.id) AS MinPrice,
    MAX(od.wanted_price) OVER(PARTITION BY p.id) AS MaxPrice
FROM product AS p
LEFT OUTER JOIN order_details AS od
ON od.product_id = p.id;
/* */ */

/* 25. Оконные функции для устранения дублей */
/*/1* */
SELECT *, ROW_NUMBER() OVER(PARTITION BY class)
FROM (
    SELECT * FROM product
    UNION ALL
    SELECT * FROM product
) AS foo;
/* */ */

/* Доп. задание на доп. баллы */
DROP TABLE IF EXISTS table1;
CREATE TABLE IF NOT EXISTS table1 (
    id              INT,
    var1            TEXT,
    valid_from_dttm DATE,
    valid_to_dttm   DATE
    );
--
DROP TABLE IF EXISTS table2;
CREATE TABLE IF NOT EXISTS table2 (
    id              INT,
    var2            TEXT,
    valid_from_dttm DATE,
    valid_to_dttm   DATE
    );
--
INSERT INTO table1 VALUES (1, 'A', '2018-09-01', '2018-09-15');
INSERT INTO table1 VALUES (1, 'B', '2018-09-16', '5999-12-31');
--
INSERT INTO table2 VALUES (1, 'A', '2018-09-01', '2018-09-18');
INSERT INTO table2 VALUES (1, 'B', '2018-09-19', '5999-12-31');
--
SELECT t1.id, t1.var1, t2.var2,
    GREATEST(t1.valid_from_dttm, t2.valid_from_dttm) AS greatest_from,
    LEAST(t1.valid_to_dttm, t2.valid_to_dttm) AS least_to
FROM table1 t1
JOIN table2 t2
ON t1.id = t2.id
    AND t1.valid_from_dttm <= t2.valid_to_dttm
    AND t2.valid_from_dttm <= t1.valid_to_dttm;

-- Для себя
DROP TABLE IF EXISTS t1;
CREATE TABLE IF NOT EXISTS t1 (
    id    INT,
    v1    CHAR,
    vfrom INT,
    vto   INT
    );
--
DROP TABLE IF EXISTS t2;
CREATE TABLE IF NOT EXISTS t2 (
    id    INT,
    v2    CHAR,
    vfrom INT,
    vto   INT
    );
--
DROP TABLE IF EXISTS t3;
CREATE TABLE IF NOT EXISTS t3 (
    id    INT,
    v3    CHAR,
    vfrom INT,
    vto   INT
    );
--
INSERT INTO t1 VALUES (1, 'A', 0, 33);
INSERT INTO t1 VALUES (1, 'B', 34, 66);
INSERT INTO t1 VALUES (1, 'C', 67, 100);
--
INSERT INTO t2 VALUES (1, 'A', 0, 20);
INSERT INTO t2 VALUES (1, 'B', 21, 47);
INSERT INTO t2 VALUES (1, 'C', 48, 100);
--
INSERT INTO t3 VALUES (1, 'A', 0, 40);
INSERT INTO t3 VALUES (1, 'B', 41, 87);
INSERT INTO t3 VALUES (1, 'C', 88, 100);
--
SELECT t12.id, t12.v1, t12.v2, t3.v3,
    GREATEST(gfrom, t3.vfrom) AS greatest_from,
    LEAST(lto, t3.vto) AS least_to
FROM (
    SELECT t1.id, t1.v1, t2.v2,
        GREATEST(t1.vfrom, t2.vfrom) AS gfrom,
        LEAST(t1.vto, t2.vto) AS lto
    FROM t1
    JOIN t2
    ON t1.id = t2.id
        AND t1.vfrom <= t2.vto
        AND t2.vfrom <= t1.vto
) AS t12
JOIN t3
ON t12.id = t3.id
    AND t12.gfrom <= t3.vto
    AND t3.vfrom <= t12.lto;

--
-- Защита:
INSERT INTO user_post
(id, user_id, shared_post_id, text, creation_date)
VALUES
(
    uuid_generate_v4(),
    (SELECT id FROM user_main LIMIT 1),
    NULL,
    'test text',
    '2022-09-20 21:45:01.260562'
);

INSERT INTO user_post_attachment
VALUES
(
    '5eb66d86-c33b-4382-9b4f-74b2e82fa468',
    (SELECT id FROM file LIMIT 1)
);

WITH table_all AS (
    SELECT *
    FROM user_main AS um
    JOIN (
        SELECT id, user_id, creation_date AS post_cd
        FROM user_post
    ) AS up
    ON up.user_id = um.id
    JOIN user_post_attachment AS upa
    ON upa.post_id = up.id
)
SELECT
    username,
    fullname,
    email,
    creation_date,
    post_cd,
    file_id
FROM table_all
WHERE EXTRACT(YEAR FROM post_cd) = 2022
ORDER BY post_cd DESC;

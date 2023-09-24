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
/*TODO*/
/* */ */

/* 24. Оконные функции. Использование конструкция MIN/MAX/AVG/OVER() */
/*/1* */
/*TODO*/
/* */ */

/* 25. Оконные функции для устранения дублей */
/*/1* */
/*TODO*/
/* */ */

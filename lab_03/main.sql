-- 1. Скалярная функция
{
CREATE OR REPLACE FUNCTION fn_count_users()
RETURNS INT AS $$
    SELECT COUNT(*) FROM user_main;
$$ LANGUAGE SQL;

SELECT fn_count_users();
}

-- 2. Подставляемая табличная функция
{
CREATE OR REPLACE FUNCTION fn_get_user_followers_count()
RETURNS TABLE
    (
        username VARCHAR(32),
        subscriber_count INT
    )
AS $$
    SELECT username, COUNT(follower_id) AS subscriber_count
    FROM user_main AS t
    JOIN (
        SELECT * FROM user_subscription
    ) AS tt
    ON id = tt.following_id
    GROUP BY username
    ORDER BY subscriber_count DESC;
$$ LANGUAGE SQL;

SELECT * FROM fn_get_user_followers_count();
}

-- 3. Многооператорная табличная функция
{
DROP FUNCTION fn_get_brics_users_subs();

CREATE OR REPLACE FUNCTION fn_helper(x_country VARCHAR(256))
RETURNS TABLE
    (
        username      VARCHAR(32),
        country       VARCHAR(256),
        subscribed_to VARCHAR(32)
    )
AS $$
    SELECT a.username, a.country, b.subscribed_to
    FROM user_main AS a
    JOIN (
        SELECT d.follower_id, d.following_id, c.subscribed_to
        FROM user_subscription AS d
        JOIN (
            SELECT e.id, e.username AS subscribed_to
            FROM user_main AS e
        ) AS c
        ON c.id = d.following_id
    ) AS b
    ON a.id = b.follower_id
    WHERE a.country = x_country;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION fn_get_brics_users_subs()
RETURNS TABLE
    (
        username      VARCHAR(32),
        country       VARCHAR(256),
        subscribed_to VARCHAR(32),
        priority      INT
    )
AS $$
BEGIN
    RETURN QUERY SELECT *, 0 FROM fn_helper('Brazil');
    RETURN QUERY SELECT *, 1 FROM fn_helper('Russian Federation');
    RETURN QUERY SELECT *, 2 FROM fn_helper('India');
    RETURN QUERY SELECT *, 3 FROM fn_helper('China');
    RETURN QUERY SELECT *, 4 FROM fn_helper('South Africa');
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fn_get_brics_users_subs();
}

-- 4. Рекурсивная функция или функция с рекурсивным ОТВ
{
CREATE OR REPLACE FUNCTION fn_bfs_subs(x_username TEXT)
RETURNS TABLE 
    (
        follower  VARCHAR(32),
        following VARCHAR(32)
    )
AS $$
    WITH RECURSIVE ss(follower, following) AS ( --, depth_) AS (
        SELECT c.username AS follower, a.username AS following --, 0 AS depth_
        FROM user_main AS a
        JOIN (SELECT * FROM user_subscription) AS b
        ON a.id = b.following_id
        JOIN (SELECT id, username FROM user_main) AS c
        ON b.follower_id = c.id
        WHERE a.username LIKE x_username

        UNION

        SELECT c.username AS follower, a.username AS following --, ss.depth_ + 1
        FROM user_main AS a
        JOIN (SELECT * FROM user_subscription) AS b
        ON a.id = b.following_id
        JOIN (SELECT id, username FROM user_main) AS c
        ON b.follower_id = c.id
        JOIN ss
        ON a.username = ss.follower
    )

    SELECT * FROM ss;
$$ LANGUAGE SQL;

SELECT * FROM fn_bfs_subs('bianca796182'::TEXT);
}

-- 5. Хранимую процедуру без параметров или с параметрами
{
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE OR REPLACE PROCEDURE fn_insert_user(x_username VARCHAR(32))
AS $$
    INSERT INTO user_main(
        id,
        username,
        fullname,
        email,
        password_hash,
        birthday,
        creation_date
    )
    VALUES
    (
        uuid_generate_v4(),
        x_username,
        'Default Human',
        'default@example.net',
        'defaultpasswordhash',
        '1901-01-01',
        NOW()
    );
$$ LANGUAGE SQL;

CALL fn_insert_user('john12345');
CALL fn_insert_user('snow54321');

SELECT username, fullname FROM user_main WHERE fullname = 'Default Human';
}

-- 6. Рекурсивную хранимую процедуру или хранимую процедуру с
-- рекурсивным ОТВ
{
CREATE OR REPLACE PROCEDURE fn_hypnotize(x_username VARCHAR(32), hypnosis_power INT)
AS $$
    BEGIN
        UPDATE user_main
        SET bio = 'All Glory to the Hypnotoad'
        WHERE username = x_username;

        IF (hypnosis_power > 0) THEN
            WITH RECURSIVE sub_tree AS (
                SELECT a.following_id AS id, x_username AS username, b.username AS sub_username, 1 AS current_depth
                FROM user_subscription AS a
                JOIN user_main AS b
                ON a.following_id = (
                    SELECT id FROM user_main WHERE username = x_username
                ) AND b.id = a.follower_id

                UNION ALL

                SELECT a.following_id, st.sub_username AS username, b.username AS sub_username, st.current_depth + 1 AS current_depth
                FROM sub_tree AS st
                JOIN user_subscription AS a
                ON a.following_id = (
                    SELECT id FROM user_main WHERE username = st.sub_username
                )
                JOIN user_main AS b
                ON b.id = a.follower_id

                WHERE st.current_depth < hypnosis_power
            )

            UPDATE user_main
            SET bio = 'All Glory to the Hypnotoad'
            WHERE username IN (SELECT sub_username FROM sub_tree);
        END IF;
    END;
$$ LANGUAGE plpgsql;
}

-- 7. Хранимую процедуру с курсором
{
}

-- 8. Хранимую процедуру доступа к метаданным
{
}

-- 9. DML-Триггер AFTER
{
}

-- 10. DML-Триггер INSTEAD OF
{
}

-- Test recursive
{
    WITH RECURSIVE sub_tree AS (
        SELECT a.following_id AS id, 'bianca796182'::VARCHAR(32) AS username, b.username AS sub_username, 1 AS current_depth
        FROM user_subscription AS a
        JOIN user_main AS b
        ON a.following_id = (
            SELECT id FROM user_main WHERE username = 'bianca796182'
        ) AND b.id = a.follower_id

        UNION ALL

        SELECT a.following_id, st.sub_username AS username, b.username AS sub_username, st.current_depth + 1 AS current_depth
        FROM sub_tree AS st
        JOIN user_subscription AS a
        ON a.following_id = (
            SELECT id FROM user_main WHERE username = st.sub_username
        )
        JOIN user_main AS b
        ON b.id = a.follower_id

        WHERE st.current_depth < 5
    )

    SELECT * FROM sub_tree;
}

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
CREATE OR REPLACE PROCEDURE fn_list_users()
AS $$
    DECLARE
        rec user_main%ROWTYPE;
        cur CURSOR FOR (
            SELECT *
            FROM user_main
        );
    BEGIN
        OPEN cur;

        LOOP
            FETCH NEXT FROM cur INTO rec;

            EXIT WHEN NOT FOUND;

            RAISE NOTICE 'Username: %', rec.username;
        END LOOP;

        CLOSE cur;
    END;
$$ LANGUAGE plpgsql;
}

-- 8. Хранимую процедуру доступа к метаданным
{
DROP PROCEDURE fn_get_db_meta(dbname text);

CREATE OR REPLACE PROCEDURE fn_get_db_meta(dbname text)
AS $$
    DECLARE
        dbid INT;
    BEGIN
        SELECT pg_database.oid
        FROM pg_database
        WHERE pg_database.datname = dbname
        INTO dbid;
        
        RAISE NOTICE 'DB: %, ID: %', dbname, dbid;
    END;
$$ LANGUAGE plpgsql;

CALL fn_get_db_meta('evilcorp');
}

-- 9. DML-Триггер AFTER
{
CREATE OR REPLACE FUNCTION fn_echo_insert()
RETURNS TRIGGER
AS $$
    BEGIN
        RAISE NOTICE 'INSERTED new record;';
        RETURN new;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_echo_insert
    AFTER INSERT ON user_main
EXECUTE PROCEDURE fn_echo_insert();

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
    'useasdfrasdfnamellkjlkjsakdjf',
    'Default Human',
    'default@example.net',
    'defaultpasswordhash',
    '1901-01-01',
    NOW()
);
}

-- 10. DML-Триггер INSTEAD OF
{
CREATE OR REPLACE FUNCTION fn_you_shall_not_pass()
RETURNS TRIGGER
AS $$
    BEGIN
        RAISE NOTICE 'YOU SHALL NOT PASS %;', old;
        RETURN old;
    END;
$$ LANGUAGE plpgsql;

CREATE VIEW file_copy AS
SELECT * FROM file;

CREATE OR REPLACE TRIGGER tg_you_shall_not_pass
    INSTEAD OF DELETE
    ON file_copy
    FOR EACH ROW
EXECUTE PROCEDURE fn_you_shall_not_pass();
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

-- Защита
{
-- фя по ид пользователя
-- опр. стат сделанных постов в опр даты с какого то по какое-то
-- указывать комменты если есть
-- были ли прикреплены файлы
-- если да то инфу о файлах
DROP FUNCTION IF EXISTS fn_get_stats(UUID, TIMESTAMP WITH TIME ZONE, TIMESTAMP WITH TIME ZONE);
CREATE OR REPLACE FUNCTION fn_get_stats(
    x_id  UUID,
    since TIMESTAMP WITH TIME ZONE,
    until TIMESTAMP WITH TIME ZONE
)
RETURNS TABLE
    (
        post_id UUID,
        creation_date TIMESTAMP WITH TIME ZONE,
        attachment_file UUID,
        file_url VARCHAR(256),
        commenter VARCHAR(32),
        comment_text TEXT
    )
AS $$
    SELECT
        up.id AS post_id,
        up.creation_date AS creation_date,
        upa.file_id AS attachment_file,
        f.url AS file_url,
        um.username AS commenter,
        uc.text AS comment_text
    FROM user_post AS up
    LEFT OUTER JOIN user_post_comment AS uc
    ON up.id = uc.post_id
    LEFT OUTER JOIN user_main AS um
    ON uc.commenter_id = um.id
    LEFT OUTER JOIN user_post_attachment AS upa
    ON up.id = upa.post_id
    LEFT OUTER JOIN file AS f
    ON upa.file_id = f.id
    WHERE up.user_id = x_id
    AND up.creation_date >= since
    AND up.creation_date <= until;
$$ LANGUAGE SQL;

SELECT * FROM fn_get_stats(
    -- '84bfd7b2-5ceb-4e53-9bc3-78e053d63f1d'::UUID,
    'f8ae45fa-6439-4d81-8ccf-9deacbe16b16'::UUID,
    '1990-11-07 00:00:00.000000+03'::TIMESTAMP,
    NOW()
);

SELECT * FROM fn_get_stats(
    '84bfd7b2-5ceb-4e53-9bc3-78e053d63f1d'::UUID,
    -- 'f8ae45fa-6439-4d81-8ccf-9deacbe16b16'::UUID,
    '1990-11-07 00:00:00.000000+03'::TIMESTAMP,
    NOW()
);
}

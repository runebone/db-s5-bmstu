CREATE EXTENSION IF NOT EXISTS plpython3u;
SELECT * FROM pg_language;

-- Создать, развернуть и протестировать 6 объектов SQL CLR:

-- 1. Определяемую пользователем скалярную функцию CLR,
DROP FUNCTION IF EXISTS pyfn_get_user_followers_count;
CREATE OR REPLACE FUNCTION pyfn_get_user_followers_count(x_username VARCHAR(32))
RETURNS INT
AS $$
    query = plpy.prepare("""
        SELECT username, COUNT(follower_id) AS subscriber_count
        FROM user_main AS t
        JOIN (
            SELECT * FROM user_subscription
        ) AS tt
        ON id = tt.following_id
        WHERE username = $1
        GROUP BY username
        """, ["VARCHAR(32)"])
    result = plpy.execute(query, [x_username])
    if result:
        return result[0]["subscriber_count"]
$$ LANGUAGE plpython3u;
--
SELECT * FROM pyfn_get_user_followers_count('bianca796182'::VARCHAR(32));

-- 2. Пользовательскую агрегатную функцию CLR,
DROP FUNCTION IF EXISTS pyfn_count_users_with_name;
CREATE OR REPLACE FUNCTION pyfn_count_users_with_name(x_name VARCHAR(32))
RETURNS VARCHAR(32)
AS $$
    query = plpy.prepare("""
        SELECT fullname
        FROM user_main
        WHERE fullname LIKE $1
        """, ["VARCHAR(32)"])
    result = plpy.execute(query, [' '.join([x_name, "%"])])
    if result:
        return len(result)
$$ LANGUAGE plpython3u;
--
SELECT * FROM pyfn_count_users_with_name('John'::VARCHAR(32));

-- 3. Определяемую пользователем табличную функцию CLR,
DROP FUNCTION IF EXISTS pyfn_get_users_with_name;
CREATE OR REPLACE FUNCTION pyfn_get_users_with_name(x_name VARCHAR(32))
RETURNS TABLE (
    username VARCHAR(32),
    fullname VARCHAR(32)
) AS $$
    query = plpy.prepare("""
        SELECT username, fullname
        FROM user_main
        WHERE fullname LIKE $1
        """, ["VARCHAR(32)"])
    result = plpy.execute(query, [' '.join([x_name, "%"])])
    if result:
        return result
$$ LANGUAGE plpython3u;
--
SELECT * FROM pyfn_get_users_with_name('John'::VARCHAR(32));

-- 4. Хранимую процедуру CLR,
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE OR REPLACE PROCEDURE pyfn_insert_user(x_username VARCHAR(32))
AS $$
    query = plpy.prepare("""
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
        $1,
        'Default Human',
        'default@example.net',
        'defaultpasswordhash',
        '1901-01-01',
        NOW()
    );
    """, ["VARCHAR(32)"])
    plpy.execute(query, [x_username])
$$ LANGUAGE plpython3u;
--
CALL pyfn_insert_user('john123456');
CALL pyfn_insert_user('snow654321');
--
SELECT username, fullname FROM user_main WHERE fullname = 'Default Human';

-- 5. Триггер CLR,
CREATE OR REPLACE FUNCTION pyfn_you_shall_not_pass()
RETURNS TRIGGER
AS $$
    old = TD["old"]
    plpy.notice(f"YOU SHALL NOT PASS {old['id']}")
    return None
$$ LANGUAGE plpython3u;
--
DROP VIEW file_copy;
CREATE VIEW file_copy AS
SELECT * FROM file;
--
CREATE OR REPLACE TRIGGER tg_you_shall_not_pass
    INSTEAD OF DELETE
    ON file_copy
    FOR EACH ROW
EXECUTE PROCEDURE pyfn_you_shall_not_pass();
--
DELETE FROM file_copy;

-- 6. Определяемый пользователем тип данных CLR.
CREATE TYPE user_subcount AS
(
    username VARCHAR(32),
    subscriber_count INT
);
DROP FUNCTION IF EXISTS pyfn_get_user_followers_count2;
CREATE OR REPLACE FUNCTION pyfn_get_user_followers_count2(x_username VARCHAR(32))
RETURNS user_subcount
AS $$
    query = plpy.prepare("""
        SELECT username, COUNT(follower_id) AS subscriber_count
        FROM user_main AS t
        JOIN (
            SELECT * FROM user_subscription
        ) AS tt
        ON id = tt.following_id
        WHERE username = $1
        GROUP BY username
        """, ["VARCHAR(32)"])
    result = plpy.execute(query, [x_username])
    if result:
        return (result[0]["username"], result[0]["subscriber_count"])
$$ LANGUAGE plpython3u;
--
SELECT * FROM pyfn_get_user_followers_count2('bianca796182'::VARCHAR(32));

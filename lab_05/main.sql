-- 1. Из таблиц БД, созданной в ЛР1, извлечь данные в JSON.
-- См.: main.py

-- 2. Выполнить загрузку и сохранение JSON файла в таблицу. Созданная таблица
-- после всех манипуляций должна соответствовать таблице БД, созданной в ЛР1.

-- touch /json/tmp.json && chmod ugo+rw /json/tmp.json
COPY (
    SELECT json_agg(file) FROM file
) TO '/json/tmp.json';
--
DROP TABLE IF EXISTS filejsonb;
CREATE TABLE filejsonb (
    data JSONB
);
--
COPY filejsonb(data) FROM '/json/tmp.json';
--
SELECT x.* FROM filejsonb, json_to_recordset(
    filejsonb.data::json
) AS x(
    id            UUID,
    url           VARCHAR(256),
    filetype      VARCHAR(8),
    filesize      BIGINT,
    uploaded_by   UUID,
    creation_date TIMESTAMP
);
-- Доказательство идентичности таблиц
SELECT x.* FROM filejsonb, json_to_recordset(
    filejsonb.data::json
) AS x(
    id            UUID,
    url           VARCHAR(256),
    filetype      VARCHAR(8),
    filesize      BIGINT,
    uploaded_by   UUID,
    creation_date TIMESTAMP
)
EXCEPT
SELECT * FROM file;

-- 3. Создать таблицу, в которой будет атрибут с типом JSON. Заполнить атрибут
-- правдоподобными данными с помощью команд INSERT.
DROP TABLE IF EXISTS user_json;
CREATE TABLE user_json (
    id      UUID,
    user_id UUID,
    data    JSON
);
--
INSERT INTO user_json(id, user_id, data)
VALUES (
    uuid_generate_v4(),
    uuid_generate_v4(),
    '{"key1": "a", "key2": "b"}'
);

-- 4.1. Извлечь JSON фрагмент из JSON документа
WITH json AS (
    SELECT jsonb_array_elements(data) AS data
    FROM filejsonb
)
SELECT json.data FROM json;

-- 4.2. Извлечь значения конкретных узлов или атрибутов JSON документа
WITH json AS (
    SELECT jsonb_array_elements(data) AS data
    FROM filejsonb
)
SELECT json.data->>'id' AS id, json.data->>'url' AS url FROM json;

-- 4.3. Выполнить проверку существования узла или атрибута
WITH json AS (
    SELECT jsonb_array_elements(data) AS data
    FROM filejsonb
)
SELECT
    json.data ? 'unexisting_field' AS unexisting_field,
    json.data ? 'id' AS existing_field
FROM json LIMIT 1;

-- 4.4. Изменить JSON документ
WITH json AS (
    SELECT jsonb_array_elements(data) AS data FROM filejsonb
),
updated_data AS (
    SELECT (
        CASE
                WHEN (data->>'filetype')::text = 'audio' THEN jsonb_set(data, '{filetype}', '"video"', true)
                ELSE data
        END
    ) AS new_data
    FROM json
)
-- SELECT * FROM updated_data;
UPDATE filejsonb SET data = (SELECT jsonb_agg(new_data) FROM updated_data);

-- 4.5. Разделить JSON документ на несколько строк по узлам
WITH json AS (
    SELECT jsonb_array_elements(data) AS data
    FROM filejsonb
)
SELECT x.* FROM json, json_to_record(data::json) AS x(
    id            UUID,
    url           VARCHAR(256),
    filetype      VARCHAR(8),
    filesize      BIGINT,
    uploaded_by   UUID,
    creation_date TIMESTAMP
);

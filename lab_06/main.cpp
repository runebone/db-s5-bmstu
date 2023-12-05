#include <iostream>
#include <pqxx/pqxx>

#define TCB "\033[34m"
#define RC "\033[0;0;0m"

pqxx::result doScalarRequest(pqxx::work& w) {
    std::string request = "SELECT username FROM user_main LIMIT 5";

    return w.exec(request);
}

pqxx::result doRequestWithMultipleJoins(pqxx::work& w) {
    std::string request = " \
WITH user_age AS ( \
    SELECT id, EXTRACT(YEAR FROM NOW()) - EXTRACT(YEAR FROM birthday) AS age \
    FROM user_main \
), \
user_subscriber_count AS ( \
    SELECT following_id AS id, COUNT(follower_id) AS subscriber_count \
    FROM user_subscription \
    GROUP BY following_id \
) \
SELECT username, age, subscriber_count \
FROM user_main AS t \
JOIN (SELECT * FROM user_age) AS tt ON tt.id = t.id \
JOIN (SELECT * FROM user_subscriber_count) AS ttt ON ttt.id = t.id \
ORDER BY subscriber_count DESC, age DESC \
LIMIT 5 \
";

    return w.exec(request);
}

pqxx::result doRequestWithOTBAndWindowFunctions(pqxx::work& w) {
    std::string request = " \
WITH aoaoa AS ( \
SELECT p.id, p.price, p.name, od.wanted_price, \
    AVG(od.wanted_price) OVER(PARTITION BY p.id) AS AvgPrice, \
    MIN(od.wanted_price) OVER(PARTITION BY p.id) AS MinPrice, \
    MAX(od.wanted_price) OVER(PARTITION BY p.id) AS MaxPrice \
FROM product AS p \
LEFT OUTER JOIN order_details AS od \
ON od.product_id = p.id \
) \
SELECT * FROM aoaoa; \
";

    return w.exec(request);
}

pqxx::result doRequestToMetadata(pqxx::work& w) {
    std::string request = " \
SELECT * FROM information_schema.triggers \
";

    return w.exec(request);
}

pqxx::result callScalarFunction(pqxx::work& w) {
    std::string request = " \
CREATE OR REPLACE FUNCTION fn_count_users() \
RETURNS INT AS $$ \
    SELECT COUNT(*) FROM user_main; \
$$ LANGUAGE SQL; \
 \
SELECT fn_count_users(); \
";

    return w.exec(request);
}

pqxx::result callTableFunction(pqxx::work& w) {
    std::string request = " \
CREATE OR REPLACE FUNCTION fn_get_user_followers_count() \
RETURNS TABLE \
    ( \
        username VARCHAR(32), \
        subscriber_count INT \
    ) \
AS $$ \
    SELECT username, COUNT(follower_id) AS subscriber_count \
    FROM user_main AS t \
    JOIN ( \
        SELECT * FROM user_subscription \
    ) AS tt \
    ON id = tt.following_id \
    GROUP BY username \
    ORDER BY subscriber_count DESC; \
$$ LANGUAGE SQL; \
 \
SELECT * FROM fn_get_user_followers_count(); \
";

    return w.exec(request);
}

pqxx::result callKeptProcedure(pqxx::work& w) {
    std::string request = " \
CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"; \
CREATE OR REPLACE PROCEDURE fn_insert_user(x_username VARCHAR(32)) \
AS $$ \
    INSERT INTO user_main( \
        id, \
        username, \
        fullname, \
        email, \
        password_hash, \
        birthday, \
        creation_date \
    ) \
    VALUES \
    ( \
        uuid_generate_v4(), \
        x_username, \
        'Default Human', \
        'default@example.net', \
        'defaultpasswordhash', \
        '1901-01-01', \
        NOW() \
    ); \
$$ LANGUAGE SQL; \
 \
SELECT username, fullname FROM user_main WHERE fullname = 'Default Human'; \
";

    return w.exec(request);
}

pqxx::result callSystemFunctionOrProcedure(pqxx::work& w) {
    std::string request = " \
    SELECT NOW(); \
";

    return w.exec(request);
}

pqxx::result createTable(pqxx::work& w) {
    std::string request = " \
DROP TABLE IF EXISTS post_likes_reposts; \
CREATE TABLE IF NOT EXISTS post_likes_reposts ( \
    post_id UUID, \
    likes   INT DEFAULT 0, \
    reposts INT DEFAULT 0 \
    ); \
";

    return w.exec(request);
}

pqxx::result insertDataIntoCreatedTable(pqxx::work& w) {
    std::string request = " \
CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"; \
INSERT INTO post_likes_reposts (post_id) VALUES (uuid_generate_v4()); \
";

    return w.exec(request);
}

pqxx::result selectDataFromCreatedTable(pqxx::work& w) {
    std::string request = " \
SELECT * FROM post_likes_reposts; \
";

    return w.exec(request);
}

void printResult(const pqxx::result& result) {
    for (const auto& row : result) {
        std::cout << "| ";
        for (const auto& value : row) {
            if (value.is_null()) {
                std::cout
                    << "NULL"
                    << " | ";
            } else {
                std::cout
                    << value.as<std::string>()
                    << " | ";
            }
        }
        std::cout << std::endl;
    }
}

int main() {
    try {
        pqxx::connection conn("host=localhost port=8001 dbname=evilcorp user=postgres password=hotdog123");
        std::cout << "Connected to " << conn.dbname() << std::endl;
        pqxx::work w(conn);

        int c = 1;
        char buf[255];

        for (; c != 0;) {
            printf("Выберите действие:\n");
            printf("[ 1] Выполнить скалярный запрос\n");
            printf("[ 2] Выполнить запрос с несколькими JOIN-ами\n");
            printf("[ 3] Выполнить запрос с ОТВ и оконными функциями\n");
            printf("[ 4] Выполнить запрос к метаданным\n");
            printf("[ 5] Вызвать скалярную функцию\n");
            printf("[ 6] Вызвать табличную функцию\n");
            printf("[ 7] Вызвать хранимую процедуру\n");
            printf("[ 8] Вызвать системную функцию\n");
            printf("[ 9] Создать таблицу\n");
            printf("[10] Вставить данные в созданную таблицу\n");
            printf("[11] Вывести созданную таблицу\n");
            printf("[ 0] Выйти\n");
            printf(">>> ");

            if (scanf("%d", &c) != 1) {
                printf("aoaoa.\n");
                fgets(buf, sizeof(buf), stdin); // Flushing input
                continue;
            }

            printf(TCB);
            switch (c) {
                case 1:
                    printResult(doScalarRequest(w));
                    break;
                case 2:
                    printResult(doRequestWithMultipleJoins(w));
                    break;
                case 3:
                    printResult(doRequestWithOTBAndWindowFunctions(w));
                    break;
                case 4:
                    printResult(doRequestToMetadata(w));
                    break;
                case 5:
                    printResult(callScalarFunction(w));
                    break;
                case 6:
                    printResult(callTableFunction(w));
                    break;
                case 7:
                    printResult(callKeptProcedure(w));
                    break;
                case 8:
                    printResult(callSystemFunctionOrProcedure(w));
                    break;
                case 9:
                    printResult(createTable(w));
                    break;
                case 10:
                    printResult(insertDataIntoCreatedTable(w));
                    break;
                case 11:
                    printResult(selectDataFromCreatedTable(w));
                    break;
                default:
                    break;
            }
            printf(RC);
        }

        w.commit();
    } catch (const std::exception &e) {
        std::cerr << e.what() << std::endl;
        return 1;
    }
    return 0;
}

#include <iostream>
#include <pqxx/pqxx>

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

pqxx::result doRequestWithOTBandWindowFunctions(pqxx::work& w) {
    std::string request = "";

    return w.exec(request);
}

pqxx::result doRequestToMetadata(pqxx::work& w) {
    std::string request = "";

    return w.exec(request);
}

pqxx::result callScalarFunction(pqxx::work& w) {
    std::string request = "";

    return w.exec(request);
}

pqxx::result callTableFunction(pqxx::work& w) {
    std::string request = "";

    return w.exec(request);
}

pqxx::result callKeptProcedure(pqxx::work& w) {
    std::string request = "";

    return w.exec(request);
}

pqxx::result callSystemFunctionOrProcedure(pqxx::work& w) {
    std::string request = "";

    return w.exec(request);
}

pqxx::result createTable(pqxx::work& w) {
    std::string request = "";

    return w.exec(request);
}

pqxx::result insertDataIntoCreatedTable(pqxx::work& w) {
    std::string request = "";

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
        pqxx::connection c("host=localhost port=8001 dbname=evilcorp user=postgres password=hotdog123");
        std::cout << "Connected to " << c.dbname() << std::endl;
        pqxx::work w(c);

        printResult(doScalarRequest(w));
        printResult(doRequestWithMultipleJoins(w));

        w.commit();
    } catch (const std::exception &e) {
        std::cerr << e.what() << std::endl;
        return 1;
    }
    return 0;
}

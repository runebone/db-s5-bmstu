#include <iostream>
#include <pqxx/pqxx>

#define TCR "\033[31m"
#define TCB "\033[34m"
#define RC "\033[0;0;0m"

void printResult(const pqxx::result& result);

pqxx::result task21(pqxx::work& w) {
    std::string request = " \
    WITH xxx AS ( \
        SELECT MIN(age) AS min_age_in_days, dept \
        FROM ( \
            SELECT *, NOW() - bd AS age \
            FROM emps \
        ) AS foo \
        GROUP BY dept \
    ) \
    SELECT dept \
    FROM xxx \
    WHERE min_age_in_days = ( \
        SELECT MIN(min_age_in_days) \
        FROM xxx \
    ) \
    ";

    return w.exec(request);
}

pqxx::result task22(pqxx::work& w) {
    std::string request = "
    ";

    return w.exec(request);
}

pqxx::result task23(pqxx::work& w) {
    std::string request = " \
    WITH xxx AS ( \
        SELECT * \
        FROM emps \
        JOIN in_out \
        ON emps.id = in_out.emp_id \
    ) \
    SELECT emp_id \
    FROM ( \
        SELECT emp_id, MIN(ctime) AS mct \
        FROM xxx \
        GROUP BY emp_id \
        ORDER BY emp_id \
    ) AS foo \
    WHERE mct - '09:00:00' < '00:10:00'; \
    ";

    return w.exec(request);
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
            printf("[ 1] Task 2.1\n");
            printf("[ 2] Task 2.2\n");
            printf("[ 3] Task 2.3\n");
            printf("[ 0] Выйти\n");
            printf(">>> ");

            if (scanf("%d", &c) != 1) {
                printf(TCR "Error\n" RC);
                fgets(buf, sizeof(buf), stdin);
                continue;
            }

            printf(TCB);
            switch (c) {
                case 1:
                    printResult(task21(w));
                    break;
                case 2:
                    printResult(task22(w));
                    break;
                case 3:
                    printResult(task23(w));
                    break;
                default:
                    printf(TCR "IndexError\n" RC);
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

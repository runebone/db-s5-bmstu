#include <iostream>
#include <pqxx/pqxx>

int main() {
    try {
        pqxx::connection c("host=localhost port=8001 dbname=evilcorp user=postgres password=hotdog123");
        std::cout << "Connected to " << c.dbname() << std::endl;

        pqxx::work w(c);
        pqxx::result r = w.exec("SELECT * FROM user_main");

        std::cout << "Found " << r.size() << "records:" << std::endl;
        for (auto row : r) {
            std::cout << row[0].as<std::string>() << ": " << row[1].as<std::string>() << std::endl;
        }

        w.commit();
    } catch (const std::exception &e) {
        std::cerr << e.what() << std::endl;
        return 1;
    }
    return 0;
}

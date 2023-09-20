all:
	docker exec -it lab_01-postgresql-db-1 psql -U postgres -d evilcorp

.PHONY: bash
bash:
	docker exec -it lab_01-postgresql-db-1 bash

.PHONY: db
db:
	cat ./create_tables.sql | docker exec -i lab_01-postgresql-db-1 psql -U postgres -d evilcorp
	cat ./copy_tables.sql | docker exec -i lab_01-postgresql-db-1 psql -U postgres -d evilcorp
	cat ./alter_tables.sql | docker exec -i lab_01-postgresql-db-1 psql -U postgres -d evilcorp

.PHONY: restart
restart:
	docker-compose down
	sudo rm -rf postgresql_data
	docker-compose up

.PHONY: clean
clean:
	docker-compose down
	sudo rm -rf postgresql_data

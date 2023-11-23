all:
	docker exec -it shared-postgresql-db-1 psql -U postgres -d evilcorp

.PHONY: bash
bash:
	docker exec -it shared-postgresql-db-1 bash

.PHONY: db
db:
	cat ./shared/sql/create_tables.sql | docker exec -i shared-postgresql-db-1 psql -U postgres -d evilcorp
	cat ./shared/sql/copy_tables.sql | docker exec -i shared-postgresql-db-1 psql -U postgres -d evilcorp
	cat ./shared/sql/alter_tables.sql | docker exec -i shared-postgresql-db-1 psql -U postgres -d evilcorp

.PHONY: restart
restart:
	docker-compose -f ./shared/docker-compose.yml down
	sudo rm -rf ./shared/postgresql_data
	docker-compose -f ./shared/docker-compose.yml up

.PHONY: clean
clean:
	docker-compose -f ./shared/docker-compose.yml down
	sudo rm -rf postgresql_data

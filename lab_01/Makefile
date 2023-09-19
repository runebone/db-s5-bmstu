all:
	docker exec -it lab_01-postgresql-db-1 psql -U postgres -d evilcorp

.PHONY: bash
bash:
	docker exec -it lab_01-postgresql-db-1 bash

.PHONY: db
db:
	cat ./create_tables.sql | docker exec -i lab_01-postgresql-db-1 psql -U postgres -d evilcorp
	cat ./add_constraints.sql | docker exec -i lab_01-postgresql-db-1 psql -U postgres -d evilcorp


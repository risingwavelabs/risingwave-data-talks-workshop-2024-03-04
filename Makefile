# Seed kafka from the parquet file
.PHONY: seed-kafka
seed-kafka:
	python3 seed_kafka.py

# Starts an interactive terminal with the db
.PHONY: psql
psql:
	psql -h localhost -p 4566 -d dev -U root

# Creates the source ddl
.PHONY: rw-source
rw-source:
	./rw_source.py

# Creates MVs on the source
.PHONY: rw-mv
rw-mv:
	./rw_mv.py
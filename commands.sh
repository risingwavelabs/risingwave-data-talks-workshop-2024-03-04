export PGHOST=localhost
export PGPORT=4566
export PGUSER=root
export PGDATABASE=dev

# Seed trip data from the parquet file
seed-kafka() {
	python3 seed_kafka.py
}

# Creates various ddls
# USAGE: `rw-ddl <ddl-name>`.
# If no ddl-name is provided, it will create all the DDLs.
# If ddl-name is provided, it will create the specific DDL.
rw-ddl() {
	./rw_ddl.py "$@"
}

# Starts the risingwave cluster
start-cluster() {
	docker-compose -f docker/docker-compose.yml up -d
}

# Stops the risingwave cluster
stop-cluster() {
	docker-compose -f docker/docker-compose.yml down
}

# Cleans the risingwave cluster
clean-cluster() {
	docker-compose -f docker/docker-compose.yml down -v
}
.PHONY: seed-kafka
seed-kafka:
	python3 seed_kafka.py

.PHONY: psql
psql:
	psql -h localhost -p 4566 -d dev -U root
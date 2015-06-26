#!/bin/bash
# Test par_psql with 4-way parallelism, running a CPU-intensive function. 

DB_NAME="par_psql_test"
DB_OPTIONS="-d $DB_NAME"

setup_benchmark() {
  echo "Creating fresh database for test of $1"
  dropdb --if-exists $DB_NAME
  createdb $DB_NAME
  psql $DB_OPTIONS --file='benchmark_setup.sql'
}

setup_benchmark psql;
time psql $DB_OPTIONS --file='benchmark.sql'
echo "==== That was the result for psql ===="

sleep 4 # wait a moment for DB/server to catch up before starting next run

setup_benchmark par_psql;
time ./par_psql $DB_OPTIONS --file='benchmark.sql'
echo "==== That was the result for par_psql ===="



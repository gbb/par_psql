#!/bin/bash
# Test par_psql with 4-way parallelism, running a CPU-intensive function. 
# This test should be run in the distribution folder of par_psql (e.g. ./par_psql exists)

DB_NAME="par_psql_test"
DB_OPTIONS="-d $DB_NAME"
LOG="/tmp/par_psql_benchmarks"

./par_psql --parpsqlversion > $LOG

setup_benchmark() {
  echo "Creating fresh database to run '$1'"
  dropdb --if-exists $DB_NAME
  createdb $DB_NAME
  psql $DB_OPTIONS --file="setup_$1"
}

cd benchmarks

for bm in $(ls benchmark*.sql); do 
  for program in "psql" "../par_psql"; do 

  setup_benchmark "$bm";
  sleep 3 # wait a moment for DB/server to catch up with work before starting run

  echo "==== Starting benchmark run of $bm using $program ===="  
  { time $program $DB_OPTIONS --file="$bm" ; }  2>> $LOG 
  echo "==== 'real' above is the result for $bm using $program ====" >> $LOG
  tail -4 $LOG | grep real

  done

done

dropdb $DB_NAME

echo "A summary of the results has been placed in $LOG."

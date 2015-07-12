\echo Benchmark for 4-way parallelism using a user-defined pg/plsql function.

SELECT SETSEED(0.5);

\echo Preparing input data table for benchmark.

CREATE TABLE par_psql_test (id SERIAL, value NUMERIC);

INSERT INTO par_psql_test VALUES (generate_series(1,200000),trunc(random()*10000+1)::numeric);
CREATE INDEX ppt_id ON par_psql_test (id);

VACUUM ANALYZE par_psql_test;

\echo Benchmark setup is complete.

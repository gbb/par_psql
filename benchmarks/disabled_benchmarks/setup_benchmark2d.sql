\echo Benchmark for 4-way parallelism using a user-defined pg/plsql function.

SELECT SETSEED(0.5);

\echo Preparing input data table for benchmark.

CREATE TABLE par_psql_test (id SERIAL, value NUMERIC);

INSERT INTO par_psql_test VALUES (generate_series(1,200000),trunc(random()*10000+1)::numeric);
CREATE INDEX ppt_id ON par_psql_test (id);

CREATE TABLE par_psql_test1 AS SELECT * FROM par_psql_test where id%4=0;
CREATE INDEX ppt_id1 ON par_psql_test1 (id);

CREATE TABLE par_psql_test2 AS SELECT * FROM par_psql_test where id%4=1;
CREATE INDEX ppt_id2 ON par_psql_test2 (id);

CREATE TABLE par_psql_test3 AS SELECT * FROM par_psql_test where id%4=2;
CREATE INDEX ppt_id3 ON par_psql_test3 (id);

CREATE TABLE par_psql_test4 AS SELECT * FROM par_psql_test where id%4=3;
CREATE INDEX ppt_id4 ON par_psql_test4 (id);

VACUUM ANALYZE par_psql_test;
VACUUM ANALYZE par_psql_test1;
VACUUM ANALYZE par_psql_test2;
VACUUM ANALYZE par_psql_test3;
VACUUM ANALYZE par_psql_test4;

\echo Benchmark setup is complete.

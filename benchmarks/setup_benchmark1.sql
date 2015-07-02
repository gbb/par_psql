\echo Benchmark for 4-way parallelism using select and postgres md5 function.

\echo Preparing input data table for benchmark. Generating 10 million rows.

CREATE TABLE bm (id INT, md5 TEXT);

INSERT INTO bm (id, md5) 
SELECT id, md5(id::text)
FROM generate_series(1,10000000) AS id;

CREATE INDEX bm_id ON bm (id);

VACUUM ANALYZE bm;

\echo Benchmark setup is complete.



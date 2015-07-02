\echo 'This code uses a naive approach where a single table is used for output.'
\echo 'On some machines and queries, this will suffer from exclusive write lock contention'

-- The hailstone function uses mainly the cpu, not much ram or I/O.
-- Here, it is included in the benchmark to show that serial code 
-- such as function definitions can be mixed with parallelised code.

\echo 'Defining the benchmark function.'

CREATE OR REPLACE FUNCTION hailstone(startvalue NUMERIC)
RETURNS NUMERIC AS $$
DECLARE n NUMERIC;
BEGIN
  n:=STARTVALUE; 
  FOR i IN 1..1000 LOOP  
    WHILE n>1 LOOP
      IF n%2=0 THEN n:=n/2; ELSE n:=1+n*3; END IF;
    END LOOP;
  END LOOP;
  RETURN n;
END;
$$ LANGUAGE plpgsql;

\echo 'Preparing the results table.'

CREATE UNLOGGED TABLE par_psql_result (id SERIAL, value NUMERIC);

-- use the modulo operator to split the work to be done into 4 balanced sets

\echo 'Starting batch 1/4.'

INSERT INTO par_psql_result SELECT id,hailstone(value)
    FROM par_psql_test where id%4=0; --&

\echo 'Starting batch 2/4.'

INSERT INTO par_psql_result SELECT id,hailstone(value)
    FROM par_psql_test where id%4=1; --&

\echo 'Starting batch 3/4.'

INSERT INTO par_psql_result SELECT id,hailstone(value)
    FROM par_psql_test where id%4=2; --&

\echo 'Starting batch 4/4.'

INSERT INTO par_psql_result SELECT id,hailstone(value)
    FROM par_psql_test where id%4=3; --&

\echo 'Benchmark finished.'

select 'Done';

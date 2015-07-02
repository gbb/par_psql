\echo 'Similar to benchmark2.sql, but using 4 unlogged tables independently'

-- The hailstone function uses mainly the cpu, not much ram or I/O.
-- Here, it is included in the benchmark to show that serial code 
-- such as function definitions can be mixed with parallelised code.

\echo 'Defining the benchmark function.'

CREATE OR REPLACE FUNCTION hailstone1(startvalue NUMERIC)
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

CREATE OR REPLACE FUNCTION hailstone2(startvalue NUMERIC)
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

CREATE OR REPLACE FUNCTION hailstone3(startvalue NUMERIC)
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

CREATE OR REPLACE FUNCTION hailstone4(startvalue NUMERIC)
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

\echo 'Preparing 4 independent results tables.'

CREATE UNLOGGED TABLE par_psql_result1 (id SERIAL, value NUMERIC); --&
CREATE UNLOGGED TABLE par_psql_result2 (id SERIAL, value NUMERIC); --& 
CREATE UNLOGGED TABLE par_psql_result3 (id SERIAL, value NUMERIC); --& 
CREATE UNLOGGED TABLE par_psql_result4 (id SERIAL, value NUMERIC); 

-- use the modulo operator to split the work to be done into 4 balanced sets

\echo 'Starting batch 1/4.'

INSERT INTO par_psql_result1 SELECT id,hailstone1(value)
    FROM par_psql_test where id%4=0; --&

\echo 'Starting batch 2/4.'

INSERT INTO par_psql_result2 SELECT id,hailstone2(value)
    FROM par_psql_test where id%4=1; --&

\echo 'Starting batch 3/4.'

INSERT INTO par_psql_result3 SELECT id,hailstone3(value)
    FROM par_psql_test where id%4=2; --&

\echo 'Starting batch 4/4.'

INSERT INTO par_psql_result4 SELECT id,hailstone4(value)
    FROM par_psql_test where id%4=3; --&

\echo 'Joining results.'

CREATE UNLOGGED TABLE par_psql_result AS 
  SELECT * FROM par_psql_result1 UNION 
  SELECT * FROM par_psql_result2 UNION 
  SELECT * FROM par_psql_result3 UNION 
  SELECT * FROM par_psql_result4; 

\echo 'Benchmark finished.'

select 'Done';

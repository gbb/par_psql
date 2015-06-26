par_psql v0.1: Parallel ‘psql’. 
------------------------------

*Run parallel queries and workflows inline in PostgreSQL’s psql tool.*
*Useful for ‘slightly big data’, GIS.*

Hi everyone!

http://github.com/gbb/par_psql/             

This is a tool (par_psql) which makes parallelisation easier for postgres/psql users, by providing a new piece of syntax.


How to use it
-------------

When you start writing --& at the end of your queries or groups of queries, they are run in parallel.
When you stop writing --&, the script synchronises (waits for everything to complete) and then serial behaviour resumes as normal.

This allows easy control of parallelism and synchronisation inline within your SQL script.

par_psql is a wrapper around psql, so it should be fully compatible with existing scripts and use cases. The degree of parallelism can be limited manually or automatically via e.g. pgbouncer.

Quick example
-------------

```
create table a as ...
create table a1 as ...  --&
create table a2 as ...  --&
update table b ...  --&
create table c ...
```

Here, line 1 is run by itself. Lines 2-4 are run in parallel. After they complete, line 5 is run.

To run the script, you just change the command ‘psql’ to ‘par_psql’.
(It’s painful to enter passwords interactively so I recommend using PG_PASSWORD).

```
export PGPASSWORD=xyz123;     psql -h localhost -U username -d mydb —-file=myscript.sql
export PGPASSWORD=xyz123; par_psql -h localhost -U username -d mydb —-file=myscript.sql
```

The tool is backwards compatible with existing psql scripts (*) and should work with any version of PostgreSQL. The only dependencies are bash and psql. Benchmarks and examples are provided at http://github.com/gbb/par_psql. (I'll add more examples later at http://parpsql.com.)

*   because --&  is a comment in SQL, par_psql scripts will run without modification (or parallelism) in the psql client

Some cool uses
--------------

1. GIS and any other discipline where you prepare diverse source datasets in a workflow before intersecting/integrating them together.

2. Where you have CPU-intensive work, split the work by one field and run in parallel without WAL logging, then join the results. e.g.

```
create temporary table part1 as select myfunc(columns) from table where id%4=0; --&
create temporary table part2 as select myfunc(columns) from table where id%4=1; --&
create temporary table part3 as select myfunc(columns) from table where id%4=2; --&
create temporary table part4 as select myfunc(columns) from table where id%4=3; --&
create table whole as 
select * from part1 union select * from part2 union 
select * from part3 union select * from part4;
```

- It’s a very good idea to have an index on the field you’re splitting on!

- (You can also split the work e.g. by GIS bounding boxes, or using range types, to process parts of a map, or periods of time, in parallel)

3. Preview runs, without delaying the main task.

```
create table smallpreview as select myfunc(columns) from table LIMIT 10000 --&  
create table bigpreview as select myfunc(columns) from table LIMIT 100000; --&  
create table result as select myfunc(columns) from table; --&   — full result
```

(You can use LIMIT or modulo arithmetic or a GIS bounding box to select preview rows (e.g. where id%100=0), LIMIT xxxxx.)


4. Scripts where several tasks must run at fixed times after the script begins (use pg_sleep() and run in parallel).

```
select pg_sleep(3600); select ‘Task 1, begins 1 hour after start of script’; --&
select pg_sleep(7200); select ‘Task 2, begins 2 hours after start of script’; --&
```

To see some examples, you can try the following commands in the distribution directory:

```
./run_benchmark.sh                                   # (see benchmark.sql)
./par_psql --file=example.sql -d par_psql_test       # (see example.sql)
```

The run_benchmark.sh example runs on a 2-core server in 12 seconds (psql) and slightly under 7 seconds (par_psql).

Tips
----

- Use an index if you’re splitting the work by a particular field
- Use a spatial index if you’re using a GIS bounding box to preview or split up the work.
— Use PGPASSWORD to avoid entering your password every time.
- Store the output to a log file if it gets messy.
- Put complex transactions or complex pieces of workflow into functions, and call the function in parallel.


Background/purpose
------------------


At my workplace we do quite a lot of GIS/map work with PostgreSQL and PostGIS, involving large tables and related data (>100GB). This means preprocessing, joining, and postprocessing many heterogenous datasets that are combined with complex workflows. It often means datasets that are so big you have to split them up and run them in batches. This type of work can take days or weeks to run depending on what you're doing. 

The underlying challenge in this type of work comes from the need to sometimes work in parallel (when the work can be divided easily), sometimes work in serial (when it can’t), with clear points of synchronisation in our data workflows where all parallel processes need to complete before continuing. This is a common problem in ‘slightly big data’ workflows. 

To improve performance, I've been writing makefiles and BASH scripts to call psql at appropriate times in parallel. This usually resulted in either: a) lots of psql files b) ugly BASH files with sql in quotes mixed throughout.

It also creates a subtle maintainability problem - it's hard for other people to work out what parts are being run 
in parallel, and more importably, why and when it's safe to do so with future work/changes.

This program solves the problem, by allowing the SQL/GIS analyst to indicate in-line with a small comment to 
parp_sql which tasks can be run in parallel, and where synchronisation points should occur. This is achieved 
with the minimal syntax of '--&'. This is easier to write, and easier to maintain. 

Because the parallelisation functionality is added by an SQL comment, scripts for par_psql are automatically 
backwards compatible with psql. This means you can take all your old psql scripts, mark them up a little 
bit, and run it immediately in parp_sql for huge performance gains. But if you realise you hate huge 
performance gains (or you've introduced a bug by parallelising things wrongly), your code still works immediately in 
psql without needing to change anything back. 

In other words: 

1. Put psql code into par_psql -> it runs in serial.
2. Put par_psql code into par_psql -> it runs in parallel.
3. Put par_psql code into psql -> it runs in serial.


There’s nothing here that couldn’t be done another way using bash, make, parallel, crontabs etc, but the key advantage is simplicity and making the workflow and parallelism inline with the sql queries. 


Current issues, license
-----------------------

The tool is only a few lines of BASH, so there are some limitations, e.g. 

1. Multi-line transactions etc. must be run in ‘serial-mode’ or defined inside a function before use in parallel operation. 
2. You are required to provide your script as a file, not interactively. 
3. Temporary environment settings changed by the script via ‘set’ will not be preserved. You must set them on any line they are needed.
4. There are a couple of grammar quirks which exist in theory but hopefully not too often in practice. For example: the parser won’t pick up this disallowed statement currently if it’s multi-line:

```
  BEGIN TRANSACTION
  ; —&
```

or semi-colons used in comments, alongside a --& marker:

```
  SELECT     —- old code here with semicolon; --& 
  * FROM TABLE;
```

So please keep in mind the tool has been built as a quick hack for easy GIS-style workflows, not as a complete solution for everyone’s needs :-)

It’s available under the postgresql open source license. I am grateful to the Norwegian Forest and Landscape Institute (soon to be integrated into the Norwegian NIBIO Institute) for supporting and open sourcing this and other scripts as a contribution to this year’s FOSS4G Europe Open Source Mapping conference.


Graeme Bell  
grb@skogog-land-skap.no   (remove the hyphens to email me)

http://github.com/gbb/par_psql/ 




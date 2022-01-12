par_psql v0.22 (Jan 12, 2022): Parallel ‘psql’. 
-----------------------------------------------

Hi! This tool (par_psql) makes parallelisation easier for postgresql/psql, by providing in-line syntax for manual parallelisation.

It's useful if you have large GIS / data workloads to run, and you want to quickly modify them to run on multiple threads/cores.

News
----

*Latest news (12th January 2022): Good lord, it's been 6 years without an update! Three contributed bugfixes have been merged.*

How to use it
-------------

When you start writing --& at the end of your queries or groups of queries, they are run in parallel.
When you stop writing --&, the script synchronises (waits for everything to complete) and then serial behaviour resumes as normal.

This allows easy control of parallelism and synchronisation inline within your SQL script.

par_psql is a wrapper around psql, so it should be fully compatible with existing scripts and use cases. The degree of parallelism can be limited manually or automatically via e.g. pgbouncer. There is one extra option: you can also use --parpsqlversion to get the version number of par_psql.

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

Since --&  is a comment in SQL, par_psql scripts will run without modification (or parallelism) in the psql client.

How to install it
-------------

In Linux, BSD or MacOS (and perhaps Cygwin for Windows), type this as an admin/root user: 

    git clone https://github.com/gbb/par_psql
    cd par_psql
    ./install.sh

It will be installed into the same directory as 'psql'. 

Some cool uses
--------------

- GIS and any other discipline where you prepare diverse source datasets in a workflow before intersecting/integrating them together.

- Where you have CPU-intensive work, split the work by one field and run in parallel without WAL logging, then join the results. e.g.

```
create unlogged table part1 as select myfunc(columns) from table where id%4=0; --&
create unlogged table part2 as select myfunc(columns) from table where id%4=1; --&
create unlogged table part3 as select myfunc(columns) from table where id%4=2; --&
create unlogged table part4 as select myfunc(columns) from table where id%4=3; --&
create table whole as 
select * from part1 union select * from part2 union 
select * from part3 union select * from part4;
```

It’s a very good idea to have an index on the field you’re splitting on! 
You can also split the work up e.g. by GIS bounding boxes, or using range types, to process parts of a map, or periods of time, in parallel.

- Preview runs, without delaying the main task.

```
create table smallpreview as select myfunc(columns) from table LIMIT 10000 --&  
create table bigpreview as select myfunc(columns) from table LIMIT 100000; --&  
create table result as select myfunc(columns) from table; --&   — full result
```

You could use LIMIT or modulo arithmetic or a GIS bounding box to select preview rows (e.g. where id%100=0), LIMIT xxxxx.

- Scripts where several tasks must run at fixed times after the script begins (use pg_sleep() and run in parallel).

```
select pg_sleep(3600); select ‘Task 1, begins 1 hour after start of script’; --&
select pg_sleep(7200); select ‘Task 2, begins 2 hours after start of script’; --&
```

Examples
-------

To see some examples, you can try the following commands in the distribution directory:

```
./run_benchmarks.sh                                  # (see benchmarks/*.sql)
./par_psql --file=example.sql -d par_psql_test       # (see example.sql)
```

Some example benchmarks, 4-way parallelism, SSD+ software RAID, Xeon E3 4Ghz, taken July 2nd 2015 using the 
v0.2 edition of par_psql.

|PG 9.3.7 benchmarks|Description|psql|par_psql|
|:---:|:-------:|:----:|:------:|
|1|SELECT with where clause, 10 million rows (work is in memory)|185s|52s|
|2|pl/pgsql static function calls on 200000 rows |62s|16s|
|3|overhead - 4 groups of empty queries with synchronisation points|0.012s|0.220s|

Observations from results
-------
- CPU-intensive queries parallelise superbly.
- CPU-intensive pgsql functions parallelise superbly (if declared 'STATIC'). 
- The cost of (par_psql + parallel sessions + synchronisation waits) is low (50ms total to run a group of parallel queries and synchronise them). 

More benchmarking information here: [BENCHMARKS.md](https://github.com/gbb/par_psql/blob/master/BENCHMARKS.md)


Tips
----

- Use an index if you’re splitting the work by a particular field
- Use a spatial index if you’re using a GIS bounding box to preview or split up the work.
— Use PGPASSWORD to avoid entering your password every time.
- Store the output to a log file if it gets messy.
- Put complex transactions or complex pieces of workflow into functions, and call the function in parallel.
- Use UNLOGGED tables rather than TEMPORARY tables because temporary tables can't be shared between parallel sessions in postgres.


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

See Also
--------

- [pmpp: Poor Man's Parallel Processing](https://github.com/moat/pmpp).
Corey Huinker had the awesome idea of using dblink async as a foundation for distributing queries. This allows  parallelisation at the query level and across multiple dbs. PMPP requires a little bit more syntax, but it is capable of addressing a wider range of parallelisation cases than par_psql. Check it out! A very cool project.

- A presentation on 'easy parallel programming' given at FOSS4G Como & FOSS4G Norway: http://graemebell.net/foss4gcomo.pdf.



Graeme Bell  
xg--i--tx@graemebell.net   (remove the hyphens to email me)

http://github.com/gbb/par_psql/ 

http://parpsql.graemebell.net (was previously parpsql.com )



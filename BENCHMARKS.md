Benchmarks
----------

Some example benchmarks, 4-way parallelism, SSD+ software RAID, Xeon E3 4Ghz, taken July 2nd 2015 using the 
v0.2 edition of par_psql.

Please note, these benchmark routines are not official in any sense, they're just some timing tests I have quickly 
made up to look at CPU-constrained and pgplsql performance as well as program overhead. The benchmarks have been 
implemented with 4-way parallelism.

|PG 9.3.7 benchmarks|Description|psql|par_psql|
|:---:|:-------:|:----:|:------:|
|1|SELECT with where clause, 10 million rows (work is in memory)|185s|52s|
|2|pl/pgsql function calls on 200000 rows (work is in memory)|86s|45s|
|3|overhead - 4 groups of empty queries with synchronisation points|0.012s|0.220s|

|PG 9.4.4 benchmarks|Description|psql|par_psql|
|:---:|:-------:|:----:|:------:|
|1|SELECT with where clause, 10 million rows (work is in memory)|185s|52s|
|2|pl/pgsql function calls on 200000 rows (work is in memory)|77s|33s|
|3|overhead - 4 groups of empty queries with synchronisation points|0.015s|0.228s|

Observations from results
-------
- CPU-intensive queries parallelise superbly.
- CPU-intensive pgsql functions parallelise but less well.
- The cost of (par_psql + parallel sessions + synchronisation waits) is low (50ms total to run a group of parallel querie$

Re: pl/pgsql - some further results.

|PG 9.4.4 benchmarks|Description|psql|par_psql|
|:---:|:-------:|:----:|:------:|
|2b|pl/pgsql function calls on 200000 rows (independent output tables)|76s|32s|
|2c|pl/pgsql function calls on 200000 rows (separately defined functions)|76s|35s|
|2d|pl/pgsql function calls on 200000 rows (independent input+output tables)|76s|31s|

The pgsql results are interesting, there seems to be a limit in postgres's ability to parallelise any running 
pl/pgsql code (I've seen that before in another project where only 2x parallelism was achieved in place of 8x when 
many pl/pgsql calls were running).




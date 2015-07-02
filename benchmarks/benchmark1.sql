\echo 'Starting batch 1/4.'

select count(a.id) from bm a, bm b where a.md5=b.md5 and a.id%4=0; --&

\echo 'Starting batch 2/4.'

select count(a.id) from bm a, bm b where a.md5=b.md5 and a.id%4=1; --&

\echo 'Starting batch 3/4.'

select count(a.id) from bm a, bm b where a.md5=b.md5 and a.id%4=2; --& 

\echo 'Starting batch 4/4.'

select count(a.id) from bm a, bm b where a.md5=b.md5 and a.id%4=3; --&

\echo 'Benchmark finished.'


\echo 'An estimate of par_psql overhead. 4 runs of 9 parallel threads with synchronisation points.'

select 4; --&
select 4; --&
select 4; --&
select 4; --&

select 1;

select 4; --&
select 4; --&
select 4; --&
select 4; --&

select 1;

select 4; --&
select 4; --&
select 4; --&
select 4; --&

select 1;

select 4; --&
select 4; --&
select 4; --&
select 4; --&

select 1;

select 'Done';

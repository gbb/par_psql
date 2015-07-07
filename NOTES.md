- It's important to have indices if you don't want heaps of sequential scans running together.
- Use PGPASSWORD to avoid logging in (or set up pg_hba for local logins without passwords)
- Limit parallelism to be similar to the number of CPUs.
- If you are writing out lots of rows, pick an appropriately fast/parallel storage system e.g. high-end SSDs, RAID.

- If you ever see a warning about 'relation XYZ does not exist' from your SQL scripts, it's probably because you used a temporary table somewhere or because you used the 'search_path' environment setting.
- For temporary tables: just change to unlogged tables instead, because temporary tables can't be shared between different db sessions e.g. you can't do parallel programming with them. Make sure you drop the unlogged tables at the end, because unlogged tables are not dropped automatically (unlike temporary tables). I will add a new warning message to detect accidental use of temporary tables, as soon as I can.
- If you were using 'set search_path' in your script: just use the full schema.domainname format for naming tables. e.g. public.mytable, schema1.table1, instead of simply 'table1'. Or remove the 'set search_path' statement from your script; or move it to your .psqlrc file so that it runs every time psql is used.

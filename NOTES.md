- It's important to have indices if you don't want heaps of sequential scans running together.
- Use PGPASSWORD to avoid logging in (or set up pg_hba for local logins without passwords)
- Limit parallelism to be similar to the number of CPUs.
- If you are writing out lots of rows, pick an appropriately fast/parallel storage system e.g. high-end SSDs, RAID.


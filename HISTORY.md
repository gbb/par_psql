Changelog
----

0.22 - Change summary.

       - Bugfix: now returns error status correctly if the script aborts
       during execution. (thanks to https://github.com/harrybiddle!)

       - Bugfix: now detects use of single transaction mode and aborts 
       script with error message & status (also harrybiddle).

       - Bugfix: no longer accidentally recognises e.g. 'transaction_id' 
       column as 'transaction' keyword (thanks to https://github.com/gugaiz!)

       - Maintainer note: I am *delighted* that people noticed & patched 
       bugs on a repo that's 6 years since the last update. Thank you both!


0.21 - Change summary.

      1. par_psql now works on MacOS/BSD.

      2. Benchmarks etc. now run even if you haven't installed par_psql yet.

      3. Documentation updates.

      4. Bugfixes as follows:

      - This corrects a bug in the bash tests '[[ ]]' - they were using string 
     comparison instead of integer. This was affecting MacOS and 
     probably other BSDs - probably the locale settings in Linux made it 
     unnoticeable previously. Par_psql is now tested and working with
     Postgresql 9.5 on Macos El Capitan (10.11). 

      - Removed -V from 'sort' in the benchmarks, this option doesn't exist
     in MacOS's sort shell command.

      - Updated the program name in run_benchmarks to "../par_psql", since users
       may not have installed it to their path before running a benchmark test.

      - Updated contact information.

      - Renamed the 'error detection' testing script to make its purpose more obvious.

      - Added a note that to run tests you must have createdb permission.

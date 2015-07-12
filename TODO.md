Add a check for TEMPORARY TABLE occuring anywhere.
It won't be preserved inside a parallel block, has to be rewritten as UNLOGGED.

Add a check for 'set' occuring anywhere. issue a warning

Possibly add a check for people to mention a database on the command line.

#!/bin/bash

# tests

DBNAME=par_psql_tests

createdb $DBNAME

echo "BEGIN; --& " > /tmp/$DBNAME 
./par_psql --file=/tmp/$DBNAME -d $DBNAME

echo "SELECT --& " > /tmp/$DBNAME 
./par_psql --file=/tmp/$DBNAME -d $DBNAME


dropdb $DBNAME
rm /tmp/$DBNAME

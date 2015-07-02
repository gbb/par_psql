#!/bin/bash
# Simple installer for par_psql. 
# G Bell 

# Find out if psql is installed and where
psqltest=$(which psql)

if [ $? = 0 ] ; then 
  # If psql is installed, store par_psql there. 
  installdir=$(dirname $psqltest)
  cp ./par_psql $installdir
  if [ $? = 0 ]; then
    chmod 0755 "$installdir/par_psql"
    echo -en "\nInstallation of par_psql into $installdir was successful.\n"
  else
    echo -en "\nUnable to copy par_psql into $installdir. Installation failed.\n"
  fi
else
  # Otherwise report an error
  echo -en "\n'psql' is needed but not installed. Please install psql and try again.\n"
fi

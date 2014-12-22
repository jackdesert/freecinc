#! /bin/bash

# this script is just a wrapper around taskd so that taskd
# will start up again immediately if it ever dies
#
# The proper way to invoke this script is to call
#   `nohup script/run_taskd_indefinitely.sh &`


# Make sure $TASKDDATA is set
if [ -z "$TASKDDATA" ]; then
  echo "ERROR: TASKDDATA not set"
  exit 1
elif [ ! -d "$TASKDDATA" ]; then
  echo "ERROR: TASKDDATA directory does not exist"
  exit 1
else
  echo "REMINDER: call this with 'nohup' and a trailing '&'"
fi

while true; do
  /usr/local/bin/taskd server
  sleep 7
  echo "taskd restarted `date -u`" >> log/taskd_restart.log
done


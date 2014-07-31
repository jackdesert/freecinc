#! /bin/bash

# this script is just a wrapper around freecinc so that freecinc
# will start up again immediately if it ever dies
# Kind of like what a unicorn server would do
#
# The proper way to invoke this script is to call
#   nohup script/run_freecinc_indefinitely.sh &

# This reminder only displays in the terminal if you forget to invoke with 'nohup'
echo "REMINDER: call this with 'nohup' and a trailing '&'"

while true; do
  cd /home/dev/freecinc
  RACK_ENV=production bundle exec rackup config-freecinc.ru -p 9952
  sleep 10
  echo "freecinc restarted `date`" >> log/freecinc_restart.log
done



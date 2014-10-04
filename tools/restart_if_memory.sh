#! /bin/bash
PROCESS='/usr/local/bin/taskd server'
PID=`pgrep -f "$PROCESS"`
echo pid is $PID

MEM=`cat /proc/$PID/status | awk '/VmRSS/ { print $2}'`
echo mem is $MEM

THRESH=50000
echo mem is $THRESH

if (( $MEM > $THRESH ))
then
  MESSAGE="taskd killed because memory was $MEM kB `date -u`"
  echo $MESSAGE >> /home/dev/freecinc/log/taskd_restart.log
  pkill -f "$PROCESS"
else
  echo taskd memory usage is less than $THRESH kB
fi   

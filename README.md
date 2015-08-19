FreeCinc
========

Setting up your own taskserver takes some effort. Why not share your effort by allowing others to sync with it also?

Live on the web at https://freecinc.com


Starting the web server
-----------------------

### Production Mode
It is recommended that you start freecinc using the wrapper script. That way, if it dies, it is immediately replaced with another

    nohup script/run_freecinc_indefinitely.sh &


### Development Mode

Basic:

    bundle exec freecinc.rb

With auto-reloading:

    bundle exec rerun freecinc.rb --background


Starting Guard-LiveReload
-------------------------

    bundle exec guard -g views


Starting Sass
-------------

    cd /path/to/freecinc && bundle exec sass --watch /path/to/freecinc/public/sass:/path/to/freecinc/public'


Starting taskd on the Server
----------------------------

It is recommended that you start taskd using the wrapper script. That way, if it dies, it is immediately replaced with another

    cd freecinc && nohup script/run_taskd_indefinitely.sh &


Running tests
-------------

    bundle exec rspec


Automate the remote machine sync check
--------------------------------------

The script in tools/restart_unless_sync.go is a remote monitoring service for taskd.
If you make changes to restart_unless_sync.go, build it:

    go build restart_unless_sync.go

Then commit the changes (and the changes to the executable, which is named 'restart_unless_sync') and push them to a remote monitoring server.
Put this in your crontab on the remote monitoring server

    LOG=/home/ubuntu/freecinc/tools/log/go.log
    * * * * * /home/ubuntu/freecinc/tools/bin/restart_unless_sync >> $LOG 2>> $LOG

In order for it to work, you must first set up taskwarrior


Script that kills taskd if the memory usage is too high
-------------------------------------------------------

This script is to be run once a minute from your production server.

    freecinc/tools/restart_if_memory.sh

It is built as a bash script so that it can start up without inducing extra memory penalty (in case the memory is already running out)

FreeCinc
========

Setting up your own [TaskServer](http://taskwarrior.org/docs/taskserver/why.html) takes some effort. By running freecinc on the same server as your TaskServer, you allow others access to sync with your TaskServer. Like sharing is caring. Like free beer. Like love and a handshake.

The original FreeCinc is live on the web at [FreeCinc.com](https://freecinc.com)

Setting up TaskServer
---------------------

Start with the [TaskServer Docs](http://taskwarrior.org/docs/taskserver/setup.html) and get help in the taskwarrior channel on FreeNode.

Once you have your TaskServer syncing with a client, set these variables in config/location.yml:

    install_dir
    pki_dir
    salt

Then start the web server (ideally in development mode the first time so you can see any error messages)


Starting the web server
-----------------------


### Development Mode

Basic:

    bundle exec rackup config-freecinc.ru

With port specified:

    bundle exec rackup config-freecinc.ru -p 9952

With binding to 0.0.0.0 for use in a VM:

    bundle exec rackup config-freecinc.ru -o 0.0.0.0

With auto-reloading:

    bundle exec rerun 'rackup config-freecinc.ru -o 0.0.0.0' --background --pattern '*.rb'


### Production Mode
It is recommended that you start freecinc using the wrapper script. That way, if it dies, it is immediately replaced with another

    nohup script/run_freecinc_indefinitely.sh &


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

It is recommended to run this script once a minute from your production server if you are experiencing occasional memory bloats with taskd:

    freecinc/tools/restart_if_memory.sh

It is built as a bash script so that it can start up without inducing extra memory penalty (in case the memory is already running out)

FreeCinc
========

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

    nohup script/run_taskd_indefinitely.sh &


Running tests
-------------

    bundle exec rspec


Check if taskd is running on a remote machine
---------------------------------------------

The script in tools/port_checker.rb is intended to be a remote monitoring service for taskd.
Put this in your crontab on a separate server
(preferably one that is run by a different company)

    # Check if taskd is running every minute and send email
    TOOLS=/home/dev/freecinc/tools
    * * * * * cd $TOOLS && bash -lc '/home/dev/.rbenv/shims/ruby port_checker.rb' 2>> $TOOLS/log/cronlog >> $TOOLS/log/cronlog

Check if you can sync with a remote machine
-------------------------------------------

Before running this script, you must set up TaskWarrior on the machine that will run this script. 
Then put this in your crontab:

    * * * * *  TOOLS=/home/ubuntu/freecinc/tools && ERROR_LOG=$TOOLS/log/cron.log && cd $TOOLS && /bin/bash -lc '/home/ubuntu/.rbenv/shims/ruby sync_checker.rb' >> $ERROR_LOG 2>> $ERROR_LOG

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

This will return either 0 or 1:

    nc -z -w5 freecinc.com 53589

And this will print that to the display:

    nc -z -w5 freecinc.com 53589; echo $?


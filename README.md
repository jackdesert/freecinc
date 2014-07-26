FreeCinc
========

Starting the web server
-----------------------

    # Production Mode
    cd /path/to/freecinc && RACK_ENV=production bundle exec rackup config-freecinc.ru -p 9952

    # Development Mode
    bundle exec rerun freecinc.rb


Starting Guard-LiveReload
-------------------------

    bundle exec guard -g views


Starting Sass
-------------

    cd /path/to/freecinc && bundle exec sass --watch /path/to/freecinc/public/sass:/path/to/freecinc/public'


Starting taskd on the Server
----------------------------

The version that works with cron:

    * * * * * /usr/local/bin/taskd server --data /home/dev/taskddata --daemon


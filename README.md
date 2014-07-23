FreeCinc
========

Starting the web server
-----------------------

    bundle exec rerun freecinc.rb
    # OR
    bundle exec rackup config-freecinc.ru -p 9952


Starting Guard-LiveReload
-------------------------

    bundle exec guard -g views


Starting Sass
-------------

    cd /path/to/freecinc && bundle exec sass --watch /path/to/freecinc/public/sass:/path/to/freecinc/public'

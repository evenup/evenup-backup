What is it?
===========

Puppet module to install the ruby backup gem and create jobs to back up various
services and directories.

Released under the Apache 2.0 licence

Usage:
------

To install:
<pre>
  include backups
</pre>

To backup the /opt/myapp/logs and /var/log/ directories at 4:25 every day:
<pre>
  backups::archive { 'logs'
    path    => [ '/opt/myapp/logs', '/var/log' ],
    hour    => 4,
    minute  => 25,
  }
</pre>

To backup a development Riak install:
<pre>
  backups::archive { 'dev-riak'
    mode    => 'dev',
    hour    => 4,
    minute  => 25,
  }
</pre>

Contribute:
-----------
* Fork it
* Create a topic branch
* Improve/fix (with spec tests)
* Push new topic branch
* Submit a PR

# == Define: backups::riak
#
# This define will create a backup job for a riak node or riak dev instance.
#
# === Parameters
#
# [*hour*]
#   Integer.  This controls the hour of the cron entry job
#
# [*minute*]
#   Integer.  This controls the minute of the cron entry job
#
# [*mode*]
#   String.  Valid options are dev or prod.
#     * dev:  backs up the 4 node dev instance provided by the riakdev module
#     * prod: backs up the single node prod instance provided by the riak module
#
# [*keep*]
#   Integer.  Number of backups to keep for this job.
#   Defaults to 0.  If set to 0, specific job retention is not set and system default is used
#
# [*enable*]
#   Boolean.  Is the backup cron entry enabled?
#   Defaults to true
#
# [*tmp_path*]
#   String. Sets the tmp directory for the backup job
#
# === Examples
#
# * Installation:
#     backups::riak {
#       hour    => 4,
#       minute  => 25,
#       mode    => 'dev',
#       enable  => true;
#     }
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
# === Copyright
#
# Copyright 2012 EvenUp.
#
define backups::riak (
  $hour,
  $minute,
  $mode,
  $keep     = 0,
  $enable   = true,
  $tmp_path = '/tmp',
){

  include backups
  Class['backups'] ->
  Backups::Riak[$name]

  $ensure = $enable ? {
    true    => 'present',
    default => 'absent',
  }

  concat {
    "/etc/backup/models/${name}.rb":
      owner => root,
      group => admin,
      mode  => 0440;
  }

  concat::fragment {
    "backup_riak_header_${name}":
      target  => "/etc/backup/models/${name}.rb",
      content => template('backups/job_header.erb'),
      order   => 01;

    "backups_riak_${name}":
      target  => "/etc/backup/models/${name}.rb",
      content => template('backups/job_riak.erb'),
      order   => 20;

    "backup_riak_footer_${name}":
      target  => "/etc/backup/models/${name}.rb",
      content => template('backups/job_footer.erb'),
      order   => 99;
  }

  case $::disposition {
    'vagrant':  {
      $cron_ensure = 'absent'
    }
    default  :  {
      $cron_ensure = $enable ? {
        true    => 'present',
        default => 'absent',
      }
    }
  }

  $tmp = $tmp_path ? {
    ''      => '',
    default => "--tmp-path ${tmp_path}"
  }

  cron {
    "riak_${name}":
      ensure  => $cron_ensure,
      command => "cd /opt/backup ; ./bin/backup perform --trigger ${name} -c /etc/backup/config.rb -l /var/log/backup/ ${tmp}",
      user    => 'root',
      hour    => $hour,
      minute  => $minute;
  }

}

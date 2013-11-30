# == Define: backups::mongodb
#
# This define will create a backup job for a mongodb node or mongodb dev instance.
#
# === Parameters
#
# [*hour*]
#   Integer.  This controls the hour of the cron entry job
#
# [*minute*]
#   Integer.  This controls the minute of the cron entry job
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
#     backups::mongodb {
#       hour    => 4,
#       minute  => 25,
#       mode    => 'dev',
#       enable  => true;
#     }
#
# === Authors
#
# * Sam Bashton <mailto:sam@bashton.com>
#
# === Copyright
#
# Copyright 2013 Bashton Ltd
#
define backups::mongodb (
  $hour,
  $minute,
  $dbname,
  $dbhost      = 'localhost',
  $username    = undef,
  $password    = undef,
  $collections = undef,
  $keep        = 0,
  $enable      = true,
  $tmp_path    = '/tmp',
  $port        = '27017',
  $lock        = false,
  $oplog       = false,
){

  include backups
  Class['backups'] ->
  Backups::Mongodb[$name]

  $ensure = $enable ? {
    true    => 'present',
    default => 'absent',
  }

  concat {
    "/etc/backup/models/${name}.rb":
      owner => 'root',
      group => 'root',
      mode  => 0440;
  }

  concat::fragment {
    "backup_mongodb_header_${name}":
      target  => "/etc/backup/models/${name}.rb",
      content => template('backups/job_header.erb'),
      order   => 01;

    "backups_mongodb_${name}":
      target  => "/etc/backup/models/${name}.rb",
      content => template('backups/job_mongodb.erb'),
      order   => 20;

    "backup_mongodb_footer_${name}":
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
    "mongodb_${name}":
      ensure  => $cron_ensure,
      command => "cd /opt/backup ; ./bin/backup perform --trigger ${name} -c /etc/backup/config.rb -l /var/log/backup/ ${tmp}",
      user    => 'root',
      hour    => $hour,
      minute  => $minute;
  }

}

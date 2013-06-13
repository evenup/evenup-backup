# == Define: backups::archive
#
# This define will create a backup job for files located on disk
#
# === Parameters
#
# [*path*]
#   String.   The path that should be archived
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
# [*tmp_path*]
#   String. Sets the tmp directory for the backup job
#
# === Examples
#
# * Installation:
#     backups::archive {
#       path    => '/path/to/files',
#       hour    => 4,
#       minute  => 25;
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
define backups::archive(
  $path,
  $hour,
  $minute,
  $keep = 0,
  $tmp_path = '/tmp',
){

  include backups
  Class['backups'] ->
  Backups::Archive[$name]

  concat {
    "/etc/backup/models/${name}.rb":
      owner => root,
      group => admin,
      mode  => 0440;
  }

  concat::fragment {
    "backup_archive_header_${name}":
      target  => "/etc/backup/models/${name}.rb",
      content => template('backups/job_header.erb'),
      order   => 01;

    "backups_archive_${name}":
      target  => "/etc/backup/models/${name}.rb",
      content => template('backups/job_archive.erb'),
      order   => 02;

    "backup_archive_footer_${name}":
      target  => "/etc/backup/models/${name}.rb",
      content => template('backups/job_footer.erb'),
      order   => 99;
  }

  $cron_ensure = $::disposition ? {
    'vagrant' => absent,
    default   => present
  }

  $tmp = $tmp_path ? {
    ''      => '',
    default => "--tmp-path ${tmp_path}"
  }

  cron {
    "archive_${name}":
      ensure  => $cron_ensure,
      command => "cd /opt/backup ; ./bin/backup perform --trigger ${name} -c /etc/backup/config.rb -l /var/log/backup/ ${tmp}",
      user    => 'root',
      hour    => $hour,
      minute  => $minute;
  }
}

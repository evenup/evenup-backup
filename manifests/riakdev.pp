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
# [*numNodes*]
#   Integer.  Number of riak dev nodes
#   Default: 3
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
#       enable  => true;
#     }
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
# === Copyright
#
# Copyright 2014 EvenUp.
#
define backups::riakdev (
  $hour,
  $minute,
  $numNodes = 3,
  $keep     = 0,
  $enable   = true,
  $tmp_path = '/tmp',
){

  include backups
  Class['backups'] ->
  Backups::Riakdev[$name]

  if !is_integer($numNodes) {
    fail("numNodes for ${name} must be an integer")
  }

  $bad_chars = '\.\\\/-'
  $name_real = regsubst($name, "[${bad_chars}]", '_', 'G')

  $ensure = $enable ? {
    true    => 'present',
    default => 'absent',
  }

  file { "/etc/backup/models/${name}.rb":
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => template("${module_name}/job_header.erb", "${module_name}/job_riakdev.erb", "${module_name}/job_footer.erb"),
    require => Class['backups'],
  }

  $cron_ensure = $enable ? {
    true    => 'present',
    default => 'absent',
  }

  $tmp = $tmp_path ? {
    ''      => '',
    default => "--tmp-path ${tmp_path}"
  }

  cron { "riak_${name}":
    ensure  => $cron_ensure,
    command => "cd /opt/backup ; ./bin/backup perform --trigger ${name_real} -c /etc/backup/config.rb -l /var/log/backup/ ${tmp} --quiet",
    user    => 'root',
    hour    => $hour,
    minute  => $minute;
  }

}

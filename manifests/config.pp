# == Class: backup::config
#
# Configures the backup application
#
class backup::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { '/etc/backup':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0550',
    purge   => $::backup::purge_jobs,
    force   => $::backup::purge_jobs,
    recurse => $::backup::purge_jobs,
  }

  file { '/etc/backup/models':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0550',
    require => File['/etc/backup'],
  }

  file { '/etc/backup/config.rb':
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => template('backup/config.rb.erb'),
  }

  file { '/var/log/backup':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0555',
  }

}
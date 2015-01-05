# == Class: backup::install
#
# Installs the backup gem (and dependencies if desired)
#
class backup::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::backup::install_dependencies {
    package { $::backup::package_dependencies:
      ensure => 'installed',
      before => Package['rubygem-backup'],
    }
  }

  package { 'rubygem-backup':
    ensure   => $::backup::ensure,
    name     => $::backup::package_name,
    provider => $::backup::package_provider,
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

  file { '/var/log/backup':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0555',
  }

}
# == Class: backup
#
# This class installs the backup scripts and defines for adding specific
# backup jobs on a node.
#
# === Parameters
#
# === Examples
#
# * Installation:
#     class { 'backup': }
#
class backup (
  # Package options
  $ensure               = $::backup::params::ensure,
  $package_name         = $::backup::params::package_name,
  $package_provider     = $::backup::params::package_provider,
  $install_dependencies = $::backup::params::install_dependencies,
  $package_dependencies = $::backup::params::package_dependencies,
  $purge_jobs           = $::backup::params::purge_jobs,
  ) inherits backup::params {

  class { 'backup::install': } ~>
  class { 'backup::config': }

}

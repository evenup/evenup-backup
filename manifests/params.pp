# == Class: backup::params
#
# Sets the default parameters for the module
#
class backup::params {
  $ensure               = 'latest'
  $package_name         = 'backup'
  $package_provider     = 'gem'
  $install_dependencies = true
  $purge_jobs           = true
  case $::osfamily {
    'RedHat': {
      $package_dependencies = ['ruby-devel', 'libxslt-devel', 'libxml2-devel', 'gcc-c++']
    }
    'Debian': {
      $package_dependencies = ['ruby-dev', 'libxslt1-dev', 'libxml2-dev', 'g++', 'patch']
    }
    default: {
      fail("${::osfamily} not supported by backups")
    }
  }
}

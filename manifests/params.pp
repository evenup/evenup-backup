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

      # Ruby 1.9.3 is needed for backup
      if versioncmp($::operatingsystemmajrelease, '6') < 1 {
        fail("${::operatingsystem} >= 7 is required")
      }
    }
    'Debian': {
      $package_dependencies = ['ruby-dev', 'libxslt1-dev', 'libxml2-dev', 'g++', 'patch']
      if $::lsbmajordistrelease {
        $releaseversion = $::lsbmajordistrelease
      }
      elsif $::lsbmajdistrelease {
        $releaseversion = $::lsbmajdistrelease
      }
      if versioncmp($releaseversion, '12.04') < 1 {
        fail("${::operatingsystem} >= 14.04 is required")
      }
    }
    default: {
      fail("${::osfamily} not supported by backups")
    }
  }
}

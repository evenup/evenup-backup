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

  ## Storage options
  # Common options
  $storage_type         = undef
  $keep                 = undef
  $split_into           = undef
  $path                 = undef
  # S3
  $aws_access_key       = undef
  $aws_secret_key       = undef
  $bucket               = undef
  $aws_region           = undef
  # Remote storage common
  $storage_username     = undef
  $storage_password     = undef
  $storage_host         = undef
  # FTP
  $ftp_port             = 21
  $ftp_passive_mode     = false

  ## Encryptors
  $encryptor            = undef
  # OpenSSL
  $openssl_password     = undef

  ## Compressors
  $compressor           = undef
  $level                = undef

  ## Notifiers
  # Email
  $enable_email         = false
  $email_success        = false
  $email_warning        = true
  $email_failure        = true
  $email_from           = undef
  $email_to             = undef
  $relay_host           = 'localhost'
  $relay_port           = '25'
  # Hipchat
  $enable_hc            = false
  $hc_success           = false
  $hc_warning           = true
  $hc_failure           = true
  $hc_token             = undef
  $hc_from              = 'Backup'
  $hc_notify            = []
}

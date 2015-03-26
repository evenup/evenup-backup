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

  ## Storage options
  # Common options
  $storage_type         = $::backup::params::storage_type,
  $keep                 = $::backup::params::keep,
  $split_into           = $::backup::params::split_into,
  $path                 = $::backup::params::path,
  # S3
  $aws_access_key       = $::backup::params::aws_access_key,
  $aws_secret_key       = $::backup::params::aws_secret_key,
  $bucket               = $::backup::params::bucket,
  $aws_region           = $::backup::params::aws_region,
  # Remote storage common
  $storage_username     = $::backup::params::storage_username,
  $storage_password     = $::backup::params::storage_password,
  $storage_host         = $::backup::params::storage_host,
  # FTP
  $ftp_port             = $::backup::params::ftp_port,
  $ftp_passive_mode     = $::backup::params::ftp_passive_mode,

  ## Encryptors
  $encryptor            = $::backup::params::encryptor,
  # OpenSSL
  $openssl_password     = $::backup::params::openssl_password,

  ## Compressors
  $compressor           = $::backup::params::compressor,
  $level                = $::backup::params::level,

  ## Notifiers
  # Email
  $enable_email         = $::backup::params::enable_email,
  $email_success        = $::backup::params::email_success,
  $email_warning        = $::backup::params::email_warning,
  $email_failure        = $::backup::params::email_failure,
  $email_from           = $::backup::params::email_from,
  $email_to             = $::backup::params::email_to,
  $relay_host           = $::backup::params::relay_host,
  $relay_port           = $::backup::params::relay_port,
  # Hipchat
  $enable_hc            = $::backup::params::enable_hc,
  $hc_success           = $::backup::params::hc_success,
  $hc_warning           = $::backup::params::hc_warning,
  $hc_failure           = $::backup::params::hc_failure,
  $hc_token             = $::backup::params::hc_token,
  $hc_from              = $::backup::params::hc_from,
  $hc_notify            = $::backup::params::hc_notify,
  ) inherits backup::params {

  class { '::backup::install': } ~>
  class { '::backup::config': }

}

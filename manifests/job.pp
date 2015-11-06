# == Define: backup::job
#
# Creates and schedules a job definition
#
define backup::job (
  $types,
  $description       = undef,
  $hour              = '23',
  $minute            = '05',
  $monthday          = '*',
  $month             = '*',
  $weekday           = '*',
  $ensure            = 'present',
  $utilities         = undef,
  $tmp_path          = '~/Backup/.tmp',
  $before_job        = undef,
  $after_job         = undef,

  ## Backup types
  # Archive
  $add               = undef,
  $exclude           = undef,
  # Multiple databases
  $dbname            = undef,
  $host              = 'localhost',
  $username          = undef,
  $password          = undef,
  $port              = undef,
  # MongoDB
  $collections       = undef,
  $lock              = false,
  # Riak
  $node              = "riak@${::fqdn}",
  $cookie            = 'riak',
  # Redis
  $rdb_path          = '/var/lib/redis/dump.rdb',

  ## Storage options
  # Common options
  $storage_type      = $::backup::storage_type,
  $keep              = $::backup::keep,
  $split_into        = $::backup::split_into,
  $path              = $::backup::path,
  # S3
  $aws_access_key    = $::backup::aws_access_key,
  $aws_secret_key    = $::backup::aws_secret_key,
  $bucket            = $::backup::bucket,
  $aws_region        = $::backup::aws_region,
  # Remote storage common
  $storage_username  = $::backup::storage_username,
  $storage_password  = $::backup::storage_password,
  $storage_host      = $::backup::storage_host,
  # FTP
  $ftp_port          = $::backup::ftp_port,
  $ftp_passive_mode  = $::backup::ftp_passive_mode,

  ## Encryptors
  $encryptor         = $::backup::encryptor,
  # OpenSSL
  $openssl_password  = $::backup::openssl_password,

  ## Compressors
  $compressor        = $::backup::compressor,
  $level             = $::backup::level,

  ## Logging
  # Console
  $console_quiet     = $::backup::console_quiet,
  # File
  $logfile_enabled   = $::backup::logfile_enabled,
  $logfile_path      = $::backup::logfile_path,
  $logfile_max_bytes = $::backup::logfile_max_bytes,
  # Syslog
  $syslog_enabled    = $::backup::syslog_enabled,
  $syslog_ident      = $::backup::syslog_ident,
  $syslog_options    = $::backup::syslog_options,
  $syslog_facility   = $::backup::syslog_facility,
  $syslog_info       = $::backup::syslog_info,
  $syslog_warn       = $::backup::syslog_warn,
  $syslog_error      = $::backup::syslog_error,

  ## Notifiers
  # Email
  $enable_email      = $::backup::enable_email,
  $email_success     = $::backup::email_success,
  $email_warning     = $::backup::email_warning,
  $email_failure     = $::backup::email_failure,
  $email_from        = $::backup::email_from,
  $email_to          = $::backup::email_to,
  $relay_host        = $::backup::relay_host,
  $relay_port        = $::backup::relay_port,
  # Hipchat
  $enable_hc         = $::backup::enable_hc,
  $hc_success        = $::backup::hc_success,
  $hc_warning        = $::backup::hc_warning,
  $hc_failure        = $::backup::hc_failure,
  $hc_token          = $::backup::hc_token,
  $hc_from           = $::backup::hc_from,
  $hc_notify         = $::backup::hc_notify,
){

  if ! defined(Class['backup']) {
    fail('You must include the backup base class before creating a backup job')
  }

  ### This file has 3 sections if you're looking to find a single part
  ## Validation
  ## Variables (except for $_types)
  ## Actual building of job

  $_types = any2array($types)

  if !member(['present', 'absent'], $ensure) {
    fail("[Backup::Job::${name}]: Invalid ensure ${ensure}.  Valid values are present and absent")
  }

  if $utilities and !is_hash($utilities) {
    fail("[Backup::Job::${name}]: Utility paths need to be a hash: {'utility_name' => 'path'}")
  }

  if !member(['archive', 'mongodb', 'riak', 'redis'], $_types) {
    $__types = join($_types, ', ')
    fail("[Backup::Job::${name}]: Invalid types in '${__types}'.  Supported types are archive, mongodb, and riak")
  }

  # Validate archive specific things
  if member($_types, 'archive') {
    if !$add {
      fail("[Backup::Job::${name}]: Files or directories to archive need to be specified with the 'add' parameter")
    }
    if !is_string($add) and !is_array($add) {
      fail("[Backup::Job::${name}]: The add parameter takes either an individual path as a string or an array of paths")
    }
    if !is_string($exclude) and !is_array($exclude) {
      fail("[Backup::Job::${name}]: The exclude parameter takes either an individual path as a string or an array of paths")
    }
  } # Archive

  # Validate database specific things
  if member($_types, 'mongodb') {
    if $port and !is_integer($port) {
      fail("[Backup::Job::${name}]: Invalid port (${port})")
    }
  }

  # Currently only mongo needs these, but other DB types will so breaking it out
  if member($_types, 'mongodb') {
    if !$dbname {
      fail("[Backup::Job::${name}]: dbname is required with this database type")
    }
    if $username and !$password {
      fail("[Backup::Job::${name}]: Database password is required with username")
    }
  }

  # MongoDB
  if member($_types, 'mongodb') {
    if $collections and (!is_string($collections) and !is_array($collections)) {
      fail("[Backup::Job::${name}]: Collections to backup for MongoDB must be a string or array if defined")
    }
    validate_bool($lock)
  } # MongoDB

  # Storage
  if !member(['s3', 'local', 'ftp'], $storage_type) {
    fail("[Backup::Job::${name}]: Currently supported storage types are: ftp, local, and s3")
  }

  if $keep and !is_integer($keep) {
    fail("[Backup::Job::${name}]: If defined, keep must be an integer")
  } # Storage

  if $split_into and !is_integer($split_into) {
    fail("[Backup::Job::${name}]: If split_into is set it must be an integer")
  }

  # local and ftp require path parameter
  if member(['ftp', 'local'], $storage_type) {
    if !$path {
      fail("[Backup::Job::${name}]: Path parameter is required with storage_type => ${storage_type}")
    }
  }

  # S3
  if $storage_type == 's3' {
    if !$aws_access_key or !is_string($aws_access_key) {
      fail("[Backup::Job::${name}]: Parameter aws_access_key is required for S3 storage")
    }

    if !$aws_secret_key or !is_string($aws_secret_key) {
      fail("[Backup::Job::${name}]: Parameter aws_secret_key is required for S3 storage")
    }

    if !$bucket or !is_string($bucket) {
      fail("[Backup::Job::${name}]: S3 bucket must be specified")
    }

    if $aws_region and !member([
      'us-east-1',
      'us-west-2',
      'us-west-1',
      'eu-west-1',
      'eu-central-1',
      'ap-southeast-1',
      'ap-southeast-2',
      'ap-northeast-1',
      'sa-east-1',
    ], $aws_region ) {
      fail("[Backup::Job::${name}]: ${aws_region} is an invalid region")
    }
  } # S3

  if $storage_type == 'ftp' {
    if !$storage_username or !is_string($storage_username) {
      fail("[Backup::Job::${name}]: Parameter storage_username is required for FTP storage")
    }

    if !$storage_password or !is_string($storage_password) {
      fail("[Backup::Job::${name}]: Parameter storage_password is required for FTP storage")
    }

    if !$storage_host or !is_string($storage_host) {
      fail("[Backup::Job::${name}]: Parameter storage_host is required for FTP storage")
    }

    if !$ftp_port or !is_integer($ftp_port) {
      fail("[Backup::Job::${name}]: ftp_port must be an integer.  (Got: ${ftp_port})")
    }

    validate_bool($ftp_passive_mode)
  }

  # Encryptor
  if $encryptor and !member(['openssl'], $encryptor) {
    fail("[Backup::Job::${name}]: Supported encryptors are openssl")
  }

  if $encryptor == 'openssl' {
    if !$openssl_password or !is_string($openssl_password) {
      fail("[Backup::Job::${name}]: 'openssl_password' must be set with encryptor => 'openssl' ")
    }
  }

  # Compressor
  if $compressor and !member(['bzip2', 'gzip'], $compressor) {
    fail("[Backup::Job::${name}]: Supported compressors are bzip2 and gzip")
  }

  if $compressor and $level and (!is_integer($level) or ($level < 1 or $level > 9) ) {
    fail("[Backup::Job::${name}]: The 'level' parameter takes integers from 1 to 9")
  } # compressors

  # Email
  if $enable_email {
    validate_bool($email_success, $email_warning, $email_failure)
    if $email_from {
      validate_re($email_from, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$', "[Backup::Job::${name}]: ${email_from} is not a valid email address")
    }

    if !$email_to {
      fail("[Backup::Job::${name}]: A destination email address is required for email notifications")
    } else {
      validate_re($email_to, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$', "[Backup::Job::${name}]: ${email_to} is not a valid email address")
    }

    if $relay_port and !is_integer($relay_port) {
      fail("[Backup::Job::${name}]: relay_port must be a port number")
    }

  } # Email

  # Hipchat
  if $enable_hc {
    validate_bool($hc_success, $hc_warning, $hc_failure)

    if !$hc_token or !is_string($hc_token) {
      fail("[Backup::Job::${name}]: hc_token is required for hipchat notifications")
    }

    if (!is_string($hc_notify) and !is_array($hc_notify)) or size($hc_notify) < 1 {
      fail("[Backup::Job::${name}]: hc_notify needs to be a room or array of rooms to notify")
    }
  } # Hipchat

  ### Phewh, that was a lot of validation

  $bad_chars = '\.\\\/-'
  $_name = regsubst($name, "[${bad_chars}]", '_', 'G')

  if $description {
    $_description = $description
  } else {
    $_description = "${name} backup"
  }

  if $path {
    $_path = $path
  } else {
    $_path = $::fqdn
  }

  if $email_from {
    $_email_from = $email_from
  } else {
    $_email_from = "backup@${::domain}"
  }

  # Real work
  concat { "/etc/backup/models/${_name}.rb":
    ensure => $ensure,
  }

  # Template uses
  # - $_name
  # - $_description
  concat::fragment { "${_name}_header":
    target  => "/etc/backup/models/${_name}.rb",
    content => template('backup/job/header.erb'),
    order   => '01',
  }

  if $utilities {
    # Template uses
    # - $utilities
    concat::fragment { "${_name}_utilities":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/utilities.erb'),
      order   => '05',
    }
  }

  if $before_job {
    # Template uses
    # - $before_job
    concat::fragment { "${_name}_before":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/before.erb'),
      order   => '06',
    }
  }

  if member($_types, 'archive') {
    # Template uses
    # - $add
    # - $exclude
    concat::fragment { "${_name}_archive":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/archive.erb'),
      order   => '10',
    }
  }
  if member($_types, 'mongodb') {
    # Template uses
    # - $dbname
    # - $username
    # - $password
    # - $port
    # - $lock
    # - $collections
    concat::fragment { "${_name}_mongodb":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/mongodb.erb'),
      order   => '11',
    }
  }
  if member($_types, 'riak') {
    concat::fragment { "${_name}_riak":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/riak.erb'),
      order   => '12',
    }
  }

  if member($_types, 'redis') {
    concat::fragment { "${_name}_redis":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/redis.erb'),
      order   => '12',
    }
  }

  if $compressor == 'bzip2' {
    # Template uses
    # - $level
    concat::fragment { "${_name}_bzip2":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/bzip2.erb'),
      order   => '20',
    }
  } elsif $compressor == 'gzip' {
    # Template uses
    # - $level
    concat::fragment { "${_name}_gzip":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/gzip.erb'),
      order   => '20',
    }
  }

  if $encryptor == 'openssl' {
    # Template uses
    # - $openssl_password
    concat::fragment { "${_name}_openssl":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/openssl.erb'),
      order   => '25',
    }
  }

  if $split_into {
    # Template uses
    # - $split_into
    concat::fragment { "${_name}_split":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/split.erb'),
      order   => '30',
    }
  }

  if $storage_type == 'local' {
    # Template uses
    # - $path
    # - $keep
    concat::fragment { "${_name}_local":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/local.erb'),
      order   => '35',
    }
  } elsif $storage_type == 's3' {
    # Template uses
    # - $aws_access_key
    # - $aws_secret_key
    # - $path
    # - $aws_region
    # - $bucket
    # - $keep
    concat::fragment { "${_name}_s3":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/s3.erb'),
      order   => '35',
    }
  } elsif $storage_type == 'ftp' {
    # Template uses
    # - $server_username
    # - $server_password
    # - $server_ip
    # - $server_port
    # - $server_passive_mode
    # - $path
    # - $keep
    concat::fragment { "${_name}_ftp":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/ftp.erb'),
      order   => '35',
    }
  }

  if $logfile_enabled or $syslog_enabled or $console_quiet {
    # Template uses
    # - $console_quiet
    # - $logfile_enabled
    # - $logfile_path
    # - $logfile_max_bytes
    # - $syslog_enabled
    # - $syslog_ident
    # - $syslog_options
    # - $syslog_facility
    # - $syslog_info
    # - $syslog_warn
    # - $syslog_error
    concat::fragment { "${_name}_logging":
    target  => "/etc/backup/models/${_name}.rb",
    content => template('backup/job/logging.erb'),
    order   => '45',
    }

  }

  if $enable_email {
    # Template uses
    # - $email_success
    # - $email_warning
    # - $email_failure
    # - $email_from
    # - $email_to
    # - $relay_host
    # - $relay_port
    concat::fragment { "${_name}_email":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/email.erb'),
      order   => '50',
    }
  }

  if $enable_hc {
    # Template uses
    # - $hc_success
    # - $hc_warning
    # - $hc_failure
    # - $hc_token
    # - $hc_from
    # - $hc_notify
    concat::fragment { "${_name}_hipchat":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/hipchat.erb'),
      order   => '51',
    }
  }

  if $after_job {
    # Template uses
    # - $after_job
    concat::fragment { "${_name}_after":
      target  => "/etc/backup/models/${_name}.rb",
      content => template('backup/job/after.erb'),
      order   => '06',
    }
  }

  concat::fragment { "${_name}_footer":
    target  => "/etc/backup/models/${_name}.rb",
    content => template('backup/job/footer.erb'),
    order   => '99',
  }

  cron { "${name}-backup":
    ensure   => $ensure,
    command  => "/usr/local/bin/backup perform --trigger ${_name} --config-file '/etc/backup/config.rb' --tmp-path ${tmp_path}",
    minute   => $minute,
    hour     => $hour,
    monthday => $monthday,
    month    => $month,
    weekday  => $weekday,
  }
}

# == Class: backups
#
# This class installs the backup scripts and defines for adding specific
# backup jobs on a node.
#
# === Parameters
#
# === Examples
#
# * Installation:
#     class { 'backups': }
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
# === Copyright
#
# Copyright 2012 EvenUp.
#
class backups {

  require ruby
  include ruby::hipchat
  include ruby::httparty
  include ruby::mail

  # TODO - this should fail if hiera values not defined.  spec tests fail currently though
  $aws_access_key = hiera('backups::aws_access_key', 'undefined')
  $aws_secret_key = hiera('backups::aws_secret_key', 'undefined')
  $bucket = hiera('backups::bucket')
  $password = hiera('backups::password', '')
  $backup_node = regsubst($::hostname, '-', '_')

  # Notifications
  $enable_mail = hiera('backups::enable_mail', false)
  $enable_hc = hiera('backups::enable_hc', false)
  # Putting these in conditionals so spec tests don't freak out.  TODO - fix spec tests
  if $enable_mail {
    $mail_success = hiera('backups::mail_success', false)
    $mail_warning = hiera('backups::mail_warning', true)
    $mail_failure = hiera('backups::mail_failure', true)
    $mail_from = hiera('backups::mail_from', "backups@${::fqdn}")
    $mail_to = hiera('backups::mail_to', "root@${::domain}")
    $mail_address = hiera('backups::mail_address', 'localhost')
    $mail_port = hiera('backups::mail_port', '25')
    $mail_domain = hiera('backups::mail_domain', $::domain)
  }
  if $enable_hc {
    $hc_success = hiera('backups::hc_success', false)
    $hc_warning = hiera('backups::hc_warning', true)
    $hc_failure = hiera('backups::hc_failure', true)
    $hc_token = hiera('backups::hc_token')
    $hc_from = hiera('backups::hc_from', 'Backups')
    $hc_notify = hiera('backups::hc_notify')  # Which rooms to notify, this should be an array
  }

  package {
    # TODO - should these be moved to the ruby class?
    [ 'rubygem-backup', 'rubygem-fog']:
      ensure  => latest;

    'rubygem-excon':
      ensure  => '0.14.3-1.el6';
  }

  file {
    '/etc/backup':
      ensure  => directory,
      owner   => root,
      group   => admin,
      mode    => '0550',
      purge   => true,
      force   => true,
      recurse => true;

    '/etc/backup/models':
      ensure  => directory,
      owner   => root,
      group   => admin,
      mode    => '0550',
      require => File['/etc/backup'];

    '/var/log/backup':
      ensure  => directory,
      owner   => root,
      group   => admin,
      mode    => '0555';

    '/etc/backup/config.rb':
      owner   => root,
      group   => admin,
      mode    => '0440',
      content => template('backups/config.rb');

    # Correct backup for riak: https://github.com/meskyanichi/backup/pull/360
    # Allow setting of riak username and group: https://github.com/meskyanichi/backup/pull/393
    '/usr/lib/ruby/gems/1.8/gems/backup-3.0.27/lib/backup/database/riak.rb':
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => 'puppet:///modules/backups/riak.rb';

    # Allow hipchat rooms_notified to accept comma-delimited string: https://github.com/meskyanichi/backup/pull/392
    # Add hostname to notification message.  No PR currently
    '/usr/lib/ruby/gems/1.8/gems/backup-3.0.27/lib/backup/notifier/hipchat.rb':
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => 'puppet:///modules/backups/hipchat.rb';

    # Hipchat gem dependency bumped to ~> 0.7.0: https://github.com/meskyanichi/backup/pull/391
    '/usr/lib/ruby/gems/1.8/gems/backup-3.0.27/lib/backup/dependency.rb':
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => 'puppet:///modules/backups/dependency.rb';
  }
}

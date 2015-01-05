# == Class: backup::config
#
# Configures the backup application
#
class backup::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { '/etc/backup/config.rb':
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => template('backup/config.rb.erb'),
  }

}
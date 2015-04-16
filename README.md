[![Puppet Forge](http://img.shields.io/puppetforge/v/evenup/backup.svg)](https://forge.puppetlabs.com/evenup/backup)
[![Build Status](https://travis-ci.org/evenup/evenup-backup.png?branch=master)](https://travis-ci.org/evenup/evenup-backup)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with backup](#setup)
    * [What backup affects](#what-backup-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with backup](#beginning-with-backup)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Changelog/Contributors](#changelog-contributors)

## Overview

Puppet module to install the ruby backup gem and create jobs to back up various services and directories.

## Module Description

The ruby backup gem allows backing up files and various databases and optionally compressing, encrypting, and splitting them into smaller chunks, and copying them to remote systems or file storage service.

This module will install the backup gem, but more powerfully allows the creation and scheduling of jobs based on the backup DSL.

A script is provided in the scripts directory to create a standalone RPM with [fpm](https://github.com/jordansissel/fpm/wiki) which includes a global binary to run jobs.

## Setup

### What backup affects

* backup ruby gem
* backup config files
* backup job cron entries

### Setup Requirements

Dependencies to build ruby gems (and backup and it's dependencies specifically) need to be installed for this module.  It can optinally install all needed dependencies from a base system.

### Beginning with backup

To install backup:

```
    puppet module install evenup-backups
```

## Usage

To install the backup gem:

```puppet
    class { 'backup': }
```

Creating a backup job to archive /etc to the local path /backups:

```puppet
    backup::job { 'etc':
      types        => 'archive',
      add          => '/etc',
      storage_type => 'local',
      path         => '/backups',
    }
```

Create a backup job to archive a riak database and its config, compressing, splitting into 1G chunks, and copying to S3 on Sundays at 01:10:

```puppet
    backup::job { 'riak':
      types          => ['archive', 'riak'],
      add            => '/etc/riak',
      cookie         => 'supersecret',
      storage_type   => 's3',
      compressor     => 'bzip2'
      level          => 9,
      split_into     => 1024,
      aws_access_key => 'AWS_ACCESS_KEY',
      aws_secret_key => 'AWS_SECRET_KEY',
      bucket         => 'backup-bucket',
      weekday        => 0,
      hour           => 1,
      minute         => 10,
    }
```

## Reference

### Public Classes

#### 'backup'

##### `ensure`

String.  Whether or not the backup gem should be installed.

Default: latest

##### `package_name`

String.  Name of the package to be installed

Default: backup

##### `package_provider`

String.  Package provider to install the gem

Default: gem

##### `install_dependencies`

Boolean.  Whether or not development dependenceis for building the backup gem should be installed.

Default: true

##### `package_dependencies`

String/Array of Strings.  List of packages to install as development dependencies.

##### `purge_jobs`

Boolean.  Whether or not unmanaged backup jobs should be purged.

Default: true

### Public Defines

#### `backup::job`

Creates backup jobs.

##### `types`

String/Array of Strings.  List of backup types to include in this job.

##### `description`

String.  A description to use for this backup job.

##### `hour`

Cron syntax.  Hour the backup job should be scheduled

Default: 23

##### `minute`

Cron syntax.  Minute the backup job should be scheduled

Default: 5

##### `monthday`

Cron syntax.  Day of the month the backup job should be scheduled

Default: *

##### `month`

Cron syntax.  Month the backup job should be scheduled

Default: *

##### `weekday`

Cron syntax.  Day of the week the backup job should be scheduled

Default: *

##### `ensure`

String.  Whether or not the job should be present

Default: present

##### `utilities`

Hash.  Commands and paths provided as key:value pairs to the location of utility commands if not available in the default path

##### `add`

String/Array of Strings.  Used with the archive backup type, list of paths to be included for backup

##### `exclude`

String/Array of Strings.  Used with the archive backup type, list of paths to be excluded for backup

##### `dbname`

String.  Used with multiple database types, database name to back up

##### `host`

String.  Hostname to back up

Default: localhost

##### `username`

String.  Username to connect to the database as

##### `password`

String.  Password for `username` to use to connect to the database

##### `port`

Integer.  Port to use to connect to the database

##### `collections`

String/Array of Strings.  MongoDB collections to back up

##### `lock`

Boolean.  Whether to enable MongoDB lock when backing up

Default: undef (false)

##### `node`

String.  Used with Riak backups, node name to back up.

Default: riak@${::fqdn}

##### `cookie`

String.  Cookie to be used for riak backups

Default: riak

#####`rdb_path`

String.  Path to the redis database

Default: /var/lib/redis/dump.rdb

##### `storage_type`

String. Type of storage to use for the backup archive

##### `keep`

String. Number of backups to keep on `storage`

##### `split_into`

Integer.  Size (MB) to split individual backup archives into

##### `path`

String.  Path for destination archive

##### `aws_access_key`

String.  AWS access key when using S3 storage type

##### `aws_secret_key`

String.  AWS secret key when using S3 storage type

##### `bucket`

String.  Bucket to store archive when using S3 storage type

##### `aws_region`

String.  Region to store archive when using S3 storage type

##### `encryptor`

String.  Encryptor to use on backup archive

##### `openssl_password`

String.  Password for archive when using OpenSSL encryptor

##### `compressor`

String.  Compressor to use on backup archive

##### `level`

String.  Compression level to use with `compressor`

##### `enable_email`

Boolean.  Enable email notifications

Default: false

##### `email_success`

Boolean.  If email enabled, should successful backups generate an email

Default: false

##### `email_warning`

Boolean.  If email enabled, should backups exiting with warnings generate an email

Default: true

##### `email_failure`

Boolean.  If email enabled, should backups exiting with errors generate an email

Default: true

##### `email_from`

String.  Email address backup job emails should be sent from

##### `email_to`

String.  Email address backup job emails should be sent to

##### `relay_host`

String.  Host backup job notifications should be relayed off of

Default: localhost

##### `relay_port`

Integer.  Port on `relayhost` emails should be sent to

Default: 25

##### `enable_hc`

Boolean.  Whether backup job noticies should be sent to HipChat

Default: false

##### `hc_success`

Boolean.  If HipChat notifications are enabled, should successful backups be posted

Default: false

##### `hc_warning`

Boolean.  If HipChat notifications are enabled, should backup jobs exiting with warning be posted

Default: true

##### `hc_failure`

Boolean.  If HipChat notifications are enabled, should backup jobs exiting with an error be posted

Default: true


##### `hc_token`

String.  HipChat API token

##### `hc_from`

String.  Name backup job alerts should be posted as

Default: Backup

##### `hc_notify`

Array of Strings.  HipChat rooms that should be notified about backup jobs


### Private Classes

* backup::config: Global configuration
* backup::install: Installs packages
* backup::params: Default parameters

## Limitations

* Requires ruby >= 1.9.3

## Development

Improvements and bug fixes are greatly appreciated.  See the [contributing guide](https://github.com/evenup/evenup-backup/blob/master/CONTRIBUTING.md) for
information on adding and validating tests for PRs.

## Changelog / Contributors

[Changelog](https://github.com/evenup/evenup-backup/blob/master/CHANGELOG)
[Contributors](https://github.com/evenup/backup/graphs/contributors)
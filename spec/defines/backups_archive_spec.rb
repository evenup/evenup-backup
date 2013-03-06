require 'spec_helper'

describe 'backups::archive', :type => :define do
  let(:title) { 'test_archive' }
  let(:params) { { :path => '/var/path', :hour => 03, :minute => 34, :keep => 10 } }
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

  it { should contain_concat('/etc/backup/models/test_archive.rb') }
  it { should contain_cron('archive_test_archive').with(
    'command' => '/usr/bin/backup perform --trigger test_archive -c /etc/backup/config.rb -l /var/log/backup/ --tmp-path /tmp',
    'hour'    => 03,
    'minute'  => 34
  ) }

end

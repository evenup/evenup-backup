require 'spec_helper'

describe 'backups::archive', :type => :define do
  let(:title) { 'test_archive' }
  let(:facts) { { :fqdn => 'myhost' } }
  let(:params) { { :path => '/var/path', :hour => 03, :minute => 34, :keep => 10 } }

  it { should contain_file('/etc/backup/models/test_archive.rb') }
  it { should contain_cron('archive_test_archive').with(
    'command' => 'cd /opt/backup ; ./bin/backup perform --trigger test_archive -c /etc/backup/config.rb -l /var/log/backup/ --tmp-path /tmp --quiet',
    'hour'    => 03,
    'minute'  => 34
  ) }
  it { should contain_file('/etc/backup/models/test_archive.rb').with(:content => /Backup::Model\.new\(:test_archive, \"host backup\"\) do/ ) }
  it { should contain_file('/etc/backup/models/test_archive.rb').with(:content => /s3\.path\s+= \"myhost\"/ ) }

end

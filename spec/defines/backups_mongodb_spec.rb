require 'spec_helper'

describe 'backups::mongodb', :type => :define do
  let(:title) { 'test_mongo' }

  context 'installing job' do
    let(:params) { { :hour => 03, :minute => 34, :dbname => 'test' } }
    it { should contain_file('/etc/backup/models/test_mongo.rb') }
    it { should contain_cron('mongodb_test_mongo').with(
      'command' => 'cd /opt/backup ; ./bin/backup perform --trigger test_mongo -c /etc/backup/config.rb -l /var/log/backup/ --tmp-path /tmp --quiet',
      'hour'    => 03,
      'minute'  => 34
    ) }
  end

  context "when enable => false" do
    let(:params) { { :hour => 03, :minute => 34, :enable => false, :dbname => 'test' } }
    it { should contain_cron('mongodb_test_mongo').with('ensure' => 'absent') }
  end

  context 'contain header and footer' do
    let(:params) { { :hour => 03, :minute => 34, :dbname => 'test' } }
    let(:facts) { { :fqdn => 'myhost' } }
      it { should contain_file('/etc/backup/models/test_mongo.rb').with(:content => /Backup::Model\.new\(:test_mongo, \"host backup\"\) do/ ) }
      it { should contain_file('/etc/backup/models/test_mongo.rb').with(:content => /s3\.path\s+= \"myhost\"/ ) }
  end

end

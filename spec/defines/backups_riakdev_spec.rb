require 'spec_helper'

describe 'backups::riakdev', :type => :define do
  let(:title) { 'test_riak' }

  context 'installing job' do
    let(:params) { { :hour => 03, :minute => 34 } }
    it { should contain_file('/etc/backup/models/test_riak.rb') }
    it { should contain_cron('riak_test_riak').with(
      'command' => 'cd /opt/backup ; ./bin/backup perform --trigger test_riak -c /etc/backup/config.rb -l /var/log/backup/ --tmp-path /tmp --quiet',
      'hour'    => 03,
      'minute'  => 34
    ) }
  end

  context "when enable => false" do
    let(:params) { { :hour => 03, :minute => 3, :enable => false } }
    it { should contain_cron('riak_test_riak').with('ensure' => 'absent') }
  end

  context 'contain header and footer' do
    let(:params) { { :hour => 03, :minute => 34 } }
    let(:facts) { { :fqdn => 'myhost' } }
    it { should contain_file('/etc/backup/models/test_riak.rb').with(:content => /Backup::Model\.new\(:test_riak, \"host backup\"\) do/ ) }
    it { should contain_file('/etc/backup/models/test_riak.rb').with(:content => /s3\.path\s+= \"myhost\"/ ) }
  end

  context 'with 2 nodes' do
    let(:params) { { :hour => 03, :minute => 34, :numNodes => 2 } }
    # Config archive
    it { should contain_file('/etc/backup/models/test_riak.rb').with(:content => /archive\.add \"\/var\/lib\/riak\/dev1\/etc\"/ ) }
    it { should contain_file('/etc/backup/models/test_riak.rb').with(:content => /archive\.add \"\/var\/lib\/riak\/dev2\/etc\"/ ) }
    it { should_not contain_file('/etc/backup/models/test_riak.rb').with(:content => /archive\.add \"\/var\/lib\/riak\/dev3\/etc\"/ ) }

    # DB job
    it { should contain_file('/etc/backup/models/test_riak.rb').with(:content => /database Riak, :dev1 do \|db\|/ ) }
    it { should contain_file('/etc/backup/models/test_riak.rb').with(:content => /database Riak, :dev2 do \|db\|/ ) }
    it { should_not contain_file('/etc/backup/models/test_riak.rb').with(:content => /database Riak, :dev3 do \|db\|/ ) }
  end

end

require 'spec_helper'

describe 'backups::riak', :type => :define do
  let(:title) { 'test_riak' }
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

  context 'installing job' do
    let(:params) { { :hour => 03, :minute => 34, :mode  => 'dev' } }
    it { should contain_concat('/etc/backup/models/test_riak.rb') }
    it { should contain_cron('riak_test_riak').with(
      'command' => 'cd /opt/backup ; ./bin/backup perform --trigger test_riak -c /etc/backup/config.rb -l /var/log/backup/ --tmp-path /tmp',
      'hour'    => 03,
      'minute'  => 34
    ) }
  end

  context "when enable => false" do
    let(:params) { { :hour => 03, :minute => 34, :mode  => 'dev', :enable => false } }
    it { should contain_cron('riak_test_riak').with('ensure' => 'absent') }
  end

end

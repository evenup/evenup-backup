require 'spec_helper'
 
describe 'backups::riak', :type => :define do
  let(:title) { 'test_riak' }
  let(:params) { { :hour => 03, :minute => 34, :mode  => 'dev' } }
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

  it { should contain_concat('/etc/backup/models/test_riak.rb') }
  it { should contain_cron('riak_test_riak').with(
    'command' => '/usr/bin/backup perform --trigger test_riak -c /etc/backup/config.rb -l /var/log/backup/',
    'hour'    => 03,
    'minute'  => 34
  ) }
  
  context "when enable => false" do
    let(:params) { { :hour => 03, :minute => 34, :mode  => 'dev', :enable => false } }
    it { should contain_cron('riak_test_riak').with('ensure' => 'absent') }
  end

end

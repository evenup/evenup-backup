require 'spec_helper'

describe 'backup', :type => :class do
  let(:facts) { { :hostname => 'test.mydomain.com', :osfamily => 'RedHat' } }

  describe "class with default parameters" do

    [ '/etc/backup', '/etc/backup/models', '/var/log/backup' ].each do |directory|
      it { should contain_file(directory).with(:ensure => 'directory' ) }
    end

    it { should create_file('/etc/backup/config.rb')}
  end

  context 'not manage jobs' do
    let(:params) { { :purge_jobs => false } }
    it { should contain_file('/etc/backup').with(:purge => false ) }
  end

end

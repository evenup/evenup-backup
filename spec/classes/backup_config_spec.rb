require 'spec_helper'

describe 'backup', :type => :class do
  let(:facts) { { :hostname => 'test.mydomain.com', :osfamily => 'RedHat', :lsbmajordistrelease => '7' } }

  describe "class with default parameters" do

    it { should create_file('/etc/backup/config.rb')}
  end

  context 'not manage jobs' do
    let(:params) { { :purge_jobs => false } }
    it { should contain_file('/etc/backup').with(:purge => false ) }
  end

end

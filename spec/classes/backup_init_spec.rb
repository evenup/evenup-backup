require 'spec_helper'

describe 'backup', :type => :class do
  let(:facts) { { :hostname => 'test.mydomain.com', :osfamily => 'RedHat', :operatingsystemmajrelease => '7' } }

  describe "class with default parameters" do

    it { should create_class('backup') }
    it { should contain_class('backup::install') }
    it { should contain_class('backup::config') }
  end

end

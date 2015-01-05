require 'spec_helper_acceptance'

describe 'backup class' do

  context 'install' do

    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'backup': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('backup') do
      it { should be_installed.by('gem') }
    end
  end

  context 'backup job' do
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'backup': }
      backup::job { 'beaker_job':
        types        => 'archive',
        add          => ['/var/log', '/boot'],
        exclude      => '/var/log/messages',
        storage_type => 'local',
        path         => '/root',
        split_into   => 20
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe command("/usr/local/bin/backup perform --trigger beaker_job --config-file '/etc/backup/config.rb'") do
      its(:exit_status) { should eq 0 }
    end

    describe file('/root/beaker_job') do
      it { should be_directory }
    end

    describe command('ls -l /root/beaker_job/*/beaker_job.tar-aaa') do
      its(:exit_status) { should eq 0 }
    end

    describe command('ls -l /root/beaker_job/*/beaker_job.tar-aab') do
      its(:exit_status) { should eq 0 }
    end

  end

end

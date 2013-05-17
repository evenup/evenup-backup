#!/bin/bash

# Clone the repo
git clone https://github.com/meskyanichi/backup.git

cd backup

# Set up bundler
sed -i "3i $: << File.join(File.dirname(__FILE__), '..',  \"lib\")" lib/backup.rb
sed -i "5i require 'rubygems'" lib/backup.rb
sed -i "6i require 'bundler/setup'" lib/backup.rb
# Add hostname to hipchat output
sed -i '/message = "\[Backup::%s\] #{@model.label} (#{@model.trigger})" % name/c message = "[Backup::%s] #{@model.label} (#{@model.trigger}@#{Socket.gethostname})" % name' lib/backup/notifier/hipchat.rb

# Bundle
bundle install --path=vendor/bundle
bundle install --binstubs
bundle install --standalone
cd ..

# Build the package
fpm \
  -s dir \
  -t rpm \
  -v 3.5.1 \
  --iteration '1' \
  -n rubygem-backup \
  -a noarch \
  --vendor 'LetsEvenUp.com' \
  --maintainer "Justin Lambert" \
  --prefix /opt/backup \
  --rpm-user root \
  --rpm-group root \
  -x opt/backup/.git* \
  -d rubygem-bundler \
  -C backup .


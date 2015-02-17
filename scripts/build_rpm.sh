#!/bin/bash

if [ -z $1 ] ; then
  echo "Please run with version to build:  ${0} <version>"
  exit 1
fi

# Clone the repo
if [ -d backup ] ; then
  cd backup
  git checkout -- lib/backup.rb
  git fetch
else
  git clone https://github.com/meskyanichi/backup.git
  cd backup
fi

git checkout $1

# Set up bundler
sed -i "3i $: << File.join(File.dirname(__FILE__), '..',  \"lib\")" lib/backup.rb

# Bundle
bundle install --standalone
cd ..

mkdir tmp

echo "cat > /usr/local/bin/backup <<EOF" > tmp/install_bin.sh
echo "#!/usr/bin/env ruby" >> tmp/install_bin.sh
echo "# encoding: utf-8" >> tmp/install_bin.sh
echo "" >> tmp/install_bin.sh
echo "$:.unshift File.expand_path '/opt/backup/bundle', __FILE__" >> tmp/install_bin.sh
echo "require 'bundler/setup'" >> tmp/install_bin.sh
echo "load File.expand_path '/opt/backup/bin/backup', __FILE__" >> tmp/install_bin.sh
echo "EOF" >> tmp/install_bin.sh
echo "" >> tmp/install_bin.sh
echo "chmod 0555 /usr/local/bin/backup" >> tmp/install_bin.sh

echo "rm -f /usr/local/bin/backup" > tmp/remove_bin.sh
# Build the package
fpm \
  -s dir \
  -t rpm \
  -v ${1} \
  --iteration '1' \
  -n rubygem-backup \
  -a noarch \
  --vendor 'LetsEvenUp.com' \
  --maintainer "Justin Lambert" \
  --prefix /opt/backup \
  --rpm-user root \
  --rpm-group root \
  --after-install tmp/install_bin.sh \
  --after-remove tmp/remove_bin.sh \
  -x opt/backup/.git* \
  -C backup .

rm -rf tmp
#  -d rubygem-bundler \

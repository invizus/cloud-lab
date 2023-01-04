http://apt.puppet.com/

wget http://apt.puppet.com/puppet-release-bullseye.deb

## server:

apt-get install puppetserver

/etc/default/puppetserver set to 1g

## agent:

sudo apt-get install puppet-agent

sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true

## next
https://www.puppet.com/docs/puppet/7/config_files.html

https://www.puppet.com/docs/puppet/5.5/quick_start_sudo.html#install-the-saz-sudo-module
https://www.puppet.com/docs/puppetserver/5.3/configuration.html

## or next
https://www.linode.com/docs/guides/getting-started-with-puppet-6-1-basic-installation-and-setup/
https://forge.puppet.com/modules/puppetlabs/docker/readme


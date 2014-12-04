#! /usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections

apt-get install --assume-yes --fix-missing ntp
echo "server pool.ntp.org" > /etc/ntp.conf
export NTP_SERVER=pool.ntp.org

mkdir -p /home/jenkins/src
pushd /home/jenkins/src
git clone https://git.openstack.org/openstack-infra/system-config
system-config/install_puppet.sh && system-config/install_modules.sh
puppet apply --modulepath=/home/jenkins/src/system-config/modules:/etc/puppet/modules -e \
"class { openstack_project::single_use_slave: install_users => false, ssh_key => \"$( cat $HOME/.ssh/id_rsa.pub | awk '{print $2}' )\" }"
popd


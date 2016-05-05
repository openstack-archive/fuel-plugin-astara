#!/bin/bash

if ! which nova; then
  sudo apt-get -y install python-novaclient
fi

ram=${1:-512}
disk=${2:-3}
vcpus=${3:-1}
flavor_name=${4:-m1.astara}
id=${5:-511}

source /root/openrc

if ! nova flavor-list | awk '{ print $4 }' | grep "^$flavor_name" ; then
	nova flavor-create $flavor_name $id $ram $disk $vcpus
fi

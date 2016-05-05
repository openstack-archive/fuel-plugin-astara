#!/bin/bash -e

if ! which neutron; then
  sudo apt-get -y install python-neutronclient
fi

source /root/openrc

source $(dirname $0)/functions


mgt_name=${1:-"astara_mgmt"}
mgt_prefix=${2:-"fdca:3ba5:a17a:acda::/64"}


net_id="$(neutron net-list | grep " $mgt_name " | awk '{ print $2 }')"
if [[ -z "$net_id" ]]; then
	echo "Creating astara mgt net: $mgt_name"
	net_id=$(neutron net-create $mgt_name | grep " id " | awk '{ print $4 }')
	echo "Created astara mgt net: $net_id"
else
	echo "Found existing astara mgt net: $net_id"
fi

subnet_id="$(neutron subnet-list | grep " $mgt_prefix " | awk '{ print $2 }')"
if [[ -z "$subnet_id" ]]; then
	echo "Creating new astara mgt subnet for $mgt_prefix"
	if [[ "$mgt_prefix" =~ ':' ]]; then
		subnet_create_args="--name astara_mgmt --ip-version=6 --ipv6_address_mode=slaac --enable_dhcp"
	fi
	subnet_id=$(neutron subnet-create $mgt_name $mgt_prefix $subnet_create_args | grep ' id ' | awk '{ print $4 }')

else
	echo "Found existing mgt subnet for $mgt_prefix; $subnet_id"
fi


iniset /etc/astara/orchestrator.ini DEFAULT management_network_id $net_id
iniset /etc/astara/orchestrator.ini DEFAULT management_subnet_id $subnet_id

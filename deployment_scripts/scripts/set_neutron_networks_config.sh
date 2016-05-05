#!/bin/bash -e
# Spin indefinitely until our mgt net and subnet show up in neutron. This will
# be timed out by deployment_tasks if it does not succeed.

source /root/openrc

source $(dirname $0)/functions

if ! which neutron; then
    sudo apt-get -y install python-neutronclient
fi

mgt_name=${1:-"astara_mgmt"}
mgt_prefix=${2:-"fdca:3ba5:a17a:acda::/64"}

while [[ -z "$net_id" ]]; do
	net_id="$(neutron net-list | grep " $mgt_name " | awk '{ print $2 }')"
	if [[ -z "$net_id" ]]; then
		echo "Still waiting on mgt net"
		sleep 1
	else
		echo "Found astara mgt net: $net_id"
		break
	fi
done

while [[ -z "$subnet_id" ]]; do
	subnet_id="$(neutron subnet-list | grep " $mgt_prefix" | awk '{ print $2 }')"
	if [[ -z "$subnet_id" ]]; then
		echo "Still waiting on mgt subnet"
		sleep 1
	else
		echo "Found astara mgt subnet: $subnet_id"
		break
	fi
done

iniset /etc/astara/orchestrator.ini DEFAULT management_network_id $net_id
iniset /etc/astara/orchestrator.ini DEFAULT management_subnet_id $subnet_id

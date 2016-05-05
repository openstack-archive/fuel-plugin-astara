Astara plugin for Mirantis Fuel
===============================

Astara is a network orchestration service designed for provisioning Neutron 
managed virtual network functions in an OpenStack deployment.

Limitations:
------------
	Currently this plugin is not compatible with the following features:

	- Neutron DVR
	- FWaaS
        - LBaaSv1
	- other SDN solutions


Compatible versions:
--------------------

	- Mirantis Fuel 8.0
	- Akanda Astara 8.0

To obtain the plugin:
---------------------

The Astara plugin can be downloaded from the [Fuel Plugin Catalog](
https://www.mirantis.com/products/openstack-drivers-and-plugins/fuel-plugins/).


To install the plugin:
----------------------

- Prepare a clean fuel master node.

- Copy the plugin onto the fuel master node:

		scp astara-fuel-plugin-1.0-1.0.0-0.noarch.rpm root@<Fuel_Master_Node_IP>:/tmp

- Install the plugin on the fuel master node:

		cd /tmp

		fuel plugins --install astara-fuel-plugin-1.0-1.0.0-0.noarch.rpm

- Check the plugin was installed:

		fuel plugins --list


User Guide
----------

To deploy a cluster with the Astara plugin, use the Fuel web UI to deploy an
OpenStack cluster in the usual way, with the following guidelines:

- Create a new OpenStack environment, selecting:

	Liberty on Ubuntu Trusty

	"Neutron with VLAN segmentation" or "Neutron with tunneling segmentation" as the networking setup

- Under the network tab, configure the 'Network' settings for your environment. For example (exact values will
  depend on your setup):

  	Public (External):

	- IP Range: 172.16.0.2 - 172.16.0.126
        - CIDR: 172.16.0.0/24
        - Use VLAN tagging: No
        - Gateway: 172.16.0.1 
	- Floating IP range: 172.16.0.130 - 172.16.0.254


	Management (Management):

- Under the settings tab, make sure the following options are checked:

	"Use Astara Network Orchestrator"

- Under the setting tab, configure Astara Management Service Port, API Port, and Management IPv6 prefix

	- Astara Management IPv6 Prefix
	- Astara Management Service Port
	- Astara API Service Port

- Add nodes 

- Deploy changes


Deployment details
------------------
Deployment of Openstack using Astara Network Orchestrator does the following:

- Configures Nova:

	Enable Metadata Service

	Enable IPv6

	Enables Nova to attach external networks to an VM Instance
	
- Configures Neutron: 

	Disables Metadata Agent, L3 Agent, and DHCP Agent

	Enables Astara API extensions

	Enables Astara service plugin

	Enables Astara core plugin

- Uploads Astara Router Service VM into Openstack Image Service (glance)

- Configure Horizon:

	Enable Astara dashboard extensions

	Configure Astara management service details

- Create Public and Management Networks for Openstack deployment


Known issues
------------

None.

Release Notes
-------------

**1.0.0**

* Initial release of the plugin


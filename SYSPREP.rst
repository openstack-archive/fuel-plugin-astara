*****
Mirantis VirtualBox Configuration 
*****
Virtualbox Configuration on Linux
=================================
Install Virtualbox
------------------

Virtualbox: `<https://www.virtualbox.org/wiki/Linux_Downloads>`_

Download Virtual Box Extensions
::
	% wget http://download.virtualbox.org/virtualbox/<version>/Oracle_VM_VirtualBox_Extension_Pack-<version>-<build>.vbox-extpack

Install Virtual Box Extensions
::
	% sudo VBoxManage extpack install <Extension>

Verify Installation of Extension Pack
::
	% sudo VBoxManage list extpacks

Install Expect and GIT
::
	% sudo apt-get install expect git

Download Mirantis Virtualbox Scripts with VRDE support
::
	% git clone https://github.com/stackforge/fuel-main.git

Download Mirantis Fuel ISO from `<https://www.mirantis.com/products/mirantis-openstack-software/>`_ and copy ISO to fuel-main/virtualbox/iso directory
::
	% cp MirantisOpenStack-7.0.iso ~/fuel-main/virtualbox/iso


Change to virtualbox directory in fuel-main 
::
	% cd fuel-main/virtualbox


Change config.sh parameters for headless install
::
	# Set to 1 to run VirtualBox in headless mode
	headless=1
	skipfuelmenu="yes"

SED CLI commands to change values in config.sh
::
	% sed -i -e "s/headless=0/headless=1/g;" config.sh
	% sed -i -e "s/skipfuelmenu=\"no\"/skipfuelmenu=\"yes\"/g;" config.sh

Deploy Fuel

- For 3 node cluster
::
		% ./launch_8GB.sh
- For 5 node cluster
::
		% ./launch_16GB.sh

This will take about 1/2hr-2hrs depending upon hardware - build image from ISO automated install, docker containers and puppet configuration.

Access Fuel Node via RDP for monitoring of installation process
::
	Master Fuel Node: RDP to port 5000 on the virtualbox server
	Slave Fuel Node: RDP to port 500x on the virtualbox server

Accessing Fuel Nodes via SSH

Mirantis-Operations: `<https://docs.mirantis.com/openstack/fuel/fuel-7.0/operations.html#accessing-the-shell-on-the-nodes>`_

Access of the Mirantis Fuel and Openstack UI via SSH Tunnel Port Forwarding
::
	% ssh <virtualbox_server> -L XXXX:10.20.0.2:8000 -L XXXX:10.20.0.2: -L XXXX:172.16.0.3:443

Clean up of Virtualbox environment
----------------------------------

Modify Virtualbox Script to remove vbox interfaces
::
	% cat << EOF >> fuel-main/virtualbox/actions/clean-previous-installation.sh

	# Delete host-only interfaces
	if [[ "$rm_network" == "0" ]]; then
    	delete_fuel_ifaces
	else
    	delete_all_hostonly_interfaces
	fi

	EOF

Clean up environment
::
	% ./clean.sh


Akanda Installation - Pre Fuel Plugin
=====================================
Upload Akanda-Appliance into Glance
::
	% wget -c http://akandaio.objects.dreamhost.com/akanda_cloud.qcow2
	% glance image-create --name akanda --disk-format qcow2 --container-format bare --file akanda.qcow2 

Install PIP on Openstack Controller Node
::
	% apt-get install python-pip

Install Astara RUG service on the Openstack Controller Instances
::
	% pip install -e git://github.com/stackforge/akanda-rug.git@stable/kilo#egg=akanda-rug

Configuration of Astara-Rug
::
	% mkdir /etc/akanda-rug
	% cp src/akanda-rug/* /etc/akanda-rug

Edit /etc/akanda-rug/rug.ini
::
	[DEFAULT]
	# Debugging Level
	debug=True
	verbose=True
	# Authenication 
	admin_user=<neutron_user>
	admin_password=<neutron_password
	admin_tenant_name=service
	auth_url=http://<keystone_auth_url>:35357/v2.0/
	auth_strategy=keystone
	auth_region=<auth_region>

	# Oslo Messaging
	amqp_url = amqp://<amq_user>:<amq_password>@<amq_host>:/

	# Rabbit (Deprecated)
	rabbit_password = <amq_password>
	rabbit_host = <amq_host>
	rabbit_userid = <amq_user>

	# Astara Configuration
	rug_api_port = 44250
	akanda_mgt_service_port=5000
	reboot_error_threshold = 2
	num_worker_threads = 2
	num_worker_processes = 2
	boot_timeout = 6000

	# 
	management_prefix=fdca:3ba5:a17a:acda::/64
	management_network_id=<neutron_management_net_uuid>
	management_subnet_id=<neutron_management_subnet_uuid>

	# Public Network (Floating IP)
	external_prefix=<external_prefix_cidr>
	external_network_id=<neutron_external_net_uuid>
	external_subnet_id=<neutron_external_subnet_uuid>
	
	plug_external_port=True

	router_image_uuid=<glance_akanda_image_uuid>
	router_instance_flavor=1
	router_ssh_public_key=/etc/akanda/akanda.pub

	# to plug in rug interface
	interface_driver=akanda.rug.common.linux.interface.OVSInterfaceDriver
	ovs_integration_bridge=br-int

	provider_rules_path=/opt/stack/akanda-rug/etc/provider_rules.json
	control_exchange = neutron

	[AGENT]
	root_helper=sudo

	[database]
	connection = mysql+pymysql://<mysql_user>:<mysql_password>@<mysql_host>/akanda?charset=utf8

Create SSH public key for router access
::
	% mkdir /etc/akanda
	% vi /etc/akanda/akanda.pub


Change Neutron Services to use Astara in /etc/neutron/neutron.conf
::
	api_extensions_path = <path to akanda-neutron extension: ~/akanda-neutron/akanda/neutron/extensions
	service_plugins = akanda.neutron.plugins.ml2_neutron_plugin.L3RouterPlugin
	core_plugin = akanda.neutron.plugins.ml2_neutron_plugin.Ml2Plugin

	[akanda]
	floatingip_subnet = <neutron_floating_subnet_uuid>

Configure ML2 plugin /etc/neutron/plugin/ml2/ml2_conf.ini


Enable and Configure Nova to use Astara in /etc/nova/nova.conf
::
	use_ipv6 = True
	service_neutron_metadata_proxy = True


Enable and Configure Astara in Horizon
::
	
	
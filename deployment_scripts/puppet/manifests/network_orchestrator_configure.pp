notice('MODULAR: astara config')

$astara_settings = hiera('fuel-plugin-astara')

# pass through fuel plugin config
astara_config {
    'DEFAULT/astara_api_port': value => $astara_settings['astara_api_port'];
    'DEFAULT/astara_mgt_service_port': value => $astara_settings['astra_mgmt_service_port'];
    'DEFAULT/management_prefix': value => $astara_settings['astra_mgmt_ipv6_prefix'];
}

# piece together authtoken config from hiera, using neutron's service creds.
$neutron_settings = hiera('quantum_settings')
$neutron_keystone_settings = $neutron_settings['keystone']
$keystone_settings = hiera_hash('keystone', {})
$service_endpoint = hiera('service_endpoint')
$management_vip = hiera('management_vip')

$ssl_hash = hiera_hash('use_ssl', {})
$internal_protocol = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'protocol', 'http')
$internal_address  = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'hostname', [$service_endpoint, $management_vip])
$internal_port     = '5000'

$public_url   = "${public_protocol}://${public_address}:${public_port}"
$admin_url    = "${admin_protocol}://${admin_address}:${admin_port}"
$internal_url = "${internal_protocol}://${internal_address}:${internal_port}"

$admin_protocol = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'protocol', 'http')

$auth_suffix  = pick($keystone_settings['auth_suffix'], '/')
$auth_url     = "${internal_url}${auth_suffix}"

# XXX need to replace with zookeeper
$memcache_addresses = hiera('memcached_addresses')
$memcache_address = $memcache_addresses[0]

$region = hiera('region', 'RegionOne')

# setup keystone authtoken middleware
astara_config {
    'keystone_authtoken/auth_plugin': value => 'password';
    'DEFAULT/auth_url': value => $auth_url;
    'keystone_authtoken/auth_uri': value => $auth_url;
    'keystone_authtoken/auth_url': value => $internal_url;
    'keystone_authtoken/project_domain_id': value => 'default';
    'keystone_authtoken/user_domain_id': value => 'default';
    'keystone_authtoken/project_name': value => 'services';
    'keystone_authtoken/username': value => 'neutron';
    'keystone_authtoken/password': value => $neutron_keystone_settings['admin_password'];
    'keystone_authtoken/auth_region': value => $region;
}


# setup db access to the controller with the known password
$database_vip               = hiera('database_vip', $management_vip)
$db_host                    = pick($astara_settings['db_host'], $database_vip)
$db_user                    = pick($astara_settings['db_user'], 'astara')
$db_name                    = pick($astara_settings['db_name'], 'astara')
#$db_password                = pick($astara_settings['astara_db_password'], 'astara')
$db_password                 = 'astara'
$database_connection        = "mysql://${db_user}:${db_password}@${db_host}/${db_name}?charset=utf8"
astara_config {
    'database/connection': value => $database_connection;
}

# setup access to neutron's rabbit queue
# matching neutron's rabbit setup here -- it uses nova's credentials?
$rabbit_settings = hiera('rabbit')
$rabbit_user = 'nova'
$rabbit_password  = $rabbit_settings['password']
$rabbit_host = hiera('amqp_hosts')

astara_config {
    'DEFAULT/control_exchange': value => 'neturon';
    'DEFAULT/rpc_backend': value => 'rabbit';
    'oslo_messaging_rabbit/rabbit_userid': value => $rabbit_user;
    'oslo_messaging_rabbit/rabbit_password': value => $rabbit_password, secret => true;
    'oslo_messaging_rabbit/rabbit_hosts': value => $rabbit_host;
}

# setup the neutron L3 agent
neutron_config {
    'agent/root_helper': value => 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf';
    'oslo_messaging_rabbit/rabbit_userid': value => $rabbit_user;
    'oslo_messaging_rabbit/rabbit_password': value => $rabbit_password, secret => true;
    # XXX note sure where non-default 5673 comes from?
    'oslo_messaging_rabbit/rabbit_hosts': value => $rabbit_host;
}


# drop an openrc for the neutron service tenant
class { 'openstack::auth_file':
  admin_user          => 'neutron',
  admin_password      => $neutron_keystone_settings['admin_password'],
  admin_tenant        => 'services',
  region_name         => $region,
  auth_url            => $auth_url,
}

astara_config {
    'DEFAULT/endpoint_type': value => 'internalURL';
    'DEFAULT/log_file': value => '/var/log/astara/astara-orchestrator.log';
}

# Setup coordination cluster services.
# NOTE: we use memcache here for testing until a zookeeper module is available in feul
astara_config {
    'coordination/enabled': value => 'True';
    'coordination/url': value => "memcached://${memcache_address}:11211";
}

# setup metadata proxy access
astara_config {
	'DEFAULT/nova_metadata_ip': value => $management_vip;
	'DEFAULT/neutron_metadata_proxy_shared_secret': value => $neutron_settings["metadata"]["metadata_proxy_shared_secret"];
}

# TODO(adam_g): flavor ids are hard-coded as params to astara::flavor::create,
# should be centralized somewhere.
astara_config {
	'router/instance_flavor': value => "511";
	'loadbalancer/instance_flavor': value => "511";
}

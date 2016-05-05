
notice('MODULAR: astara::astara_neutron::install')

class astara::astara_neutron::install {
	class { 'astara::repo::liberty': }

	package { 'neutron-plugin-astara':
        ensure => present,
        require => Class['astara::repo::liberty'],
	}

    # TODO: These will need to be special cased for when we deploy the Mitaka
    # version (akanda -> astara)
    neutron_config {
        'DEFAULT/core_plugin': value => 'akanda.neutron.plugins.ml2_neutron_plugin.Ml2Plugin';
        'DEFAULT/api_extensions_path': value => '/usr/lib/python2.7/dist-packages/akanda/neutron/extensions';
        'DEFAULT/service_plugins': value => 'akanda.neutron.plugins.ml2_neutron_plugin.L3RouterPlugin';
        'DEFAULT/notification_driver': value => 'neutron.openstack.common.notifier.rpc_notifier';
        'DEFAULT/astara_auto_add_resources': value => 'False';
    }
}

notice('MODULAR: astara::networks::create')

$astara_settings = hiera('fuel-plugin-astara')
$mgt_net_name = $astara_settings['astara_mgmt_name']
$mgt_prefix = $astara_settings['astara_mgmt_ipv6_prefix']

class astara::networks::create {
    exec { 'create networks':
        path => '/bin:/usr/bin',
        command => '/bin/bash ./scripts/create_neutron_networks.sh ${mgt_net_name} ${mgt_prefix}',
        logoutput => true,
    }
}

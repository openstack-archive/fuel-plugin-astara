notice('MODULAR: astara::networks::set')

$astara_settings = hiera('fuel-plugin-astara')

$mgt_net_name = $astara_settings['astara_mgmt_name']
$mgt_prefix = $astara_settings['astara_mgmt_ipv6_prefix']

class astara::networks::set {
    exec { 'set networks':
        path => '/bin:/usr/bin',
        command => '/bin/bash ./scripts/set_neutron_networks.sh ${mgt_net_name} ${mgt_prefix}',
        logoutput => true,
    }
}

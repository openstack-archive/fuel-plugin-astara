notice('MODULE: astara-neutron install')

include astara

class { 'astara::astara_neutron::install': }

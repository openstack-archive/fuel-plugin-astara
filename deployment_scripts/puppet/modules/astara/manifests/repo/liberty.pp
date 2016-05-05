class astara::repo::liberty {
    include apt
    if hiera('fuel_version') != '8.0' {
        fail('Currently Astara deployment supported only with Fuel 8.0/liberty')
    }

    # we install liberty on all nodes except the astara nodes
    notice('MODULAR: astara - Installing controller version for Liberty')
    apt::ppa { 'ppa:astara-drivers/astara-liberty': }
    exec {
        'apt-get update':
        path => '/usr/bin/',
        require => Apt::Ppa['ppa:astara-drivers/astara-liberty']
    }
}

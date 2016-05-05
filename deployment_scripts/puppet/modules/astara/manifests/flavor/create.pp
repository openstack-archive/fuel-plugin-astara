notice('MODULAR: astara::flavor::create')

class astara::flavor::create (
	$ram = '512',
	$disk = '3',
	$vcpus = '1',
	$flavor_name = 'm1.astara',
	$flavor_id = '511',
) {
    exec { 'create':
        path => '/bin:/usr/bin',
        command => '/bin/bash ./scripts/create_nova_flavor.sh ${ram} ${disk} ${vcpus} ${flavor_name} ${id}',
        logoutput => true,
    }
}

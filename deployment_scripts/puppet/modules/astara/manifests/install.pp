
# dependency issues between liberty and mitaka  prevent a packaged
# installation right now
#class astara::install {
#    class { 'astara::repo': }
#
#    package { 'astara-orchestrator':
#	ensure => 'present',
#	require => Class['astara::repo'],
#	tag => ['openstack', 'astara-orchestrator-package'],
#    }
#}


# install from src in a venv instead.
class astara::install {
	$astara_settings = hiera('fuel-plugin-astara')
	$astara_repo_url = pick($astara_settings['git_repo_url'], 'https://github.com/openstack/astara.git')
	$astara_repo_branch = pick($astara_settings['git_branch'], 'stable/mitaka')
	$repo_dir = '/opt/astara'
	exec { 'install-from-src':
		command => "/bin/bash ./scripts/install_astara_from_src.sh ${astara_repo_url} ${astara_repo_branch} ${$repo_dir}"
	}
}

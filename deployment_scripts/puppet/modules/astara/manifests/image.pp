notice('MODULAR: Grabbing astara appliance image')

class astara::image {

  $astara_settings = hiera('fuel-plugin-astara')
  $image_url = $astara_settings['astara_appliance_image_location']
  
  exec { 'need_image':
      command => '/bin/true',
      onlyif => '/usr/bin/test ! -e /root/astara_appliance.qcow2',
  }
  notice("Downloading astara applinace from ${image_url}")

  exec { "/usr/bin/wget -O astara_appliance.qcow2 --timestamping ${image_url}":
      alias => "get-image",
      cwd => "/tmp",
      require => Exec['need_image'],
  }

  file { "/root/astara_appliance.qcow2":
      ensure => present,
      source => "/tmp/astara_appliance.qcow2",
      require => Exec["get-image"] }

}

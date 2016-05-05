
notice('MODULAR: astara/db.pp')

$node_name      = hiera('node_name')

$astara_settings = hiera('fuel-plugin-astara')
$mysql_hash     = hiera_hash('mysql_hash', {})

$database_vip   = hiera('database_vip')

$mysql_root_user     = pick($mysql_hash['root_user'], 'root')
$mysql_db_create     = pick($mysql_hash['db_create'], true)
$mysql_root_password = $mysql_hash['root_password']

$db_user     = 'astara'
$db_name     = 'astara'
#$db_password = pick($astara_settings['astara_db_password'], $mysql_root_password)
# XXX TODO pull generated passwd from environment config
$db_password = 'astara'

$db_host          = pick($astara_settings['metadata']['db_host'], $database_vip)
$db_create        = pick($astara_settings['metadata']['db_create'], $mysql_db_create)
$db_root_user     = pick($astara_settings['metadata']['root_user'], $mysql_root_user)
$db_root_password = pick($astara_settings['metadata']['root_password'], $mysql_root_password)

$allowed_hosts = [ $node_name, 'localhost', '127.0.0.1', '%' ]

validate_string($mysql_root_user)

if $db_create {

  class { 'galera::client':
    custom_setup_class => hiera('mysql_custom_setup_class', 'galera'),
  }

  class { 'astara::db::mysql':
    user          => $db_user,
    password      => $db_password,
    dbname        => $db_name,
    allowed_hosts => $allowed_hosts,
  }

  class { 'osnailyfacter::mysql_access':
    db_host     => $db_host,
    db_user     => $db_root_user,
    db_password => $db_root_password,
  }

  Class['galera::client'] ->
  Class['osnailyfacter::mysql_access'] ->
  Class['astara::db::mysql']

}

class mysql::config {}
include mysql::config
class mysql::server {}
include mysql::server

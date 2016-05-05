# The astara::db::mysql class creates a MySQL database for astara.
# It must be used on the MySQL server
#
# == Parameters
#
#  [*password*]
#    password to connect to the database. Mandatory.
#
#  [*dbname*]
#    name of the database. Optional. Defaults to astara.
#
#  [*user*]
#    user to connect to the database. Optional. Defaults to astara.
#
#  [*host*]
#    the default source host user is allowed to connect from.
#    Optional. Defaults to 'localhost'
#
#  [*allowed_hosts*]
#    other hosts the user is allowd to connect from.
#    Optional. Defaults to undef.
#
#  [*charset*]
#    the database charset. Optional. Defaults to 'utf8'
#
#  [*collate*]
#    the database collation. Optional. Defaults to 'utf8_general_ci'
#
#  [*mysql_module*]
#   (optional) Deprecated. Does nothing.
#
#  [*cluster_id*]
#   (optional) Deprecated. Does nothing.

class astara::db::mysql(
  $password,
  $dbname        = 'astara',
  $user          = 'astara',
  $host          = '127.0.0.1',
  $charset       = 'utf8',
  $collate       = 'utf8_general_ci',
  $allowed_hosts = undef,
) {

  ::openstacklib::db::mysql { 'astara':
    user          => $user,
    password_hash => mysql_password($password),
    dbname        => $dbname,
    host          => $host,
    charset       => $charset,
    collate       => $collate,
    allowed_hosts => $allowed_hosts,
  }

}

notice('MODULAR: astara::db::sync')

class astara::db::sync {
  exec {  'astara-db-sync':
    command	=> 'astara-dbsync --config-file /etc/astara/orchestrator.ini upgrade head',
    path        => '/usr/bin',
    user        => 'astara',
    logoutput   => on_failure,
  }
}

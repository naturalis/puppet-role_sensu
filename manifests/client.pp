#
#
#
class role_sensu::client(
  $client_cert,
  $client_key,
  $rabbitmq_password  = 'bladiebla',
  $sensu_server       = '127.0.0.1',
  $plugins            = {},
  $checks             = {},
  $check_disk         = true,
  $disk_warning       = 85,
  $disk_critical      = 95,
  $check_load         = true,
  $load_warning       = '0.3,0.3,0.3',
  $load_critical      = '1,0.99,0.95',
  $processes_to_check = []

){

  $builtin_checks = {}
  $builtin_plugins = {}

  $ruby_run_comand = '/opt/sensu/embedded/bin/ruby -C/opt/sensu/embedded/bin'

  role_sensu::keys::client { 'client_keys' :
    private => $client_key,
    cert    => $client_cert,
  } ->


  class { 'sensu':
    #purge_config             => true,
    rabbitmq_password        => $rabbitmq_password,
    rabbitmq_ssl_private_key => '/etc/ssl/rabbitmq_client_key.pem',
    rabbitmq_ssl_cert_chain  => '/etc/ssl/rabbitmq_client_cert.pem',
    rabbitmq_host            => $sensu_server,
    subscriptions            => 'sensu-test',
    use_embedded_ruby        => true,
    rabbitmq_port            => 5671,
    rabbitmq_vhost           => '/sensu',
    client_keepalive         => {
      'handlers' => ['default']
    }
  }


  if $check_disk {
    $builtin_plugins['sensu-plugins-disk-checks'] = {}
    $builtin_checks['check_disk_space'] = { 'command' => "${ruby_run_comand} check-disk-usage.rb -w ${disk_warning} -c ${disk_critical}"}
    $builtin_checks['check_disk_mounts'] = {'command' => "${ruby_run_comand} check-fstab-mounts.rb" }
  }

  if $check_load {
    $builtin_plugins['sensu-plugins-load-checks'] = {}
    $builtin_checks['check_load'] = {'command' => "${ruby_run_comand} check-load.rb -w ${load_warning} -c ${load_critical} --per-core"}
  }

  if size($processes_to_check) > 0 {
    $builtin_plugins['sensu-plugins-process-checks'] = {}
  }

  class { 'role_sensu::plugins':
    plugins => merge($plugins, $builtin_plugins)
  }

  class { 'role_sensu::checks':
    checks => merge($checks, $builtin_checks)
  }


}

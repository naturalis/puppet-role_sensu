#
#
#
class role_sensu::client(
  $client_cert,
  $client_key,
  $rabbitmq_password  = 'bladiebla',
  $sensu_server       = '127.0.0.1',
  $plugins            = [],
  $checks             = {},
  $check_disk         = true,
  $disk_warning       = 85,
  $disk_critical      = 95,
  $check_load         = true,
  $load_warning       = '0.99,0.95,0.9',
  $load_critical      = '0.99,0.99,0.95',
  $reboot_warning     = true,
  $processes_to_check = [],
  $subscriptions      = ['appserver'],
  $checks_defaults    = {
    interval      => 600,
    occurrences   => 3,
    refresh       => 60,
    handlers      => [ 'default'],
    subscribers   => ['appserver'],
    standalone    => true },

){

  $builtin_plugins = ['sensu-plugins-disk-checks', 'sensu-plugins-load-checks', 'sensu-plugins-process-checks' ]
  $ruby_run_comand = '/opt/sensu/embedded/bin/ruby -C/opt/sensu/embedded/bin'

  role_sensu::keys::client { 'client_keys' :
    private => $client_key,
    cert    => $client_cert,
  } ->
  class { 'role_sensu::install_apt_repo': } ->

  class { 'sensu':
    install_repo             => false,
    sensu_plugin_name        => 'ruby',
    rabbitmq_password        => $rabbitmq_password,
    rabbitmq_ssl_private_key => '/etc/ssl/rabbitmq_client_key.pem',
    rabbitmq_ssl_cert_chain  => '/etc/ssl/rabbitmq_client_cert.pem',
    rabbitmq_host            => $sensu_server,
    subscriptions            => $subscriptions,
    use_embedded_ruby        => true,
    rabbitmq_port            => 5671,
    rabbitmq_vhost           => '/sensu',
    purge                    => {
      'config'   => true
    },
    client_keepalive         => {
      'handlers' => ['default']
    }
  }


# Sensu check defaults
  Sensu::Check {
    interval    => $checks_defaults['interval'],
    occurrences => $checks_defaults['occurrrences'],
    refresh     => $checks_defaults['refresh'],
    handlers    => $checks_defaults['handlers'],
    subscribers => $checks_defaults['subscribers'],
    standalone  => $checks_defaults['standalone'],
  }


  if $reboot_warning {
    sensu::check { 'check_reboot_required':
      command     => 'if [ -f /var/run/reboot-required ] ; then echo reboot required ; return 1 ; else echo no reboot required ;fi',
    }
  }

  if $check_disk {
    sensu::check { 'check_disk_usage':
      command     => "${ruby_run_comand} check-disk-usage.rb -w ${disk_warning} -c ${disk_critical}"
    }
    sensu::check { 'check_disk_mounts':
      command     => "${ruby_run_comand} check-fstab-mounts.rb"
    }
  }

  if $check_load {
    sensu::check { 'check_CPU_load':
      command     => "${ruby_run_comand} check-load.rb -w ${load_warning} -c ${load_critical}"
    }
  }

  if size($processes_to_check) > 0 {
    role_sensu::check_process_installer { $processes_to_check :
      checks_defaults => $checks_defaults,
    }
  }

  $plugin_array = unique(concat($plugins, $builtin_plugins))
  role_sensu::plugin_installer { $plugin_array : }

  Sensu::Check <| tag == 'central_sensu' |> {
    interval    => $checks_defaults['interval'],
    occurrences => $checks_defaults['occurrrences'],
    refresh     => $checks_defaults['refresh'],
    handlers    => $checks_defaults['handlers'],
    subscribers => $checks_defaults['subscribers'],
    standalone  => $checks_defaults['standalone'],
  }

}

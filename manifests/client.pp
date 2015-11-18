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
  $disk_warning_perc  = 85,
  $disk_critical_perc = 95,
){

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

  class { 'role_sensu::plugins':
    plugins => $plugins
  }

  if $check_disk {
    class { 'role_sensu::plugins':
      plugins => {
        'sensu-plugins-disk-checks',
        'sensu-plugins-load-checks'
      }
    }
    class { 'role_sensu::checks':
      checks => {
        'check_disk_space'  => {
          'command' => "/opt/sensu/embedded/bin/ruby check-disk-usage.rb -w ${disk_warning_perc} -c ${disk_critical_perc}"
        },
        'check_disk_mounts' => {
          'command' => '/opt/sensu/embedded/bin/ruby check-fstab-mounts.rb'
        }
      }
    }
  }

  class { 'role_sensu::checks':
    checks => $checks
  }
}

#
#
#
define role_sensu::rabbitmq (
  $sensu_password,
  $public_keyname = '/etc/ssl/rabbitmq_server_key.pem',
  $cert_keyname = '/etc/ssl/rabbitmq_server_cert.pem',
  $cacert_keyname = '/etc/ssl/rabbitmq_server_key.pem',
)
{

  class { 'rabbitmq':
    ssl_key    => $public_keyname,
    ssl_cert   => $cert_keyname,
    ssl_cacert => $cacert_keyname,
    ssl        => true,
  }

  # ssl_key    => '/etc/rabbitmq/ssl//server_key.pem',
  # ssl_cert   => '/etc/rabbitmq/ssl//server_cert.pem',
  # ssl_cacert => '/etc/rabbitmq/ssl//cacert.pem',

  rabbitmq_vhost { '/sensu': }

  rabbitmq_user { 'sensu': password => $sensu_password }

  rabbitmq_user_permissions { 'sensu@/sensu':
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }

}

#
#
#
class role_sensu::client(
  $client_cert,
  $client_key,
  $rabbitmq_password = 'bladiebla',
  $sensu_server      = '127.0.0.1'
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
    client_port              => {'port' => '3030'},
    rabbitmq_port            => 5671,
    rabbitmq_vhost           => '/sensu',
    client_keepalive         => { 'handlers' => ['default'] }
  }
}

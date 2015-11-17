#
#
#
define role_sensu::keys::server (
  $private,
  $cert,
  $cacert,
  $private_keyname = '/etc/ssl/rabbitmq_server_key.pem',
  $cert_keyname    = '/etc/ssl/rabbitmq_server_cert.pem',
  $cacert_keyname  = '/etc/ssl/rabbitmq_cacert.pem'
){

  file { $private_keyname :
    ensure  => present,
    content => $private,
    mode    => '0644',
  }

  file { $cert_keyname :
    ensure  => present,
    content => $cert,
    mode    => '0644',
  }

  file { $cacert_keyname :
    ensure  => present,
    content => $cacert,
    mode    => '0644',
  }

}

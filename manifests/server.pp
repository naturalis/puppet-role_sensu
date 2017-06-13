# == Class: role_sensu::server
#
# Full description of class role_sensu here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { role_sensu:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Atze de Vries <Atze.deVries@naturalis.nl>
#
# === Copyright
#
# Copyright 2014 Naturalis
#
class role_sensu::server(
  $server_key,
  $server_cert,
  $cacert,
  $client_cert,
  $client_key,
  $web_client_key,
  $web_client_cert,
  $rabbitmq_password = 'bladiebla',
  $api_user          = 'sensu_api',
  $api_password      = 'bladiebla',
  $sensu_username    = 'sensu',
  $sensu_password    = 'bladiebla',
  $subscriptions     = ['appserver'],
  $handler_definitions = {},
  $plugin_array      = [],
  $uchiwa_dns_name   = 'sensu.naturalis.nl',
  $expose_api        = false,
  $extra_uchiwa_cons = [],
){


  $uchiwa_api_config = [
    { name     => 'Naturalis Sensu',
      host     => 'localhost',
      ssl      => false,
      insecure => false,
      port     => 4567,
      user     => $api_user,
      pass     => $api_password,
      timeout  => 5
      }
    ]

  if (count($extra_uchiwa_cons) > 0) {
    $sensu_api_endpoints = concat($uchiwa_api_config,$extra_uchiwa_cons)
  }else{
    $sensu_api_endpoints = $uchiwa_api_config
  }

  ensure_packages(['make','gcc','build-essential'], {'ensure' => 'present'})
  
  role_sensu::keys::server { 'server_keys' :
    private => $server_key,
    cert    => $server_cert,
    cacert  => $cacert
  } ->

  role_sensu::keys::client { 'client_keys' :
    private => $client_key,
    cert    => $client_cert,
  } ->

  role_sensu::rabbitmq { 'sensu_rmq_sever':
    sensu_password => $rabbitmq_password
  } ->

  class { 'redis': } ->

#  class { 'role_sensu::install_apt_repo': } ->

  class { 'sensu':
    server                   => true,
    #purge_config            => true,
    install_repo             => false,
    #fix for sensu always doing something
    sensu_plugin_name        => 'ruby',
    rabbitmq_password        => $rabbitmq_password,
    rabbitmq_ssl_private_key => '/etc/ssl/rabbitmq_client_key.pem',
    rabbitmq_ssl_cert_chain  => '/etc/ssl/rabbitmq_client_cert.pem',
    rabbitmq_host            => 'localhost',
    subscriptions            => $subscriptions,
    api                      => true,
    api_user                 => $api_user,
    api_password             => $api_password,
    use_embedded_ruby        => true,
    rabbitmq_port            => 5671,
    rabbitmq_vhost           => '/sensu',
  } ->


  class { 'uchiwa':
    sensu_api_endpoints => $sensu_api_endpoints,
    user                => $sensu_username,
    pass                => $sensu_password,
    install_repo        => false            # otherwise you get this: Apt::Source[sensu] is already declared in file /etc/puppet/modules/sensu/manifests/repo/apt.pp
  }


  create_resources( 'sensu::handler' , $handler_definitions, {} )
  role_sensu::plugin_installer { $plugin_array : }
  
  role_sensu::keys::client { 'nginx_keys' :
    private         => $web_client_key,
    cert            => $web_client_cert,
    private_keyname => '/etc/ssl/web_client_key.pem',
    cert_keyname    => '/etc/ssl/web_client_cert.pem'
  } ->

  class {'nginx': }

  nginx::resource::upstream { 'sensu_naturalis_nl':
    members => ['localhost:3000'],
  }

  nginx::resource::vhost { $uchiwa_dns_name :
    proxy       => 'http://sensu_naturalis_nl',
    ssl         => true,
    listen_port => 443,
    ssl_cert    => '/etc/ssl/web_client_cert.pem',
    ssl_key     => '/etc/ssl/web_client_key.pem',
  }

  if (expose_api) {

    nginx::resource::upstream { 'sensuapi_naturalis_nl':
      members => ['localhost:4567'],
    }

    nginx::resource::vhost { 'sensu api expose' :
      proxy       => 'http://sensuapi_naturalis_nl',
      ssl         => true,
      listen_port => 8443,
      ssl_port    => 8443,
      ssl_cert    => '/etc/ssl/web_client_cert.pem',
      ssl_key     => '/etc/ssl/web_client_key.pem',
    }
  }


}

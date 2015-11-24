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

  class { 'role_sensu::install_apt_repo': } ->

  class { 'sensu':
    server                   => true,
    #purge_config             => true,
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
    sensu_api_endpoints => $uchiwa_api_config,
    user                => $sensu_username,
    pass                => $sensu_password,
    install_repo        => false            # otherwise you get this: Apt::Source[sensu] is already declared in file /etc/puppet/modules/sensu/manifests/repo/apt.pp
  }


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

  nginx::resource::vhost { 'sensu.naturalis.nl':
    proxy       => 'http://sensu_naturalis_nl',
    ssl         => true,
    listen_port => 443
    ssl_cert    => '/etc/ssl/web_client_cert.pem',
    ssl_key     => '/etc/ssl/web_client_key.pem',
  }




  # if $rabbitmq_password == 'changeme' {
  #   fail('please change the rabbitmq_password')
  # }
  #
  # if $sensu_cluster_name == 'changeme' {
  #   fail('please change the sensu_cluser_name')
  # }
  #

  # class { 'redis': } ->
  #
  # class { 'rabbitmq': } ->
  #
  # exec { 'added rabbitmq user Sensu since stupid puppet module doenst work':
  #   command => '/usr/sbin/rabbitmqctl add_user sensu',
  #   unless  => '/usr/sbin/rabbitmqctl list_users | /bin/grep sensu',
  # } ->
  #
  # exec { 'added rabbitmq vhost Sensu since stupid puppet module doenst work':
  #   command => '/usr/sbin/rabbitmqctl add_vhost sensu',
  #   unless  => '/usr/sbin/rabbitmqctl list_vhosts | /bin/grep sensu',
  # } ->
  #
  # # rabbitmq_user { 'sensu':
  # #   password => '',
  # #   require  => Class['rabbitmq'],
  # # }
  #
  # # rabbitmq_vhost { 'sensu':
  # #   ensure  => present,
  # # } ->
  # exec { 'added rabbitmq persmissions of sensu vhost since stupid puppet module doenst work':
  #   command => '/usr/sbin/rabbitmqctl set_permissions -p sensu ".*" ".*" ".*"',
  #   unless  => '/usr/sbin/rabbitmqctl list_permissions -p sensu | /bin/grep -v vhost | grep sensu',
  # } ->
  #
  # # rabbitmq_user_permissions { 'sensu@sensu':
  # #   configure_permission => '.*',
  # #   read_permission      => '.*',
  # #   write_permission     => '.*',
  # # } ->
  #
  # class { 'sensu':
  #   rabbitmq_password => '',
  #   server            => true,
  #   api               => true,
  #   use_embedded_ruby => true,
  #   subscriptions     => ['sensu-test','sensu-server'],
  # }
  #
  # Sensu::Check <<| tag == "sensu_check_${sensu_cluster_name}" |>>
  #
  # # sensu::handler { 'default':
  # #   command => 'mail -s \'sensu alert\' aut@naturalis.nl',
  # # }
  #
  # class { 'uchiwa':
  #   install_repo => false,
  # }
  #
  # uchiwa::api { 'Default Uchiwa API':
  #   host => $::ipaddress,
  #   user => '',
  #   pass => '',
  # }
  #
  # package {'git': }
  #
  # vcsrepo { '/opt/sensu-community-plugins':
  #   ensure   => present,
  #   provider => git,
  #   source   => 'git://github.com/sensu/sensu-community-plugins',
  #   require  => Package['git'],
  # }
  #
  # # needs package ruby-dev
  # # needs gem install mail sensu-plugin
  #
  # sensu::handler {'default':
  #   command => '/opt/sensu-community-plugins/handlers/notification/mailer.rb',
  # }
  #
  # file {'/etc/sensu/conf.d/mailer.json':
  #   ensure  => present,
  #   content => template('role_sensu/config/mailer.json.erb'),
  #   notify  => Service['sensu-server'],
  # }
  #






}

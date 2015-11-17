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
  $rabbitmq_password = 'bladiebla',
){

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

  class { 'sensu':
    server                   => true,
    purge_config             => true,
    rabbitmq_password        => $rabbitmq_password,
    rabbitmq_ssl_private_key => '/etc/ssl/rabbitmq_client_key.pem',
    rabbitmq_ssl_cert_chain  => '/etc/ssl/rabbitmq_client_cert.pem',
    rabbitmq_host            => 'localhost',
    subscriptions            => 'sensu-test',
    use_embedded_ruby        => true,
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

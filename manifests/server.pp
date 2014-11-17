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
  $rabbitmq_password  = 'changeme',
  $sensu_cluster_name = 'changeme',
){

  if $rabbitmq_password == 'changeme' {
    fail('please change the rabbitmq_password')
  }

  if $sensu_cluster_name == 'changeme' {
    fail('please change the sensu_cluser_name')
  }


  class { 'redis': } ->

  class { 'rabbitmq': } ->

  exec { 'added rabbitmq user Sensu since stupid puppet module doenst work':
    command => '/usr/sbin/rabbitmqctl add_user sensu',
    unless  => '/usr/sbin/rabbitmqctl list_users | /bin/grep sensu',
  } ->

  exec { 'added rabbitmq vhost Sensu since stupid puppet module doenst work':
    command => '/usr/sbin/rabbitmqctl add_vhost sensu',
    unless  => '/usr/sbin/rabbitmqctl list_vhosts | /bin/grep sensu',
  } ->

  # rabbitmq_user { 'sensu':
  #   password => '',
  #   require  => Class['rabbitmq'],
  # }

  # rabbitmq_vhost { 'sensu':
  #   ensure  => present,
  # } ->
  exec { 'added rabbitmq persmissions of sensu vhost since stupid puppet module doenst work':
    command => '/usr/sbin/rabbitmqctl set_permissions -p sensu ".*" ".*" ".*"',
    unless  => '/usr/sbin/rabbitmqctl list_permissions -p sensu | /bin/grep -v vhost | grep sensu',
  } ->

  # rabbitmq_user_permissions { 'sensu@sensu':
  #   configure_permission => '.*',
  #   read_permission      => '.*',
  #   write_permission     => '.*',
  # } ->

  class { 'sensu':
    rabbitmq_password => '',
    server            => true,
    api               => true,
    use_embedded_ruby => true,
  }

  Sensu::Check <<| tag == "sensu_check_${sensu_cluster_name}" |>>

  # sensu::handler { 'default':
  #   command => 'mail -s \'sensu alert\' aut@naturalis.nl',
  # }

  class { 'uchiwa':
    install_repo => false,
  }

  uchiwa::api { 'Default Uchiwa API':
    host => $::ipaddress,
    user => '',
    pass => '',
  }

  package {'git': }

  vcsrepo { '/opt/sensu-community-plugins':
    ensure   => present,
    provider => git,
    source   => 'git://github.com/sensu/sensu-community-plugins',
    require  => Package['git'],
  }

  # needs package ruby-dev
  # needs gem install mail sensu-plugin

  sensu::handler {'mail_aut':
    command => '/opt/sensu-community-plugins/handlers/notification/mailer.rb',
    config  => {
        'admin_gui'    => 'http://10.41.3.22:3000/',
        'mail_from'    => 'sensu@naturalis.nl',
        'mail_to'      => 'aut@naturalis.nl',
        'smtp_address' => 'localhost',
        'smtp_port'    => '25',
        'smtp_domain'  => 'naturalis.nl'
    }
  }





}

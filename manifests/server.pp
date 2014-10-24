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

  rabbitmq_user { 'sensu':
    password => '',
  } ->

  rabbitmq_vhost { 'sensu':
    ensure => present,
  } ->

  rabbitmq_user_permissions { 'sensu@sensu':
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  } ->

  class { 'sensu':
    rabbitmq_password => $rabbitmq_password,
    server            => true,
    api               => true,
  }

  Sensu::Check <<| tag == "sensu_check_${sensu_cluster_name}" |>> {
    require => Class['sensu']
  }

  sensu::handler { 'default':
    command => 'mail -s \'sensu alert\' aut@naturalis.nl',
  }

}

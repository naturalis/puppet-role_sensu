#
#
#
class role_sensu::client(
  $sensu_server       = 'changeme',
  $rabbitmq_password  = 'changeme',
  $sensu_cluster_name = 'changeme',
  )
{
  if $sensu_server == 'changeme' { fail ('change the var $sensu_server to something else (and not changeme)')}
  if $rabbitmq_password == 'changeme' { fail('please change the rabbitmq_password') }
  if $sensu_cluster_name == 'changeme' { fail('please change the sensu_cluser_name') }

  class { 'sensu':
    rabbitmq_password  => $rabbitmq_password,
    rabbitmq_host      => $sensu_server,
    subscriptions      => 'sensu-test',
    server             => false,
  }

  sensu::check { 'check_cron':
    command     => '/bin/ps -aux | grep -v grep | grep cron',
    handlers    => 'default',
    subscribers => 'sensu-test'
  }

  @@sensu::check { "check_ping_of_${::fqdn}":
    command     => '/bin/echo 0',
    handlers    => 'default',
    subscribers => 'sensu-test',
    standalone  => true,
    tag         => "sensu_check_${sensu_cluster_name}",
  }
  realize(Sensu::Check["check_ping_of_${::fqdn}"])

  #Sensu::Check <<| tag == "sensu_check_${sensu_cluster_name}" |>>

  $dbgmsg = "@@sensu::check { check_ping_of_${::fqdn}:
    command     => '/bin/echo 0',
    handlers    => 'default',
    subscribers => 'sensu-test',
    standalone  => true,
    tag         => sensu_check_${sensu_cluster_name},
  }"

  notify { 'DEBUG': message => $dbgmsg}


}

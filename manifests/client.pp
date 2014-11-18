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
    rabbitmq_password => $rabbitmq_password,
    rabbitmq_host     => $sensu_server,
    subscriptions     => 'sensu-test',
    server            => false,
  }

  sensu::check { 'check_cron':
    command     => '/bin/ps -aux | grep -v grep | grep cron',
    handlers    => 'default',
    subscribers => 'sensu-test'
  }

  # this is a registrated check
  sensu::check { 'check_puppet_service':
    command     => '/bin/ps -aux | grep -v grep | grep puppet',
    handlers    => 'default',
    subscribers => 'sensu-test',
    standalone  => false,
    publish     => true,
  }

  # this is not a registrated check
  @@sensu::check { 'check_www_catalogue_of_life_org':
    command     => '/opt/sensu-community-plugins/plugins/http/check-http.rb --url http://www.catalogueoflife.org -q \'Welcome to the Catalogue of Life website\'',
    handlers    => 'default',
    subscribers => 'sensu-test',
    standalone  => false,
    tag         => "sensu_check_${sensu_cluster_name}",
  }







}

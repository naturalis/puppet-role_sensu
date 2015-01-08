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
    subscribers => 'sensu-server',
    standalone  => false,
    tag         => "sensu_check_${sensu_cluster_name}",
  }

  @@sensu::check { 'check_www_walvisstrandingen_nl':
    command     => '/opt/sensu-community-plugins/plugins/http/check-http.rb --url http://www.walvisstrandingen.nl -q \'Alle geregistreerde Nederlandse walvisstrandingen\'',
    handlers    => 'default',
    subscribers => 'sensu-server',
    standalone  => false,
    tag         => "sensu_check_${sensu_cluster_name}",
  }

  @@sensu::check { 'check_www_soortenbank_nl':
    command     => '/opt/sensu-community-plugins/plugins/http/check-http.rb --url http://www.soortenbank.nl -q \'Zoek naar de soort:\'',
    handlers    => 'default',
    subscribers => 'sensu-server',
    standalone  => false,
    tag         => "sensu_check_${sensu_cluster_name}",
  }

  @@sensu::check { 'check_www_nederlandsesoorten_nl':
    command     => '/opt/sensu-community-plugins/plugins/http/check-http.rb --url http://www.nederlandsesoorten.nl -q \'Home\'',
    handlers    => 'default',
    subscribers => 'sensu-server',
    standalone  => false,
    tag         => "sensu_check_${sensu_cluster_name}",
  }

  @@sensu::check { 'check_www_naturalis_nl':
    command     => '/opt/sensu-community-plugins/plugins/http/check-http.rb --url http://www.naturalis.nl/nl/ -q \'Bezoekersinfo\'',
    handlers    => 'default',
    subscribers => 'sensu-server',
    standalone  => false,
    tag         => "sensu_check_${sensu_cluster_name}",
  }

  @@sensu::check { 'check_3d_naturalis_nl':
    command     => '/opt/sensu-community-plugins/plugins/http/check-http.rb --url http://3d.naturalis.nl/nl/ -q \'biodiversity in cyberspace\'',
    handlers    => 'default',
    subscribers => 'sensu-server',
    standalone  => false,
    tag         => "sensu_check_${sensu_cluster_name}",
  }
  
  @@sensu::check { 'check_www_catalogueoflife_org':
    command     => '/opt/sensu-community-plugins/plugins/http/check-http.rb --url http://www.catalogueoflife.org/ -q \'Welcome to the Catalogue of Life website\'',
    handlers    => 'default',
    subscribers => 'sensu-server',
    standalone  => false,
    tag         => "sensu_check_${sensu_cluster_name}",
  }
  
  @@sensu::check { 'check_bioportal.naturalis.nl/':
    command     => '/opt/sensu-community-plugins/plugins/http/check-http.rb --url http://bioportal.naturalis.nl/ -q \'Browse through Dutch natural history collections\'',
    handlers    => 'default',
    subscribers => 'sensu-server',
    standalone  => false,
    tag         => "sensu_check_${sensu_cluster_name}",
  }
  
  @@sensu::check { 'check_www_nationaalherbarium_nl/':
    command     => '/opt/sensu-community-plugins/plugins/http/check-http.rb --url http://www.nationaalherbarium.nl/invasieven/ -q \'Table of Contents\'',
    handlers    => 'default',
    subscribers => 'sensu-server',
    standalone  => false,
    tag         => "sensu_check_${sensu_cluster_name}",
  }
  
}

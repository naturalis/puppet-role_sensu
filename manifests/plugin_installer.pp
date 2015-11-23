#
#
#
define role_sensu::plugin_installer (
) {

  exec { "Installing Sensu Gem: ${name}" :
    command => "/opt/sensu/embedded/bin/gem install --install-dir /opt/sensu/embedded/lib/ruby/gems/2.0.0 ${name}",
    unless  => "/opt/sensu/embedded/bin/gem list --local | grep ${name}",
    require => Class['sensu'],
  }

  # package { $title:
  #   ensure          => $version,
  #   provider        => gem,
  #   install_options => [{
  #     '--install-dir' => '/opt/sensu/embedded/lib/ruby/gems/2.0.0'
  #   }],
  # }

}

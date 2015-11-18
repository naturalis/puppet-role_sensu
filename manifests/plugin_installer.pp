#
#
#
define role_sensu::plugin_installer (
  $version = undef,
) {

  exec { "Installing Sensu Gem: ${title}" :
    command => "/opt/sensu/embedded/bin/gem install --install-dir /opt/sensu/embedded/lib/ruby/gems/2.0.0 ${title}",
    unless  => "/opt/sensu/embedded/bin/gem list --local | grep ${title}"
  }

  # package { $title:
  #   ensure          => $version,
  #   provider        => gem,
  #   install_options => [{
  #     '--install-dir' => '/opt/sensu/embedded/lib/ruby/gems/2.0.0'
  #   }],
  # }

}

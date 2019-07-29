#
#
#
define role_sensu::plugin_installer (
) {

  ensure_packages(['build-essential'])

  exec { "Installing Sensu Gem: ${title}" :
    command => "/opt/sensu/embedded/bin/gem install ${title}",
    unless  => "/opt/sensu/embedded/bin/gem list --local | grep ${title}",
    require => [Class['sensu'],Package['build-essential']]
  }


}

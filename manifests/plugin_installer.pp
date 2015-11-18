#
#
#
define role_sensu::plugin_installer (
  $version = undef,
) {

  package { $title:
    ensure          => $version,
    provider        => gem,
    install_options => [{
      '--install-dir' => '/opt/sensu/embedded/lib/ruby/gems/2.0.0'
    }],
  }

}

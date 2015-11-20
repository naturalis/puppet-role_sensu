#
# == Parameters
#
class role_sensu::install_apt_repo {

  $repo_key_id = '8911D8FF37778F24B4E726A218609E3D7580C77F'
  $repo_key_source = 'http://repos.sensuapp.org/apt/pubkey.gpg'

  if defined(apt::source) {

    # $ensure = $sensu::install_repo ? {
    #   true    => 'present',
    #   default => 'absent'
    # }


    $url = 'http://repos.sensuapp.org/apt'

    apt::source { 'sensu_repo':
      ensure   => present,
      location => $url,
      release  => 'sensu',
      repos    => 'main',
      include  => {
        'src' => false,
      },
      key      => {
        'id'     => $repo_key_id,
        'source' => $repo_key_source,
      },
      before   => Package['sensu'],
      notify   => Exec['apt-update'],
    }

    exec { 'apt-update':
      refreshonly => true,
      command     => '/usr/bin/apt-get update',
    }

  } else {
    fail('This class requires puppetlabs-apt module')
  }

}

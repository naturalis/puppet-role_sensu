#
#
#
class role_sensu::ssl(
  $ssl_check_hash          = { 'waarneming.nl' => { 'warning_days' => '14', 'critical_days' => '7' },
                                'waarnemingen.be' => { 'warning_days' => '14', 'critical_days' => '7' },
                              },
)
{

package { 'bc':
  ensure => installed,
}

# create checks from hash
create_resources('role_sensu::sslchecks', $ssl_check_hash)

}

#
#
#
define role_sensu::sslchecks(
#  $host             = $title
  $warning_days     = '30',
  $critical_days    = '15',
  $port             = '443',
)
{

# create check script from template
  file { "/usr/local/sbin/chkssl_${title}.sh":
    mode    => '0755',
    content => template('role_sensu/chkssl.sh.erb'),
  }

# export check so sensu monitoring can make use of it
  @sensu::check { "Check_SSL ${title}" :
    interval  => '600',
    command   => "/usr/local/sbin/chkssl_${title}.sh",
    tag       => 'central_sensu',
}
}

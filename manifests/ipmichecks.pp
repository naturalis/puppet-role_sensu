#
#
#
define role_sensu::ipmichecks(
  $user     = $role_sensu::ipmi::ipmi_user,
  $password = $role_sensu::ipmi::ipmi_password,
  $ip,
  $options,
  $script   = "${role_sensu::ipmi::scriptdir}/check_ipmi_sensor",
)
{

# create check script from template
  file { "/usr/local/sbin/chkipmi_${ip}_${title}.sh":
    mode    => '0755',
    content => template('role_sensu/chkipmi.sh.erb'),
  }

# export check so sensu monitoring can make use of it
  @sensu::check { "Check IPMI ${ip}_${title}" :
    interval  => '600',
    command   => "/usr/local/sbin/chkipmi_${ip}_${title}.sh",
    tag       => 'central_sensu',
}
}

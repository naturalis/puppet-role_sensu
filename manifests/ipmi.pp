#
#
#
class role_sensu::ipmi(
  $ipmi_user                = 'ADMIN',
  $ipmi_password            = 'ADMIN',
  $check_ipmi_sensor_repo   = 'https://github.com/thomas-krenn/check_ipmi_sensor_v3.git',
  $scriptdir                = '/opt/check_ipmi',
  $required_packages        = ['libipc-run-perl','freeipmi-tools','git'],
  $ipmi_check_hash          = { 'stack-hpc-001' => { 'ip' => '172.16.35.64', 'options' => '' },
                                'fuel' => { 'ip' => '172.16.35.89', 'options' => '' },
                                'stack-ceph-001' => { 'ip' => '172.16.35.87', 'options' => '' }
                              },
)
{

# download check_ipmi_sensor from repo
  vcsrepo { "${scriptdir}":
    ensure        => present,
    provider      => git,
    source        => $check_ipmi_sensor_repo,
    require       => Package['git'],
  }

# install required software
  package { $required_packages: 
    ensure        => installed,
  }

# create checks from hash
create_resources('role_sensu::ipmichecks', $ipmi_check_hash)

}

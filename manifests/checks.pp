#
#
#
class role_sensu::checks(
    $checks,
    $defaults,
)
{
#notify{$checks:}
 create_resources( 'sensu::check', $checks, $defaults )
}

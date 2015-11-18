#
#
#
class role_sensu::checks(
      $checks = {}
)
{
  create_resources( 'sensu::check', $checks, {} )
}

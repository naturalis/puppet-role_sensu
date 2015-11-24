#
#
#
class role_sensu::checks(
      $checks = {},
      $defaults = {}
)
{
  create_resources( 'sensu::check', $checks, {} )
}

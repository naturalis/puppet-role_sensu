#
#
#
define role_sensu::check_process_installer(
  $checks_defaults = {}
){

  $ruby_run_comand = '/opt/sensu/embedded/bin/ruby -C/opt/sensu/embedded/bin'
  $hash = { "check_process_${title}" =>
    {'command' => "${ruby_run_comand} check-process.rb -p ${title}"}
  }
  create_resources( 'sensu::check', $hash, $checks_defaults )
}

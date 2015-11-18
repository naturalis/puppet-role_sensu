#
#
#
class role_sensu::plugins ($plugins = {}) { create_resources('role_sensu::plugin_installer', $plugins, {}) }

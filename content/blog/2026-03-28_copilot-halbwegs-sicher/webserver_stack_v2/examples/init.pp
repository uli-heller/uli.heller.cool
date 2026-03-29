# Beispiel Puppet Manifest zur Verwendung des webserver_stack Moduls

# Standard Verwendung (alle Komponenten aktiviert):
# include webserver_stack

# Mit eigenen Parametern:
class { 'webserver_stack':
  apache_enabled        => true,
  tomcat_enabled        => true,
  webapp_enabled        => true,
  tomcat_port           => 8080,
  tomcat_shutdown_port  => 8005,
  tomcat_version        => '9',
  webapp_name           => 'example-app',
}

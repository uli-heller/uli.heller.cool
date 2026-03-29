# Komplexe Beispiele zur Verwendung des webserver_stack Moduls

# Beispiel 1: Nur Apache ohne Tomcat
class { 'webserver_stack':
  apache_enabled  => true,
  tomcat_enabled  => false,
  webapp_enabled  => false,
}

# Beispiel 2: Custom Tomcat Port und Webapp Name
class { 'webserver_stack':
  apache_enabled   => true,
  tomcat_enabled   => true,
  webapp_enabled   => true,
  tomcat_port      => 9090,
  tomcat_version   => '9',
  webapp_name      => 'my-custom-app',
}

# Beispiel 3: Mehrere Webapps hinzufügen
class { 'webserver_stack':
  webapp_name => 'app1',
}

class { 'webserver_stack::webapp':
  webapp_name => 'app2',
  tomcat_home => '/opt/tomcat',
  require     => Class['webserver_stack::tomcat'],
}

class webserver_stack (
  Boolean $apache_enabled        = true,
  Boolean $tomcat_enabled        = true,
  Boolean $webapp_enabled        = true,
  Integer $tomcat_port           = 8080,
  Integer $tomcat_shutdown_port  = 8005,
  String $tomcat_version         = '9',
  String $webapp_name            = 'example-app',
) {

  if $apache_enabled {
    include webserver_stack::apache
  }

  if $tomcat_enabled {
    class { 'webserver_stack::tomcat':
      tomcat_port          => $tomcat_port,
      tomcat_shutdown_port => $tomcat_shutdown_port,
      tomcat_version       => $tomcat_version,
    }
  }

  if $webapp_enabled {
    class { 'webserver_stack::webapp':
      webapp_name  => $webapp_name,
      tomcat_home  => '/opt/tomcat',
      require      => Class['webserver_stack::tomcat'],
    }
  }

  if $apache_enabled and $tomcat_enabled {
    class { 'webserver_stack::reverse_proxy':
      tomcat_port => $tomcat_port,
      require     => [
        Class['webserver_stack::apache'],
        Class['webserver_stack::tomcat'],
      ],
    }
  }
}

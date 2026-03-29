class webserver_stack::webapp (
  String $webapp_name = 'example-app',
  String $tomcat_home = '/opt/tomcat',
) {

  # Webapps Verzeichnis erstellen falls nicht vorhanden
  file { "${tomcat_home}/webapps":
    ensure => directory,
    owner  => 'tomcat',
    group  => 'tomcat',
    mode   => '0755',
  }

  # Beispiel Webapp Verzeichnis erstellen
  file { "${tomcat_home}/webapps/${webapp_name}":
    ensure  => directory,
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0755',
    require => File["${tomcat_home}/webapps"],
  }

  # Beispiel index.jsp erstellen
  file { "${tomcat_home}/webapps/${webapp_name}/index.jsp":
    ensure  => present,
    content => epp('webserver_stack/index.jsp.epp', {
      'webapp_name' => $webapp_name,
    }),
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0644',
    require => File["${tomcat_home}/webapps/${webapp_name}"],
    notify  => Service['tomcat'],
  }

  # WEB-INF Verzeichnis erstellen
  file { "${tomcat_home}/webapps/${webapp_name}/WEB-INF":
    ensure  => directory,
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0755',
    require => File["${tomcat_home}/webapps/${webapp_name}"],
  }

  # web.xml Deployment Descriptor erstellen
  file { "${tomcat_home}/webapps/${webapp_name}/WEB-INF/web.xml":
    ensure  => present,
    content => file('webserver_stack/web.xml'),
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0644',
    require => File["${tomcat_home}/webapps/${webapp_name}/WEB-INF"],
    notify  => Service['tomcat'],
  }
}

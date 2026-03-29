class webserver_stack::tomcat (
  Integer $tomcat_port           = 8080,
  Integer $tomcat_shutdown_port  = 8005,
  String $tomcat_version         = '10',
) {

  # Java Laufzeitumgebung installieren
  $java_package = $::osfamily ? {
    'Debian' => 'openjdk-21-jre-headless',
    default  => 'java-21-openjdk',
  }

  package { $java_package:
    ensure => installed,
  }

  # Tomcat User erstellen
  user { 'tomcat':
    ensure  => present,
    home    => '/opt/tomcat',
    shell   => '/bin/nologin',
    system  => true,
  }

  # Tomcat Group erstellen
  group { 'tomcat':
    ensure => present,
    system => true,
  }

  # Tomcat Installation Verzeichnis erstellen
  file { '/opt/tomcat':
    ensure  => directory,
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0755',
    require => [
      User['tomcat'],
      Group['tomcat'],
    ],
  }

  # Tomcat herunterladen und installieren
  exec { 'download_tomcat':
    command => "cd /tmp && wget -q https://archive.apache.org/dist/tomcat/tomcat-${tomcat_version}/v${tomcat_version}.0.0/apache-tomcat-${tomcat_version}.0.0.tar.gz && tar -xzf apache-tomcat-${tomcat_version}.0.0.tar.gz -C /opt/tomcat --strip-components=1 && chown -R tomcat:tomcat /opt/tomcat",
    path    => ['/usr/bin', '/bin'],
    creates => '/opt/tomcat/bin/startup.sh',
    require => [
      File['/opt/tomcat'],
      Package['java-1.8.0-openjdk'],
    ],
  }

  # Tomcat server.xml Konfiguration
  file { '/opt/tomcat/conf/server.xml':
    ensure  => present,
    content => epp('webserver_stack/server.xml.epp', {
      'connector_port'   => $tomcat_port,
      'shutdown_port'    => $tomcat_shutdown_port,
    }),
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0600',
    require => Exec['download_tomcat'],
    notify  => Service['tomcat'],
  }

  # Tomcat Systemd Service erstellen
  file { '/etc/systemd/system/tomcat.service':
    ensure  => present,
    content => file('webserver_stack/tomcat.service'),
    mode    => '0644',
    require => Exec['download_tomcat'],
    notify  => Exec['systemd_reload'],
  }

  exec { 'systemd_reload':
    command     => 'systemctl daemon-reload',
    path        => ['/usr/bin', '/usr/sbin'],
    refreshonly => true,
  }

  # Tomcat Service starten und aktivieren
  service { 'tomcat':
    ensure    => running,
    enable    => true,
    require   => [
      File['/etc/systemd/system/tomcat.service'],
      Exec['systemd_reload'],
    ],
  }

  # Firewall öffnen für Tomcat
  if $::osfamily == 'Debian' {
    exec { 'open_tomcat_firewall':
      command => "ufw allow ${tomcat_port}/tcp",
      path    => ['/usr/bin', '/usr/sbin'],
      unless  => "ufw status | grep ${tomcat_port}",
      onlyif  => 'which ufw',
    }
  } else {
    exec { 'open_tomcat_firewall':
      command => "firewall-cmd --permanent --add-port=${tomcat_port}/tcp && firewall-cmd --reload",
      path    => ['/usr/bin', '/usr/sbin'],
      unless  => "firewall-cmd --list-all | grep ${tomcat_port}",
      onlyif  => 'which firewall-cmd',
    }
  }
}

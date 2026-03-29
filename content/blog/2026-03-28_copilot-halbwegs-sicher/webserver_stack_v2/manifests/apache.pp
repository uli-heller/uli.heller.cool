class webserver_stack::apache {

  # Apache httpd Paket installieren
  package { 'httpd':
    ensure => installed,
  }

  # Apache Modul proxy und proxy_http für Reverse Proxy aktivieren
  apache_module { ['proxy', 'proxy_http', 'rewrite', 'headers']:
    ensure => present,
  }

  # Apache Service starten und aktivieren
  service { 'httpd':
    ensure    => running,
    enable    => true,
    require   => [
      Package['httpd'],
      Apache_module['proxy'],
      Apache_module['proxy_http'],
    ],
  }

  # Firewall öffnen für HTTP
  if $::osfamily == 'Debian' {
    exec { 'open_http_firewall':
      command => 'ufw allow 80/tcp',
      path    => ['/usr/bin', '/usr/sbin'],
      unless  => 'ufw status | grep 80',
      onlyif  => 'which ufw',
    }
  } else {
    exec { 'open_http_firewall':
      command => 'firewall-cmd --permanent --add-service=http && firewall-cmd --reload',
      path    => ['/usr/bin', '/usr/sbin'],
      unless  => 'firewall-cmd --list-all | grep http',
      onlyif  => 'which firewall-cmd',
    }
  }
}

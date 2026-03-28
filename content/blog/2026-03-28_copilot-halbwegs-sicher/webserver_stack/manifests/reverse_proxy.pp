class webserver_stack::reverse_proxy (
  Integer $tomcat_port = 8080,
) {

  # Apache VirtualHost Konfiguration für Reverse Proxy
  file { '/etc/httpd/conf.d/reverse_proxy.conf':
    ensure  => present,
    content => epp('webserver_stack/reverse_proxy.conf.epp', {
      'tomcat_port' => $tomcat_port,
    }),
    mode    => '0644',
    notify  => Service['httpd'],
  }
}

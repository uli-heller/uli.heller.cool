# Webserver Stack Modul

Dieses Puppet-Modul installiert und konfiguriert:
- **Apache httpd** als Frontend Reverse Proxy
- **Tomcat** als Application Server
- **Eine Beispiel-Webapp** innerhalb von Tomcat

## Verwendung

```puppet
include webserver_stack
```

## Parameter

### webserver_stack

- `apache_enabled` (Boolean): Apache httpd installieren und aktivieren. Standard: `true`
- `tomcat_enabled` (Boolean): Tomcat installieren und aktivieren. Standard: `true`
- `webapp_enabled` (Boolean): Beispiel-Webapp bereitstellen. Standard: `true`
- `tomcat_port` (Integer): Port für Tomcat. Standard: `8080`
- `tomcat_shutdown_port` (Integer): Shutdown Port für Tomcat. Standard: `8005`
- `tomcat_version` (String): Tomcat Version. Standard: `10`
- `webapp_name` (String): Name der Webapp. Standard: `example-app`

## Beispiel mit eigenen Parametern

```puppet
class { 'webserver_stack':
  apache_enabled   => true,
  tomcat_enabled   => true,
  webapp_enabled   => true,
  tomcat_version   => '10',
  tomcat_port      => 8080,
  webapp_name      => 'myapp',
}
```

## Abhängigkeiten

Das Modul benötigt:
- puppetlabs/stdlib

## Unterstützte Betriebssysteme

- CentOS 7, 8
- RedHat 7, 8
- Ubuntu 18.04, 20.04, 22.04, 24.04

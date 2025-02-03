+++
date = '2025-02-07'
draft = false
title = 'Protokollieren von HTTP/HTTPS-Anfragen und -Antworten'
categories = [ 'Netzwerk' ]
tags = [ 'network', 'linux', 'ubuntu' ]
+++

<!--
Protokollieren von HTTP/HTTPS-Anfragen und -Antworten
=====================================================
-->

Das Programm HTTPTAP scheint es auf sehr einfache Art
und Weise zu ermöglichen, den HTTP/HTTPS-Verkehr zu protokollieren.
Ein Testbericht!

<!--more-->

Vorabtest: Release herunterladen und auf Viren prüfen
-----------------------------------------------------

- [httptap_linux_x86_64.tar.gz](https://github.com/monasticacademy/httptap/releases/download/v0.0.8/httptap_linux_x86_64.tar.gz) herunterladen
- Hochladen nach VirusTotal.com
- Prüfergebnis: OK

Quellen clonen
--------------

```
git clone git@github.com:monasticacademy/httptap.git
cd httptap
```

Bauen
-----

```
make
# httptap
```

Test
----

```
$ ./httptap --help
Usage: httptap [--verbose] [--no-new-user-namespace] [--stderr] [--tun TUN] [--subnet SUBNET] [--gateway GATEWAY] [--webui WEBUI] [--user USER
] [--no-overlay] [--stack STACK] [--dump-tcp] [--dump-har DUMP-HAR] [--http HTTP] [--https HTTPS] [--head] [--body] [COMMAND [COMMAND ...]]

Positional arguments:
  COMMAND

Options:
  --verbose, -v [env: HTTPTAP_VERBOSE]
  --no-new-user-namespace
                         do not create a new user namespace (must be run as root) [env: HTTPTAP_NO_NEW_USER_NAMESPACE]
  --stderr               log to standard error (default is standard out) [env: HTTPTAP_LOG_TO_STDERR]
  --tun TUN              name of the TUN device that will be created [default: httptap]
  --subnet SUBNET        IP address of the network interface that the subprocess will see [default: 10.1.1.100/24]
  --gateway GATEWAY      IP address of the gateway that intercepts and proxies network packets [default: 10.1.1.1]
  --webui WEBUI          address and port to serve API on [env: HTTPTAP_WEB_UI]
  --user USER            run command as this user (username or id)
  --no-overlay           do not mount any overlay filesystems [env: HTTPTAP_NO_OVERLAY]
  --stack STACK          which tcp implementation to use: 'gvisor' or 'homegrown' [default: gvisor, env: HTTPTAP_STACK]
  --dump-tcp             dump all TCP packets sent and received to standard out [env: HTTPTAP_DUMP_TCP]
  --dump-har DUMP-HAR    path to dump HAR capture to [env: HTTPTAP_DUMP_HAR]
  --http HTTP            list of TCP ports to intercept HTTPS traffic on [default: [80]]
  --https HTTPS          list of TCP ports to intercept HTTP traffic on [default: [443]]
  --head                 whether to include HTTP headers in terminal output
  --body                 whether to include HTTP payloads in terminal output
  --help, -h             display this help and exit

$ ./httptap -- firefox
...
error reading http request over tls server conn: remote error: tls: unknown certificate authority, aborting
error reading http request over tls server conn: remote error: tls: bad certificate, aborting
---> GET https://detectportal.firefox.com/canonical.html
<--- 200 https://detectportal.firefox.com/canonical.html (90 bytes)
error reading http request over tls server conn: remote error: tls: bad certificate, aborting
error reading http request over tls server conn: remote error: tls: bad certificate, aborting
---> GET https://detectportal.firefox.com/success.txt?ipv4
<--- 200 https://detectportal.firefox.com/success.txt?ipv4 (8 bytes)
error reading http request over tls server conn: remote error: tls: bad certificate, aborting
...
```

Fazit
-----

Es klappt nicht so richtig, weil der Browser der CA von HTTPTAP
nicht vertraut! Eigentlich klar! Trotzdem schade ...oder auch beruhigend!

Links
-----

- [Github - httptap](https://github.com/monasticacademy/httptap)

Historie
--------

- 2025-02-07: Erste Version

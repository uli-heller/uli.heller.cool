+++
date = '2024-11-29'
draft = true
title = 'LXC: Kein Zugriff auf\'s Internet'
categories = [ 'LXC/LXD' ]
tags = [ 'lxc', 'lxd', 'linux', 'ubuntu', 'debian' ]
+++

<!--
LXC: Kein Zugriff auf's Internet
================================
-->

Heute habe ich auf meinem Laptop
erstmals mit LXC/LXD rumgespielt.
Leider gab es Probleme beim Zugriff
auf das Internet aus einem Container heraus!

<!--more-->

Vorbemerkung
------------

Die LXC/LXD-Grundinitialisierung
beschreibe ich in einer anderen Anleitung!
Hier konzentriere ich mich auf
obiges Problem!

Container anlegen und aktualisieren
-----------------------------------

Container anlegen:

```
$ lxc launch ubuntu:24.04 build-2404
Creating build-2404
Starting build-2404
```

Container aktualisieren:

```
$ lxc exec build-2404 apt update
Ign:1 http://archive.ubuntu.com/ubuntu noble InRelease                                                               
Ign:2 http://archive.ubuntu.com/ubuntu noble-updates InRelease                                                       
...
W: Failed to fetch http://security.ubuntu.com/ubuntu/dists/noble-security/InRelease  Cannot initiate the connection to security.ubuntu.com:80 (2620:2d:4000:1::102). - connect (101: Network is unreachable) Cannot initiate the connection to security.ubuntu.com:80 (2620:2d:4000:1::103). - connect (101: Network is unreachable) Cannot initiate the connection to security.ubuntu.com:80 (2620:2d:4002:1::103). - connect (101: Network is unreachable) Cannot initiate the connection to security.ubuntu.com:80 (2620:2d:4002:1::102). - connect (101: Network is unreachable) Cannot initiate the connection to security.ubuntu.com:80 (2620:2d:4000:1::101). - connect (101: Network is unreachable) Cannot initiate the connection to security.ubuntu.com:80 (2620:2d:4002:1::101). - connect (101: Network is unreachable) Could not connect to security.ubuntu.com:80 (91.189.91.83), connection timed out Could not connect to security.ubuntu.com:80 (91.189.91.82), connection timed out Could not connect to security.ubuntu.com:80 (185.125.190.82), connection timed out Could not connect to security.ubuntu.com:80 (185.125.190.83), connection timed out Could not connect to security.ubuntu.com:80 (91.189.91.81), connection timed out Could not connect to security.ubuntu.com:80 (185.125.190.81), connection timed out
W: Some index files failed to download. They have been ignored, or old ones used instead.
```

Die Aktualisierung klappt nicht!

Kurztest Internet-Zugriff:

```
$ lxc exec build-2404 -- nc -z -w5 -v google.com 443
nc: connect to google.com (142.250.186.110) port 443 (tcp) timed out: Operation now in progress
nc: connect to google.com (2a00:1450:4001:829::200e) port 443 (tcp) failed: Network is unreachable
```

Internet-Zugriff klappt nicht!

Kurzanalyse auf dem Laptop
--------------------------

```
$ sudo iptables -L
[sudo] Passwort für uli: 
# Warning: iptables-legacy tables present, use iptables-legacy to see them
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy DROP)
target     prot opt source               destination         
DOCKER-USER  all  --  anywhere             anywhere            
DOCKER-ISOLATION-STAGE-1  all  --  anywhere             anywhere            
ACCEPT     all  --  anywhere             anywhere             ctstate RELATED,ESTABLISHED
DOCKER     all  --  anywhere             anywhere            
ACCEPT     all  --  anywhere             anywhere            
ACCEPT     all  --  anywhere             anywhere            

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain DOCKER (1 references)
target     prot opt source               destination         

Chain DOCKER-ISOLATION-STAGE-1 (1 references)
target     prot opt source               destination         
DOCKER-ISOLATION-STAGE-2  all  --  anywhere             anywhere            
RETURN     all  --  anywhere             anywhere            

Chain DOCKER-ISOLATION-STAGE-2 (1 references)
target     prot opt source               destination         
DROP       all  --  anywhere             anywhere            
RETURN     all  --  anywhere             anywhere            

Chain DOCKER-USER (1 references)
target     prot opt source               destination         
RETURN     all  --  anywhere             anywhere           
```

Es werden ungewöhnlich viele Regeln angezeigt.
Sie scheinen mit Docker zusammenzuhängen.

```
$ dpkg -l docker.io
Gewünscht=Unbekannt/Installieren/R=Entfernen/P=Vollständig Löschen/Halten
| Status=Nicht/Installiert/Config/U=Entpackt/halb konFiguriert/
         Halb installiert/Trigger erWartet/Trigger anhängig
|/ Fehler?=(kein)/R=Neuinstallation notwendig (Status, Fehler: GROSS=schlecht)
||/ Name           Version                 Architektur  Beschreibung
+++-==============-=======================-============-=================================
ii  docker.io      24.0.7-0ubuntu2~22.04.1 amd64        Linux container runtime
```

Korrekturversuch - Docker löschen
---------------------------------

```
$ sudo apt purge docker.io
Paketlisten werden gelesen… Fertig
Abhängigkeitsbaum wird aufgebaut… Fertig
Statusinformationen werden eingelesen… Fertig
Die folgenden Pakete wurden automatisch installiert und werden nicht mehr benötigt:
  containerd libclamav9 libtfm1 pigz runc ubuntu-fan
Verwenden Sie »sudo apt autoremove«, um sie zu entfernen.
Die folgenden Pakete werden ENTFERNT:
  docker.io*
0 aktualisiert, 0 neu installiert, 1 zu entfernen und 0 nicht aktualisiert.
Nach dieser Operation werden 108 MB Plattenplatz freigegeben.
Möchten Sie fortfahren? [J/n] J
...
```

Leider klappt der Internet-Zugriff noch immer nicht:

```
$ lxc exec build-2404 -- nc -z -w5 -v google.com 443
nc: connect to google.com (142.250.186.110) port 443 (tcp) timed out: Operation now in progress
nc: connect to google.com (2a00:1450:4001:80e::200e) port 443 (tcp) failed: Network is unreachable
```

Es gibt auch immer noch viele Regeln in `iptables` für Docker:

```
$ sudo iptables -L
...
Chain DOCKER-USER (1 references)
target     prot opt source               destination         
RETURN     all  --  anywhere             anywhere            
```

Korrekturversuch - Reboot
-------------------------

Versionen
---------

- Getestet mit Ubuntu 22.04.5 LTS auf dem Host
- Getestet mit LXC-6.1, snap version und docker.io-24.0.7
- Getestet mit Ubuntu 24.04.1 LTS im Container

Historie
--------

- 2024-11-29: Erste Version

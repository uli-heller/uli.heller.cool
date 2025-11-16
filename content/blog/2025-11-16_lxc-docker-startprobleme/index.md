+++
date = '2025-11-16'
draft = false
title = 'LXC/LXD: Docker - Startprobleme im Ubuntu-Container'
categories = [ 'LXC/LXD' ]
tags = [ 'incus', 'lxc', 'lxd', 'docker', 'linux', 'ubuntu' ]
+++

<!--
LXC/LXD: Docker - Startprobleme im Ubuntu-Container
============================
-->

Seit neuestem startet Docker in einem Ubuntu-Container
nicht mehr. Man erhält Fehlermeldungen wie diese:

```
root@docker-2404:~# docker run hello-world
docker: Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: open sysctl net.ipv4.ip_unprivileged_port_start file: reopen fd 8: permission denied: unknown

Run 'docker run --help' for more information
```

Betroffen sind Container mit LXD/LXC und INCUS.
Hier einige Lösungsvarianten!

<!--more-->

AppArmor für RUNC deaktivieren
------------------------------

Eine Möglichkeit besteht darin, innerhalb des Containers
AppArmor für RUNC zu deaktivieren:

```
$ incus exec docker-2404 bash

root@docker-2404:~# ln -s /etc/apparmor.d/runc /etc/apparmor.d/disable/
root@docker-2404:~# apparmor_parser -R  /etc/apparmor.d/runc
```

Danach klappt es wieder!

Ältere Version von RUNC verwenden
---------------------------------

Das Problem tritt auf, seit RUNC auf die Version 1.3.3 aktualisiert wurde.
Es verschwindet, wenn man eine ältere Version einspielt:

```
                    # Verfügbare Versionen von "runc" ermitteln
root@docker-2404:~# apt-cache policy runc
runc:
  Installed: 1.3.3-0ubuntu1~24.04.2
  Candidate: 1.3.3-0ubuntu1~24.04.2
  Version table:
 *** 1.3.3-0ubuntu1~24.04.2 500
        500 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages
        500 http://security.ubuntu.com/ubuntu noble-security/main amd64 Packages
        100 /var/lib/dpkg/status
     1.1.12-0ubuntu3 500
        500 http://archive.ubuntu.com/ubuntu noble/main amd64 Packages

                    # Ältere Version einspielen
root@docker-2404:~# apt-cache install runc=1.1.12-0ubuntu3
```

Danach klappt es wieder!

**ACHTUNG**: Die ältere Version enthält gravierende Sicherheitslücken!
Keine gute Lösung!

Zurück zu 1.3.3:

```
root@docker-2404:~# apt update
root@docker-2404:~# apt upgrade
```

Vorabversion von LXD/LXC einspielen
-----------------------------------

Bei Verwendung von LXD/LXC funktioniert Stand 2025-11-16
die Umstellung auf eine Vorabversion:

```
        # Verfügbare SNAPs sichten
host:~$ snap info lxd
...
  6/stable:         6.5-ccdfb39    2025-10-09 (36020) 118MB -
  6/candidate:      6.5-dc8291a    2025-11-11 (36535) 118MB -
  6/beta:           ↑                                       
  6/edge:           git-4d61f62    2025-11-14 (36613) 119MB -
...

        # Es gibt eine SEHR neue -> die probieren wir!
host:~$ snap refresh lxd --channel=edge
```

Danach den Docker-Container durchstarten
und es klappt wieder!

Spezialversion für INCUS
------------------------

Bei Ubuntu-24.04 ist INCUS in der Version 6.0.0
enthalten. Für die neueste, noch nicht veröffentlichte
INCUS-Version gibt es einen Patch für das Problem.
Dieser kann auch in 6.0.0 eingebaut werden mit
geringen Anpassungen.

Hier der angepasste Patch: [999-runc-133.patch](999-runc-133.patch)

Baut man INCUS-6.0.0 mit diesem Patch und
startet den Docker-Container durch, dann klappt
es wieder!

Versionen
---------

- Getestet unter Ubuntu 22.04 mit LXD-6.5-ccdfb39 (Snap-Version stable)
  und git-4d61f62 (Snap-Version edge)
- Getestet unter Ubuntu-2404 mit INCUS-6.0.0

Links
-----

- [incusd/apparmor/lxc: Don't bother with sys/proc protections when nesting enabled](https://github.com/lxc/incus/pull/2624/commits/1fbe4bffb9748cc3b07aaf5db310d463c1e827d0)

Historie
--------

- 2025-11-16: Erste Version

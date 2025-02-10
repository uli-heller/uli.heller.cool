+++
date = '2025-02-04'
draft = false
title = 'LXC/LXD: Docker im Ubuntu-24.04-Container'
categories = [ 'LXC/LXD' ]
tags = [ 'lxc', 'lxd', 'docker', 'linux', 'ubuntu' ]
+++

<!--
LXC/LXD: Docker im Container
============================
-->

Wenn man sich für OpenSource-Software interessiert,
kommt man heutzutage fast nicht an Docker vorbei.
Zahlreiche Programme werden als Docker-Container angeboten
und können so sehr einfach getestet werden.

Problem: Die Kombination aus Dockerfile und Image
trennt den Arbeitsplatzrechner nur sehr ungenügend
von der Fremdsoftware. Ohne detaillierte Prüfung kann
ich nicht sicher sein, dass mein Rechner nicht kompromittiert
wird.

Abhilfe: Docker im LXC/LXD-Container!

<!--more-->

Container anlegen
-----------------

```
$ lxc copy ubuntu-2404 docker
```

Container konfigurieren
-----------------------

```
$ lxc config set docker \
  security.idmap.size=700000 \
  security.nesting=true \
  security.syscalls.intercept.mknod=true \
  security.syscalls.intercept.setxattr=true
```

Container starten
-----------------

```
$ lxc start docker
$ lxc ls docker
+--------+---------+----------------------+------+-----------+-----------+
|  NAME  |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+--------+---------+----------------------+------+-----------+-----------+
| docker | RUNNING | 10.38.231.226 (eth0) |      | CONTAINER | 0         |
+--------+---------+----------------------+------+-----------+-----------+
```

Docker im Container installieren
--------------------------------

```
$ lxc exec docker bash

root@docker:~# apt update
Hit:1 http://archive.ubuntu.com/ubuntu noble InRelease
Get:2 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:3 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
...
Building dependency tree... Done
Reading state information... Done
42 packages can be upgraded. Run 'apt list --upgradable' to see them.

root@docker:~# apt upgrade -y
...
Setting up netplan.io (1.1.1-1~ubuntu24.04.1) ...
Setting up ssh-import-id (5.11-0ubuntu2.24.04.1) ...
Processing triggers for systemd (255.4-1ubuntu8.4) ...
Processing triggers for dbus (1.14.10-4ubuntu4.1) ...
Processing triggers for libc-bin (2.39-0ubuntu8.3) ...

root@docker:~# apt install docker.io -y
...

root@docker:~# ln -s /etc/apparmor.d/runc /etc/apparmor.d/disable/
root@docker:~# apparmor_parser -R  /etc/apparmor.d/runc
```

Kurztest
--------

```
root@docker:~# docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
e6590344b1a5: Pull complete
Digest: sha256:d715f14f9eca81473d9112df50457893aa4d099adeb4729f679006bf5ea12407
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash
...
```

Probleme
--------

### error jailing process inside rootfs: pivot_root .: permission denied

Ausführen des Kurztests scheitert mit obiger Meldung:

```
root@docker:~# docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
e6590344b1a5: Pull complete
Digest: sha256:d715f14f9eca81473d9112df50457893aa4d099adeb4729f679006bf5ea12407
Status: Downloaded newer image for hello-world:latest
docker: Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: error jailing process inside rootfs: pivot_root .: permission denied: unknown.
```

Zur Korrektur im Container dies ausführen:

```
root@docker:~# ln -s /etc/apparmor.d/runc /etc/apparmor.d/disable/
root@docker:~# apparmor_parser -R  /etc/apparmor.d/runc
```

Danach klappt's:

```
root@docker:~# docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
...
```

Versionen
---------

- Getestet unter Ubuntu 22.04 mit LXD-6.2-bde4d03
  (Snap-Version)
- Getestet mit einem Ubuntu 24.04 Container
  und docker.io 26.1.3-0ubuntu1~24.04.1

Links
-----

- [Github - Ubuntu 24.04 AppArmor breaks pivot_root inside LXD containers](https://github.com/canonical/lxd/issues/13389)
- [daemons-point.com - Docker in LXD/LXC-Container](https://daemons-point.com/blog/2022/12/25/docker-in-lxc-container/)

Historie
--------

- 2025-02-10: security.idmap.size=700000
- 2025-02-04: Erste Version

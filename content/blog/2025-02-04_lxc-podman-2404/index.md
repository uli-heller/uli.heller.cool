+++
date = '2025-02-04'
draft = false
title = 'LXC/LXD: Podman im Container mit Ubuntu-24.04'
categories = [ 'LXC/LXD' ]
tags = [ 'lxc', 'lxd', 'docker', 'podman', 'linux', 'ubuntu' ]
+++

<!--
LXC/LXD: Podman im Container mit Ubuntu-24.04
=============================================
-->

Podman soll ziemlich ähnlich funktionieren
wie Docker. Also schnell mal austesten in einem
LXC-Container mit mit Ubuntu-22.04!

<!--more-->

Container anlegen
-----------------

```
$ lxc copy ubuntu-2404 podman
```

Container konfigurieren
-----------------------

```
$ lxc config set podman \
  security.nesting=true \
  security.syscalls.intercept.mknod=true \
  security.syscalls.intercept.setxattr=true
```

Container starten
-----------------

```
$ lxc start podman
$ lxc ls podman
+-------------+---------+---------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4        | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+---------------------+------+-----------+-----------+
| podman      | RUNNING | 10.38.231.76 (eth0) |      | CONTAINER | 0         |
+-------------+---------+---------------------+------+-----------+-----------+
```

Podman im Container installieren
--------------------------------

```
$ lxc exec podman bash

root@podman:~# apt update
Hit:1 http://archive.ubuntu.com/ubuntu noble InRelease
Get:2 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:3 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
...
Building dependency tree... Done
Reading state information... Done

root@podman:~# apt upgrade -y
...

root@podman:~# apt install podman -y
...
```

Kurztest
--------

```
root@podman:~# podman run hello-world
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

Podman läuft in einem Ubuntu-24.04-Container wesentlich problemloser
als Docker! Für Docker müssen Anpassungen bzgl. AppArmor
vorgenommen werden, für Podman nicht!

Versionen
---------

- Getestet unter Ubuntu 22.04 mit LXD-6.2-bde4d03
  (Snap-Version)
- Getestet mit einem Ubuntu 24.04 Container
  und podman 4.9.3+ds1-1ubuntu0.2

Links
-----

- [Github - Ubuntu 24.04 AppArmor breaks pivot_root inside LXD containers](https://github.com/canonical/lxd/issues/13389)
- [daemons-point.com - Docker in LXD/LXC-Container](https://daemons-point.com/blog/2022/12/25/docker-in-lxc-container/)

Historie
--------

- 2025-02-04: Erste Version

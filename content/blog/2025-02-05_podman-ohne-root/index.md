+++
date = '2025-02-05'
draft = false
title = 'LXC/LXD: Podman ohne "root"'
categories = [ 'LXC/LXD' ]
tags = [ 'lxc', 'lxd', 'docker', 'podman', 'linux', 'ubuntu' ]
+++

<!--
LXC/LXD: Podman ohne "root"
===========================
-->

Ich experimentiere mit dem Docker-Ersatz "podman"
in meinen Containern und schaue, was beim Einsatz
ohne "root" so geht. Idealerweise ist's damit
schwieriger Systemlücken auszunutzen.

<!--more-->

Ausgangspunkt
-------------

Container mit Podman, bspw.

- [LXC/LXD: Podman im Container mit Ubuntu-24.04]({{< ref "/blog/2025-02-01_lxc-podman-2404" >}})
- [LXC/LXD: Podman im Container mit Ubuntu-22.04]({{< ref "/blog/2025-02-03_lxc-podman-2204" >}})

Kurztest
--------

- LXC-Container starten: `lxc start podman`
- Im LXC-Container anmelden als "Nicht-Root": `ssh ubuntu@podman.lxd`
- Test:
  ```
  ubuntu@podman:~$ podman run hello-world
  Resolved "hello-world" as an alias (/etc/containers/registries.conf.d/shortnames.conf)
  Trying to pull docker.io/library/hello-world:latest...
  Getting image source signatures
  ...
  Hello from Docker!
  ...
  ```
- Klappt! Super!


Bind-Mount-Lücke
----------------

Ich versuche, im LXC-Container einen Podman/Docker-Container
zu starten mit Zugriff auf Teile des Dateisystems
vom LXC-Container. Genauer soll der Podman/Docker-Container
auf das Verzeichnis "/etc" zugreifen können.

Mit Docker klappt das problemlos. Der Docker-Container kann
"/etc" vom LXC-Container "sehen" und auch modifizieren.
Hoffentlich geht es mit Podman "besser" im Sinne: Modifizieren
klappt nicht!

Innerhalb des LXC-Containers:

```
ubuntu@podman:~$ podman run --volume /etc:/mnt -it ubuntu bash
...
root@3a9222cb719b:/# ls -l /mnt/passwd
-rw-r--r-- 1 nobody nogroup 1193 Nov 15 14:11 /mnt/passwd

root@2d5e5e8aaaea:/# touch /mnt/uli-war-da
touch: cannot touch '/mnt/uli-war-da': Permission denied

root@3a9222cb719b:/# cat /mnt/shadow
cat: /mnt/shadow: Permission denied

root@3a9222cb719b:/# cat /mnt/shadow-
cat: /mnt/shadow-: Permission denied
```

Sieht ziemlich perfekt aus. "root" innerhalb vom
Podman/Docker-Container hat gleiche/ähnliche Rechte
wie "ubuntu" im LXC-Container!

Tests mit anderen Varianten
---------------------------

- LXC-Container: Ubuntu-24.04, Podman -> Rechte eingeschränkt
- LXC-Container: Ubuntu-22.04, Podman -> Rechte eingeschränkt
- LXC-Container: Ubuntu-24.04, Docker -> Rechte **nicht** eingeschränkt
- LXC-Container: Ubuntu-22.04, Docker -> Rechte **nicht** eingeschränkt

Damit Docker im LXC-Container unter dem Benutzer "ubuntu"
ausgeführt werden kann, muß dieser der Gruppe "docker"
hinzugefügt werden:

```
root@docker-2204:~# usermod -aG docker ubuntu
```

Eventuell hilft "rootless docker" etwas.
Das habe ich (noch) nicht untersucht!

Probleme
--------

### Ubuntu-20.04: "newuidmap: write to uid_map failed"

Ich habe PODMAN auch getestet auf einem Rechner mit Ubuntu-20.04, dabei gibt es Probleme.

/etc/lsb-release:

```
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=20.04
DISTRIB_CODENAME=focal
DISTRIB_DESCRIPTION="Ubuntu 20.04.6 LTS"
```

Sonstige Versionen:

```sh
ubuntu-20.04:~ # uname -r
5.15.0-131-generic

ubuntu-20.04:~ # lxc version
Client version: 6.2
Server version: 6.2

ubuntu-20.04:~ # snap list lxd
Name  Version      Rev    Tracking       Publisher   Notes
lxd   6.2-bde4d03  31820  latest/stable  canonical✓  -
```

Damit:

```sh
ubuntu-20.04:~ # lxc copy ubuntu-2404 podman-2404
ubuntu-20.04:~ # lxc config set podman-2404 security.nesting=true security.syscalls.intercept.mknod=true security.syscalls.intercept.setxattr=true
ubuntu-20.04:~ # lxc start podman-2404
ubuntu-20.04:~ # lxc ls podman-2404
+-------------+---------+---------------------+------+-----------+-----------+
|    NAME     |  STATE  |        IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+---------------------+------+-----------+-----------+
| podman-2404 | RUNNING | 10.38.131.38 (eth0) |      | CONTAINER | 0         |
+-------------+---------+---------------------+------+-----------+-----------+
ubuntu-20.04:~ # lxc exec podman-2404 bash

root@podman-2404:~# apt install -y podman
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following package was automatically installed and is no longer required:
  libfuse2t64
Use 'apt autoremove' to remove it.
The following additional packages will be installed:
...

root@podman-2404:~# podman run hello-world
Resolved "hello-world" as an alias (/etc/containers/registries.conf.d/shortnames.conf)
Trying to pull docker.io/library/hello-world:latest...
Getting image source signatures
Copying blob e6590344b1a5 done   | 
Copying config 74cc54e27d done   | 
Writing manifest to image destination

Hello from Docker!
...

root@podman-2404:~# exit
ubuntu-20.04:~ # ssh ubuntu@podman-2404.lxd

ubuntu@podman-2404:~$ podman run hello-world
ERRO[0000] running `/usr/bin/newuidmap 508 0 1000 1 1 100000 65536`: newuidmap: write to uid_map failed: Operation not permitted 
Error: cannot set up namespace using "/usr/bin/newuidmap": exit status 1
```

Umstellung auf "cgroups v2" bringt keine Besserung!

Lösung: [Unable to run rootless docker/podman under a (rootless) LXD container](https://discuss.linuxcontainers.org/t/unable-to-run-rootless-docker-podman-under-a-rootless-lxd-container/15276)

- Im Podman-Container: `cat /proc/self/uid_map` -> nur 65536 UIDs sind möglich
- Host-Rechner:
  - `lxc config set podman-2404 security.idmap.size=200000`
  - `lxc stop podman-2404`
  - `lxc start podman-2404`
- Danach klappt es!

Versionen
---------

- Getestet unter Ubuntu 22.04 mit LXD-6.2-bde4d03
  (Snap-Version)
- Getestet mit Ubuntu-24.04 und Ubuntu-22.04-Containern
  jeweils mit Docker und Podman

Links
-----

- [LXC/LXD: Podman im Container mit Ubuntu-24.04]({{< ref "/blog/2025-02-01_lxc-podman-2404" >}})
- [LXC/LXD: Podman im Container mit Ubuntu-22.04]({{< ref "/blog/2025-02-03_lxc-podman-2204" >}})
- [Github - Ubuntu 24.04 AppArmor breaks pivot_root inside LXD containers](https://github.com/canonical/lxd/issues/13389)
- [daemons-point.com - Docker in LXD/LXC-Container](https://daemons-point.com/blog/2022/12/25/docker-in-lxc-container/)
- [linuxcontainers.org - Unable to run rootless docker/podman under a (rootless) LXD container](https://discuss.linuxcontainers.org/t/unable-to-run-rootless-docker-podman-under-a-rootless-lxd-container/15276)

Historie
--------

- 2025-02-10: Problemlösung
- 2025-02-08: Korrektur des Formatierungsproblems, Problem mit 20.04
- 2025-02-05: Erste Version

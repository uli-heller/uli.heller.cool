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

Historie
--------

- 2025-02-05: Erste Version

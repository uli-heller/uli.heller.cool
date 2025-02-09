+++
date = '2025-02-11'
draft = false
title = 'Ubuntu-20.04: Umstellen auf CGROUPS v2'
categories = [ 'Ubuntu' ]
tags = [ 'linux', 'ubuntu' ]
+++

<!--
Ubuntu-20.04: Umstellen auf CGROUPS v2
======================================
-->

Ich habe Probleme mit LXC/LXD-Containern
und vermute, dass es an CGROUPS liegt.
Mein Host-Rechner unter Ubuntu-20.04
verwendet noch CGROUPS v1 und nicht CGROUPS v2.

Hier beschreibe ich die Umstellung!

<!--more-->

Unterstützte Varianten von CGROUPS ermitteln
--------------------------------------------

```sh
ubuntu-20.04# grep cgroup /proc/filesystems
nodev	cgroup
nodev	cgroup2
```

Aktive Variante von CGROUPS ermitteln
-------------------------------------

```sh
ubuntu-20.04# stat -fc %T /sys/fs/cgroup
tmpfs
```

Wenn das Kommando "tmpfs" ausgibt, dann ist CGROUPS v1 aktiv.
Bei CGROUPS v2 wird "cgroup2fs" ausgegeben!

Ausgangspunkt
-------------

- Ubuntu-20.04
- CGROUPS v1 ist aktiv
- CGROUPS v1 ud v2 werden unterstützt

Änderungen
----------

### /etc/default/grub

```diff
--- /etc/default/grub.orig	2025-02-10 00:10:25.236762113 +0100
+++ /etc/default/grub	2025-02-10 00:09:36.464777672 +0100
@@ -8,7 +8,7 @@
 GRUB_HIDDEN_TIMEOUT_QUIET=false
 GRUB_TIMEOUT=5
 GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
-GRUB_CMDLINE_LINUX_DEFAULT="nomodeset consoleblank=0"
+GRUB_CMDLINE_LINUX_DEFAULT="nomodeset consoleblank=0 systemd.unified_cgroup_hierarchy=1"
 GRUB_CMDLINE_LINUX=""
```

### Aktivieren

```
update-grub
apt upgrade
reboot
```

Nachkontrolle
-------------

```sh
ubuntu-20.04# stat -fc %T /sys/fs/cgroup
cgroup2fs
```

Test: Klappt's nun mit Podman?
------------------------------

```
lxc start podman-2404
ssh ubuntu@podman-2404.lxd
podman run hello-world
# klappt leider nicht!
```

Leider erscheint noch immer diese Fehlermeldung:

```
ubuntu@podman-2404:~$ podman run hello-world
ERRO[0000] running `/usr/bin/newuidmap 257 0 1000 1 1 100000 65536`: newuidmap: write to uid_map failed: Operation not permitted 
Error: cannot set up namespace using "/usr/bin/newuidmap": exit status 1
```

Versionen
---------

- Getestet unter Ubuntu 20.04

Links
-----

- [webuzo - So aktivieren Sie cGroups v2](https://webuzo-com.translate.goog/docs/how-tos/how-to-enable-cgroups-v2/?_x_tr_sl=en&_x_tr_tl=de&_x_tr_hl=de&_x_tr_pto=rq)

Historie
--------

- 2025-02-11: Erste Version

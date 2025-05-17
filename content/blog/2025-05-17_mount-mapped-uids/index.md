+++
date = '2025-05-17'
draft = false
title = 'Ubuntu: Dateisystem mit Nutzeranpassung einhängen'
categories = [ 'linux' ]
tags = [ 'linux', 'ubuntu', 'debian' ]
+++

<!--
Ubuntu: Dateisystem mit Nutzeranpassung einhängen
=================================================
-->

Bei Verwendung von LXC/LXD/INCUS
werden bei mir innerhalb der betreffenden Container
andere IDs für die typischen Unix-Nutzer verwendet
als außerhalb, also bspw. habe ich einen INCUS-Container
"u-2404" und dessen Nutzer "root" mit einer UID von 0
innerhalb vom Container nutzt "real" die UID 165536.

Im Dateisystem auf dem Arbeitsplatzrechner tauchen dann die
"realen" UIDs auf. Manchmal möchte man das Dateisystem aber
mit den "richtigen" UIDs "sehen" - also so, wie innerhalb des
Containers. Das kann man mit "Bind Mounts" erreichen und
hier beschreibe ich, wie das geht.

<!-- more -->

## Sichtung des Container-Dateisystems

Das zugehörige Container-Dateisystem sieht so aus:

```sh
$ sudo ls -la /var/lib/incus/storage-pools/default/containers/u-2404/rootfs/
insgesamt 16
drwxr-xr-x 1 165536 165536  236 Apr 22 09:56 .
d--x------ 1 165536 root     78 Apr 24 18:58 ..
lrwxrwxrwx 1 165536 165536    7 Apr 22  2024 bin -> usr/bin
drwxr-xr-x 1 165536 165536    0 Feb 26  2024 bin.usr-is-merged
drwxr-xr-x 1 165536 165536    0 Apr 22  2024 boot
...
```

Man sieht: Statt "root" taucht die "merkwürdige" UID auf.

## Einbinden mit "X-mount.idmap"

Wenn man einen Arbeitsplatzrechner hat, der eine hinreichend neue Version
von util-linux verwendet, dann kann man "X-mount.idmap" verwenden.

- KO: util-linux     2.37.2-4ubuntu3.4 (= Ubuntu-22.04)
- OK: util-linux     2.39.3-9ubuntu6.2 (= Ubuntu-24.04)
- Man benötigt wohl mindestens die Version 2.39
- Überprüfen mit `dpkg -l util-linux`

Wenn die Voraussetzungen erfüllt sind, dann
klappt es so:

```sh
$ INCUS_FS=/var/lib/incus/storage-pools/default/containers/u-2404/rootfs/
$ INCUS_UID=165536
$ INCUS_UID_CNT=65535
$ MOUNT_PT=/tmp/mount-test
$ mkdir "${MOUNT_PT}"       # Einhängepunkt anlegen
$ sudo mount -o "bind,X-mount.idmap=b:${INCUS_UID}:0:${INCUS_UID_CNT}" "${INCUS_FS}" "${MOUNT_PT}"

$ ls -al "${MOUNT_PT}"
insgesamt 20
drwxr-xr-x  1 root root  236 Apr 22 09:56 .
drwxrwxrwt 32 root root 4096 Mai 17 07:46 ..
lrwxrwxrwx  1 root root    7 Apr 22  2024 bin -> usr/bin
drwxr-xr-x  1 root root    0 Feb 26  2024 bin.usr-is-merged
drwxr-xr-x  1 root root    0 Apr 22  2024 boot
...

$ la -aln "${MOUNT_PT}/home/ubuntu"
insgesamt 16
drwxr-x--- 1 1000 1000   80 Apr 24 19:00 .
drwxr-xr-x 1    0    0   12 Apr 22 09:46 ..
-rw------- 1 1000 1000    5 Apr 24 19:00 .bash_history
-rw-r--r-- 1 1000 1000  220 Mär 31  2024 .bash_logout
...

$ sudo umount "${MOUNT_PT}"
$ rmdir "${MOUNT_PT}"
```

## Einbinden mit "bindfs"

Bei fast allen Varianten von Arbeitsplatzrechnern
klappt das Einbingen mit "bindfs":

```
$ INCUS_FS=/var/lib/incus/storage-pools/default/containers/u-2404/rootfs/
$ INCUS_UID=165536
$ INCUS_GID=${INCUS_UID}
$ MOUNT_PT=/tmp/mount-test
$ mkdir "${MOUNT_PT}"       # Einhängepunkt anlegen
$ sudo bindfs "--uid-offset=-${INCUS_UID}" "--gid-offset=-${INCUS_GID}" "${INCUS_FS}" "${MOUNT_PT}"

$ ls -al "${MOUNT_PT}"
insgesamt 20
drwxr-xr-x  1 root root  236 Apr 22 09:56 .
drwxrwxrwt 32 root root 4096 Mai 17 07:46 ..
lrwxrwxrwx  1 root root    7 Apr 22  2024 bin -> usr/bin
drwxr-xr-x  1 root root    0 Feb 26  2024 bin.usr-is-merged
drwxr-xr-x  1 root root    0 Apr 22  2024 boot
...

$ la -aln "${MOUNT_PT}/home/ubuntu"
insgesamt 16
drwxr-x--- 1 1000 1000   80 Apr 24 19:00 .
drwxr-xr-x 1    0    0   12 Apr 22 09:46 ..
-rw------- 1 1000 1000    5 Apr 24 19:00 .bash_history
-rw-r--r-- 1 1000 1000  220 Mär 31  2024 .bash_logout
...

$ sudo umount "${MOUNT_PT}"
$ rmdir "${MOUNT_PT}"
```

Links
-----

- [ArchLinux - Anleitung zu X-mount.idmap](https://bbs.archlinux.org/viewtopic.php?id=301351)
- [Anleitung bindfs](https://bindfs.org/docs/bindfs.1.html)

Versionen
---------

- Getestet mit Ubuntu 24.04.2 LTS und Ubuntu-22.04.5 LTS (nur BINDFS)

Historie
--------

- 2025-05-17: Erste Version

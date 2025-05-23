+++
date = '2025-05-23'
draft = false
title = 'Von LXC/LXD zu INCUS'
categories = [ 'INCUS', 'LXC/LXD' ]
tags = [ 'incus', 'lxc', 'lxd', 'linux', 'ubuntu', 'debian' ]
+++

<!--
Von LXC/LXD zu INCUS
====================
-->

Ich bin intensiver Nutzer von LXC/LXD.
Leider gab es vor einiger Zeit ja eine Auftrennung
und das ursprüngliche Kern-Entwickerteam arbeitet nun
an INCUS. Hier beschreibe ich, wie ich einen Container
umziehe von LXC/LXD nach INCUS.

<!-- more -->

## Ausganglage

Ich habe einen Plattenbereich "ubuntu--vg-lxdlv",
auf dem diverse LXC/LXD-Container rumliegen.
Die LXC/LXD-Container habe ich bislang mit Ubuntu-20.04
betrieben.

Zwischenzeitlich habe ich meinen Rechner aktualisiert auf
Ubuntu-24.04 und INCUS. Ich möchte nun die Container
übernehmen in INCUS.

## Plattenbereich einbinden

```sh
sudo mount /dev/mapper/ubuntu--vg-lxdlv /mnt
```

## Image importieren

```sh
$ sudo du -hs /mnt/containers/noble-32
513M	/mnt/containers/noble-32

$ time sudo image import /mnt/containers/noble-32 --alias noble-32-image
Image imported with fingerprint: 1e03aa9015a0ac1ffa7f09b94aa0a11d7fbbeaeae73af170e3a8ade540f2fd8e

real	2m44,910s
user	2m38,183s
sys	0m1,514s

$ incus image ls
+----------------+--------------+--------+------------------------------------+--------------+-----------+-----------+-----------------------+
| ALIAS          | FINGERPRINT  | PUBLIC |            DESCRIPTION             | ARCHITECTURE |   TYPE    |   SIZE    |      UPLOAD DATE      |
+----------------+--------------+--------+------------------------------------+--------------+-----------+-----------+-----------------------+
| noble-32-image | 77b38a70a668 | no     | Ubuntu noble i386 - Created by uli | i686         | CONTAINER | 109.36MiB | 2025/05/23 19:28 CEST |
+----------------+--------------+--------+------------------------------------+--------------+-----------+-----------+-----------------------+
```

## Container starten

```sh
$ incus launch noble-32-image noble-32
```

## Container testen

```sh
$ ssh root@noble-32.incus
Welcome to Ubuntu 24.04.1 LTS (GNU/Linux 6.11.0-26-generic i686)
...
```

## Image löschen

Der Container bleibt erhalten!

```sh
$ incus image delete noble-32-image

$ incus image ls
+-------+-------------+--------+-------------+--------------+------+------+-------------+
| ALIAS | FINGERPRINT | PUBLIC | DESCRIPTION | ARCHITECTURE | TYPE | SIZE | UPLOAD DATE |
+-------+-------------+--------+-------------+--------------+------+------+-------------+

$ incus ls noble-32
+----------+---------+----------------------+------+-----------+-----------+
|   NAME   |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+----------+---------+----------------------+------+-----------+-----------+
| noble-32 | RUNNING | 10.38.231.114 (eth0) |      | CONTAINER | 0         |
+----------+---------+----------------------+------+-----------+-----------+
```

Links
-----

- [INCUS: Grundeinrichtung mit Netzwerk]({{< ref "/blog/2025-04-24_incus-mit-netzwerk" >}})

Versionen
---------

- Getestet mit Ubuntu 24.04.2 LTS und INCUS-6.0.0-1ubuntu0.2
- LXC/LXD-Container erzeugt mit Ubuntu-20.04

Historie
--------

- 2025-05-23: Erste Version

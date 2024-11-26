+++
date = '2024-11-29'
draft = true
title = 'LXC: Erzeugen eines Build-Containers'
categories = [ 'LXC/LXD' ]
tags = [ 'lxc', 'lxd', 'linux', 'ubuntu', 'debian' ]
+++

<!--
LXC: Erzeugen eines Build-Containers
====================================
-->

Hier beschreibe ich, wie ich einen Container anlege,
in dem ich Ubuntu-Pakete bauen kann. Die Beschreibung
verwendet einen Container für Ubuntu-24.04 (noble)
und erstellt das Paket "git".

<!--more-->

LXC/LXD-Grundinitialisierung
----------------------------

```
  # Speicherplatz
$ sudo vgdisplay
  --- Volume group ---
  VG Name               ubuntu-vg
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  7
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                5
  Open LV               4
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <475,42 GiB
  PE Size               4,00 MiB
  Total PE              121707
  Alloc PE / Size       31744 / 124,00 GiB
  Free  PE / Size       89963 / <351,42 GiB
  VG UUID               He3sn9-GGjP-ZPBt-vvea-SDHc-SXOg-zUZ9DF

$ sudo lvcreate -n lxclv -L 50G ubuntu-vg
  Logical volume "lxclv" created.

  # Initialisierung
$ sudo lxd init
Would you like to use LXD clustering? (yes/no) [default=no]: no
Do you want to configure a new storage pool? (yes/no) [default=yes]: yes
Name of the new storage pool [default=default]: 
Name of the storage backend to use (powerflex, zfs, btrfs, ceph, dir, lvm) [default=zfs]: btrfs
Create a new BTRFS pool? (yes/no) [default=yes]: yes
Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]: yes
Path to the existing block device: /dev/mapper/ubuntu--vg-lxclv
Would you like to connect to a MAAS server? (yes/no) [default=no]: 
Would you like to create a new local network bridge? (yes/no) [default=yes]: 
What should the new bridge be called? [default=lxdbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 
Would you like the LXD server to be available over the network? (yes/no) [default=no]: 
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]: 
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: yes
config: {}
networks:
- config:
    ipv4.address: auto
    ipv6.address: auto
  description: ""
  name: lxdbr0
  type: ""
  project: default
storage_pools:
- config:
    source: /dev/mapper/ubuntu--vg-lxclv
  description: ""
  name: default
  driver: btrfs
storage_volumes: []
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
projects: []
cluster: null

  # Network
$ lxc network create lxdhostonly ipv4.address=10.2.210.1/24 ipv4.nat=false ipv6.address=none
Network lxdhostonly created

$ lxc network create lxdnat ipv4.address=10.38.231.1/24 ipv4.nat=true ipv6.address=none
Network lxdnat created

$ lxc profile device set default eth0 network=lxdnat

$ lxc network delete lxdbr0
Network lxdbr0 deleted

$ lxc network list
+-------------+----------+---------+----------------+------+-------------+---------+---------+
|    NAME     |   TYPE   | MANAGED |      IPV4      | IPV6 | DESCRIPTION | USED BY |  STATE  |
+-------------+----------+---------+----------------+------+-------------+---------+---------+
| docker0     | bridge   | NO      |                |      |             | 0       |         |
+-------------+----------+---------+----------------+------+-------------+---------+---------+
| lxdhostonly | bridge   | YES     | 10.2.210.1/24  | none |             | 0       | CREATED |
+-------------+----------+---------+----------------+------+-------------+---------+---------+
| lxdnat      | bridge   | YES     | 10.38.231.1/24 | none |             | 2       | CREATED |
+-------------+----------+---------+----------------+------+-------------+---------+---------+
| wlp1s0      | physical | NO      |                |      |             | 0       |         |
+-------------+----------+---------+----------------+------+-------------+---------+---------+
```

Basiscontainer
--------------

```
$ lxc launch ubuntu:24.04 build-2404
Creating build-2404
Starting build-2404

$ lxc exec build-2404 bash
root@build-2404:~# apt update
...
root@build-2404:~# apt upgrade
...
root@build-2404:~# exit

uli@uliip5:~$ lxc exec build-2404 -- sudo -u ubuntu -i
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@build-2404:~$ exit
```

Quelltext-Repos aktivieren
--------------------------

```
$ lxc exec build-2404 bash
root@build-2404:~# ed -e "s/:\s*deb/: deb-src/" </etc/apt/sources.list.d/ubuntu.sources >/etc/apt/sources.list.d/deb-src.sources

root@build-2404:~# apt update
```

Hilfsprogramme
--------------

```
$ lxc exec build-2404 -- sudo -u ubuntu -i
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@build-2404:~$ mkdir -p build/git
ubuntu@build-2404:~$ cd build/git

ubuntu@build-2404:~$ apt source git
Reading package lists... Done
NOTICE: 'git' packaging is maintained in the 'Git' version control system at:
https://repo.or.cz/r/git/debian.git/
...
Fetched 8159 kB in 5s (1634 kB/s)
sh: 1: dpkg-source: not found
E: Unpack command 'dpkg-source --no-check -x git_2.43.0-1ubuntu7.1.dsc' failed.
N: Check if the 'dpkg-dev' package is installed.

ubuntu@build-2404:~$ sudo apt install dpkg-dev
...

ubuntu@build-2404:~/build/git$ apt source git
Reading package lists... Done
NOTICE: 'git' packaging is maintained in the 'Git' version control system at:
https://repo.or.cz/r/git/debian.git/
...
dpkg-source: info: applying CVE-2024-32020.patch
dpkg-source: info: applying CVE-2024-32021.patch
dpkg-source: info: applying CVE-2024-32465.patch

ubuntu@build-2404:~/build/git$ sudo apt build-dep git
Reading package lists... Done
Reading package lists... Done
...
```

Bauen
-----

```
$ lxc exec build-2404 -- sudo -u ubuntu -i
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@build-2404:~$ mkdir -p build/git
ubuntu@build-2404:~$ cd build/git

ubuntu@build-2404:~/build/git$ apt source git

ubuntu@build-2404:~/build/git$ cd git-2.43.0

ubuntu@build-2404:~/build/git/git-2.43.0$ dpkg-buildpackage
dpkg-buildpackage: info: source package git
dpkg-buildpackage: info: source version 1:2.43.0-1ubuntu7.1
dpkg-buildpackage: info: source distribution noble-security
dpkg-buildpackage: info: source changed by Leonidas Da Silva Barbosa...
...
```

Aktualisieren
-------------

```
ubuntu@build-2404:~/build/git/git-2.43.0$ uupdate -u ../git-2.47.1.tar.xz 
Command 'uupdate' not found, but can be installed with:

sudo apt install devscripts
sudo apt install joe

ubuntu@build-2404:~/build/git/git-2.43.0$ uupdate -u ../git-2.47.1.tar.xz 

ubuntu@build-2404:~/build/git/git-2.43.0$ cd ../git-2.47.1
ubuntu@build-2404:~/build/git/git-2.47.1$ jmacs debian/changelog
ubuntu@build-2404:~/build/git/git-2.47.1$ head debian/changelog
git (1:2.47.1-0dp11~1noble7.1) noble; urgency=medium

  * New upstream release.

 -- Uli Heller <uli.heller@daemons-point.com>  Tue, 26 Nov 2024 22:52:42 +0000

ubuntu@build-2404:~/build/git/git-2.47.1$ jmacs debian/patches/series
ubuntu@build-2404:~/build/git/git-2.47.1$ dpkg-buildpackage
```

Offen
-----

- Namensauflösung
- Nutzertrennung

Probleme
--------

### Kein Zugriff auf's Internet vom Container aus

Der Container hat keinen Zugriff auf's Internet.
Dies äußert sich bspw. so:

```
$ lxc exec build-2404 bash
root@build-2404:~# nc -z -v -w5 google.com 443
nc: connect to google.com (142.250.185.78) port 443 (tcp) timed out: Operation now in progress
nc: connect to google.com (2a00:1450:4001:810::200e) port 443 (tcp) failed: Network is unreachable
```

Gelöst habe ich es mit:

- Löschen von Docker: `sudo apt purge docker.io`
- Neustart: `sudo reboot` (ohne ging es nicht)

Danach klappt es:

```
root@build-2404:~# nc -z -v -w5 google.com 443
Connection to google.com (142.250.185.78) 443 port [tcp/https] succeeded!
```

Versionen
---------

- Getestet mit Ubuntu 22.04.5 LTS auf dem Host
- Getestet mit LXC-6.1, snap version
- Getestet mit Ubuntu 24.04.1 LTS im Container

Historie
--------

- 2024-11-29: Erste Version

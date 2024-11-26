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
root@build-2404:~# 


```

Historie
--------

- 2024-11-29: Erste Version

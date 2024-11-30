+++
date = '2024-12-05'
draft = false
title = 'LXC/LXD: Grundeinrichtung mit Netzwerk'
categories = [ 'LXC/LXD' ]
tags = [ 'lxc', 'lxd', 'linux', 'ubuntu', 'debian' ]
+++

<!--
LXC/LXD: Grundeinrichtung mit Netzwerk
======================================
-->

Hier beschreibe ich, wie ich
LXC/LXD auf meinem Ubuntu-Rechner einrichte.

Ziele:

- Abgeschottete Container
- Container wahlweise mit und ohne Zugriff in's Internet
- Container netzwerktechnisch erreichbar via Containername (.lxd)

<!--more-->

LXD installieren
----------------

```
$ sudo snap install lxd
```

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
```

Netzwerkbrücken
---------------

```
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

Testcontainer
--------------

```
$ lxc launch ubuntu:24.04 ubuntu-2404
Creating ubuntu-2404
Starting ubuntu-2404

$ lxc exec ubuntu-2404 bash
root@ubuntu-2404:~# apt update
...
root@ubuntu-2404:~# apt upgrade
...
root@ubuntu-2404:~# exit

uli@uliip5:~$ lxc exec ubuntu-2404 -- sudo -u ubuntu -i
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@ubuntu-2404:~$ exit
```

Namensauflösung - erste Tests
-----------------------------

Aktuelle Anleitung (basierend auf INCUS): [How to integrate with systemd-resolved](https://linuxcontainers.org/incus/docs/main/howto/network_bridge_resolved/)

Basierend auf vorgenannter Anleitung mit Anpassung INCUS -> LXD und
unter ausschliesslicher Berücksichtigung von IPV4:

```
$ lxc network get lxdnat ipv4.address
10.38.231.1/24
$ lxc network get lxdhostonly ipv4.address
10.2.210.1/24

$ lxc network get lxdnat dns.domain
$ lxc network get lxdhostonly dns.domain
  # If this option is not set, the default domain name is lxd

$ sudo resolvectl dns lxdnat 10.38.231.1
$ sudo resolvectl domain lxdnat '~lxd'
$ sudo resolvectl dns lxdhostonly 10.2.210.1
$ sudo resolvectl domain lxdhostonly '~lxd'
```

Kurztest:

```
$ ping ubuntu-2404.lxd
PING ubuntu-2404.lxd (10.38.231.56) 56(84) bytes of data.
64 bytes from ubuntu-2404.lxd (10.38.231.56): icmp_seq=1 ttl=64 time=0.044 ms
64 bytes from ubuntu-2404.lxd (10.38.231.56): icmp_seq=2 ttl=64 time=0.068 ms
^C
--- ubuntu-2404.lxd ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1007ms
rtt min/avg/max/mdev = 0.044/0.056/0.068/0.012 ms
```

Namensauflösung - dauerhafte Einrichtung
----------------------------------------

Aktuelle Anleitung (basierend auf INCUS): [How to integrate with systemd-resolved](https://linuxcontainers.org/incus/docs/main/howto/network_bridge_resolved/)

Basierend auf vorgenannter Anleitung mit Anpassung INCUS -> LXD und
unter ausschliesslicher Berücksichtigung von IPV4 sind diese Schritte notwendig:

Netzwerkbrücken einrichten (wie zuvor):

```
#!/bin/bash
#

#
# Netzwerk-Brücken
#
lxc network create lxdhostonly ipv4.address=10.2.210.1/24 ipv4.nat=false ipv6.address=none
lxc network create lxdnat ipv4.address=10.38.231.1/24 ipv4.nat=true ipv6.address=none
```

Standardcontainer auf Nutzung von "lxdnat" festlegen:

```
lxc profile device set default eth0 network=lxdnat
```

DNS dauerhaft aktivieren für beide Netzwerkbrücken:

```
#
# DNS
#
for bridge in lxdhostonly lxdnat; do
ipaddress="$(lxc network get ${bridge} ipv4.address)"
cat >/etc/systemd/system/lxd-dns-${bridge}.service <<EOF
[Unit]
Description=LXD per-link DNS configuration for ${bridge}
BindsTo=sys-subsystem-net-devices-${bridge}.device
After=sys-subsystem-net-devices-${bridge}.device

[Service]
Type=oneshot
ExecStart=/usr/bin/resolvectl dns ${bridge} ${ipaddress}
ExecStart=/usr/bin/resolvectl domain ${bridge} ~lxd
ExecStart=/usr/bin/resolvectl dnssec ${bridge} off
ExecStart=/usr/bin/resolvectl dnsovertls ${bridge} off
ExecStopPost=/usr/bin/resolvectl revert ${bridge}
RemainAfterExit=yes

[Install]
WantedBy=sys-subsystem-net-devices-${bridge}.device
EOF
systemctl daemon-reload
systemctl enable --now lxd-dns-${bridge}
done
```

Initialisierungsskript: [initialize-lxd.sh](bin/initialize-lxd.sh)

Versionen
---------

- Getestet mit Ubuntu 22.04.5 LTS auf dem Host
- Getestet mit LXC-6.1, snap version
- Getestet mit Ubuntu 24.04.1 LTS im Container

Historie
--------

- 2024-12-05: Erste Version

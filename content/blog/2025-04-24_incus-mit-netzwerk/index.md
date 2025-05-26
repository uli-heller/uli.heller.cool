+++
date = '2025-04-24'
draft = false
title = 'INCUS: Grundeinrichtung mit Netzwerk'
categories = [ 'INCUS', 'LXC/LXD' ]
tags = [ 'incus', 'lxc', 'lxd', 'linux', 'ubuntu', 'debian' ]
+++

<!--
INCUS: Grundeinrichtung mit Netzwerk
======================================
-->

Hier beschreibe ich, wie ich
INCUS auf meinem Ubuntu-Rechner einrichte.
INCUS ist der Nachfolger von LXC/LXD.
Er steht bei Ubuntu-24.04 per Standard zur Verfügung.
LXC/LXD gibt es auch noch. "Im Notfall" kehre
ich dazu zurück, falls es mit INCUS nicht so richtig klappt.

Dieser Artikel orientiert sich an
[LXC/LXD: Grundeinrichtung mit Netzwerk]({{< ref "/blog/2024-12-05_lxc-mit-netzwerk" >}}).

Ziele:

- Abgeschottete Container
- Container wahlweise mit und ohne Zugriff in's Internet
- Container netzwerktechnisch erreichbar via Containername (.incus)


<!--more-->

INCUS installieren
----------------

```
$ sudo apt install incus
```

Nutzer als INCUS-Admin freischalten
-----------------------------------

```
$ sudo usermod -a -G incus-admin uli
```

Danach: Neustart und Kontrolle mit `id|grep incus-admin`-
Abmelden und neu anmelden hat bei mir nicht geklappt!

INCUS-Grundinitialisierung
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

$ sudo lvcreate -n incuslv -L 50G ubuntu-vg
  Logical volume "incuslv" created.

  # Initialisierung
$ incus admin init
Would you like to use clustering? (yes/no) [default=no]: no
Do you want to configure a new storage pool? (yes/no) [default=yes]: yes
Name of the new storage pool [default=default]: default
Name of the storage backend to use (dir, lvm, lvmcluster, btrfs) [default=btrfs]: btrfs
Create a new BTRFS pool? (yes/no) [default=yes]: yes
Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]: yes                           
Path to the existing block device: /dev/mapper/ubuntu--vg-incuslv
Would you like to create a new local network bridge? (yes/no) [default=yes]: yes
What should the new bridge be called? [default=incusbr0]: incusbr0
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: auto
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: auto
Would you like the server to be available over the network? (yes/no) [default=no]: no
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]: yes
Would you like a YAML "init" preseed to be printed? (yes/no) [default=no]: yes
config: {}
networks:
- config:
    ipv4.address: auto
    ipv6.address: auto
  description: ""
  name: incusbr0
  type: ""
  project: default
storage_pools:
- config:
    source: /dev/mapper/ubuntu--vg-incuslv
  description: ""
  name: default
  driver: btrfs
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      network: incusbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
projects: []
cluster: null
```

Testcontainer
-------------

```
$ incus launch images:ubuntu/24.04 ubuntu-2404
Launching ubuntu-2404

$ incus exec ubuntu-2404 bash
root@ubuntu-2404:~# apt update
...
root@ubuntu-2404:~# apt upgrade
...
root@ubuntu-2404:~# exit

$ incus exec ubuntu-2404 -- sudo -u ubuntu -i
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@ubuntu-2404:~$ exit
logout
```

Isolierte Benutzerkennungen
---------------------------

Bei Ubuntu-24.04 sind /etc/subuid und /etc/subgid
schon (fast) korrekt erweitert. Es muß bei "root"
jeweils die erste Zahl angepasst werden von "1000000"
auf "100000":

- /etc/subuid
  ```
  uheller:100000:65536
  root:100000:1000000000
  ```
- /etc/subgid
  ```
  uheller:100000:65536
  root:100000:1000000000
  ```

Aktivieren der isolierten UIDs:

```
$ incus profile set default security.idmap.isolated=true
$ sudo systemctl restart incus.service
```

Skript für die Durchführung der Änderungen:

```
for es in /etc/subuid /etc/subgid; do
  for u in root; do
    grep "^${u}:100000:1000000000" "${es}" >/dev/null && continue
    if grep "^${u}:" "${es}" >/dev/null 2>&1; then
      sed -i -e "s/^${u}:.*/${u}:100000:1000000000" "${es}"
    else
      echo "${u}:100000:1000000000" >>"${es}"
    fi
  done
done
incus profile set default security.idmap.isolated=true
systemctl restart incus.service
```

Diese Änderung ist auch Teil des Initialisierungsskripts: [initialize-incus.sh](bin/initialize-incus.sh)

Netzwerkbrücken
---------------

```
  # Network
$ incus network create incushostonly ipv4.address=10.2.210.1/24 ipv4.nat=false ipv6.address=none
Network incushostonly created

$ incus network create incusnat ipv4.address=10.38.231.1/24 ipv4.nat=false ipv6.address=none
Network incusnat created

$ incus profile device set default eth0 network=incushostonly
$ incus profile device add default eth1 nic network=incusnat

$ incus network delete incusbr0
Network incusbr0 deleted

$ incus network list
+-----------------+----------+---------+----------------+------+-------------+---------+---------+
|      NAME       |   TYPE   | MANAGED |      IPV4      | IPV6 | DESCRIPTION | USED BY |  STATE  |
+-----------------+----------+---------+----------------+------+-------------+---------+---------+
| enp3s0          | physical | NO      |                |      |             | 0       |         |
+-----------------+----------+---------+----------------+------+-------------+---------+---------+
| enx0023575c9346 | physical | NO      |                |      |             | 0       |         |
+-----------------+----------+---------+----------------+------+-------------+---------+---------+
| incushostonly   | bridge   | YES     | 10.2.210.1/24  | none |             | 0       | CREATED |
+-----------------+----------+---------+----------------+------+-------------+---------+---------+
| incusnat        | bridge   | YES     | 10.38.231.1/24 | none |             | 3       | CREATED |
+-----------------+----------+---------+----------------+------+-------------+---------+---------+
| wlp4s0          | physical | NO      |                |      |             | 0       |         |
+-----------------+----------+---------+----------------+------+-------------+---------+---------+
```

Diese Änderung ist auch Teil des Initialisierungsskripts: [initialize-incus.sh](bin/initialize-incus.sh)

Namensauflösung - erste Tests
-----------------------------

Aktuelle Anleitung: [How to integrate with systemd-resolved](https://linuxcontainers.org/incus/docs/main/howto/network_bridge_resolved/)

Basierend auf vorgenannter Anleitung
unter ausschliesslicher Berücksichtigung von IPV4:

```
$ incus network get incusnat ipv4.address
10.38.231.1/24
$ incus network get incushostonly ipv4.address
10.2.210.1/24

$ incus network get incusnat dns.domain
$ incus network get incushostonly dns.domain
  # If this option is not set, the default domain name is incus(?)

$ sudo resolvectl dns incusnat 10.38.231.1
$ sudo resolvectl domain incusnat '~incus'
$ sudo resolvectl dns incushostonly 10.2.210.1
$ sudo resolvectl domain incushostonly '~incus'
```

Kurztest:

```
$ ping ubuntu-2404.incus
PING ubuntu-2404.incus (10.38.231.74) 56(84) bytes of data.
64 bytes from ubuntu-2404.incus (10.38.231.74): icmp_seq=1 ttl=64 time=0.023 ms
64 bytes from ubuntu-2404.incus (10.38.231.74): icmp_seq=2 ttl=64 time=0.050 ms
^C
--- ubuntu-2404.incus ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1005ms
rtt min/avg/max/mdev = 0.023/0.036/0.050/0.013 ms
```

Namensauflösung - dauerhafte Einrichtung
----------------------------------------

Aktuelle Anleitung (basierend auf INCUS): [How to integrate with systemd-resolved](https://linuxcontainers.org/incus/docs/main/howto/network_bridge_resolved/)

Basierend auf vorgenannter Anleitung
unter ausschliesslicher Berücksichtigung von IPV4 sind diese Schritte notwendig:

Netzwerkbrücken einrichten (wie zuvor):

```
#!/bin/bash
#

#
# Netzwerk-Brücken
#
incus network info incushostonly >/dev/null 2>&1 || {
  incus network create incushostonly ipv4.address=10.2.210.1/24 ipv4.nat=false ipv6.address=none
}
incus network info incusnat >/dev/null 2>&1 || {
  incus network create incusnat ipv4.address=10.38.231.1/24 ipv4.nat=true ipv6.address=none
}
incus profile device set default eth0 network=incusnat

incus network info incusbr0 >/dev/null 2>&1 && {
  incus network delete incusbr0
}
```

Standardcontainer auf Nutzung von "incusnat" festlegen:

```
incus profile device set default eth0 network=incushostonly
incus profile device add default eth1 nic network=incusnat
```

Profile für "hostonly" und "nat":

```
incus profile create hostonly
incus profile set hostonly security.idmap.isolated true
incus profile device add hostonly eth0 nic network=incushostonly
incus profile device add hostonly root disk path=/ pool=default

incus profile create nat
incus profile set nat security.idmap.isolated true
incus profile device add nat eth0 nic network=incushostonly
incus profile device add nat eth1 nic network=incusnat
incus profile device add nat root disk path=/ pool=default
```

DNS dauerhaft aktivieren für beide Netzwerkbrücken:

```
#
# DNS
#
for bridge in incushostonly incusnat; do
ipaddress="$(incus network get ${bridge} ipv4.address|cut -d "/" -f 1)"
cat >/etc/systemd/system/incus-dns-${bridge}.service <<EOF
[Unit]
Description=INCUS per-link DNS configuration for ${bridge}
BindsTo=sys-subsystem-net-devices-${bridge}.device
After=sys-subsystem-net-devices-${bridge}.device

[Service]
Type=oneshot
ExecStart=/usr/bin/resolvectl dns ${bridge} ${ipaddress}
ExecStart=/usr/bin/resolvectl domain ${bridge} ~incus
ExecStart=/usr/bin/resolvectl dnssec ${bridge} off
ExecStart=/usr/bin/resolvectl dnsovertls ${bridge} off
ExecStopPost=/usr/bin/resolvectl revert ${bridge}
RemainAfterExit=yes

[Install]
WantedBy=sys-subsystem-net-devices-${bridge}.device
EOF
systemctl daemon-reload
systemctl enable --now incus-dns-${bridge}
done
```

Diese Änderung ist auch Teil des Initialisierungsskripts: [initialize-incus.sh](bin/initialize-incus.sh)

Offene Punkte
-------------

- Reboot-Test
  - Werden laufende Container automatisch gestartet?
  - Funktioniert DNS?
- Image-Test
  - Klappt's mit eigenen LXC/LXD-Images?

Links
-----

- [Arch: Incus](https://wiki.archlinux.org/title/Incus#Initialize_Incus_config)
- [How to integrate with systemd-resolved](https://linuxcontainers.org/incus/docs/main/howto/network_bridge_resolved/)

Versionen
---------

- Getestet mit Ubuntu 24.04.2 LTS und incus-6.0.0-1ubuntu0.2 auf dem Host

Historie
--------

- 2025-05-26: eth0, eth1 und Profile anlegen
- 2025-04-24: Erste Version

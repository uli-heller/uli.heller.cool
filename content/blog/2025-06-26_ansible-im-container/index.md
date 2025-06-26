+++
date = '2025-06-26'
draft = true
title = 'ANSIBLE: Alte Version in einem Container verwenden'
categories = [ 'devops' ]
tags = [ 'ansible', 'linux', 'ubuntu' ]
+++

<!--ANSIBLE: Alte Version in einem Container verwenden-->
<!--======================================-->

Einen Teil meiner Infrastruktur habe ich mit ANSIBLE
aufgesetzt. Leider vor sehr langer Zeit mit einer mittlerweile
veralteten Version von ANSIBLE (2.9). Diese kann mit aktuellen
Ubuntu-Versionen nicht mehr verwendet werden.

Hier beschreibe ich, wie ich es in einem Container nutze

<!--more-->

## Container aufsetzen und aktualisieren

### Aufsetzen

```
lxc image import --alias focal dp-focal-v1.12.1-amd64-lxcimage.tar.xz
lxc launch focal ubuntu-2004
```

### Aktualisieren

```
lxc exec ubuntu-2004 bash

# Innerhalb der "neuen" bash
apt update
apt upgrade
poweroff
```

### Kopieren

```
lxc copy ubuntu-2004 ansible
```

## Ansible einrichten

```
sudo apt install pipx
pipx install --include-deps $(pwd)/ansible-stable-2.9.27.tar.gz
pipx inject ansible dnspython
pipx inject ansible netaddr
```

Links
-----

- [Homepage: gocryptfs](https://nuetzlich.net/gocryptfs/)
- [GITHUB: gocryptfs](https://github.com/rfjakob/gocryptfs)

Versionen
---------

Getestet mit

- Ubuntu-24.04 und Github:gocryptfs "master" vom 2025-05-31

Historie
--------

- 2025-05-31: Erste Version

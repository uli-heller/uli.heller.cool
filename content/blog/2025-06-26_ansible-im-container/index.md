+++
date = '2025-06-26'
draft = false
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

### Herunterladen

LXC-Image herunterladen von
[Github: Ubuntu-Images für LXC](https://github.com/uli-heller/lxc-ubuntu-i386-amd64/releases/tag/v1.12.1).

Danach Virencheck!

### Aufsetzen

```
lxc image import --alias jammy jammy-v1.12.1-amd64-lxcimage.tar.xz
lxc launch jammy ubuntu-2204
```

### Aktualisieren

```
lxc exec ubuntu-2204 bash

# Innerhalb der "neuen" bash
apt update
apt upgrade
poweroff
```

### Kopieren

```
lxc copy ubuntu-2204 ansible
lxc start ansible
```

## Ansible einrichten

### Container vorbereiten

Alle hierin beschrieben Kommandos
"laufen" im Ansible-Container, also
nach Eingabe von `lxc exec ansible bash`.

```
apt install -y python2
apt install -y pipx
apt install -y rsync
apt install -y git     # benötige ich zum Zugriff auf meine Playbooks
```

### Wechseln zum Benutzer "ubuntu" im Ansible-Container

```
ssh -A ubuntu@ansible.lxd
```

### Herunterladen

"ansible-tar.gz" herunterladen mit
[diesem Link](https://codeload.github.com/ansible/ansible/tar.gz/v2.9.27).
Danach Virencheck!

Kommando zum Herunterladen:
`wget https://codeload.github.com/ansible/ansible/tar.gz/v2.9.27 -O ansible-2.9.27.tar.gz`

### Einrichten

```
pipx install --include-deps $(pwd)/ansible-2.9.27.tar.gz
pipx inject ansible dnspython
pipx inject ansible netaddr
```

## Playbooks einspielen

### Wechseln zum Benutzer "ubuntu" im Ansible-Container

```
ssh -A ubuntu@ansible.lxd
```

### Git-Repo clonen

```
mkdir git
cd git
git clone (repo-url)
cd (repo-basename)
```

### SSH-Zugriff testen

Mein Testrechner hat den Namen "goliath", also:

```
ssh goliath
# muß klappen!
```

### Ansible-Playbook testen

```
ansible-playbook site.yml --check --diff -l goliath
# sollte nun keinen Fehler anzeigen
```

Links
-----

- [Github: Ubuntu-Images für LXC](https://github.com/uli-heller/lxc-ubuntu-i386-amd64/releases/tag/v1.12.1)
- [Github: ansible-2.9.27.tar.gz](https://codeload.github.com/ansible/ansible/tar.gz/v2.9.27)

Versionen
---------

Getestet mit

- Ubuntu-22.04 und LXC-Image von Ubuntu-20.04 (focal)

Historie
--------

- 2025-06-26: Erste Version

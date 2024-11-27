+++
date = '2024-12-01'
draft = false
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

Voraussetzung
-------------

- LXC/LXD ist installiert
- ... und initialisiert

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
                   # Zusatzpakete installieren
root@build-2404:~# apt install dpkg-dev devscripts joe

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
root@build-2404:~# sed -e "s/:\s*deb/: deb-src/" </etc/apt/sources.list.d/ubuntu.sources >/etc/apt/sources.list.d/deb-src.sources

root@build-2404:~# apt update
```

Paket-Quelltext installieren
----------------------------

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

ubuntu@build-2404:~/build/git$ sudo apt build-dep git

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

- 2024-12-01: Erste Version

+++
date = '2025-01-07'
draft = false
title = 'PROOT: Dateisysteme ohne "root"'
categories = [ 'Dateisystem' ]
tags = [ 'linux', 'ubuntu' ]
+++

<!--PROOT: Dateisysteme ohne "root"-->
<!--===============================-->

Hier zeige ich, wie ich ohne "root" mit
Dateisystemen arbeite, die "root"-Mechanismen
benötigen.

<!--more-->

Vorbereiten
-----------

```
$ uname -a
Linux uliip5 6.8.0-49-generic #49~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Wed Nov  6 17:42:15 UTC 2 x86_64 x86_64 x86_64 GNU/Linux

$ sudo apt install -y proot
Paketlisten werden gelesen… Fertig
Abhängigkeitsbaum wird aufgebaut… Fertig
Statusinformationen werden eingelesen… Fertig
Die folgenden Pakete wurden automatisch installiert und werden nicht mehr benötigt:
  containerd libclamav9 libpkgconf3 libtfm1 pigz runc ubuntu-fan
Verwenden Sie »sudo apt autoremove«, um sie zu entfernen.
Die folgenden NEUEN Pakete werden installiert:
  proot
0 aktualisiert, 1 neu installiert, 0 zu entfernen und 0 nicht aktualisiert.
Es müssen 75,3 kB an Archiven heruntergeladen werden.
Nach dieser Operation werden 211 kB Plattenplatz zusätzlich benutzt.
Holen:1 http://archive.ubuntu.com/ubuntu jammy/universe amd64 proot amd64 5.1.0-1.3 [75,3 kB]
Es wurden 75,3 kB in 1 s geholt (65,6 kB/s).         
Vormals nicht ausgewähltes Paket proot wird gewählt.
...

$ cd $HOME/Downloads
$ wget https://github.com/uli-heller/lxc-ubuntu-i386-amd64/releases/download/v1.12.1/noble-v1.12.1-amd64-lxcimage.tar.xz
```

Dateisystem initialisieren
--------------------------

```
$ mkdir /tmp/proot-tests
$ xz -cd $HOME/Downloads/noble-v1.12.1-amd64-lxcimage.tar.xz|(cd /tmp/proot-tests && tar xf -)
$ proot -R /tmp/proot-tests/rootfs -0 /bin/bash
#
```

Test: Bauen von Paketen
-----------------------

```
$ proot -S /tmp/proot-tests/rootfs /bin/bash
root:~ # sed -e "s,^deb ,deb-src ," /etc/apt/sources.list >/etc/apt/sources.list.d/deb-src.list
root:~ # mkdir /src
root:~ # cd /src
root:/src # apt update
Hit:1 http://archive.ubuntu.com/ubuntu noble InRelease
Get:2 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:3 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
...
root:/src # apt source at
Reading package lists... Done
NOTICE: 'at' packaging is maintained in the 'Git' version control system at:
https://salsa.debian.org/debian/at.git -b debian
Please use:
git clone https://salsa.debian.org/debian/at.git -b debian
to retrieve the latest (possibly unreleased) updates to the package.
Need to get 157 kB of source archives.
Get:1 http://archive.ubuntu.com/ubuntu noble/universe at 3.2.5-2.1ubuntu3 (dsc) [2078 B]
Get:2 http://archive.ubuntu.com/ubuntu noble/universe at 3.2.5-2.1ubuntu3 (tar) [133 kB]
Get:3 http://archive.ubuntu.com/ubuntu noble/universe at 3.2.5-2.1ubuntu3 (diff) [21.9 kB]
Fetched 157 kB in 2s (101 kB/s)
sh: 1: dpkg-source: not found
E: Unpack command 'dpkg-source --no-check -x at_3.2.5-2.1ubuntu3.dsc' failed.
N: Check if the 'dpkg-dev' package is installed.

root:/src # apt install -y dpkg-dev
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  binutils binutils-common binutils-x86-64-linux-gnu build-essential bzip2 cpp cpp-13 cpp-13-x86-64-linux-gnu
  cpp-x86-64-linux-gnu dirmngr fakeroot fontconfig-config fonts-dejavu-core fonts-dejavu-mono g++ g++-13
...
Setting up libheif-plugin-aomdec:amd64 (1.17.6-1ubuntu4.1) ...
Setting up libheif-plugin-libde265:amd64 (1.17.6-1ubuntu4.1) ...
Setting up libheif-plugin-aomenc:amd64 (1.17.6-1ubuntu4.1) ...
Processing triggers for libc-bin (2.39-0ubuntu8.3) ...

root:/src # apt source at
Reading package lists... Done
NOTICE: 'at' packaging is maintained in the 'Git' version control system at:
https://salsa.debian.org/debian/at.git -b debian
Please use:
git clone https://salsa.debian.org/debian/at.git -b debian
to retrieve the latest (possibly unreleased) updates to the package.
Skipping already downloaded file 'at_3.2.5-2.1ubuntu3.dsc'
Skipping already downloaded file 'at_3.2.5.orig.tar.gz'
Skipping already downloaded file 'at_3.2.5-2.1ubuntu3.debian.tar.xz'
Need to get 0 B of source archives.
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LANGUAGE = (unset),
	LC_ALL = (unset),
	LANG = "de_DE.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
dpkg-source: info: extracting at in at-3.2.5
dpkg-source: info: unpacking at_3.2.5.orig.tar.gz
dpkg-source: info: unpacking at_3.2.5-2.1ubuntu3.debian.tar.xz

root:/src # cd at-3.2.5

root:/src/at-3.2.5 # apt build-dep at
Reading package lists... Done
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  autoconf automake autopoint autotools-dev bison bsdextrautils debhelper debugedit dh-autoreconf dh-strip-nondeterminism
...
Building database of manual pages ...
setpriv: setresgid failed: Operation not permitted
Created symlink /etc/systemd/system/timers.target.wants/man-db.timer → /usr/lib/systemd/system/man-db.timer.
Setting up debhelper (13.14.1ubuntu5) ...
Processing triggers for libc-bin (2.39-0ubuntu8.3) ...

root:/src/at-3.2.5 # dpkg-buildpackage
...
perl: warning: Falling back to the standard locale ("C").
dpkg-buildpackage: info: binary and diff upload (original source NOT included)
 signfile at_3.2.5-2.1ubuntu3.dsc
gpg: skipped "William Grant <wgrant@ubuntu.com>": No secret key
gpg: dpkg-sign._2J_Wmec/at_3.2.5-2.1ubuntu3.dsc: clear-sign failed: No secret key
dpkg-buildpackage: error: failed to sign at_3.2.5-2.1ubuntu3.dsc file: OpenPGP backend command cannot sign
```

Trotz "scheinbarem" Fehler hat alles geklappt!
Also: DEB-Paket bauen ohne "root" geht!

Fehler und Probleme
-------------------

### Fehlermeldung "proot warning: ptrace(PEEKDATA): Input/output error"

Die Fehlermeldung erscheint quasi immer, wenn man die Option "-R" oder "-S" verwendet:

```
$ proot -R /tmp/proot-tests/rootfs -0 /bin/bash
...
proot warning: ptrace(PEEKDATA): Input/output error
proot warning: ptrace(PEEKDATA): Input/output error
proot warning: ptrace(PEEKDATA): Input/output error
# exit

$ proot -S /tmp/proot-tests/rootfs  -0 /bin/bash#
...
proot warning: ptrace(PEEKDATA): Input/output error
proot warning: ptrace(PEEKDATA): Input/output error
proot warning: ptrace(PEEKDATA): Input/output error
# exit

$ proot -r /tmp/proot-tests/rootfs  -0 /bin/bash
groups: cannot find name for group ID 108
groups: cannot find name for group ID 113
groups: cannot find name for group ID 10000
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

# 
```

Korrektur: Problem tritt nicht mehr auf mit "proot-5.4.0"!

Links
-----

- [Homepage: Proot](https://proot-me.github.io/)
- [Github: Proot](https://github.com/proot-me/proot)

Versionen
---------

Getestet mit

- Ubuntu-22.04 und proot-5.1.0-1.3
- Ubuntu-22.04 und proot-5.4.0 (selbst kompiliert)

Historie
--------

- 2025-01-07: Erste Version

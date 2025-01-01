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

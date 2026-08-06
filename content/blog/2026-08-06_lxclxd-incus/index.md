+++
date = '2026-08-06'
draft = false
title = 'INCUS: Wechsel von LXC/LXD zu INCUS'
categories = [ 'INCUS', 'LXC/LXD' ]
tags = [ 'incus', 'lxc', 'lxd', 'linux', 'ubuntu', 'debian' ]
+++

<!--
INCUS: Wechsel von LXC/LXD zu INCUS
===================================
-->

Ich habe gestern einen neuen Rechner aufgesetzt
mit Ubuntu-26.04-Server. Es stellt sich heraus,
dass LXC/LXD direkt verfügbar ist. Da ich lieber INCUS
verwende, muß das nun entfernt und durch INCUS
ersetzt werden. Glücklicherweise habe ich noch
keine Container, das sollte die Umstellung
vereinfachen.

<!--more-->

Sichtung LXC/LXD-Pakete
-----------------------

```
$ dpkg -l "*lx[cd]*"
+-- Desired=Unknown/Install/Remove/Purge/Hold
|+- Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
||+ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||| Name             Version      Architektur  Beschreibung
+++-================-============-============-=====================================
un  lxd              <keine>      <keine>      (keine Beschreibung vorhanden)
ii  lxd-agent-loader 0.13ubuntu0  all          LXD - VM agent loader
ii  lxd-installer    14ubuntu0    all          Wrapper to install lxd snap on demand

$ snap list
Name    Version      Rev    Tracking       Publisher   Notes
core26  20260629     462    latest/stable  canonical✓  base
lxd     6.9-ab8fad2  40424  6/stable/…     canonical✓  -
snapd   2.76.1       27591  latest/stable  canonical✓  snapd
```

Aufräumplan
-----------

1. DEB-Paket "lxd-installer" entfernen
2. DEB-Paket "lxd-agent-loader" entfernen
   (unklar: Ist das wirklich eine gute Idee?)
3. SNAP "lxd" entfernen

Aufräumaktion
-------------

### lxd-installer

```
$ sudo apt remove lxd-installer
ENTFERNE:
  lxd-installer  ubuntu-server

Zusammenfassung:
  Aktualisiere: 0, Installiere: 0, Entferne: 2, Aktualisiere nicht: 6
  Freigegebener Platz: 39,9 kB

Fortfahren? [J/n] 
(Lese Datenbank ... 139774 Dateien und Verzeichnisse sind derzeit installiert.)
Entfernen von ubuntu-server (1.570.2) ...
Entfernen von lxd-installer (14ubuntu0) ...
```

### lxd-agent-loader

```
$ sudo apt remove lxd-agent-loader
ENTFERNE:                                   
  lxd-agent-loader

Zusammenfassung:
  Aktualisiere: 0, Installiere: 0, Entferne: 1, Aktualisiere nicht: 6
  Freigegebener Platz: 28,7 kB

Fortfahren? [J/n] 
(Lese Datenbank ... 139762 Dateien und Verzeichnisse sind derzeit installiert.)
Entfernen von lxd-agent-loader (0.13ubuntu0) ...
```

### lxd

```
$ sudo snap remove lxd
lxd removed (snap data snapshot saved)
```

... wahrscheinlich wäre `sudo snap remove lxd --purge` besser!

Snapshots aufräumen:

```
$ snap saved
Set  Snap  Age    Version      Rev    Size   Notes
1    lxd   2m43s  6.9-ab8fad2  40424  113kB  auto

$ sudo snap forget 1
Snapshot #1 forgotten.

$ snap saved
No snapshots found.
```

INCUS installieren
----------------

```
$ sudo apt install incus
# ... sehr viele Zusatzpakete werden eingespielt
```

Nutzer kontrollieren und korrigieren
------------------------------------

```
$ id
uid=1000(uli) gid=1000(uli) groups=1000(uli),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),100(users),101(lxd)
```

Also:

- Gruppe "lxd" muß weg
- Gruppe "incus-admin" muß rein

```
$ sudo deluser uli lxd
$ sudo usermod -a -G incus-admin uli
```

Danach: Abmelden und neu anmelden!

```
$ id
uid=1000(uli) gid=1000(uli) groups=1000(uli),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),100(users),981(incus-admin)
```

Weitere Aktionen
----------------

Damit ist LXC/LXD nun entfernt und INCUS steht zur Verfügung.
Weiteres Vorgehen dann wie beschrieben in
[INCUS: Grundeinrichtung mit Netzwerk]({{< ref "/blog/2025-04-24_incus-mit-netzwerk" >}})

Links
-----

- [INCUS: Grundeinrichtung mit Netzwerk]({{< ref "/blog/2025-04-24_incus-mit-netzwerk" >}})


Versionen
---------

- Getestet mit Ubuntu 26.04 LTS und incus-6.0.5-8

Historie
--------

- 2026-08-06: Erste Version

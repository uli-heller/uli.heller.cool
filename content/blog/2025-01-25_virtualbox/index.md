+++
date = '2025-01-25'
draft = false
title = 'Virtualbox mit Ubuntu-22.04'
categories = [ 'Virtualbox' ]
tags = [ 'virtualbox', 'ubuntu', 'linux' ]
+++

<!--
Virtualbox mit Ubuntu-22.04
===========================
-->

Virtualbox verwende ich seit Jahren,
der Einsatz sollte unkompliziert sein!

<!--more-->

Installation
------------

```
sudo apt update
sudo apt upgrade
sudo apt install virtualbox
...
dpkg -l virtualbox
# -> 6.1.50-dfsg-1~ubuntu1.22.04.3
```

Start
-----

- Kommando: `virtualbox`
- Maschine - Neu
  - Name: test-vb
  - Typ: Linux
  - Version: Ubuntu (64-bit)
  - Weiter
- Speicher: 1024 MB
- Keine Festplatte
  - Erzeugen
  - Fortfahren
- "test-vb" anwählen
  - Starten
- Es erscheint relativ schnell eine Fehlermeldung
- Nutzer in Gruppe "vboxusers" aufnehmen
  ```
  $ sudo adduser uheller vboxusers
  Benutzer »uheller« wird der Gruppe »vboxusers« hinzugefügt …
  Benutzer uheller wird zur Gruppe vboxusers hinzugefügt.
  Fertig.
  ```
- Abmelden/Anmelden
- `id` -> vboxusers wird angezeigt
- Nochmal testen -> klappt nicht!
- Diverse Variationen mit den VM-Einstellungen: Nix hilft!

Paket bauen
-----------

Grob geht es mit "lxc-ubuntu-i386-amd64" wie folgt:

- `./build-proot.sh -s noble -o jammy -S -a amd64 kbuild`
- `./build.proot.sh -s noble -o jammy -S -a amd64 -k virtualbox`
  (scheitert mit einem Fehler)
- `proot.sh build-jammy-amd64/rootfs bash`
  - `cd /src/virtualbox/virtualbox-7*/debian`
  - "rules" anpassen - systemd-Zeugs weg
  - "control" anpassen - breaks-Zeugs weg
  - `cd ..`
  - `dpkg-buildpackage` - dauert sehr lange!

Man erhält virtualbox-7.0.16.

Test mit neuem Paket
--------------------

- Einspielen:

  ```
  $ sudo apt install \
    ./virtualbox_7.0.16-dfsg-2ubuntu1.1~uh~jammy1_amd64.deb \
    ./virtualbox-dkms_7.0.16-dfsg-2ubuntu1.1~uh~jammy1_amd64.deb \
    ./virtualbox-qt_7.0.16-dfsg-2ubuntu1.1~uh~jammy1_amd64.deb
  ...

  $ virtualbox
  ```

- Test
  - Maschine auf Vorgängerschritt anwählen
    - Ändern - Massenspeicher - ControllerIDE - "leer"
    - Rechts CD-Symbol
    - Abbild auswählen
    - alpine*.iso
    - OK
  - Gleiche Maschine anwählen
    - Starten -> klappt!
    - Fenster schliessen - "... die virtuelle Maschine ausschalten" - OK

Versionen
---------

- Ubuntu-22.04
- Kernel 6.8.0-51-generic
- Virtualbox 6.1.50-dfsg-1~ubuntu1.22.04.3 von Ubuntu-22.04
- Virtualbox 7.0.16-dfsg-2ubuntu1.1 von Ubuntu-24.04

Links
-----

- [Github: lxc-ubuntu-i386-amd64](https://github.com/uli-heller/lxc-ubuntu-i386-amd64) ... bauen von Paketen
- [AlpineLinux-3.21 - ISO](https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-extended-3.21.2-x86_64.iso)

Historie
--------

- 2025-01-25: Erste Version

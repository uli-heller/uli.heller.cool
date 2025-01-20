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

Paket bauen für 20.04
---------------------

- `./build-proot.sh -S -a amd64 -s noble -o focal -k virtualbox` -> meckert an: dh-sequence-dkms und später kbuild
- `./build-proot.sh -S -a amd64 -s noble -o focal -k dh-dkms`
- `./build-proot.sh -S -a amd64 -s noble -o focal -k kbuild`
- `./build-proot.sh -S -a amd64 -s noble -o focal -k virtualbox` -> meckert an: libtpms-dev:amd64
- `./build-proot.sh -S -a amd64 -s noble -o focal -k libtpms-dev`
- `./build-proot.sh -S -a amd64 -s noble -o focal -k virtualbox` -> bricht ab mit Fehler wegen KMOD_SCROLL
  ```
  In file included from /src/virtualbox/virtualbox-7.0.16-dfsg/include/iprt/stream.h:42,
                   from /src/virtualbox/virtualbox-7.0.16-dfsg/src/VBox/Frontends/VBoxSDL/VBoxSDL.cpp:35:
  /src/virtualbox/virtualbox-7.0.16-dfsg/src/VBox/Frontends/VBoxSDL/VBoxSDL.cpp: In function 'const char* keyModToStr(unsigned int)':
  /src/virtualbox/virtualbox-7.0.16-dfsg/src/VBox/Frontends/VBoxSDL/VBoxSDL.cpp:713:25: error: 'KMOD_SCROLL' was not declared in this scope; did you mean 'KMOD_RALT'?
    713 |         RT_CASE_RET_STR(KMOD_SCROLL);
        |                         ^~~~~~~~~~~
  /src/virtualbox/virtualbox-7.0.16-dfsg/include/iprt/cdefs.h:2404:43: note: in definition of macro 'RT_CASE_RET_STR'
   2404 | #define RT_CASE_RET_STR(a_Const)     case a_Const: return #a_Const
        |                                           ^~~~~~~
  kmk: *** [/usr/share/kBuild/footer-pass2-compiling-targets.kmk:277: /src/virtualbox/virtualbox-7.0.16-dfsg/out/obj/VBoxSDL/VBoxSDL.o] Error 1
  make[1]: *** [debian/rules:62: override_dh_auto_build] Error 2
  make[1]: Leaving directory '/src/virtualbox/virtualbox-7.0.16-dfsg'
  ```

  - Anpassen: Zeile 713 auskommentieren
  - debian/control: libsdb2 auskommentieren, breaks-Zeugs weg
  
- `./build-proot.sh -S -a amd64 -s noble -o focal -k virtualbox` -> klappt!

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

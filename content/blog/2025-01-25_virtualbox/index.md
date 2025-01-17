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

```
$ sudo adduser uli vboxusers
Benutzer »uli« wird der Gruppe »vboxusers« hinzugefügt …
Benutzer uli wird zur Gruppe vboxusers hinzugefügt.
Fertig.
```

Versionen
---------

- Ubuntu-22.04
- Kernel 6.8.0-51-generic
- Virtualbox 6.1.50-dfsg-1~ubuntu1.22.04.3

Links
-----

- TBD

https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-extended-3.21.2-x86_64.iso

Historie
--------

- 2025-01-24: Erste Version

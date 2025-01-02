+++
date = '2025-01-05'
draft = false
title = 'debchange - Werkzeug zum Verwalten der Datei "debian/changelog"'
categories = [ 'Linux' ]
tags = [ 'linux', 'ubuntu' ]
+++

<!--debchange - Werkzeug zum Verwalten der Datei "debian/changelog"-->
<!--===============================================================-->

Ich erzeuge relativ viele Debian-Pakete
und verwende dabe gelegentlich das Programm "debchange".
Hier meine gesammelten Erkenntnisse dazu!

<!--more-->

Neuen Versionseintrag erstellen - debchange -i
----------------------------------------------

Kommando: `debchange -i --changelog data/changelog`

Öffnet einen Editor mit der Changelog-Datei und
einem frischen Änderungsblock:

```
gocryptfs (2.4.0-1ubuntu0.24.04.3) UNRELEASED; urgency=medium

  * 

 -- Uli Heller <uli@ulicsl>  Thu, 02 Jan 2025 19:00:17 +0100

gocryptfs (2.4.0-1ubuntu0.24.04.2) noble-security; urgency=medium

  * No change rebuild due to golang-1.22 update

 -- Evan Caville <evan.caville@canonical.com>  Fri, 01 Nov 2024 10:42:11 +0100
...
```

Ungünstig:

- Versionsnummer wird einfach hochgezählt
- Email stimmt nicht
- Statt UNRELEASED sollte besser der Name der Zieldistribution erscheinen
- Änderungsnachricht leer
- Editor erfordert manuelle Eingriffe

Links
-----

- [Manual: debchange](https://manpages.debian.org/testing/devscripts/debchange.1.en.html)

Versionen
---------

Getestet mit

- Ubuntu-20.04

Historie
--------

- 2025-01-05: Erste Version

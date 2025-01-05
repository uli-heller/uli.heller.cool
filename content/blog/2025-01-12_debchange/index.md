+++
date = '2025-01-12'
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

- Versionsnummer wird einfach hochgezählt - Abhilfe: `-i` weglassen und `--local "~uli"` -> hängt "~uli1" dran
- Email stimmt nicht - Abhilfe: `DEBFULLNAME="Uli Heller" DEBEMAIL=uli@heller.cool debchange ...`
- Statt UNRELEASED sollte besser der Name der Zieldistribution erscheinen - Abhilfe: `--distribution focal`
- Änderungsnachricht leer - Abhilfe: Text hinten an's Kommando dranhängen
- Editor erfordert manuelle Eingriffe - Abhilfe: Text hinten an's Kommando dranhängen

Neuen Versionseintrag erstellen beim Umpacken
---------------------------------------------

```
DEBFULLNAME="Uli Heller" DEBEMAIL=uli@heller.cool debchange --changelog data/changelog --distribution focal --local "~uli" "Repackaged for focal/20.04" 
```

Damit ergeben sich diese Versionsnummern:

- data/changelog: 2.4.0-1ubuntu0.24.04.2 -> 2.4.0-1ubuntu0.24.04.2~uli1
- data/changelog: 2.4.0-1ubuntu0.24.04.2~uli1 -> 2.4.0-1ubuntu0.24.04.2~uli2
- data/dh-golang: 1.53 -> 1.53~uli1
- golang-defaults: 2:1.22~2build1 -> 2:1.22~2build1~uli1
- golang-github-hanwen-go-fuse: 2.0.3-1 -> 2.0.3-1~uli1
- golang-github-moby-sys: 0.0~git20231105.a4e0878-1 -> 0.0~git20231105.a4e0878-1~uli1
- golang-github-sabhiram-go-gitignore: 1.0.2+git20210923.525f6e1-1 -> 1.0.2+git20210923.525f6e1-1~uli1
- data/changelog-test1: 2.4.0-1ubuntu0.24.04.2~dp01~focal2 -> 2.4.0-1ubuntu0.24.04.2~dp01~focal2~uli1

Links
-----

- [Manual: debchange](https://manpages.debian.org/testing/devscripts/debchange.1.en.html)

Versionen
---------

Getestet mit

- Ubuntu-20.04

Historie
--------

- 2025-01-12: Erste Version

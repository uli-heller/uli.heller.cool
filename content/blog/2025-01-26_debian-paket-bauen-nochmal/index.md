+++
date = '2025-01-26'
draft = false
title = 'Debian-Paket bauen: Wiederholen nach Fehler'
categories = [ 'Paket bauen' ]
tags = [ 'dpkg-buildpackage', 'ubuntu', 'linux' ]
toc = false
+++

<!--
Debian-Paket bauen: Wiederholen nach Fehler
==========================================
-->

Gelegentlich baue ich Paket für Debian/Ubuntu.
Dazu verwende ich `dpkg-buildpackage`.
Wenn beim Bauen was schief läuft, wird üblicherweise
die komplette oft langwierige Prozedur wiederholt.

Es gibt auch eine Abkürzung!

<!--more-->

Problem
-------

- Paket-Quelltexte liegen vor
- Bauen wird gestartet mit `dpkg-buildpackage`
- Prozess bricht nach mehreren Minuten ab mit einem Fehler
- Manuelle Fehlerkorrektur
- Bauen wiederholen mit `dpkg-buildpackage` -> dauert wieder mehrere Minuten!

Beschleunigung
--------------

Wenn ich das Bauen wiederhole mit `dpkg-buildpackage --no-pre-clean`,
dann wird ein Großteil der Aktionen übersprungen und das Bauen läuft
sehr viel schneller ab!

Versionen
---------

- Ubuntu-22.04

Links
-----

- [StackExchange - How to resume package building in debian?](https://unix.stackexchange.com/questions/381221/how-to-resume-package-building-in-debian)

Historie
--------

- 2025-01-26: Erste Version

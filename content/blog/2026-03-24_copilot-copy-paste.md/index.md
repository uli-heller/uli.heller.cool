+++
date = '2026-03-24'
draft = false
title = 'Linux: Copilot und Kopieren/Einfügen'
categories = [ 'KI' ]
tags = [ 'linux', 'ubuntu', 'copilot' ]
+++

<!--
Linux: Copilot und Kopieren/Einfügen
====================================
-->

Bei einem meiner Kundenprojekte bin ich angehalten,
wann immer möglich Copilot einzusetzen. Leider gibt
es Probleme mit dem Kommandozeilen-Client und Linux: Sobald
er gestartet wurde, dann man im betreffenden Fenster
die Funktionen "Kopieren und Einfügen" (copy&paste)
nicht mehr verwenden.

<!--more-->

Warum stört das Problem?
------------------------

Ich lasse Copilot in einem Container laufen.
"Er" hat keinen Zugriff auf meine übliche Entwicklungsumgebung.
Benötigte Informationen möchte ich via "Kopieren und Einfügen"
dem Copilot zukommen lassen. Da stört es sehr, wenn dies
nicht klappt!

Erste Lösung: "--no-mouse"
--------------------------

Eine erste Lösung basiert auf einem geänderten
Aufruf von Copilot:

- Bislang: `copilot`
- Nun: `copilot --no-mouse`

Damit klappt "Kopieren und Einfügen", man verliert aber
gewisse Komfort-Funktionen innerhalb von Copilot, insbesondere
die Navigation mit der Maus.

Zweite Lösung: "xclip"
----------------------

Bei der zweiten Lösung läuft's so:

- Wechsel in den Container: `ssh -XA ubuntu@copilot.lxd`
- Installieren von "xclip" im Container: `sudo apt install xclip`
- Aufruf von Copilot: `copilot`

Damit klappt "Kopieren und Einfügen" und die
Komfort-Funktionen innerhalb von Copilot bleiben erhalten.

Versionen
---------

- Getestet unter Ubuntu-22.04 mit Copilot-v1.0.11 - klappt
- Getestet unter Ubuntu-24.04 mit Copilot-v1.0.12 - "xclip" klappt nicht, "--no-mouse" klappt
  - Nochmaliger Test ein paar Tage später, gleiche Versionen - "xclip" klappt auch!

Links
-----

- [Github - Copilot blocks right click menu of console](https://github.com/github/copilot-cli/issues/2158)

Historie
--------

- 2026-03-29: Probleme mit Ubuntu-24.04 und copilot-1.0.12 sind mysteriöser Weise weg
- 2026-03-28: Probleme mit Ubuntu-24.04 und copilot-1.0.12
- 2026-03-24: Erste Version

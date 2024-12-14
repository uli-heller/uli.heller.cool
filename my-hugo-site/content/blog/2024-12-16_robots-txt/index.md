+++
date = '2024-12-16'
draft = false
title = 'Blockieren von KI-Scannern'
categories = [ 'Lizenz' ]
tags = [ 'hugo', 'lizenz' ]
toc  = false
+++

<!--
Blockieren von KI-Scannern
==========================
-->

Ich möchte nicht, dass meine Texte für das Anlernen
von KI-Modellen verwendet werden. Hauptgrund: Wenn jemand
meine Texte in eigene Machwerke einbezieht, dann möchte ich
dort eine Referenz auf meinen Text sehen. Das klappt
bei KI-generierten Texten überhaupt nicht. Also: Keine KI!

<!--more-->

Ich verfolge einen doppelten Ansatz
zur Verbannung von KI:

- Einerseits via [Linzentbedingungen](/license)
  samt maschinenlesbarer Beschreibung
- Andererseits via "robots.txt" - da kann ich aber
  nur die mir bekannten KI-Agenten sperren

Den Inhalt der "robots.txt" habe ich hiervon:
[Custom robots.txt](https://its.mw/posts/more-hugo-tips-tricks/)

Die Datei sieht so aus:

```
# AI bots
User-agent: Amazonbot
User-agent: Applebot
User-agent: Bytespider
```

Ich speichere sie in [static/robots.txt](/robots.txt).

Links
-----

- [Michael Welford - More Hugo tips and tricks](https://its.mw/posts/more-hugo-tips-tricks/)
- [DarkVisitors](https://darkvisitors.com/) ...automatische Erzeugung
  von "robots.txt"
- [Meine Lizenz für Texte wie diesen](/license)

Historie
--------

- 2024-12-16: Erste Version

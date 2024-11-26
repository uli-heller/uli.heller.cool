+++
date = '2024-11-24'
draft = false
title = 'Hugo: Bilder mit Breite'
categories = [ 'Hugo' ]
tags = [ 'hugo' ]
+++

<!--
Hugo: Bilder mit Breite
=======================
-->

Das Einbinden von Bildern in Markdown ist für mich
persönlich ein stetiger Quell an Ärger. Insbesondere
wenn ich SVG-Bilder einbinde, dann werden die so angezeigt,
dass sie die gesamte verfügbare Breite "einnehmen".
Das ist besonders "doof" bei Mini-Piktogrammen
wie bspw. diesem hier:

![Creative Commons Logo](images/logo.svg?width=20px)

Hoffen wir mal, dass Abhilfe möglich ist!

<!--more-->

Huanlin ImageRenderer
---------------------

[Huanlin Docs - A Hugo image render hook that supports width parameter](https://huanlin.cc/blog/2024/07/10/hugo-image-render-hook-width-param/) beschreibt ein Verfahren, mit dem
es möglich sein sollte, die Breite vorzugeben.

- [Implementierung des ImageRenderers](image-renderer.txt)
- Einspielen nach "layouts/_default/_markup/render-image.html"
- Anpassen der Bilder-Syntax:
  - Bislang: `![Creative Commons Logo](images/logo.svg)`
  - Nun: `![Creative Commons Logo](images/logo.svg?width=20px)`
- Sichten: Wie sieht es "oben" aus? Gut!

[Hugo Images Module](https://images.hugomods.com/)
--------------------------------------------------

Es gibt auch eine etwas komfortablere und umfangreichere Implementierung
in Form eines [Hugo-Modul für Images](https://images.hugomods.com/).
Das wird auch im Artikel von Huanlin erwähnt. Es ist schwieriger einzuspielen.
Außerdem hat es wohl diese Einschränkungen (bei Huanlin auf Chinesisch):

  - Bilder-Pfade, die mit "." beginnen (bspw. "./images/uli.png"), werden nicht richtig unterstützt
  - Bilder werden mit den angegebenen Dimensionen gespeichert. Das Original-Bild ist
    nicht mehr verfügbar!
  - Typischerweise wird das Bild zusätzlich im WEBP-Format abgespeichert.
    Anmerkung Uli: Kann unterdrückt werden! [Konfiguration](https://images.hugomods.com/docs/configuration/#modern_format)

Ich verwende das Modul vorerst nicht!

Links
-----

- [Huanlin Docs - A Hugo image render hook that supports width parameter](https://huanlin.cc/blog/2024/07/10/hugo-image-render-hook-width-param/)
  - [Lizenz](https://github.com/huanlin/huanlin.github.io?tab=License-1-ov-file)
  - [CC BY-NC-ND 4.0](http://creativecommons.org/licenses/by-nc-nd/4.0/)
- [Hugo-Modul für Images](https://images.hugomods.com/) ... verwende ich aktuell nicht
- [Notizen](notizen.txt)
- [Implementierung des ImageRenderers](image-renderer.txt)

Historie
--------

- 2024-11-24: Erste Version

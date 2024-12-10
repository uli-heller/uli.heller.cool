---
date: 2024-11-22
draft: false
title: 'Tipps und Tricks mit PNG-Dateien'
categories:
 - Bildchen
tags:
 - pdf
 - png
 - imagemagick
---

<!--Tipps und Tricks mit PNG-Dateien-->
<!--=========================-->

Ich muß immer mal wieder mit PNG-Dateien
arbeiten. Die muß ich dann oft bearbeiten, bspw.
die Größe anpassen. Gefühlt muß ich jedes mal
wieder auf's neue "googlen", wie das funktioniert.
Hier sammle ich Tipps für solche Tätigkeiten.
Im Moment ist die Sammlung noch recht überschaubar,
sie wird wachsen!

<!--more-->

Größe halbieren
---------------

`convert -resize 50% (alt).png (neu).png`

Auf Breite skalieren
--------------------

`convert -resize 1024x (alt).png (neu).png`

Auf Höhe skalieren
------------------

`convert -resize x240 (alt).png (neu).png`

Dateigröße reduzieren
---------------------

`pngquant -o (neu).png 32 (alt).png`

Wandeln nach PDF
----------------

`convert s1.png s2.png s3.png -auto-orient result.pdf`

Historie
--------

- 2024-12-10: Wandeln nach PDF
- 2024-11-25: Dateigröße reduzieren
- 2024-11-22: Skalieren auf Breite und Höhe
- 2024-11-22: Erste Version

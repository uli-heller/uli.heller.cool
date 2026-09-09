+++
date = '2026-09-09'
draft = false
title = 'IMMICH: Importieren eines Bilderbestands mit automatischer TAG-Erzeugung'
categories = [ 'Heimserver' ]
tags = [ 'immich' ]
+++

<!--
IMMICH: Importieren eines Bilderbestands mit automatischer TAG-Erzeugung
===================================
-->

Ich spiele gerade mit der Software IMMICH herum.
Das ist eine Bilderverwaltung. Auf den ersten Blick recht
vielversprechend. Die Probleme liegen im Detail!

<!--more-->

Vorlauf
-------

Bislang habe ich

- IMMICH-Server installiert (einfach)
- Benutzer innerhalb von IMMICH-Server angelegt (einfach)
- IMMICH-Mobile auf meinem Handy installiert (einfach)
- Handy-Bilder in IMMICH importiert (einfach, quasi automatisch)

Danach sieht's innerhalb von IMMICH schonmal ganz gut aus.

Import des Bilderbestandes - erster Versuch
-------------------------------------------

Auf diversen Festplatten habe ich Unmengen an Bildern rumliegen.
Diese sollen natürlich auch in IMMICH rein.

Ich bin grob nach diesem Ablauf vorgegangen:

- Bilder "suchen"
- Alle Bilder in ein temporäres Verzeichnis kopieren:
  ```
  mkdir /tmp/bilder
  find /wo-auch-immer -type f -name "*.jpg" -o -name "*.JPG" ... | xargs -I{} -t cp {] /tmp/bilder/.
  ```
- Alle Bilder des Verzeichnisses via Web-Oberfläche in IMMICH importieren

Das Ergebnis ist OK, allerdings scheint sich jemand viel Mühe gemacht zu haben,
die Bilder in Verzeichnissen sinnig zu organisieren und diese "Information"
geht mit obigem Ablauf verloren.

Außerdem gibt es Probleme mit dem Import-Dialog. Nachdem ich ein paar tausend Bilder
importiert habe, öffnet sich der Import-Dialog quasi nicht mehr. Es klappt nur mit Firefox.
Da muß ich dann mehrfach auf "Von Computer hochladen" drücken. Der Dialog öffnet sich
erst mit mehreren Minuten Verzögerung (dann aber mehrfach).

Import des Bilderbestandes - zweiter Versuch
--------------------------------------------

Import des Bilderbestandes - finaler Ablauf
-------------------------------------------

1. Ermitteln: Wo liegen Bilder? Bspw. unter "/media/uli/meine-alte-platte"
   `IMAGE_SOURCE="/media/uli/meine-alte-platte"`
2. Optional: Zugriffsrechte korrigieren
   `find "${IMAGE_SOURCE}" -type d  \! -perm "/050" -print0|xargs -0 chmod 755
3. Ermitteln aller Dateierweiterungen:
   `find "${IMAGE_SOURCE}" -type f|sed -e 's!^.*/\([^/]*\)$!\1!' -e 's!^.*\(\.[^.]*\)$!\1!' -n -e '/^\./p'|sort -u`
4. Hier eine mögliche Liste:
   - .AVI
   - .bin
   - .dat
   - .db
   - .DS_Store
   - ...
   - .WAV
   - .wri
   - .xcf
   - .xml
5. Sichten: Welche Erweiterungen "passen" wohl auf Bilder?
   - .gif
   - .jpg
   - .JPG
6. Liste aller Bilder erstellen: `find "${IMAGE_SOURCE}" -name ".AppleDouble" -prune -type f -name "*.gif" -o -name "*.jpg" -o -name "*.JPG" >/tmp/images.list`
7. Zählwert: `wc -l /tmp/images.list` -> 6071 /tmp/images.list

Links
-----

- TBD

Versionen
---------

Getestet mit

- Ubuntu 26.04 LTS
- Immich-3.1
- ...

Historie
--------

- 2026-09-09: Erste Version

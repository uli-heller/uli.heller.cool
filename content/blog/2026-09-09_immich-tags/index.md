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

Nachdem ich erkannt habe, dass der "Verlust" der Verzeichnisse ein Problem ist,
habe ihc mit "immich-go" rumgespielt. Da gibt es die Option "--folder-as-tags".
Leider stellt sich heraus, dass das bei bereits importierten Bildern nicht
richtig funktioniert. Diese werden übersprungen.

Import des Bilderbestandes - finaler Ablauf
-------------------------------------------

Eine Recherche ergibt, dass ich am einfachsten die bestehenden JPG-Dateien
anpasse und dort Tags/Keywords setze vor dem Import mittels "immich-go".
Ich bin dabei grob so vorgegangen:

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
8. Ermitteln: Welches Zeichen taucht in der Liste **nicht** auf? Bei mir bspw. ":"!
9. Sichtung der Datei "image.list": Welche "Tags" erscheinen sinnvoll?
   Am besten "Klassen/Gruppen" ermitteln!
   - Kein Tag
     - /tmp/x/andi/Bilder/SamsungSchwarz/ITG/Burg.jpg
     - ...
   - Tag nach Doppelpunkt
     - /tmp/x/andi/Bilder/Gartenhütte/20140113_084055.jpg:2014
     - ...
10. Bearbeiten der Bilder mit "Tag nach Doppelpunkt" - Tag in den Metadaten setzen mit "exiftool"
   - Prüfen: Tag vs CreateDate
     ```
     PREV_TAG=; while read -r image_tag; do
       i="$(echo "${image_tag}"|cut -d : -f 1)";
       t="$(echo "${image_tag}"|cut -d : -f 2)";
       test "${t}" = "${PREV_TAG}" && continue;
       e="$(exiftool "${i}" | grep "^Create Date")";
       echo "${t}: ${e}";
       PREV_TAG="${t}";
     done </tmp/images.list.tag-nach-doppelpunkt
     ```
   - Setzen: Tag
     ```
     while read -r image_tag; do
       i="$(echo "${image_tag}"|cut -d : -f 1)";
       t="$(echo "${image_tag}"|cut -d : -f 2)";
       ( set -x; exiftool  -IPTC:Keywords="${t}" -XMP:TagsList="${t}" "${i}"; );
     done </tmp/images.list.tag-nach-doppelpunkt
     ```
11. Bilder in Zwischenordner kopieren
    ```
    mkdir /tmp/bilder
    cut -d : -f 1 </tmp/images.list.tag-nach-doppelpunkt|xargs -I{} -t cp {} /tmp/bilder/.
    ```
12. Bilder in IMMICH importieren
    ```
    (
      cd /tmp/bilder;
      immich-go upload from-folder --api-key=YaD...GE4 --server=https://immich.heller.cool .
      # Oder auch:
      #   ALBUM="my-album";
      #   immich-go upload from-folder --api-key=YaD...GE4 --server=https://immich.heller.cool --into-album "${ALBUM}" .;
    )
    ```

Hinweise:
- IMAGE_SOURCE=/tmp/x/andi
- IMAGE_SOURCE=/tmp/x/lilly
- `587   2808 -rw-------   1 1001     1001      2875364 Okt  6  2013 /tmp/x/andi/Bilder/SamsungSchwarz/Lillys\ eigene\ Fotos/VonLillysFotoapparat/DSCN0005.JPG`
- `find /tmp/x/andi \( -name "*.JPG" -o -name "*.jpg" \) -a -name "*5*" -a -not -perm -o=r -ls`
- `find . -type d -print0|xargs -0 chown uli:uli`

Cheatsheet
----------

### exiftool

```
exiftool '-TagsList<${directory;s(.*/([^/]+)/([^/]+)$)($1_$2)}' -r /pfad/zu/deinen/lokalen/bildern
exiftool '-TagsList<${directory;s(.*/([^/]+)/[^/]+$)($1)}' '-TagsList<${directory;s(.*/[^/]+/([^/]+)$)($1)}' -r /pfad/zu/deinen/lokalen/bildern
exiftool -IPTC:Keywords="uli-war-da" -XMP:TagsList="uli-war-da" bild.jpg
```

### Probleme

#### Dateinamen

Error: File not found - /tmp/x/andi/Bilder/SamsungSchwarz/zur Entwicklung 2009/Lilly am Hangeln/BB.jpg

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

GPS-Tracks anzeigen und bearbeiten
==================================

Vorbereitungen
--------------

Kommandozeile:

```sh
sudo apt install gpsbabel
sudo apt install xmlstarlet
sudo apt install libxml2-utils
```

Browser:

- Link zu [JGPSTrackEdit][JGPSTRACKEDIT] öffnen
- JGPSTrackEdit-1.7.1.jar herunterladen und speichern

Anzeigen
--------

java -jar ~/Software/JGPSTrackEdit-1.7.1.jar  2022-02-14*gpx

Interaktiv bearbeiten
---------------------
JGPSTrackEdit-1.7.1.jar
java -jar ~/Software/JGPSTrackEdit-1.7.1.jar  2022-02-14*gpx

Bereinigen
----------

https://oleb.net/2020/sanitizing-gpx/
http://www.gpsbabel.org/htmldoc-development/filter_position.html

Links
-----

- [JGPSTrackEdit][JGPSTRACKEDIT]
- [GPSBabel][GPSBABEL]
- [Ole Begemann - Sanitizing GPX files for public sharing][OLEB]

[GPSBABEL]: http://gpsbabel.org
[JGPSTRACKJEDIT]: https://sourceforge.net/projects/jgpstrackedit/files/binaries/
[OLEB]: https://oleb.net/2020/sanitizing-gpx/

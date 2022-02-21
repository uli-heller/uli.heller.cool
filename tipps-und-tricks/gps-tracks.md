GPS-Tracks anzeigen und bearbeiten
==================================

Vorbereitungen
--------------

Kommandozeile:

```shell
sudo apt install gpsbabel
sudo apt install xmlstarlet
sudo apt install libxml2-utils
sudo apt install openjdk-11-jre
```

Browser:

- Link zu [JGPSTrackEdit][JGPSTRACKEDIT] öffnen
- JGPSTrackEdit-1.7.1.jar herunterladen und speichern im Verzeichnis "~/Software"

Bereinigen
----------

Für das Berenigen der GPS-Tracks orientiere ich
mich im Wesentlichen an [dieser Anleitung von Ole Begemann][OLEB].

Analog der Beschreibung werden diese Daten entfernt/bereinigt:

- Elemente vom Typ `<extensions>` - diese Elemente enthalten Temperatur, Herzfrequenz und Schrittfrequenz.
    ```
        <extensions>
          <ns3:TrackPointExtension>
            <ns3:atemp>27.0</ns3:atemp>
            <ns3:hr>74</ns3:hr>
            <ns3:cad>78</ns3:cad>
          </ns3:TrackPointExtension>
        </extensions>
    ```
- Element `gpx/metadata/time`
- Elemente `//trkpt/time`
- Elemente `//trkpt/hdop, vdop und pdop` (gibt es bei meinen Garmin-Tracks nicht)

Auch alle nicht verwendeten XML-Namespaces und SchemaLocations werden
bereinigt und die UTF-Zeichen eingesetzt. Details stehen in [der Anleitung von Ole Begemann][OLEB].

Zusätzlich habe ich noch eine Positionsbereinigung eingebaut.
Du gibst einen rechteckigen Bereich vor mit

- Minimal- und Maximalwert für LAT
- Minimal- und Maximalwert für LON

und alle Streckenpunkte in diesem Bereich werden entfernt.
Das verwende ich beispielsweise, um meine Heimadresse zu verschleiern.
Damit möchte ich vermeiden, dass jemand weiß, wo **genau** ich wohne
und Abwesenheit für einen Einbruch nutzen kann.

Klar: Die Adresse sollte möglichst nicht genau in der Mitte des
Bereinigungsbereichs liegen. Das wäre sehr naheliegend und
die Mitte des Bereichs kann bei Vorlage mehrerer Tracks leicht
ermittelt werden!

### bin/gpx-clean.sh

Hier ein erster halbwegs funtionierender Stand
meines Aufräum-Skriptes. Die aktuelle Version
liegt [zum Herunterladen](/bin/gpx-clean.sh) bereit.

```shell
#!/bin/sh
#
# https://oleb.net/2020/sanitizing-gpx/
#
# find . -name "*gpx.xz"|while read f; do b="$(echo "$f"|sed -e 's/.xz$//')"; xz -d "${f}"; ./bin/gpx-clean.sh "${b}" >"${b}~"; mv "${b}~" "${b}"; xz -9 "${b}"; done
#
D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"
DD="$(dirname "${D}")"
BN="$(basename "$0")"

RC=0

TMPDIR="/tmp/${BN}.$({ date; ps waux; }|sha256sum|cut -f1 -d" ").$$~"

cleanUp () {
    rm -rf "${TMPDIR}"
    exit "${RC}"
}

trap cleanUp 0 1 2 3 4 5 6 7 8 9 10 12 13 14 15

mkdir "${TMPDIR}"

#
# Deaktivierte Bereinigungen
#   -d "/_:gpx/_:trk/_:type" \
#   -u "/_:gpx/@creator" -v "gpx-clean" \
#
xmlstarlet ed \
  -d "//_:extensions" \
  -d "/_:gpx/_:metadata/_:time" \
  -d "//_:trkpt/_:time" \
  -d "//_:trkpt/_:hdop" \
  -d "//_:trkpt/_:vdop" \
  -d "//_:trkpt/_:pdop" \
  "$1" \
  | xmlstarlet tr "${DD}/etc/remove-unused-namespaces.xslt" - \
  | xmlstarlet ed -u "/_:gpx/@xsi:schemaLocation" -v "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd" \
  | xmllint --c14n11 --pretty 2 - >"${TMPDIR}/clean.gpx"

grep -v "^\s*#" "${DD}/etc/gpx-clean-regions.conf"\
    |while IFS=":" read lat lon; do
      lat_min="$(echo "${lat}"|cut -d"-" -f1)"
      lat_max="$(echo "${lat}"|cut -d"-" -f2)"
      lon_min="$(echo "${lon}"|cut -d"-" -f1)"
      lon_max="$(echo "${lon}"|cut -d"-" -f2)"
      xmlstarlet ed -d "//_:trkpt[@lat>${lat_min} and @lat<${lat_max} and @lon>${lon_min} and @lon<${lon_max}]" "${TMPDIR}/clean.gpx" >"${TMPDIR}/clean-pos.gpx"||exit 1
      mv "${TMPDIR}/clean-pos.gpx" "${TMPDIR}/clean.gpx"
    done
RC=$?

test "${RC}" -eq 0 && cat "${TMPDIR}/clean.gpx"
cleanUp
```

### etc/gpx-clean-regions.conf

Hier eine erste Version der Regionsdatei.
Sie dient primär dem "Verstecken" meines Wohnorts.
Die aktuelle Version liegt [zum Herunterladen](/etc/gpx-clean-regions.conf) bereit.

```
#
# Format:
#  lat-limits:lon-limits
#
48.86784-48.871654:9.182696-9.189369
```

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

xmlstarlet sel -t -c "//_:trkpt" garmin-6x-7x/images/2022-02-14_7x-sapphire.gpx
xml ed -L -d "//configuration/folder[@id=\"$foldername\"]" config.xml

Links
-----

- [JGPSTrackEdit][JGPSTRACKEDIT]
- [GPSBabel][GPSBABEL]
- [Ole Begemann - Sanitizing GPX files for public sharing][OLEB]

[GPSBABEL]: http://gpsbabel.org
[JGPSTRACKJEDIT]: https://sourceforge.net/projects/jgpstrackedit/files/binaries/
[OLEB]: https://oleb.net/2020/sanitizing-gpx/

+++
date = '2025-01-01'
draft = false
title = 'GIMP: Bild abreissen'
categories = [ 'Bildchen' ]
tags = [ 'gimp' ]
+++

<!--GIMP: Bild abreissen-->
<!--====================-->

Hier zeige ich, wie man mit GIMP ein abgerissenes
Bild erzeugt, also sowas:

![Vorschau](images/home-top-abgerissen.png?width=200pt)

<!--more-->

Ausgangsbild
------------

![Ausgangsbild](images/home-top.png?width=800pt)

GIMP starten
------------

![GIMP starten](images/02-gimp-starten.png?width=800pt)

Ausgangsbild laden
------------------

- Datei
- Öffnen... "images/home-top.png" wählen

![GIMP mit Ausgangsbild](images/03-gimp-ausgangsbild.png?width=800pt)

Ansicht verkleinern
-------------------

- Ansicht
- Vergrößerung
- 25%

![GIMP Ansicht verkleinert](images/04-gimp-verkleinert.png?width=800pt)

Freie Auswahl - Bereich wählen
------------------------------

- Werkzeuge
- Auswahlwerkzeuge
- Freie Auswahl
- "Kreisförmig"

![GIMP Freie Auswahl](images/06-gimp-freie-auswahl.png?width=800pt)

Auswahl verzerren
-----------------

- Auswahl
- Verzerren...
  - Schwellwert: 0,500
  - Verteilen: 8
  - Körnigkeit: 4
  - Glätten: 2->3
  - Horizontal glätten: Ja
  - Vertikal glätten: Ja
  - OK

![GIMP Auswahl verzerrt](images/08-gimp-auswahl-verzerrt.png?width=800pt)

Kopieren und neues Bild erstellen
---------------------------------

- Bearbeiten
- Kopieren
- Datei
- Erstellen
- Aus Zwischenablage

![GIMP Neues Bild](images/09-gimp-neues-bild.png?width=800pt)

Erstes Bild einweißen
--------------------

- Zurück zum ersten Bild (oben, linkes Bild)
- Auswahl
  - Verzerren
  - OK
- Farben
  - Vordergrund: Schwarz, Hintergrund: Weiß
  - Wechseln
  - Vordergrund: Weiß, Hintergrund: Schwarz
- Werkzeuge
  - Malwerkzeuge
  - Füllen
  - Ganze Auswahl füllen
- In den Auswahlbereich klicken -> wird mit weiß gefüllt

![GIMP Auswahlbereich füllen](images/10-gimp-auswahl-fuellen.png?width=800pt)

![GIMP Auswahlbereich gefüllt](images/11-gimp-auswahl-gefuellt.png?width=800pt)

Weißen Teil als Ebene einfügen
------------------------------

- Erstes Bild
- Werkzeuge
  - Auswahlwerkzeuge
  - Freie Auswahl
- Bearbeiten
  - Kopieren
- Zweites Bild
- Bearbeiten
  - Einfügen als...
  - Als einzelne Ebene einfügen
- Unten rechts: Ebenen vertauschen

![GIMP Vereintes Bild](images/12-gimp-vereintes-bild.png?width=800pt)

Vereinen und Schatten
---------------------

- Unten rechts: Rechte Maustaste
  - Sichtbare Ebenen vereinen...
  - OK
- Filter
  - Licht und Schatten
  - Schlagschatten (veraltet)
    - VersatzX: 4
    - VersatzY: 4
    - Weichzeichnenradius: 15
    - Farbe: Schwarz
    - Deckkraft: 60
    - OK

![GIMP Schatten](images/13-gimp-schatten.png?with=800pt)

Speichern
---------

- Datei
  - Speichern unter...
  - images/home-top-abgerissen.xcf
  - OK
  - Exportieren unter...
  - images/home-top-abgerissen.png
  - OK
  
Finales Ergebnis
----------------

![Abgerissenes Bild](images/home-top-abgerissen.png?width=800pt)
  
Links
-----

- [GIMP](https://www.gimp.org)

Versionen
---------

Getestet mit Ubutu-22.04 und GIMP-3.0.0-RC2.

Historie
--------

- 2025-01-01: Erste Version

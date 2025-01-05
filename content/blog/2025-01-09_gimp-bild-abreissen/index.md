+++
date = '2025-01-09'
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

- Datei (File)
- Öffnen... (Open...) "images/home-top.png" wählen

![GIMP mit Ausgangsbild](images/03-gimp-ausgangsbild.png?width=800pt)

Ansicht verkleinern
-------------------

- Ansicht (View)
- Vergrößerung (Zoom)
- 25%

![GIMP Ansicht verkleinert](images/04-gimp-verkleinert.png?width=800pt)

Freie Auswahl - Bereich wählen
------------------------------

- Werkzeuge (Tools)
- Auswahlwerkzeuge (Selection Tools)
- Freie Auswahl (Free Select)
- "Kreisförmig"

![GIMP Freie Auswahl](images/06-gimp-freie-auswahl.png?width=800pt)

Auswahl verzerren
-----------------

- Auswahl (Select)
- Verzerren... (Distort...)
  - Schwellwert (Threshold): 0,500
  - Verteilen (Spread): 8
  - Körnigkeit (Granularity): 4
  - Glätten (Smooth): 2->3
  - Horizontal glätten (Smooth horizontally): Ja
  - Vertikal glätten (Smooth vertically): Ja
  - OK

![GIMP Auswahl verzerrt](images/08-gimp-auswahl-verzerrt.png?width=800pt)

Kopieren und neues Bild erstellen
---------------------------------

- Bearbeiten (Edit)
  - Kopieren (Copy)
- Datei (File)
  - Erstellen (Create)
    - Aus Zwischenablage (From clipboard)

![GIMP Neues Bild](images/09-gimp-neues-bild.png?width=800pt)

Erstes Bild einweißen
--------------------

- Zurück zum ersten Bild (oben, linkes Bild)
- Auswahl (Select)
  - Verzerren (Distort)
  - OK
- Farben 
  - Vordergrund: Schwarz, Hintergrund: Weiß
  - Wechseln
  - Vordergrund: Weiß, Hintergrund: Schwarz
- Werkzeuge (Tools)
  - Malwerkzeuge (Paint Tools)
  - Füllen (Bucket Fill)
  - Betroffener Bereich (Affected Area)
    - Ganze Auswahl füllen (Fill whole selection)
- In den Auswahlbereich klicken -> wird mit weiß gefüllt

![GIMP Auswahlbereich füllen](images/10-gimp-auswahl-fuellen.png?width=800pt)

![GIMP Auswahlbereich gefüllt](images/11-gimp-auswahl-gefuellt.png?width=800pt)

Weißen Teil als Ebene einfügen
------------------------------

- Erstes Bild
- Werkzeuge (Tools)
  - Auswahlwerkzeuge (Selection Tools)
  - Freie Auswahl (Free Select)
- Bearbeiten (Edit)
  - Kopieren (Copy)
- Zweites Bild
- Bearbeiten (Edit)
  - Einfügen als... (Paste as...)
  - Als einzelne Ebene einfügen (Paste as Single Layer)
- Unten rechts: Ebenen vertauschen

![GIMP Vereintes Bild](images/12-gimp-vereintes-bild.png?width=800pt)

Vereinen und Schatten
---------------------

- Unten rechts: Rechte Maustaste
  - Sichtbare Ebenen vereinen... (Merge Visible Layers...)
  - OK (Merge)
- Filter (Filters)
  - Licht und Schatten (Light and Shadow)
  - Schlagschatten (veraltet)... (Drop Shadow (lagacy)...)
    - VersatzX (OffsetX): 4 (oder auch 8)
    - VersatzY (OffsetY): 4 (oder auch 8)
    - Weichzeichnenradius (Blur radius): 15
    - Farbe (Color): Schwarz
    - Deckkraft (Opacity): 60
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

Dunkles Bild
------------

![Terminal](images/terminal.png)

![Terminal abgerissen](images/terminal-abgrissen.png)

Links
-----

- [GIMP](https://www.gimp.org)
- [daemons-point.com: GIMP: Bildchen abreissen](https://daemons-point.com/blog/2020/05/30/gimp-abreissen/)

Versionen
---------

Getestet mit Ubutu-22.04 und GIMP-3.0.0-RC2.

Historie
--------

- 2025-01-09: Erste Version

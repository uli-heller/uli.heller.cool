+++
date = '2026-02-08'
draft = false
title = 'Windows 10 in Gnome-Boxes'
categories = [ 'Virtualisierung' ]
tags = [ 'gnome boxes', 'ubuntu', 'linux' ]
+++

<!--
Windows 10 in Gnome-Boxes
=========================
-->

Vor langer Zeit habe ich Windows 10 in VirtManager
installiert und [hier (Windows in VirtManager)]({{< ref "blog/2025-07-22_windows-in-virt-manager" >}}) beschrieben. Leider habe ich die Anmeldedaten
verbummelt und kann die Installation nicht mehr nutzen.

Also: Neuinstallation, diesmal in Gnome-Boxes!

<!--more-->

Warum nicht Windows-11?
-----------------------

Kurz habe ich mit Windows-11 geliebäugelt.
Leider scheitert die Installation an den Installationsvoraussetzungen.
Die kann man umgehen, ich beschreibe den Ablauf später mal.
Vorerst nehme ich den einfachen Weg und verwende Windows-10.

Windows-10-ISO
--------------

Für die Installation habe ich diese
ISO-Datei verwendet: Win10_22H2_German_x64v1.iso.
Sie ist recht alt. Man konnte sie früher mal bei
Microsoft herunterladen. Keine Ahnung, ob das immer
noch klappt.

Grundinstallation
-----------------

Die Grundinstallation innerhalb von Gnome-Boxes ist mega-einfach:

- Neue Box anlegen
- Windows-10-ISO auswählen
- 16 GB Hauptspeicher
- 50 GB Plattenspeicher
- Dann die Installation "durchklicken"

Konfiguration
-------------

Nach der Installation erscheint der Konfigurationsassistent.
Diesen auch "durchklicken". Ich denke, es sind ein paar Neustarts
erforderlich.

Aktualisierungen
----------------

Nach der Konfiguration alle Aktualisierungen einspielen!
Das erfordert viele Downloads und ein paar weitere Neustarts!

Verbesserung der Integration
----------------------------

Auffällig und störend sind:

- Schlechte Bildschirmauflösung
- Schlechte Mausintegration - wird immer "gefangen" und muß mit "links-strg-alt" wieder befreit werden
- "Kopieren und Einfügen" funktioniert nicht zwischen Windows und Linux

Zur Abhilfe können die "spice-guest-tools" von [https://www.spice-space.org](https://www.spice-space.org) eingespielt werden:

- [spice-guest-tools-0.141.exe](https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-0.141/spice-guest-tools-0.141.exe) herunterladen
- Virencheck
- Ausführen -> alles "abnicken"

Danach klappt's perfekt!

Versionen
---------

- Ubuntu-24.04.3
- Kernel 6.17.0-14-generic
- Gnome-Boxes 46.0-1build1
- VirtManager 1:4.1.0-3ubuntu0.1

Links
-----

- [spice-guest-tools-0.141.exe](https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-0.141/spice-guest-tools-0.141.exe)
- [Windows in VirtManager]({{< ref "blog/2025-07-22_windows-in-virt-manager" >}})

Historie
--------

- 2026-02-08: Erste Version

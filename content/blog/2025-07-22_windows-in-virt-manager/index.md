+++
date = '2025-07-22'
draft = false
title = 'Windows in VirtManager'
categories = [ 'Virtualisierung' ]
tags = [ 'virtmanager', 'ubuntu', 'linux' ]
+++

<!--
Windows in VirtManager
======================
-->

Mein altes TomTom-Navi benötigt wohl eine
Aktualisierung. So lautet zumindest die
Mail, die ich gestern von TomTom empfangen habe.

Offenbar benötige ich dazu Windows oder MacOS.

<!--more-->

Aktualisierung ohne PC
----------------------

Gemäß Online-Hilfe kann ich mein TomTom ohne
PC aktualisieren. Einfach mit WLAN verbinden
und dann aktualisieren lassen.

Leider fehlt bei meinem TomTom die betreffende
Option. Eventuell hab' ich's zu lange nicht
aktualisiert.

Windows 10 in Gnome-Boxes
-------------------------

Erster Versuch scheitert, ich bekomme keine
Netzwerkverbindung.

Windows 11 in VirtManager
-------------------------

Auch dieser Versuch scheitert, weil die Virtualisierung
die Voraussetzungen für Windows 11 nicht erfüllt.

Windows 10 in VirtManager
-------------------------

Diese Versuch verhält sich sehr ähnlich
zum ersten. Die Installation klappt, aber die
Netzwerkverbindung klappt nicht.

Umstellung auf VirtIO oder Hypervisor-Standard (RTLxxxx)
bringt keine Besserung.

Letztlich habe ich es so an's Fliegen bekommen:

- Gerätemanager in Windows 10 öffnen
- Netzwerkkarte suchen - sie ist markiert mit einem gelben Kreuz
- Netzwerkkarte deinstallieren
- Nach geänderter Hardware suchen - nun erscheint die Netzwerkkarte wieder ohne Kreuz

Verbindung mit TomTom
---------------------

Die Verbindung zu meinem TomTom-Gerät "zickt" auch:

- Gerät einstecken - Anzeige "Verbunden mit Ihrem Computer"
- USB weiterleiten zur VM
- Gerät taucht im Gerätemanager auf unter Netzwerkadapter TomTom mit einem gelben Kreuz
- Gerät deinstallieren
- Nach geänderter Hardware suchen - nun erscheint TomTom ohne gelbes Kreuz und funktioniert

Versionen
---------

- Ubuntu-24.04
- Kernel 6.14.0-24-generic
- Gnome-Boxes 46.0-1build1
- VirtManager 1:4.1.0-3ubuntu0.1

Links
-----

- [ArchLinux - [SOLVED] No Network Connectivity in Virt Manager with KVM/QEMU - Antwort #4 von cryptearth](https://bbs.archlinux.org/viewtopic.php?id=291898)
- [Windows VirtIO Drivers](https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers)
- [TomTom - Update über MyDrive Connect oder Wi-Fi](https://www.tomtom.com/de_de/account/details.html)

Historie
--------

- 2025-07-22: Erste Version

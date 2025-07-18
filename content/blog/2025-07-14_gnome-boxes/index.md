+++
date = '2025-07-14'
draft = false
title = 'Gnome-Boxes mit Ubuntu-24.04'
categories = [ 'Virtualisierung' ]
tags = [ 'gnome boxes', 'ubuntu', 'linux' ]
+++

<!--
Gnome-Boxes mit Ubuntu-24.04
============================
-->

Gnome-Boxes habe ich noch nie verwendet,
ich war bislang ein Fan von VirtualBox.
Leider hakt das immer mal wieder, also
probiere ich mal was anderes!

<!--more-->

Installation
------------

```
sudo apt update
sudo apt upgrade
sudo apt install -y gnome-boxes

# Falls VirtualBox installiert ist: Deinstallieren!
sudo apt purge virtualbox virtualbox-dkms virtualbox-qt
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
...
dpkg -l gnome-boxes
# -> 46.0-1build1 amd64
```

Nutzerrechte erweitern
----------------------

Diesen Teil mußte ich nur auf Rechnern machen,
auf denen VirtualBox installiert war!

```
sudo usermod -aG kvm,libvirt $USER
```

Danach Rechner neu starten. Ab- und Anmelden
reicht meiner Erfahrung nach nicht!

Kontrolle:

```
groups
# libvirt und kvm muß enthalten sein!
```

Speicherort ändern
------------------

Üblicherweise speichert Gnome-Boxes
die VMs in Heimatverzeichnis unterhalb von /home/(nutzer).
Das passt mir nicht, ich verwende gerne einen separaten
Speicherbereich unter "/data":

- Verzeichnis anlegen: `sudo mkdir /data/gnome-boxes`
- Eigener anpassen: `sudo chown uheller:uheller /data/gnome-boxes`
- Verschieben: `mv -v "$HOME/.local/share/gnome-boxes/"* /data/gnome-boxes/.`
- Einbinden:
  - `rmdir "$HOME/.local/share/gnome-boxes"`
  - `ln -s /data/gnome-boxes "$HOME/.local/share/gnome-boxes"`
  

Start
-----

- Kommando: `gnome-boxes`
- "+" - Neue virtuelle Maschine
  - Von Datei installieren
  - ISO auswählen: ubuntu-24.04.2-desktop-amd64.iso
  - Firmware: UEFI
  - Speicher: 4 -> 8GiB
  - Datenspeicher-Begrenzung: 25 -> 50 GiB
  - Anlegen

Beobachtungen
-------------

Meine ersten Eindrücke:

- Läuft recht gut!
- Gasterweiterungen werden nicht benötigt, Größenänderungen am
  Fenster "greifen" unmittelbar
- Keinerlei Anzeigeprobleme
- Keinerlei sonstige Probleme
- Sogar "Kopieren und Einfügen" funktioniert zwischen VM und Arbeitsplatz

Probleme
--------

### Neue virtuelle Maschine - Hoppla! No KVM!

Das Problem wurde bei mir verursacht durch
VirtualBox und fehlende Nutzerrechte.
Habe die Installationsanleitung entsprechend
angepasst.

Details stehen hier [bobcares - How to Fix “No KVM Error” in GNOME Boxes](https://bobcares.com/blog/how-to-fix-no-kvm-error-in-gnome-boxes/)

Versionen
---------

- Ubuntu-24.04
- Kernel 6.11.0-29-generic
- Gnome-Boxes 46.0-1build1

Links
-----

- [bobcares - How to Fix “No KVM Error” in GNOME Boxes](https://bobcares.com/blog/how-to-fix-no-kvm-error-in-gnome-boxes/)
- [Gnome-boxes: communication between guest and host](https://itsfoss.community/t/gnome-boxes-communication-between-guest-and-host/11807/7)

Historie
--------

- 2025-07-18: Link ["Gnome-boxes: communication between guest and host"](https://itsfoss.community/t/gnome-boxes-communication-between-guest-and-host/11807/7) hinzugefügt, Hinweis auf VirtualBox bei Nutzerrechten
- 2025-07-14: Erste Version

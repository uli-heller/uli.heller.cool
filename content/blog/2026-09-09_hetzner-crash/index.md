+++
date = '2026-09-09'
draft = false
title = 'LXC/LXD: Hetzner-Server hat eine Plattenstörung'
categories = [ 'INCUS', 'LXC/LXD' ]
tags = [ 'incus', 'lxc', 'lxd' ]
+++

<!--
LXC/LXD: Hetzner-Server hat eine Plattenstörung
===================================
-->

In meiner Firma nutzen wir diverse Hetzner-Rechner mit
LXC/LXD-Containern für unsere internen Services.
Einer dieser Rechner hat seit neuestem Störungen:

- SSH-Anmeldungen auf dem Hetzner-Rechner dauern sehr lange
- Gleiches gilt für die Anmeldungen an den Containern
  (klar: Der Hetzner-Rechner wird dafür als JumpHost verwendet
  und verzögert alles)
- Dadurch klappen auch manche GIT-Kommandos auf den Containern
  nicht

Schlecht!

<!--more-->

Lösungsplan
-----------

Dieser Abschnitt wird später mal nach unten geschoben.
Er ist aktuell "oben", damit man ihn schnell finden kann.

1. Sichtung Ersatzserver -> hetzner-de-ryzen
2. Aufräumen Ersatzserver
   - INCUS zurücksetzen
     - alle Container/Images/... löschen
   - richtige Version von INCUS installieren
3. Ermitteln: Welche Container werden benötigt und in welcher Reihenfolge?
4. ...

Sichtung
--------

### Systemaktualisierung

Eine Kurzsichtung zeigt, dass auch eine Systemaktualisierung
auf dem Hetzner-Rechner nicht mehr durchläuft.
Offenbar gibt es Probleme mit SystemD.

```
# apt upgrade
Reading package lists... Done
Building dependency tree       
Reading state information... Done
...
Setting up udev (245.4-4ubuntu3.24+esm5) ...
Failed to reload daemon: Failed to activate service 'org.freedesktop.systemd1': timed out (service_start_timeout=25000ms)
Failed to reload daemon: Failed to activate service 'org.freedesktop.systemd1': timed out (service_start_timeout=25000ms)
Failed to retrieve unit state: Failed to activate service 'org.freedesktop.systemd1': timed out (service_start_timeout=25000ms)
Failed to restart udev.service: Failed to activate service 'org.freedesktop.systemd1': timed out (service_start_timeout=25000ms)
See system logs and 'systemctl status udev.service' for details.
invoke-rc.d: initscript udev, action "restart" failed.
Failed to get properties: Failed to activate service 'org.freedesktop.systemd1': timed out (service_start_timeout=25000ms)
dpkg: error processing package udev (--configure):
 installed udev package post-installation script subprocess returned error exit status 1
Errors were encountered while processing:
 udev
E: Sub-process /usr/bin/dpkg returned an error code (1)

#
```

### Systemprotokoll

Das Systemprotokoll /var/log/syslog
enthält u.a. kritische Warnungen bezüglich
der Festplatten:

```
# grep -i crit /var/log/syslog
Sep  8 00:15:11 helsinki smartd[2313]: Device: /dev/nvme0, Critical Warning (0x04): Reliability
Sep  8 00:15:11 helsinki smartd[2313]: Device: /dev/nvme1, Critical Warning (0x04): Reliability
Sep  8 00:45:11 helsinki smartd[2313]: Device: /dev/nvme0, Critical Warning (0x04): Reliability
Sep  8 00:45:11 helsinki smartd[2313]: Device: /dev/nvme1, Critical Warning (0x04): Reliability
...
```

Sichtung der historischen Protokolle zeigt, dass diese
kritische Warnung schon lange besteht:

```
# zgrep -i crit /var/log/syslog*gz
...
/var/log/syslog.7.gz:Sep  1 23:23:41 helsinki smartd[2337]: Device: /dev/nvme0, Critical Warning (0x04): Reliability
/var/log/syslog.7.gz:Sep  1 23:23:41 helsinki smartd[2337]: Device: /dev/nvme1, Critical Warning (0x04): Reliability
/var/log/syslog.7.gz:Sep  1 23:53:41 helsinki smartd[2337]: Device: /dev/nvme0, Critical Warning (0x04): Reliability
/var/log/syslog.7.gz:Sep  1 23:53:41 helsinki smartd[2337]: Device: /dev/nvme1, Critical Warning (0x04): Reliability
```

### Sichtung Container

Zunächst möchte ich ermitteln, welche Container auf dem Rechner aktuell laufen.
Typischerweise mache ich das mit `lxc list`:

```
# lxc list
internal error, please report: running "lxd.lxc" failed: cannot create transient scope: DBus error "org.freedesktop.DBus.Error.TimedOut": [Failed to activate service 'org.freedesktop.systemd1': timed out (service_start_timeout=25000ms)]

#
```

Also: "Handhabung" von Containern ist aktuell stark eingeschränkt!
Erstmal bin ich froh, dass sie noch laufen und Dienste bereitstellen!

Notwendige Nacharbeiten
-----------------------

- Wir müssen sicherstellen, dass alle Hetzner-Rechner
  bei Plattenstörungen irgendwie Alarm schlagen!

Links
-----

- TBD

Versionen
---------

Ausfallender Server:

- Ubuntu-20.04
- LXC/LXD Version x.xx (Abfragen funktionieren aktuell nicht)

Ersatzserver:

- Ubuntu 24.04
- incus-7.0.1

Historie
--------

- 2026-09-09: Erste Version

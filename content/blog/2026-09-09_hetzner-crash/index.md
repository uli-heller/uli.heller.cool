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
   - Benötigte Container (Reihenfolge noch nicht festgelegt)
     - 733M	dp-tmate
     - 834M	pocket-id
     - 969M	daemons-point-com-static
     - 1.7G	dp-share
     - 1.8G	dp-dropzone
     - 2.4G	anwesenheit
     - 2.7G	legacy-kimai
     - 4.9G	dp-ldap-2204
     - 4.9G	dp-roundcube-2204
     - 6.1G	dptools
     - 8.9G	dp-paperless-ngx
     - 21G	dp-zammad-2004
     - 35G	dp-gitea
     - 39G	dp-dovecot-2204
     - 111G	dprepo
   - Unnötige Container
     - 661M	ubuntu-2604
     - 686M	debian-bookworm
     - 721M	ubuntu-2204
     - 759M	ubuntu-2004
4. Zur Reihenfolge: Ich möchte zuerst mit einem "kleinen" Container beginnen.
   Da kann ich den Übernahme-Mechanismus schneller testen als mit einem großen
   Container. Also: "dp-tmate" oder "pocket-id".

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

### Sichtung Container via Standard-Mechanismus

Zunächst möchte ich ermitteln, welche Container auf dem Rechner aktuell laufen.
Typischerweise mache ich das mit `lxc list`:

```
# lxc list
internal error, please report: running "lxd.lxc" failed: cannot create transient scope: DBus error "org.freedesktop.DBus.Error.TimedOut": [Failed to activate service 'org.freedesktop.systemd1': timed out (service_start_timeout=25000ms)]

#
```

Also: "Handhabung" von Containern ist aktuell stark eingeschränkt!
Erstmal bin ich froh, dass sie noch laufen und Dienste bereitstellen!

### Sichtung StoragePool von LXC/LXD

Der StoragePool ist glücklicherweise problemlos zugreifbar.
Daraus kann man auch erkennen, welche Container es gibt und
wieviele Daten sie jeweils aufweisen:

```
# cd /lxd
# cd containers
# du -hs *|sort -h
661M	ubuntu-2604
686M	debian-bookworm
721M	ubuntu-2204
733M	dp-tmate
759M	ubuntu-2004
834M	pocket-id
969M	daemons-point-com-static
1.7G	dp-share
1.8G	dp-dropzone
2.4G	anwesenheit
2.7G	legacy-kimai
4.9G	dp-ldap-2204
4.9G	dp-roundcube-2204
6.1G	dptools
8.9G	dp-paperless-ngx
21G	dp-zammad-2004
35G	dp-gitea
39G	dp-dovecot-2204
111G	dprepo
```

Einschränkungen
---------------

- SSH-Zugriff auf Hetzner-Rechner und die enthaltenen Container funktioniert SEHR langsam
  (Anmeldung dauert 1 Minute oder so, danach "läuft's")
- Systemaktualisierung klappt nicht
- Container-Kommandos (alles mit `lxc` oder `lxd`) funktionieren nicht
- SystemD funktioniert nicht, bspw. `systemctl reload apache2`
- SNAP-Aufrufe sind sehr langsam (`snap list` dauert 25 Sekunden)

Vorgehen bei Konfigurationsänderungen am Apache
-----------------------------------------------

1. Änderungen vornehmen, bspw. an /etc/apache2/sites-available/daemons-point.com.conf
2. Die Änderungen sind leider erstmal nicht aktiv
3. Typischerweise aktiviert man sie via `systemctl reload apache2` - das klappt aber nicht wegen der SystemD-Einschränkung!
4. Mit dem veralteten Befehl klappt's: `apachectl -k graceful`

Neuer Hetzner-Rechner (hetzner-de-ryzen)
----------------------------------------

### Inkonsistenzen in /etc/fstab korrigieren

- Wurzel-Dateisystem nur einmalig einbinden
- apt-cache-ng -> apt-cacher-ng

### Aktuelle Version von INCUS installieren

- Bislang: Veraltete Version installiert - 6.0.0-1ubuntu0.3
- Nun: Aktuelle Version installiert - 7.0.1-8~uli04~noble

### Bestehende INCUS-Installation aufräumen

#### Automatischer Weg

```
$ incus admin init --clean
Error: unknown flag: --clean
```

... geht wohl nur bei LXD

#### Manueller Weg

Der nachfolgende manuelle Weg basiert auf einem Vorschlag von Gemini.
Der Vorschlag ist allerdings deutlich fehlerbehaftet gewesen, ohne meine Änderungen klappt
es nicht!

```
# 1. Alle Instanzen (Container/VMs) stoppen und löschen
for i in $(incus list -c n --format csv); do incus stop "$i" --force 2>/dev/null; incus delete "$i"; done

# 2. ALLE Images (Betriebssystem-Abbilder) löschen
for img in $(incus image list --format csv | cut -d, -f1); do incus image delete "$img"; done

# 3. Alle benutzerdefinierten Profile löschen (das Profil 'default' kann nicht gelöscht werden)
for p in $(incus profile list --format csv | cut -d, -f1); do [ "$p" != "default" ] && incus profile delete "$p"; done

# 4. Default-Profil bereinigen
incus profile device remove default eth0
incus profile device remove default root

# 5. Alle Netzwerke löschen (Incus-eigene wie 'incusbr0') [grep -v war Quatsch]
for n in $(incus network list --format csv | grep "YES" | cut -d, -f1); do incus network delete "$n"; done

# 6. Alle Storage Pools löschen
for s in $(incus storage list --format csv | cut -d, -f1); do incus storage delete "$s"; done
```

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
- LXC/LXD Version 6.9 (SNAP-Variante)

Ersatzserver:

- Ubuntu 24.04
- incus-7.0.1

Historie
--------

- 2026-09-09: Erste Version

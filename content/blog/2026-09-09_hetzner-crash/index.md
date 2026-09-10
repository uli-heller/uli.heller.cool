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
  ```
  $ date +Start:%Y%m%d-%H%M%S; ssh 95.216.23.95 date +SSH:%Y%m%d-%H%M%S;date +Ende:%Y%m%d-%H%M%S
  Start:20260910-070608
  SSH:20260910-070828
  Ende:20260910-070828
    # 2min 20s
  
  $ date +Start:%Y%m%d-%H%M%S; ssh 95.216.23.95 date +SSH:%Y%m%d-%H%M%S;date +Ende:%Y%m%d-%H%M%S
  Start:20260910-070854
  SSH:20260910-071058
  Ende:20260910-071058
    # 2min 4s
  
  $ date +Start:%Y%m%d-%H%M%S; ssh 95.216.23.95 date +SSH:%Y%m%d-%H%M%S;date +Ende:%Y%m%d-%H%M%S
  Start:20260910-071204
  SSH:20260910-071418
  Ende:20260910-071418
    # 2min 14s
  ```
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
5. Umzug "pocket-id"
6. Umzug "dp-tmate" - geht ohne DNS-Änderungen

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

### "apt-cacher-ng" löschen

Bei neueren Installationen hat es sich bewährt, den "apt-cacher-ng" in
einem Container laufen zu lassen. Also: Auf den Hetzner-Rechner wird
er gelöscht!

- Sichtung der APT-Konfiguration: Wird "apt-cacher-ng" verwendet? Nein!
- "apt-cacher-ng" löschen: `apt purge apt-cacher-ng; apt autoremove`
- Aktualisierungstest: `apt update` -> klappt!
- LV löschen
  - /etc/fstab: /data/apt-cacher-ng entfernen
  - `umount /data/apt-cacher-ng`
  - `lvremove /dev/vg0/apt-cacher-ng`

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

# 7. incus_lv bereinigen
lvresize -L 300G /dev/vg0/incus_lv
mkfs.btrfs -L "INCUS storage pool" -f /dev/vg0/incus_lv
```

Damit sollte INCUS weitgehend im Grundzustand sein. Gleiches gilt für
den Speicherbereich/StoragePool. Er ist komplett neu initialisiert
und kann damit keine Rückstände mehr enthalten!

### Grundinitialisierung INCUS

#### Arbeitsplatzrechner

```
$ cd .../meine-hilfsskripte # v0.4
$ ./bin/incus/remote.sh -i uli@hetzner-de-ryzen
```

##### Vorbereitungen hetzner-de-ryzen

Die nachfolgenden Kommandos werden vorgeschlagen,
wenn man "Initialisierung hetzner-de-ryzen" mehrfach durchführt
und die Kommandos noch nicht ausgeführt hat!

```
# apt install yq

# /home/uli/bin/incus/incus-initialize.sh
Network incushostonly created
Network incusnat created
Device eth0 added to default
Device eth1 added to default

# home/uli/bin/incus/incus-initialize-root.sh 
Created symlink /etc/systemd/system/sys-subsystem-net-devices-incushostonly.device.wants/incus-dns-incushostonly.service → /etc/systemd/system/incus-dns-incushostonly.service.
Unit /etc/systemd/system/incus-dns-incushostonly.service is added as a dependency to a non-existent unit sys-subsystem-net-devices-incushostonly.device.
Created symlink /etc/systemd/system/sys-subsystem-net-devices-incusnat.device.wants/incus-dns-incusnat.service → /etc/systemd/system/incus-dns-incusnat.service.
Unit /etc/systemd/system/incus-dns-incusnat.service is added as a dependency to a non-existent unit sys-subsystem-net-devices-incusnat.device.

# incus storage create default btrfs source=/dev/vg0/incus_lv source.wipe=true
Storage pool default created

# incus profile device add default root disk path=/ pool=default
Device root added to default

# echo "/dev/vg0/incus_lv /incus btrfs defaults 0 0" >>/etc/fstab
# systemctl daemon-reload
# mkdir /incus
# mount /incus
```

##### Initialisierung hetzner-de-ryzen

```
$ ./bin/incus/yaml-create.sh etc/incus-dp/apt-cacher-ng.yaml
$ ./bin/incus/yaml-create.sh etc/incus-dp/certbot.yaml
  # Da CERTBOT wegen fehlender DNS-Umstellung erstmal
  # noch nicht aktiv sein kann, muß ich die ersten Zertifikate
  # manuell vom KO-Rechner "helsinki" kopieren

$ ./bin/incus/yaml-create.sh etc/incus-dp/apache2.yaml
```

Zertifikate kopieren für "certbot" und "apache2"
------------------------------------------------

Quellpfade:

- /etc/apache2/ssl.letsencrypt
  - (domain).crt
  - private
    - (domain).key

Zielpfade:

- /home/uli/shared-letsencrypt/archive
- /home/uli/shared-letsencrypt/live/(domain)
  - privkey.pem (600)
  - fullchain.pem (644)
  - cert.pem (644) (unnötig)

Also:

- (domain).crt herunterladen von helsinki und wandeln nach fullchain.pem
  - OK: `cp login.daemons-point.com.crt fullchain.pem`
  - KO: `openssl x509 -in login.daemons-point.com.crt -out fullchain.pem`
- (domain).key herunterladen von helsinki und wandeln nach privkey.pem
  - `openssl rsa -in login.daemons-point.com.key -out privkey.pem`
- fullchain.pem ablegen auf hetzner-de-ryzen
- privkey.pem ablegen auf hetzner-de-ryzen
- Kopien von (domain).key und privkey.pem löschen
- Nachkontrolle: Stimmen die Zugriffsrechte von privkey.pem auf hetzner-de-ryzen?

DNS vorbereiten
---------------

1. Anmelden bei [https://hetzner.com](https://hetzner.com)
2. Console
3. DNS
4. daemons-point.com
5. Aktionen - Allgemeine Einstellungen
6. Standard-TTL: 86400 -> 300 - Speichern

Umzug "pocket-id"
-----------------

Ich orientiere mich am Vorgehen aus [Ticket 13315](https://zammad.daemons-point.com/#ticket/zoom/13315).
Das Grundgerüst des Vorgehens stammt von Gemini.

### Sichten bestehender Storage-Pool

- Pfad für alle Container: /lxd/containers
- Pfad für "pocket-id": /lxd/containers/pocket-id

### BTRFS-Snapshot auf dem KO-Hetznerrechner erzeugen

Üblicherweise würde man einen Snapshot des Containers erzeugen mit `lxc snapshot ...`.
Da `lxc` aber nicht mehr funktioniert, scheidet dieses Vorgehen aus.
Sichern/Übertragen ohne Snapshot ist nicht ratsam, weil dann potentiell inkonsistente
und funktionsunfähige Datenbanken gesichert/übertragen werden.

```
# btrfs filesystem show /lxd
Label: 'default'  uuid: e48d1d90-0faa-4091-9841-562129db69d1
	Total devices 1 FS bytes used 261.02GiB
	devid    1 size 350.00GiB used 350.00GiB path /dev/mapper/vg0-lxd

# btrfs subvolume show /lxd
/
	Name: 			<FS_TREE>
	UUID: 			-
	Parent UUID: 		-
	Received UUID: 		-
	Creation time: 		-
	Subvolume ID: 		5
	Generation: 		33836141
	Gen at creation: 	0
	Parent ID: 		0
	Top level ID: 		0
	Flags: 			-
	Snapshot(s):
				containers
				containers-snapshots
				images
				images/9afd22581ab1ba80514d4e2cca61c4c365db76b880c0e10eb7d8ea5adf99efd3
				custom
				custom-snapshots

# btrfs subvolume show /lxd/containers/pocket-id/
containers/pocket-id
	Name: 			pocket-id
	UUID: 			c08e30cb-966d-e947-ac7e-88c13a04a444
	Parent UUID: 		87075f5e-3965-9844-8a41-e90221750620
	Received UUID: 		-
	Creation time: 		2026-09-07 16:29:42 +0200
	Subvolume ID: 		23271
	Generation: 		33837977
	Gen at creation: 	33825095
	Parent ID: 		257
	Top level ID: 		257
	Flags: 			-
	Snapshot(s):
```

Wie erwartet ist "pocket-id" ein separates Subvolume. Es verfügt über keine Snapshots.

Snapshot anlegen:

```
# mkdir -p /lxd/containers-snapshots/pocket-id
# btrfs subvolume snapshot -r /lxd/containers/pocket-id /lxd/containers-snapshots/pocket-id/trx_hetzner-de-ryzen_$(date +%Y%m%d-%H%M%S)
Create a readonly snapshot of '/lxd/containers/pocket-id' in '/lxd/containers-snapshots/pocket-id/trx_hetzner-de-ryzen_20260909-134127'
```

### Container-Vorbereitung und -Einspielung auf dem OK-Hetznerrechner

- Anmelden auf dem OK-Hetznerrechner mit `ssh -A ...`
- Leer-Container anlegen:
  ```
  # incus copy ubuntu-2604 pocket-id
  
  # incus ls pocket-id
  +-----------+---------+------+------+-----------+-----------+
  |   NAME    |  STATE  | IPV4 | IPV6 |   TYPE    | SNAPSHOTS |
  +-----------+---------+------+------+-----------+-----------+
  | pocket-id | STOPPED |      |      | CONTAINER | 0         |
  +-----------+---------+------+------+-----------+-----------+
  
  # rm -rf /incus/containers/pocket-id/rootfs/*
  ```
- Daten übernehmen vom KO-Hetznerrechner:
  ```
  # ssh 95.216.23.95 -- oder -- date +%Y%m%d-%H%M%S; ssh 95.216.23.95 date +%Y%m%d-%H%M%S
    # ... einmaliger Test ob's klappt - dauert grob 2min 30s
  ...

  # time ssh 95.216.23.95 "tar --numeric-owner -czpf - -C /lxd/containers-snapshots/pocket-id/trx_hetzner-de-ryzen_*/rootfs/ ."\
  |tar --numeric-owner -xzpvf - -C /incus/containers/pocket-id/rootfs/
    # ... dauert eine ganze Weile, bis es "los" geht (klar, helsinki-Problem bei SSH-Anmeldung!)
  ./
  ./var/
  ./var/lib/
  ./var/lib/apt/
  ./var/lib/apt/lists/
  ./var/lib/apt/lists/partial/
  ./var/lib/apt/lists/auxfiles/
  ./var/lib/apt/lists/lock
  ./var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_resolute_InRelease
  ./var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_resolute_main_binary-amd64_Packages
  ./var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_resolute_main_i18n_Translation-en
  ...
  
  real	2m53.051s
  user	0m8.145s
  sys	0m5.190s
  ```
- Test
  ```
  # /home/uli/bin/incus/incus-nat.sh pocket-id
  # incus start pocket-id
  ```

### Zugriffstest ohne umgestelltes DNS

Auf meinem Arbeitsplatzrechner kann ich die neue Pocket-ID-Instanz
testen mit:

- OPENSSL: `openssl s_client -connect 49.12.86.41:443 -servername ://login.daemons-point.com -showcerts </dev/null`
  ... muß die ganze Zertifikatskette anzeigen
- CURL: `curl -v --resolve login.daemons-point.com:443:49.12.86.41 https://login.daemons-point.com`
  ... darf keine Zertifikatsfehler melden
- WGET: `wget  --connect-to login.daemons-point.com:443:49.12.86.41:443 https://login.daemons-point.com`
  ... scheitert bei mit mit "wget: Unbekannte Option '--connect-to'"

### Zusammenfassung

```
# Gemini - Schritt 1
# helsinki
LXD_PATH=/lxd
CONTAINER=pocket_id
mkdir -p "${LXD_PATH}/containers-snapshots/${CONTAINER}"
btrfs subvolume snapshot -r "${LXD_PATH}/containers/${CONTAINER}" "${LXD_PATH}/containers-snapshots/${CONTAINER}/trx_hetzner-de-ryzen_$(date +%Y%m%d-%H%M%S)"

# Gemini - Schritt 2 und 3 kombiniert
# hetzner-de-ryzen
INCUS_PATH=/incus
LXD_PATH=/lxd
CONTAINER=dp-tmate
incus copy ubuntu-2604 "${CONTAINER}"
incus stop -f "${CONTAINER}" 2>/dev/null
rm -rf "${INCUS_PATH}/containers/${CONTAINER}/rootfs/"*
time ssh  95.216.23.95 "tar --numeric-owner -czpf - -C \"${LXD_PATH}/containers-snapshots/${CONTAINER}/trx_hetzner-de-ryzen_\"*/rootfs/ ."\
  |tar --numeric-owner -xzpvf - -C "${INCUS_PATH}/containers/${CONTAINER}/rootfs/"

# "manchmal" müssen die UIDs/GIDs angepasst werden - nicht für pocket-id
OLD_UID="$(stat --format="%u" "${INCUS_PATH}/containers/${CONTAINER}/rootfs")"
OLD_GID="$(stat --format="%g" "${INCUS_PATH}/containers/${CONTAINER}/rootfs")"
test "${OLD_UID} ${OLD_GID}" != "0 0" && {
  /home/uli/bin/incus/incus-fuidshift -r -u "0:${OLD_UID}" -g "0:${OLD_GID}" "${INCUS_PATH}/containers/${CONTAINER}"
}

/home/uli/bin/incus/incus-nat.sh "${CONTAINER}"
incus start "${CONTAINER}"
```

### DNS umlenken für "login.daemons-point.com"

1. Anmelden bei [https://hetzner.com](https://hetzner.com)
2. Console
3. DNS
4. daemons-point.com
5. Aktionen - Zonefile bearbeiten
   - Bislang: `login	IN	CNAME	ilmarinen.daemons-point.com.`
   - Geändert: `login	IN	CNAME	hetzner-de-ryzen.daemons-point.com.`
6. Test: Ist die neue Änderung aktiv?
   ```
   sudo -s
     resolvectl flush-caches
     resolvectl statistics
       # Bei "Current Cache Size" muß 0 stehen
     resolvectl --cache=no query login.daemons-point.com
       # Es darf NIX mit "ilmarinen" erscheinen, hetzner-de-ryzen muß sichtbar sein
   ```

### Problem: Nach der DNS-Umstellung klappt die Anmeldung an Zammad nicht mehr

Fehlermeldung: Message from openid_connect: Failed to open TCP connection to login.daemons-point.com:443 (execution expired)

Offenbar benötigt Zammad eine TCP-Verbindung zum Login.
Sieht so aus, als hätte ich irgendwas an OIDC noch nicht 100%g verstanden!

Verbindungstest:

- helsinki:
  - `ping login.daemons-point.com` -> klappt, 49.12.86.41 wird verwendet
  - `nc -vz -w 5 login.daemons-point.com 443` -> klappt
- dp-zammad-2004:
  - `ping login.daemons-point.com` -> klappt nicht, 49.12.86.41 wird verwendet
  - `nc -vz -w 5 login.daemons-point.com 443` -> klappt nicht

Ich muß eine ausgehende Verbindung von dp-zammad-2004 zu login.daemons-point.com
"erlauben". Da SSH und SystemD nicht richtig funktionieren, muß ich das
irgendwie manuell in IPTABLES einpflegen!

Kurze Sichtung:

- iptables
- Typ: -t nat
- Chain: LXD_NAT_POSTROUTING
- Source: 10.2.110.12 - dp-zammad-2004
- Destination: login.daemons-point.com, port 443
- Kommando: `iptables -t nat -A LXD_NAT_POSTROUTING -j MASQUERADE -s 10.2.110.12 -p tcp --destination login.daemons-point.com --dport 443`

Nochmaliger Verbindungstest:

- dp-zammad-2004:
  - `ping login.daemons-point.com` -> klappt nicht, 49.12.86.41 wird verwendet
  - `nc -vz -w 5 login.daemons-point.com 443` -> klappt

### Fehlende Schritte

Damit "pocket-id" funktioniert, müssen noch ein paar weitere Anpassungen
vorgenommen werden:

1. ERLEDIGT - Vorgeschalteter ReverseProxy - siehe "apache2" oben
   - Ich verwende in meinem Heim-Netzwerk "caddy"
   - Für DP sollten wir vermutlich bei "apache2" bleiben
2. IN ARBEIT - DNS umlegen von helsinki -> hetzner-de-ryzen - siehe DNS oben
3. OFFEN - CERTBOT aktivieren

dp-tmate
--------

Ich gehe vor gemäß "Zusammenfassung" von "pocket-id".
Mit etwas Glück klappt es!

Hier die korrigierte und angepasste Zusammenfassung:

```
# Gemini - Schritt 1
# helsinki
LXD_PATH=/lxd
CONTAINER=dp-tmate
mkdir -p "${LXD_PATH}/containers-snapshots/${CONTAINER}"
btrfs subvolume snapshot -r "${LXD_PATH}/containers/${CONTAINER}" "${LXD_PATH}/containers-snapshots/${CONTAINER}/trx_hetzner-de-ryzen_$(date +%Y%m%d-%H%M%S)"

# Gemini - Schritt 2 und 3 kombiniert
# hetzner-de-ryzen
INCUS_PATH=/incus
LXD_PATH=/lxd
CONTAINER=dp-tmate
incus copy ubuntu-2604 "${CONTAINER}"
incus stop -f "${CONTAINER}" 2>/dev/null
rm -rf "${INCUS_PATH}/containers/${CONTAINER}/rootfs/"*
time ssh  95.216.23.95 "tar --numeric-owner -czpf - -C \"${LXD_PATH}/containers-snapshots/${CONTAINER}/trx_hetzner-de-ryzen_\"*/rootfs/ ."\
  |tar --numeric-owner -xzpvf - -C "${INCUS_PATH}/containers/${CONTAINER}/rootfs/"

# "manchmal" müssen die UIDs/GIDs angepasst werden
OLD_UID="$(stat --format="%u" "${INCUS_PATH}/containers/${CONTAINER}/rootfs")"
OLD_GID="$(stat --format="%g" "${INCUS_PATH}/containers/${CONTAINER}/rootfs")"
test "${OLD_UID} ${OLD_GID}" != "0 0" && {
  /home/uli/bin/incus/incus-fuidshift -r -u "0:${OLD_UID}" -g "0:${OLD_GID}" "${INCUS_PATH}/containers/${CONTAINER}"
}

/home/uli/bin/incus/incus-nat.sh "${CONTAINER}"
/home/uli/bin/incus/incus-hostonly.sh "${CONTAINER}"
incus start "${CONTAINER}"
```

Test: Sieht's innerhalb vom Container OK aus?

```
incus exec dp-tmate bash
  # OK, keine Fehlermeldung!
  ss -t4l
    # OK, Port 10022 ist bereit
```

Offen: Port-Weiterleitung vom Host zum Container

```
incus config device add ${CONTAINER} tmate-forward-10022 proxy listen=tcp:0.0.0.0:10022 connect=tcp:127.0.0.1:10022
```

Test: Klappt's vom Arbeitsplatzrechner aus?

- .tmate-dp.conf anpassen
  - ilmarinen -> hetzner-de-ryzen
- `tmate.sh` -> funktioniert wie üblich, hetzner-de-ryzen wird angezeigt

Notwendige Nacharbeiten
-----------------------

- Wir müssen sicherstellen, dass alle Hetzner-Rechner
  bei Plattenstörungen irgendwie Alarm schlagen!
- Einrichten von Sicherungen der Container
  - apt-cacher-ng: Wird aktiv genutzt, muß aus meiner Sicht nicht (zwingend) gesichert werden!
  - apache2: Wird aktiv genutzt, sollte gesichert werden, enthält keine veränderlichen Daten!
  - certbot: Wird aktiv genutzt, sollte gesichert werden, enthält keine veränderlichen Daten!
  - pocket-id: Wird aktiv genutzt, sollte gesichert werden!
  - dp-tmate: Wird aktiv genutzt, sollte gesichert werden, enthält keine veränderlichen Daten!
- Sichern der Daten außerhalb der Container
  - hetzner-de-ryzen:/home/uli/shared-letsencrypt ... enthält die Zertifikate; sollte gesichert werden; Platzbedarf: SEHR gering

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

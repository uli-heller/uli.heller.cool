+++
date = '2026-03-14'
draft = false
title = 'Linux: Datenträger mit FIDO2-Stick verschlüsseln'
categories = [ 'FIDO2' ]
tags = [ 'linux', 'ubuntu' ]
+++

<!--
Linux: Datenträger mit FIDO2-Stick verschlüsseln
============================
-->

Neuere Versionen von SystemD erlauben es, einen FIDO2-Schlüssel
für die Festplattenverschlüsselung zu verwenden.
Hier beschreibe ich meine Experimente damit!

<!--more-->

Getestete FIDO2-Schlüssel
-------------------------

Ich habe meine Tests unternommen mit einem SoloKey und einem YubiKey.
Für beide FIDO2-Schlüssel habe ich eine FIDO2-PIN vergeben.

- SoloKey: `fido2-token -S /dev/hidraw3` oder `fido2-token -C /dev/hidraw3`
- YubiKey: `ykman fido access change-pin`

Externen USB-Datenträger zusätzlich mit FIDO2-Schlüssel entsperren
------------------------------------------------------------------

### Zielsetzung

- Ausgangpunkt: Ich habe einen externen USB-Datenträger mit LUKS-Festplattenverschlüsselung
- Ziel: Ich möchte ihn auch mit einem FIDO2-Schlüssel und PIN entschlüsseln können

### Einrichtung

- USB-Datenträger anschliessen
- Daten des USB-Datenträgers abfragen: `lsblk` -> /dev/sdc, LUKS=/dev/sdc1
- Sicherstellen: Nur richtiger FIDO2-Stick ist eingesteckt - SoloKey
- SoloKey für Plattenverschlüsselung eintragen: `sudo systemd-cryptenroll --fido2-device=auto /dev/sdc1`
  - Bestehendes LUKS-Kennwort: xxxxx
  - PIN vom SoloKey: yyyyy
  - SoloKey drücken
  - SoloKey nochmals drücken
- Sicherstellen: Nur richtiger FIDO2-Stick ist eingesteckt - YubiKey
  - Bestehendes LUKS-Kennwort: xxxxx
  - FIDO2-PIN vom YubiKey: yyyyy
  - YubiKey drücken
  - YubiKey nochmals drücken

### Test Kommandozeile

#### SoloKey

Da ich den SoloKey zuerst eingerichtet habe, ist er das Token 0.

- LUKS öffnen - Entschlüsseln mit SoloKey: `sudo cryptsetup open --token-id 0 /dev/sdc1 usb-crypt`
  - PIN vom SoloKey wird abgefragt
  - Danach: SoloKey drücken
- Einbinden: `sudo mount /dev/mapper/usb-crypt /mnt` -> klappt
- Ausbinden: `sudo umount /mnt`
- LUKS schliessen: `sudo cryptsetup close usb-crypt`

#### YubiKey

Da ich den YubiKey nach dem SoloKey eingerichtet habe, ist er das Token 1.

- LUKS öffnen - Entschlüsseln mit YubiKey: `sudo cryptsetup open --token-id 1 /dev/sdc1 usb-crypt`
  - PIN vom YubiKey wird abgefragt
  - Danach: YubiKey drücken
- Einbinden: `sudo mount /dev/mapper/usb-crypt /mnt` -> klappt
- Ausbinden: `sudo umount /mnt`
- LUKS schliessen: `sudo cryptsetup close usb-crypt`

#### Kennwort

- LUKS öffnen - Entschlüsseln ohne FIDO2-Schlüssel: `sudo cryptsetup open /dev/sdc1 usb-crypt`
  - Kennwort wird abgefragt
  - Danach: Typischerweise längere Wartezeit
- Einbinden: `sudo mount /dev/mapper/usb-crypt /mnt` -> klappt
- Ausbinden: `sudo umount /mnt`
- LUKS schliessen: `sudo cryptsetup close usb-crypt`

Hinweis: "Manchmal" habe ich beobachtet, dass beim "LUKS öffnen" der zuletzt angelegte FIDO2-Schlüssel
verwendet wird. Eine Systematik habe ich hierbei nicht festgestellt!

### Test Desktop

- USB-Datenträger anschliessen
- Entsperren nur mittels Kennwort möglich - schade!

Offene Punkte
-------------

- Verwendung für die Boot-Platte - Entsperren beim Systemstart muß klappen!
- Entsperren via GNOME-Desktop geht aktuell nur via Kennwort

Tests
-----

Nachfolgende Tests habe ich mit Ubuntu-24.04 durchgeführt.
Ich verwende für die Tests einen USB-Datenträger. Dieser wird bei den
Tests gelöscht und überschrieben, eventuell vorher vorhandene
Daten gehen verloren!

- Ist SystemD neu genug? `dpkg -l systemd`
  - Bei mir: 255.4-1ubuntu8.12
  - Ab 248 ist's neu genug
- USB-Datenträger anschliessen
- Daten des USB-Datenträgers abfragen: `lsblk` -> /dev/sdc
- USB-Datenträger partitionieren: `sudo gdisk /dev/sdc`
  - n 1 20 default=2048 +20G 8309 p
    ```
    Number  Start (sector)    End (sector)  Size       Code  Name
       1            2048        41945087   20.0 GiB    8309  Linux LUKS
    ```
  - w Y
- LUKS initialisieren: `sudo cryptsetup --cipher aes-xts-plain64 --key-size 256 --hash sha256 --iter-time=10000 luksFormat /dev/sdc1`
  - YES
  - test
  - test
- LUKS-Metadaten sichern: `sudo cryptsetup luksDump --dump-json-metadata /dev/sdc1|tee luksdump-1.json` - [luksdump-1.json](luksdump-1.json)
- Sicherstellen: Nur richtiger FIDO2-Stick ist eingesteckt - SoloKey
- LUKS - FIDO2-Schlüssel hinzufügen: `sudo systemd-cryptenroll --fido2-device=auto /dev/sdc1`
  - test
  - PIN vom FIDO2-Schlüssel
  - FIDO2-Schlüssel 2x drücken
- LUKS-Metadaten nochmals sichern: `sudo cryptsetup luksDump --dump-json-metadata /dev/sdc1|tee luksdump-2.json` - [luksdump-2.json](luksdump-2.json)
- SoloKey trennen, YubiKey einstecken
- LUKS - zweiten FIDO2-Schlüssel hinzufügen: `sudo systemd-cryptenroll --fido2-device=auto /dev/sdc1`
  - test
  - FIDO2-Schlüssel 2x drücken, PIN wird nicht benötigt
- LUKS-Metadaten nochmals sichern: `sudo cryptsetup luksDump --dump-json-metadata /dev/sdc1|tee luksdump-3.json` - [luksdump-3.json](luksdump-3.json)
- Zugriff testen mit YubiKey: `sudo cryptsetup open /dev/sdc1 xxxxx`
  - YubiKey 1x drücken -> klappt
  - `sudo cryptsetup close xxxxx`
- Zugriff testen ohne YubiKey: `sudo cryptsetup open /dev/sdc1 xxxxx`
  - YubiKey abziehen
  - test -> klappt
  - `sudo cryptsetup close xxxxx`
- YubiKey trennen, SoloKey einstecken
- Zugriff testen mit SoloKey: `sudo cryptsetup open --token-id 0 /dev/sdc1 xxxxx`
  - SoloKey PIN: yyyyy
  - SoloKey drücken -> klappt

Notizen
-------

### Anzahl RKs auf Solokey

```
$ date
Do 19. Mär 09:10:27 CET 2026

$ fido2-token -I -c /dev/hidraw3
Enter PIN for /dev/hidraw3: 
existing rk(s): 10
remaining rk(s): 40
```

### Löschen vom YubiKey

```
$ sudo cryptsetup luksDump /dev/sdc1
...
# Slot[2] und Token[1] müssen weg

$ sudo cryptsetup -v luksKillSlot /dev/sdc1 2
Schlüsselfach 2 zum Löschen ausgewählt.
Geben Sie irgendeine verbleibende Passphrase ein: 
Schlüsselfach 0 entsperrt.
Schlüsselfach 2 entfernt.
Befehl erfolgreich.

$ sudo cryptsetup token remove --token-id 1 /dev/sdc1

$ sudo cryptsetup luksDump /dev/sdc1
...
# Hat geklappt!

# Klappt es danach mit dem SoloKey?
$ sudo cryptsetup open /dev/sdc1 xxxxx
Geben Sie die Passphrase für »/dev/sdc1« ein:
# NEIN!

# SoloKey auch noch löschen
# SoloKey neu anlegen -> klappt's?
$ sudo cryptsetup open /dev/sdc1 xxxxx
Geben Sie die Passphrase für »/dev/sdc1« ein:
# NEIN!

$ sudo cryptsetup open --token-id 0 /dev/sdc1 xxxxx
Geben Sie die PIN des Tokens 0 ein: 
Asking FIDO2 token for authentication.
👆 Please confirm presence on security token to unlock.

$ sudo cryptsetup close xxxxx
```

Versionen
---------

- Getestet unter Ubuntu-2404

Links
-----

- [Github - bertogg - fido2luks](https://github.com/bertogg/fido2luks)
  - keyscript.sh
- [PidEins - Unlocking LUKS2 volumes with TPM2, FIDO2, PKCS#11 Security Hardware on systemd 248](https://0pointer.net/blog/unlocking-luks2-volumes-with-tpm2-fido2-pkcs11-security-hardware-on-systemd-248.html)
- cryptsetup-token
- fido2-token -I -c /dev/hidraw3


Historie
--------

- 2026-03-14: Erste Version

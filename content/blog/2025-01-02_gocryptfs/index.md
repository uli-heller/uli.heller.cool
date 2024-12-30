+++
date = '2025-01-02'
draft = false
title = 'Verschlüsseltes Dateisystem mit GOCRYPTFS'
categories = [ 'Verschlüsselung' ]
tags = [ 'crypto', 'linux', 'ubuntu' ]
+++

<!--Verschlüsseltes Dateisystem mit GOCRYPTFS-->
<!--=========================================-->

Grundsätzlich verwende ich Festplatten mit Vollverschlüsselung.
Das bedeutet, dass alle meine Dateien nur in verschlüsselter
Form physikalisch auf der Platte abliegen. Wenn ich die Platte
entschlüsselt habe, dann sind sie im Klartext zugreifbar.

Einige Dateien sind für mich persönlich besonders sensitiv und
ich brauche die nicht permanent. Diese möchte ich separat verschlüsseln
und nur in Ausnahmefällen entschlüsseln.

Hier beschreibe ich, wie das mit GOCRYPTFS geht.

<!--more-->

GOCRYPTFS installieren
----------------------

```
$ sudo apt install gocryptfs
[sudo] Passwort für uli: 
Paketlisten werden gelesen… Fertig
Abhängigkeitsbaum wird aufgebaut… Fertig
Statusinformationen werden eingelesen… Fertig
Die folgenden Pakete wurden automatisch installiert und werden nicht mehr benötigt:
  containerd libclamav9 libtfm1 pigz runc ubuntu-fan
Verwenden Sie »sudo apt autoremove«, um sie zu entfernen.
Die folgenden NEUEN Pakete werden installiert:
  gocryptfs
0 aktualisiert, 1 neu installiert, 0 zu entfernen und 0 nicht aktualisiert.
Es müssen 1.970 kB an Archiven heruntergeladen werden.
Nach dieser Operation werden 8.973 kB Plattenplatz zusätzlich benutzt.
Holen:1 http://archive.ubuntu.com/ubuntu jammy-updates/universe amd64 gocryptfs amd64 1.8.0-1ubuntu0.1 [1.970 kB]
...
$ gocryptfs --version
gocryptfs 1.8.0; go-fuse 2.0.3; 2024-11-18 go1.18.1 linux/amd64
```

Kurztest
--------

```
$ cd /tmp
$ mkdir encrypted
$ mkdir decrypted
$ gocryptfs --init encrypted
Choose a password for protecting your files.
Password: 
Repeat: 

Your master key is:

    bce87b84-c2b6152c-7a74cbb3-8c7e8d37-
    804741c2-46cd797a-9b5571ff-7565757c

If the gocryptfs.conf file becomes corrupted or you ever forget your password,
there is only one hope for recovery: The master key. Print it to a piece of
paper and store it in a drawer. This message is only printed once.
The gocryptfs filesystem has been created successfully.
You can now mount it using: gocryptfs encrypted MOUNTPOINT

$ gocryptfs encrypted decrypted
Password: 
Decrypting master key
Filesystem mounted and ready.

$ ls decrypted
$ ls encrypted/
gocryptfs.conf  gocryptfs.diriv

$ for i in $(seq 1 10); do date >decrypted/${i}.date.txt; done

$ ls decrypted/
10.date.txt  1.date.txt  2.date.txt  3.date.txt  4.date.txt  5.date.txt  6.date.txt  7.date.txt  8.date.txt  9.date.txt
$ ls encrypted/
1x7SD2INc6DkDO0T6lnqyw  HAXcjyWFCF5ULwojWGWaIw  w91ojRUPJgxvG1AwwmaGZA  Z_2TpW9A_sg2fOR3CBJVxQ
gocryptfs.conf          HNAN6gmsrZSPV5tIESVTzw  wn1idkX-BCpC2ia4tRVZCw  z6PGa542pDTwe_BeZJmCvA
gocryptfs.diriv         rx5PwbMrl7RYnXyA3UBIWw  x3saIKGb-DxtpWVbdYOo7Q  ZCsV-dxiA_qowF7h4-H6rw

$ fusermount -u decrypted

$ ls decrypted/
$ ls encrypted/
1x7SD2INc6DkDO0T6lnqyw  HAXcjyWFCF5ULwojWGWaIw  w91ojRUPJgxvG1AwwmaGZA  Z_2TpW9A_sg2fOR3CBJVxQ
gocryptfs.conf          HNAN6gmsrZSPV5tIESVTzw  wn1idkX-BCpC2ia4tRVZCw  z6PGa542pDTwe_BeZJmCvA
gocryptfs.diriv         rx5PwbMrl7RYnXyA3UBIWw  x3saIKGb-DxtpWVbdYOo7Q  ZCsV-dxiA_qowF7h4-H6rw
```

Handhabungshinweise
-------------------

- Grundinitialisierung: `mkdir encrypted; gocryptfs --init encrypted`
  (muß nur einmalig gemacht werden!)
- Einbinden: `mkdir decrypted; gocryptfs encrypted decrypted`
- Dateizugriffe: Über "decrypted"!
- Ausbinden: `fusermount -u decrypted`

Wiederherstellung mit dem MasterKey
-----------------------------------

- Annahme: Ich habe entweder mein "Password"
  vergessen oder die Datei "encrypted/gocryptfs.conf"
  ist kaputt
- Dummy-Version der "gocryptfs.conf" erzeugen:
  `mkdir encrypted-2; gocryptfs --init encrypted-2/`
  (Password hierbei ist egal)
- Dummy-Version kopieren:
  `cp encrypted-2/gocryptfs.conf encrypted/gocryptfs.conf`
- Dummy-Verzeichnis löschen:
  `rm -rf encrypted-2`
- Master-Key eintragen:
  ```
  $ gocryptfs -passwd -masterkey bce87b84-c2b6152c-7a74cbb3-8c7e8d37-804741c2-46cd797a-9b5571ff-7565757c encrypted
  Using explicit master key.
  THE MASTER KEY IS VISIBLE VIA "ps ax" AND MAY BE STORED IN YOUR SHELL HISTORY!
  ONLY USE THIS MODE FOR EMERGENCIES
  Please enter your new password.
  Password: 
  Repeat: 
  A copy of the old config file has been created at "/tmp/encrypted/gocryptfs.conf.bak".
  Delete it after you have verified that you can access your files with the new password.
  Password changed.
  ```
- Danach klappt der Zugriff mit dem zuletzt vergebenen "Password"

Links
-----

- [Homepage: gocryptfs](https://nuetzlich.net/gocryptfs/)
- [GITHUB: gocryptfs](https://github.com/rfjakob/gocryptfs)
- [Recreate gocryptfs.conf using masterkey](https://github.com/rfjakob/gocryptfs/wiki/Recreate-gocryptfs.conf-using-masterkey)

Versionen
---------

Getestet mit

- Ubuntu-22.04 und gocryptfs-1.8.0-1ubuntu0.1
- Ubuntu-20.04 unt gocryptfs-1.7.1-1ubuntu0.1

Historie
--------

- 2025-01-02: Erste Version

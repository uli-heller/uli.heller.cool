+++
date = '2025-01-11'
draft = false
title = 'Verschlüsseltes Dateisystem mit GOCRYPTFS - QRCode für den MasterKey'
categories = [ 'Verschlüsselung' ]
tags = [ 'crypto', 'linux', 'ubuntu' ]
+++

<!--Verschlüsseltes Dateisystem mit GOCRYPTFS - QRCode für den Masterkey-->
<!--====================================================================-->

Bei der Neuanlage eines GOCRYPTFS
wird traditionell der Masterkey
angezeigt. Diesen soll man sich
zur Sicherheit merken, damit man im Fall
der Fälle immer noch auf die gespeicherten
Daten zugreifen kann.

<!--more-->

Man muß ihn unter Verschluß halten,
denn wer immer den Masterkey kennt, der
kann auch auf die Daten zugreifen.

Die Empfehlung ist, den Masterkey auszudrucken
und abzuheften.

Problem
-------

Wenn man den Masterkey mal braucht, muß
man ihn abtippen.

Lösung
------

Ausdruck mit QR-Code, dann kann man den Masterkey
einscannen.

Anwendung
---------

Voraussetzung: gocryptfs-2.4.0.54 oder neuer

```
$ ./gocryptfs --version
gocryptfs v2.4.0.54.qrcode; go-fuse v2.5.0; 2025-01-03 go1.23.2 linux/amd64

$ mkdir encrypted

$ ./gocryptfs --init --qrcode encrypted
Choose a password for protecting your files.
Password: 1
Repeat: 1

Your master key is:

    f5445574-1f3068e3-0f9f47f0-998f25da-
    8d0588e1-e61a28a1-10a81763-6bd583b8

QRCode:
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
█ ▄▄▄▄▄ ██▄▀▀ █▀  ▀█   █  █ ▄▄▄▄▄ █
█ █   █ █▄  ▀▄██▀ ██▀██████ █   █ █
█ █▄▄▄█ ██▀▄███▀ ▄   █ █ ▄█ █▄▄▄█ █
█▄▄▄▄▄▄▄█ ▀ █ ▀▄▀▄▀ ▀▄▀ ▀▄█▄▄▄▄▄▄▄█
█ ▄▄▀ ▄▄ ▄█  █  ▄█ █▄█▄ ██  ███▄█▀█
█ █ ▄▀ ▄▀▀▄█▀█  ▀█▀▀▀▄▀▄█ ▄▄▀  ▄▀▄█
████▀█ ▄▀ ██▀ ▄▄█   ▄█ ██ █  █▄█▄ █
█ ▄▄▀▀█▄▄▀ ▀▄ ▀▀▀▄ █▀▀ ██▀█ ██ ▄▀▄█
█ ▀▄▄██▄▄█▀▀ ▄  ██  ██  ██▀  █▄█▄ █
██▀▄█▀█▄ ▄  ▀▄ █▀█▀ ▀▄ ▄▀ ▄█▀▄ ██▄█
█▄    ▄▄▀▄▄ ▄█ ███ ███  ███  █▄█▄ █
█▄▀ ▄█▄▄▄▄█▄█▄ ▄▀▀▀ ▀ ▀▀█ ▀▄ █▀▄▀ █
█▄█████▄█▀▀ █  █▄▄  █  █▀ ▄▄▄ █▀  █
█ ▄▄▄▄▄ █  ▀██▀█▀█ ▄▀▄▀█▄ █▄█  ▄▄ █
█ █   █ █▄  ██  ██▄ ▄█ ██▄▄▄▄  █ ▄█
█ █▄▄▄█ █ █▄▀▄▀▀▀█▀▄▀▀▀ █▀██▀ ▄▄ ▄█
█▄▄▄▄▄▄▄█▄▄█▄█▄▄█▄▄█▄▄▄▄█▄██▄▄██▄▄█


If the gocryptfs.conf file becomes corrupted or you ever forget your password,
there is only one hope for recovery: The master key. Print it to a piece of
paper and store it in a drawer. This message is only printed once.
The gocryptfs filesystem has been created successfully.
You can now mount it using: gocryptfs encrypted MOUNTPOINT
```

Die Ausgaben oben sehen etwas verstrubbelt aus,
weil der Zeilenabstand zub groß ist.
Untenstehende Links liefern eine bessere Ansicht:

- Ausgabe mit "--qrcode": [master-key-qrcode.txt](secret/master-key-qrcode.txt)
- Ausgabe ohne "--qrcode": [master-key.txt](secret/master-key.txt)

Links
-----

- [Homepage: gocryptfs](https://nuetzlich.net/gocryptfs/)
- [GITHUB: gocryptfs](https://github.com/rfjakob/gocryptfs)
- [GITHUB: Mein Fork mit QRCode](https://github.com/uli-heller/gocryptfs/tree/qrcode)

Versionen
---------

Getestet mit

- Ubuntu-22.04 und gocryptfs-2.4.0.53
- Ubuntu-20.04 und gocryptfs-2.4.0.53

Historie
--------

- 2025-01-11: Erste Version

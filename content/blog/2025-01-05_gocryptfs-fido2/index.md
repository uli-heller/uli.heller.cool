+++
date = '2025-01-05'
draft = false
title = 'Verschlüsseltes Dateisystem mit GOCRYPTFS - Fido2'
categories = [ 'Verschlüsselung' ]
tags = [ 'crypto', 'linux', 'ubuntu' ]
+++

<!--Verschlüsseltes Dateisystem mit GOCRYPTFS - Fido2-->
<!--=================================================-->

GOCRYPTFS kann auch in Verbindung mit einem
Fido2-Gerät verwendet werden, also bspw.
mit einem Nitrokey.

<!--more-->

Sichtung des Fido2-Gerätes
--------------------------

```
$ fido2-token -L 
/dev/hidraw2: vendor=0x20a0, product=0x42f3 (Nitrokey Nitrokey Passkey)
```

Ich habe einen Nitrokey und das Gerät heißt "/dev/hidraw2".

Sichtung GOCRYPTFS
------------------

```
$ gocryptfs --version
gocryptfs 2.4.0; go-fuse 2.4.2; 2024-11-01 go1.18.1 linux/amd64
```

Wir brauchen eine 2-er-Version von GOCRYPTFS. Die Version 1.8.0 ist
beispielsweise ungeeignet!

Initialisierung
---------------

```
$ mkdir encrypted

$ gocryptfs -init -fido2 /dev/hidraw2 encrypted
FIDO2 Register: interact with your device ...
  # Nitrokey leuchtet blau -> berühren
FIDO2 Secret: interact with your device ...
  # Nitrokey leuchtet nochmal blau -> berühren

Your master key is:

    b948c5e5-c3dea3d3-88660ef8-d0b57bfa-
    390c65cb-98e43da7-81a7ad09-0fba41a0

If the gocryptfs.conf file becomes corrupted or you ever forget your password,
there is only one hope for recovery: The master key. Print it to a piece of
paper and store it in a drawer. This message is only printed once.
The gocryptfs filesystem has been created successfully.
You can now mount it using: gocryptfs encrypted MOUNTPOINT
```

Einbinden
---------

```
$ mkdir decrypted

$ gocryptfs encrypted decrypted
Masterkey encrypted using FIDO2 token; need to use the --fido2 option.

$ gocryptfs -fido2 /dev/hidraw2 encrypted decrypted
FIDO2 Secret: interact with your device ...
  # Nitrokey leuchtet blau -> berühren
Decrypting master key
Filesystem mounted and ready.
```

Ausbinden
---------

```
$ fusermount -u decrypted
```

Optionen
--------

Beim Initialisieren mit einem Fido2-Gerät gibt es diese Optionen:

- PIN-Verifikation: pin=true oder pin=false
- Nutzer-Verifikation: uv=true oder uv=false
- Nutzer-Präsenz: up=true oder up=false

Initiaisierung ohne Zusatz:

```
$ gocryptfs --init --fido2 /dev/hidraw2 \
  --fido2-assert-option pin=false \
  --fido2-assert-option uv=false \
  --fido2-assert-option up=false \
  encrypted
Invalid command line: "gocryptfs" "--init" "--fido2" "/dev/hidraw2" "--fido2-assert-option" "pin=false" "--fido2-assert-option" "uv=false" "--fido2-assert-option" "up=false" "encrypted": unknown flag: --fido2-assert-option. Try 'gocryptfs -help'.
```

Leider sind bei gibt es bei 2.4.0 die Aufrufoption "--fido2-assert-option" nicht!

Sichtung des Github-Repos:

- 2.4.0 wurde angelegt im Juni 2023
- "fido2-assert-option" gibt es seit grob 9 Monaten, also seit April 2024
  [Github-Commit](https://github.com/rfjakob/gocryptfs/commit/4b6b9553c4a2e14fd809754f6bf187957ff3cdfd)

Links
-----

- [Homepage: gocryptfs](https://nuetzlich.net/gocryptfs/)
- [GITHUB: gocryptfs](https://github.com/rfjakob/gocryptfs)

Versionen
---------

Getestet mit

- Ubuntu-22.04 und gocryptfs-2.4.0

Historie
--------

- 2025-01-05: Erste Version

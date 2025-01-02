+++
date = '2025-01-08'
draft = false
title = 'Verschlüsseltes Dateisystem mit GOCRYPTFS - Fido2 und kompliziertes Kennwort'
categories = [ 'Verschlüsselung' ]
tags = [ 'crypto', 'linux', 'ubuntu' ]
+++

<!--Verschlüsseltes Dateisystem mit GOCRYPTFS - Fido2 und kompliziertes Kennwort-->
<!--============================================================================-->

Im Artikel [Verschlüsseltes Dateisystem mit GOCRYPTFS - Fido2]({{< ref  "/blog/2025-01-05_gocryptfs-fido2" >}})
habe ich beschrieben, wie ich
GOCRYPTFS mit einem
Fido2-Gerät verwende. Das funktioniert ganz gut, hat aber ein Problem:
Wenn ich das Fido2-Gerät nicht im Zugriff habe, dann komme ich
an meine Daten nicht dran.

Wenn man den Masterkey kennt, dann kann man zusätzlich zur Fido2-Entschlüsselung
eine Entschlüsselung mit Kennwort hinterlegen. Die nutze ich dann im "Notfall",
wenn mein Fido2-Gerät gerade nicht zur Verfügung steht.

<!--more-->

Initialisierung mit Fido2
-------------------------

Vorgehen analog zum Artikel [Verschlüsseltes Dateisystem mit GOCRYPTFS - Fido2]({{< ref  "/blog/2025-01-05_gocryptfs-fido2" >}}):

```
$ fido2-token -L 
/dev/hidraw2: vendor=0x20a0, product=0x42f3 (Nitrokey Nitrokey Passkey)


```

Sicherheitseinschätzung
-----------------------

Da ich das Dateisystem im Regelfall mit dem Fido2-Gerät entschlüssle,
verwende ich das hinterlegte Kennwort relativ selten. Dementsprechend
kann es ruhig deutlich länger und komplizierter sein, als meine
üblichen Kennworte. Meiner Einschätzung nach ist das ein Sicherheitsgewinn!



- Wenn das Fido2-Gerät kaputt ge


t werden, also bspw.
mit einem Nitrokey auf meinem Laptop und einem
Solokey auf meinem Arbeitsplatzrechner.

<!--more-->

Sichtung des Fido2-Gerätes am Laptop
------------------------------------

```
```

Ich habe einen Nitrokey und das Gerät heißt "/dev/hidraw2".

Initialisierung mit dem Nitrokey
--------------------------------

```
$ mkdir encrypted
$ mkdir secret

$ gocryptfs --init --fido2 /dev/hidraw2 \
  --config encrypted/gocryptfs-nitro.conf encrypted
Using config file at custom location .../encrypted/gocryptfs-nitro.conf
FIDO2 Register: interact with your device ...
  # Nitrokey drücken
FIDO2 Secret: interact with your device ...
  # Nitrokey nochmal drücken
Your master key is:

    dea5f281-7ce0e001-1fb1d042-1f0410c7-
    fab9cc43-2bf4b3e9-7ed759ad-cd86d0f1

If the gocryptfs.conf file becomes corrupted or you ever forget your password,
there is only one hope for recovery: The master key. Print it to a piece of
paper and store it in a drawer. This message is only printed once.
The gocryptfs filesystem has been created successfully.
You can now mount it using: gocryptfs encrypted MOUNTPOINT

$ cat >secret/masker-key.txt <<EOF
Your master key is:

    dea5f281-7ce0e001-1fb1d042-1f0410c7-
    fab9cc43-2bf4b3e9-7ed759ad-cd86d0f1

If the gocryptfs.conf file becomes corrupted or you ever forget your password,
there is only one hope for recovery: The master key. Print it to a piece of
paper and store it in a drawer. This message is only printed once.
The gocryptfs filesystem has been created successfully.
You can now mount it using: gocryptfs encrypted MOUNTPOINT
EOF
```

Dateien ablegen
---------------

```
$ mkdir decrypted
$ gocryptfs --fido2 /dev/hidraw2 \
  --config encrypted/gocryptfs-nitro.conf \
  encrypted decrypted
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi/encrypted/gocryptfs-nitro.conf
FIDO2 Secret: interact with your device ...
  # Nitrokey drücken
Decrypting master key
Filesystem mounted and ready.

$ date >decrypted/secret-date.txt
$ cat decrypted/secret-date.txt
Do 2. Jan 09:03:34 CET 2025

$ fusermount -u decrypted
```

Manuelles Kennwort
------------------

```
$ mkdir encrypted-p
$ gocryptfs --init \
  --config encrypted-p/gocryptfs-password.conf \
  encrypted-p
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi/encrypted-p/gocryptfs-password.conf
Choose a password for protecting your files.
Password: 
Repeat: 

Your master key is:

    6994ce88-b2a8d012-3fb0e043-a5e646db-
    1c132a88-ed71f372-95d8ee49-d5711e5a

If the gocryptfs.conf file becomes corrupted or you ever forget your password,
there is only one hope for recovery: The master key. Print it to a piece of
paper and store it in a drawer. This message is only printed once.
The gocryptfs filesystem has been created successfully.
You can now mount it using: gocryptfs encrypted-p MOUNTPOINT

$ cp encrypted-p/gocryptfs-password.conf encrypted/.
$ rm -rf encrypted-p

$ gocryptfs --passwd --masterkey dea5f281-7ce0e001-1fb1d042-1f0410c7-fab9cc43-2bf4b3e9-7ed759ad-cd86d0f1 \
  --config encrypted/gocryptfs-password.conf \
  encrypted
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi/encrypted/gocryptfs-password.conf
Using explicit master key.
THE MASTER KEY IS VISIBLE VIA "ps ax" AND MAY BE STORED IN YOUR SHELL HISTORY!
ONLY USE THIS MODE FOR EMERGENCIES
Please enter your new password.
Password: 
Repeat: 
A copy of the old config file has been created at "/home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi/encrypted/gocryptfs-password.conf.bak".
Delete it after you have verified that you can access your files with the new password.
Password changed.
```

Als "password" habe ich "1" eingegeben!

Test:

```
$ mkdir decrypted
$ gocryptfs --config  encrypted/gocryptfs-password.conf \
  encrypted decrypted
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi/encrypted/gocryptfs-password.conf
Password: 
Decrypting master key
Filesystem mounted and ready.
$ ls decrypted/
secret-date.txt
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi$ cat decrypted/secret-date.txt 
Do 2. Jan 09:03:34 CET 2025
$ fusermount -u decrypted
$ rmdir decrypted
```

Sichtung des Fido2-Gerätes am Arbeitsplatzrechner
-------------------------------------------------

```
$ fido2-token -L 
/dev/hidraw2: vendor=0x0483, product=0xa2ca (SoloKeys Solo 4.1.5)
```

Ich habe einen Solokey und das Gerät heißt "/dev/hidraw2".

Initialisierung mit dem Solokey
-------------------------------

```
$ mkdir encrypted-s
$ gocryptfs --init --fido2 /dev/hidraw2 \
  --config encrypted-s/gocryptfs-solo.conf \
  encrypted-s
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi/encrypted-s/gocryptfs-solo.conf
FIDO2 Register: interact with your device ...
Enter PIN for /dev/hidraw2:
  # PIN eingeben und Knopf auf Solokey drücken
FIDO2 Secret: interact with your device ...
  # Knopf auf Solokey drücken

Your master key is:

    b82abf6f-ec17405e-c678a518-7ba37a1e-
    af33d379-54217cc5-01d691be-ad1bddd3

If the gocryptfs.conf file becomes corrupted or you ever forget your password,
there is only one hope for recovery: The master key. Print it to a piece of
paper and store it in a drawer. This message is only printed once.
The gocryptfs filesystem has been created successfully.
You can now mount it using: gocryptfs encrypted-s MOUNTPOINT

$ cp encrypted-s/gocryptfs-solo.conf encrypted/.
$ rm -rf encrypted-s

$ gocryptfs --passwd --masterkey dea5f281-7ce0e001-1fb1d042-1f0410c7-fab9cc43-2bf4b3e9-7ed759ad-cd86d0f1 \
  --fido2 /dev/hidraw2 \
  --config encrypted/gocryptfs-solo.conf \
  encrypted
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi/encrypted/gocryptfs-solo.conf
Using explicit master key.
THE MASTER KEY IS VISIBLE VIA "ps ax" AND MAY BE STORED IN YOUR SHELL HISTORY!
ONLY USE THIS MODE FOR EMERGENCIES
Password change is not supported on FIDO2-enabled filesystems.
```

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

Notizen
-------

```
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi$ mkdir encrypted-s
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi$ gocryptfs --init --fido2 /dev/hidraw2 encrypted-s
FIDO2 Register: interact with your device ...
Enter PIN for /dev/hidraw2: 
FIDO2 Secret: interact with your device ...

Your master key is:

    ab16ad29-dc256b5f-6ba55359-586df2d5-
    1fa2c213-3b3842c6-6c882174-51d008bb

If the gocryptfs.conf file becomes corrupted or you ever forget your password,
there is only one hope for recovery: The master key. Print it to a piece of
paper and store it in a drawer. This message is only printed once.
The gocryptfs filesystem has been created successfully.
You can now mount it using: gocryptfs encrypted-s MOUNTPOINT
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi$ mkdir secret-s
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi$ cat >secret-s/masterkey.txt
Your master key is:

    ab16ad29-dc256b5f-6ba55359-586df2d5-
    1fa2c213-3b3842c6-6c882174-51d008bb

If the gocryptfs.conf file becomes corrupted or you ever forget your password,
there is only one hope for recovery: The master key. Print it to a piece of
paper and store it in a drawer. This message is only printed once.

uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi$ mkdir decrypted-s
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi$ gocryptfs --fido2 /dev/hidraw2 encrypted-s decrypted-s
FIDO2 Secret: interact with your device ...
Decrypting master key
Filesystem mounted and ready.
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi$ mkdir decrypted-s
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi$ gocryptfs --fido2 /dev/hidraw2 encrypted-s decrypted-s
FIDO2 Secret: interact with your device ...
Decrypting master key
Filesystem mounted and ready.
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi$ date >decrypted-s/secret-date-solo.txt
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi$ cat decrypted-s/secret-date-solo.txt
Do 2. Jan 09:33:46 CET 2025
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi$ fusermount -u decrypted-s
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi$ rm -rf decrypted-s
```

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

- 2025-01-08: Erste Version

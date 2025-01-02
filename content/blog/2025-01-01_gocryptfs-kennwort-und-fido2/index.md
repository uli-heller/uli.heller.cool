+++
date = '2025-01-01'
draft = false
title = 'Verschlüsseltes Dateisystem mit GOCRYPTFS - Fido2 und kompliziertes Kennwort'
categories = [ 'Verschlüsselung' ]
tags = [ 'crypto', 'fido2', 'linux', 'ubuntu' ]
+++

<!--Verschlüsseltes Dateisystem mit GOCRYPTFS - Fido2 und kompliziertes Kennwort-->
<!--============================================================================-->

Im Artikel [Verschlüsseltes Dateisystem mit GOCRYPTFS - Fido2]({{< ref  "/blog/2025-01-01_gocryptfs-fido2" >}})
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

Vorgehen analog zum Artikel [Verschlüsseltes Dateisystem mit GOCRYPTFS - Fido2]({{< ref  "/blog/2025-01-01_gocryptfs-fido2" >}}):

```
$ fido2-token -L 
/dev/hidraw2: vendor=0x20a0, product=0x42f3 (Nitrokey Nitrokey Passkey)

$ mkdir encrypted
$ mkdir secret

$ gocryptfs --init --fido2 /dev/hidraw2 encrypted
FIDO2 Register: interact with your device ...
  # Nitrokey leuchtet blau -> berühren
FIDO2 Secret: interact with your device ...
  # Nitrokey leuchtet blau -> nochmal berühren

Your master key is:

    3eca91ba-52c4391d-5d7ce783-b07e40f2-
    a3808dfd-a08c7ee5-a9577f97-cc6085d3

If the gocryptfs.conf file becomes corrupted or you ever forget your password,
there is only one hope for recovery: The master key. Print it to a piece of
paper and store it in a drawer. This message is only printed once.
The gocryptfs filesystem has been created successfully.
You can now mount it using: gocryptfs encrypted MOUNTPOINT

$ cat >secret/masker-key.txt <<EOF
Your master key is:

    3eca91ba-52c4391d-5d7ce783-b07e40f2-
    a3808dfd-a08c7ee5-a9577f97-cc6085d3

If the gocryptfs.conf file becomes corrupted or you ever forget your password,
there is only one hope for recovery: The master key. Print it to a piece of
paper and store it in a drawer. This message is only printed once.
The gocryptfs filesystem has been created successfully.
You can now mount it using: gocryptfs encrypted MOUNTPOINT
EOF
```

Nutzung mit Fido2
-----------------

Das verschlüsselte Verzeichnis kann ich nun so nutzen:

```
$ mkdir /tmp/decrypted-uli
$ gocryptfs --fido2 /dev/hidraw2 encrypted /tmp/decrypted-uli
FIDO2 Secret: interact with your device ...
  # Nitrokey leuchtet blau -> berühren
Decrypting master key
Filesystem mounted and ready.

$ echo "Das ist ein geheimer Satz" >/tmp/decrypted-uli/secret.txt

$ fusermount -u /tmp/decrypted-uli
$ rmdir /tmp/decrypted-uli
```

Aktivieren des Kennworts
------------------------

```
$ mkdir encrypted-k
$ gocryptfs --init --config encrypted/gocryptfs-password.conf encrypted-k
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi/encrypted/gocryptfs-password.conf
Choose a password for protecting your files.
Password: 
Repeat: 
...
  # Kennwort (password) spielt keine Rolle, es wird nicht nochmal verwendet
  # Angezeigter Masterkey spielt keine Rolle, er wird nicht nochmal verwendet
$ rm -rf encrypted-k

$ gocryptfs --passwd --masterkey 3eca91ba-52c4391d-5d7ce783-b07e40f2-a3808dfd-a08c7ee5-a9577f97-cc6085d3 \
  --config encrypted/gocryptfs-password.conf \
  encrypted
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi/encrypted/gocryptfs-password.conf
Using explicit master key.
THE MASTER KEY IS VISIBLE VIA "ps ax" AND MAY BE STORED IN YOUR SHELL HISTORY!
ONLY USE THIS MODE FOR EMERGENCIES
Please enter your new password.
Password: dies-ist-ein-relativ-langes-kennwort
Repeat: dies-ist-ein-relativ-langes-kennwort
A copy of the old config file has been created at "/home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi/encrypted/gocryptfs-password.conf.bak".
Delete it after you have verified that you can access your files with the new password.
Password changed.

$ rm -f encrypted/gocryptfs-password.conf.bak
```

Nutzung mit Kennwort
--------------------

Das verschlüsselte Verzeichnis kann ich nun mit Kennwort
und ohne Fido2-Gerät so nutzen:

```
$ mkdir /tmp/decrypted-uli
$ gocryptfs --config encrypted/gocryptfs-password.conf encrypted /tmp/decrypted-uli
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-08_gocryptfs-multi/encrypted/gocryptfs-password.conf
Password: dies-ist-ein-relativ-langes-kennwort
Decrypting master key
Filesystem mounted and ready.

$ ls /tmp/decrypted-uli/
secret.txt
$ cat /tmp/decrypted-uli/secret.txt 
Das ist ein geheimer Satz

$ fusermount -u /tmp/decrypted-uli
$ rmdir /tmp/decrypted-uli
```

Sicherheitseinschätzung
-----------------------

Da ich das Dateisystem im Regelfall mit dem Fido2-Gerät entschlüssle,
verwende ich das hinterlegte Kennwort relativ selten. Dementsprechend
kann es ruhig deutlich länger und komplizierter sein, als meine
üblichen Kennworte. Meiner Einschätzung nach ist das ein Sicherheitsgewinn!

Links
-----

- [Homepage: gocryptfs](https://nuetzlich.net/gocryptfs/)
- [GITHUB: gocryptfs](https://github.com/rfjakob/gocryptfs)
- [Verschlüsseltes Dateisystem mit GOCRYPTFS - Fido2]({{< ref  "/blog/2025-01-01_gocryptfs-fido2" >}})

Versionen
---------

Getestet mit

- Ubuntu-22.04 und gocryptfs-2.4.0

Historie
--------

- 2025-01-01: Erste Version

+++
date = '2025-01-06'
draft = false
title = 'GOCRYPTFS bauen aus den Github-Quellen'
categories = [ 'Verschlüsselung' ]
tags = [ 'crypto', 'linux', 'ubuntu' ]
+++

<!--GOCRYPTFS bauen aus den Github-Quellen-->
<!--======================================-->

Hier zeige ich, wie ich GOCRYPTFS aus
den Github-Quellen baue.

<!--more-->

Clonen
------

```
$ git clone https://github.com/rfjakob/gocryptfs.git
Klone nach 'gocryptfs'...
remote: Enumerating objects: 13034, done.
remote: Counting objects: 100% (1923/1923), done.
remote: Compressing objects: 100% (456/456), done.
remote: Total 13034 (delta 1569), reused 1467 (delta 1467), pack-reused 11111 (from 1)
Empfange Objekte: 100% (13034/13034), 5.65 MiB | 9.29 MiB/s, fertig.
Löse Unterschiede auf: 100% (9235/9235), fertig.
``` 

Abhängigkeiten installieren
---------------------------

```
$ sudo apt install golang
$ sudo apt install libssl-dev gcc pkg-config
```

Bauen
-----

```
$ cd gocryptfs/

$ ./build.bash
go: downloading github.com/hanwen/go-fuse/v2 v2.5.0
go: downloading github.com/spf13/pflag v1.0.5
go: downloading golang.org/x/crypto v0.18.0
go: downloading golang.org/x/sys v0.16.0
go: downloading github.com/sabhiram/go-gitignore v0.0.0-20210923224102-525f6e181f06
go: downloading golang.org/x/term v0.16.0
go: downloading github.com/rfjakob/eme v1.1.2
go: downloading github.com/aperturerobotics/jacobsa-crypto v1.0.2
gocryptfs v2.4.0-50-g1464f9d; go-fuse v2.5.0; 2025-01-01 go1.21.4 linux/amd64

$ ./gocryptfs --version
gocryptfs v2.4.0-50-g1464f9d; go-fuse v2.5.0; 2025-01-01 go1.21.4 linux/amd64

$ ./gocryptfs -hh 2>&1|grep fido2
      --fido2 string                          Protect the masterkey using a FIDO2 token instead of a password
      --fido2-assert-option fido2-assert -t   Options to be passed with fido2-assert -t
```

Es sieht so aus, als wären die Fido2-Optionen nun "komplett".

Fido2-Tests
-----------

```
$ mkdir encrypted decrypted

$ gocryptfs --init --fido2 /dev/hidraw2 \
  --fido2-assert-option pin=false \
  --fido2-assert-option uv=false \
  --fido2-assert-option up=false \
  encrypted
FIDO2 Register: interact with your device ...
  # Nitrokey leuchtet blau -> berühren
FIDO2 Secret: interact with your device ...

Your master key is:

    71882563-9eeaea3b-8b217e71-f40ce40c-
    315451ba-7ffcdb6b-2d86223c-748de9f5

If the gocryptfs.conf file becomes corrupted or you ever forget your password,
there is only one hope for recovery: The master key. Print it to a piece of
paper and store it in a drawer. This message is only printed once.
The gocryptfs filesystem has been created successfully.
You can now mount it using: gocryptfs encrypted MOUNTPOINT

$ ./gocryptfs --fido2 /dev/hidraw2 encrypted decrypted
FIDO2 Secret: interact with your device ...
Decrypting master key
Filesystem mounted and ready.

$ fusermount -u decrypted
```

Mit den Optionen "--fido2-assert-option" ändert sich der Ablauf so, dass

- beim Initialisieren das Fido2-Gerät genau einmal berührt werden muß
- beim Einbinden das Fido2-Gerät nicht berührt werden muß

Besonders der zweite Punkt ist sicherheitstechnisch nicht optimal.
Wenn sich jemand unerkannt im Hintergrund auf dem Arbeitsplatzrechner
anmeldet, dann kann er unerkannt das verschlüsselte Dateisystem einbinden.
NICHT VERWENDEN!

Notizen
-------

```
$ cd gocryptfs/
$ go build
go build
go: downloading github.com/hanwen/go-fuse/v2 v2.5.0
go: downloading github.com/spf13/pflag v1.0.5
go: downloading golang.org/x/crypto v0.18.0
go: downloading github.com/rfjakob/eme v1.1.2
go: downloading golang.org/x/sys v0.16.0
go: downloading golang.org/x/term v0.16.0
go: downloading github.com/sabhiram/go-gitignore v0.0.0-20210923224102-525f6e181f06
go: downloading github.com/aperturerobotics/jacobsa-crypto v1.0.2
go build github.com/rfjakob/gocryptfs/v2/internal/stupidgcm:
# pkg-config --cflags  -- libcrypto
Package libcrypto was not found in the pkg-config search path.
Perhaps you should add the directory containing `libcrypto.pc'
to the PKG_CONFIG_PATH environment variable
Package 'libcrypto', required by 'virtual:world', not found
pkg-config: exit status 1

$ ./build.bash
./build.bash 
go build github.com/rfjakob/gocryptfs/v2/internal/stupidgcm:
# pkg-config --cflags  -- libcrypto
Package libcrypto was not found in the pkg-config search path.
Perhaps you should add the directory containing `libcrypto.pc'
to the PKG_CONFIG_PATH environment variable
Package 'libcrypto', required by 'virtual:world', not found
pkg-config: exit status 1

$ sudo apt install libssl-dev gcc pkg-config
...

$ go build

$ ./gocryptfs --version
gocryptfs [GitVersion not set - please compile using ./build.bash]; go-fuse v2.5.0; 0000-00-00 go1.21.4 linux/amd64

$ ./build.bash
gocryptfs v2.4.0-50-g1464f9d; go-fuse v2.5.0; 2025-01-01 go1.21.4 linux/amd64

$ ./gocryptfs --version
gocryptfs v2.4.0-50-g1464f9d; go-fuse v2.5.0; 2025-01-01 go1.21.4 linux/amd64

$ ./gocryptfs -hh 2>&1|grep fido2
      --fido2 string                          Protect the masterkey using a FIDO2 token instead of a password
      --fido2-assert-option fido2-assert -t   Options to be passed with fido2-assert -t
```

Links
-----

- [Homepage: gocryptfs](https://nuetzlich.net/gocryptfs/)
- [GITHUB: gocryptfs](https://github.com/rfjakob/gocryptfs)

Versionen
---------

Getestet mit

- Ubuntu-22.04 und Github:gocryptfs "master" vom 2025-01-01

Historie
--------

- 2025-01-06: Erste Version

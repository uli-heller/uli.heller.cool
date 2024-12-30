+++
date = '2025-01-04'
draft = false
title = 'Verschlüsseltes Dateisystem mit GOCRYPTFS - Klartextdateinamen'
categories = [ 'Verschlüsselung' ]
tags = [ 'crypto', 'linux', 'ubuntu' ]
+++

<!--Verschlüsseltes Dateisystem mit GOCRYPTFS - Klartextdateinamen-->
<!--==============================================================-->

GOCRYPTFS stellt ein verschlüsseltes Dateisystem zur
Verfügung. Die verschlüsselte Version kann
mit Sicherungsprogrammen wie RESTIC gesichert werden,
aus den Sicherungen können keinerlei Informationen "hergeleitet"
werden.

Problem: Da Dateinamen und Dateiinhalte verschlüsselt sind,
ist eines selektives Restaurieren schwierig! Einfacher wird es,
wenn man auf das Verschlüsseln der Dateinamen verzichtet!

<!--more-->

Übliches Verschlüsseln
----------------------

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
```

Man sieht: Die Dateinamen im verschlüsselten Bereich sind verfremdet.
Es ist unklar, welcher verschlüsselte Dateinamen welchem Klartextnamen entspricht!

Verschlüsseln mit Klartext-Dateinamen
-------------------------------------

```
$ cd /tmp
$ mkdir encrypted-k
$ mkdir decrypted-k
$ gocryptfs --init --plaintextnames encrypted-k
Choose a password for protecting your files.
Password: 
Repeat: 

Your master key is:

    5adece45-4b8d9a73-0dcbcac7-b3df9a01-
    c8b0db3b-02120cf8-3460a85c-052d0dc6

If the gocryptfs.conf file becomes corrupted or you ever forget your password,
there is only one hope for recovery: The master key. Print it to a piece of
paper and store it in a drawer. This message is only printed once.
The gocryptfs filesystem has been created successfully.
You can now mount it using: gocryptfs encrypted-k MOUNTPOINT

$ gocryptfs encrypted-k decrypted-k
Password: 
Decrypting master key
Filesystem mounted and ready.

$ ls decrypted-k
$ ls encrypted-k/
gocryptfs.conf

$ for i in $(seq 1 10); do date >decrypted-k/${i}.date.txt; done

$ ls decrypted-k/
10.date.txt  1.date.txt  2.date.txt  3.date.txt  4.date.txt  5.date.txt  6.date.txt  7.date.txt  8.date.txt  9.date.txt
$ ls encrypted-k/
10.date.txt  2.date.txt  4.date.txt  6.date.txt  8.date.txt  gocryptfs.conf
1.date.txt   3.date.txt  5.date.txt  7.date.txt  9.date.txt

$ fusermount -u decrypted-k
```

Man sieht: Die Dateinamen im verschlüsselten Bereich sind unverschlüsselt.
Damit ist es einfacher, im Falle des Restaurierens eines Teils einer Sicherung
der verschlüsselten Dateien die "richtigen" zurückzuspielen.

Links
-----

- [Homepage: gocryptfs](https://nuetzlich.net/gocryptfs/)
- [GITHUB: gocryptfs](https://github.com/rfjakob/gocryptfs)
- [Baeldung: Encrypting and Decrypting Directories on Linux With gocryptfs](https://www.baeldung.com/linux/gocryptfs-encrypt-decrypt-dirs)

Versionen
---------

Getestet mit

- Ubuntu-22.04 und gocryptfs-1.8.0-1ubuntu0.1

Historie
--------

- 2025-01-04: Erste Version

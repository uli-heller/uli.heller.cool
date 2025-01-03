+++
date = '2025-01-10'
draft = false
title = 'PROOT: Probleme bei langen Dateinamen'
categories = [ 'Dateisystem' ]
tags = [ 'linux', 'ubuntu' ]
+++

<!--PROOT: Probleme bei langen Dateinamen-->
<!--=====================================-->

Beim Bauen von GOCRYPTFS mit PROOT bin ich über eine
Fehlermeldung bezüglich zu langer Dateinamen gestolpert.

<!--more-->

Fehlermeldung beim Bauen von GOCRYPTFS
--------------------------------------

```
...
rm -f debian/statfs.1
dh_auto_clean
make[1]: Leaving directory '/src/gocryptfs/gocryptfs-2.4.0'
   dh_autoreconf_clean -O--buildsystem=golang -O--builddirectory=_build
   dh_clean -O--buildsystem=golang -O--builddirectory=_build
 dpkg-source -b .
dpkg-source: info: using source format '3.0 (quilt)'
dpkg-source: info: building gocryptfs using existing ./gocryptfs_2.4.0.orig.tar.xz
dpkg-source: warning: upstream signing key but no upstream tarball signature
tar: gocryptfs-2.4.0/tests/example_filesystems/content/longname_255_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: Cannot open: File name too long
tar: gocryptfs-2.4.0/tests/example_filesystems/v1.1-reverse-plaintextnames/longname_255_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: Cannot open: File name too long
tar: gocryptfs-2.4.0/tests/example_filesystems/v1.1-reverse/longname_255_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: Cannot open: File name too long
tar: gocryptfs-2.4.0/tests/example_filesystems/v1.3-reverse/longname_255_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: Cannot open: File name too long
tar: Exiting with failure status due to previous errors
dpkg-source: error: tar -xf - --no-same-permissions --no-same-owner subprocess returned exit status 2
dpkg-buildpackage: error: dpkg-source -b . subprocess returned exit status 29
Probleme beim Auspacken oder bauen - EXIT
```

Die Fehlermeldung ist aufgetreten beim Bauen mit PROOT.
Ich hatte sie früher nicht beobachtet, als ich noch CHROOT verwendet habe.

Test mit langem Dateinamen
--------------------------

### Direkt auf meinem Arbeitsplatz

```
$ LEN=255; touch "$(expr substr "$(seq 1 200|tr -d "\n")" 1 $LEN)"; rm -f 12345*
$ LEN=256; touch "$(expr substr "$(seq 1 200|tr -d "\n")" 1 $LEN)"; rm -f 12345*
touch: '1234567891011121314151617181920212223242526272829303132333435363738394041424344454647484950515253545556575859606162636465666768697071727374757677787980818283848586878889909192939495969798991001011021031041051061071081091101111121131141151161171181191201211' kann nicht berührt werden: Der Dateiname ist zu lang
```

Direkt auf meinem Arbeitsplatz kann ich Dateien mit einer Länge von 255
Zeichen anlegen. 256 Zeichen klappen nicht mehr!

### Innerhalb von PROOT

```
$ proot -S build-proot-jammy-amd64/rootfs/ -w / bash
# LEN=255; touch "$(expr substr "$(seq 1 200|tr -d "\n")" 1 $LEN)"; rm -f 12345*
touch: cannot touch '123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899100101102103104105106107108109110111112113114115116117118119120121': File name too long
# LEN=254; touch "$(expr substr "$(seq 1 200|tr -d "\n")" 1 $LEN)"; rm -f 12345*
# exit 
```

Innerhalb von PROOT kann ich Dateien mit einer Länge von 254
Zeichen anlegen. 255 Zeichen klappen nicht mehr!

### Test mit Bind-Mount

```
$ mkdir mnt
$ proot -S build-proot-jammy-amd64/rootfs/ -w / -b mnt:/mnt bash
# cd /mnt
# LEN=255; touch "$(expr substr "$(seq 1 200|tr -d "\n")" 1 $LEN)"
touch: cannot touch '123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899100101102103104105106107108109110111112113114115116117118119120121': File name too long
# LEN=254; touch "$(expr substr "$(seq 1 200|tr -d "\n")" 1 $LEN)"
# exit
S ls mnt
12345678910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455565758596061626364656667686970717273747576777879808182838485868788899091929394959697989910010110210310410510610710810911011111211311411511611711811912012
$ rm -rf mnt
```

Auch bei Bind-Mounts gehen nur 254 Zeichen!

Links
-----

- [Homepage: Proot](https://proot-me.github.io/)
- [Github: Proot](https://github.com/proot-me/proot)
- [Github Issue: Max filename length: 254 vs 255](https://github.com/proot-me/proot/issues/391)

Versionen
---------

Getestet mit

- Ubuntu-20.04 und proot-5.4.0 (selbst kompiliert)

Historie
--------

- 2025-01-10: Erste Version

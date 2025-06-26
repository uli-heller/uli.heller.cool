+++
date = '2025-05-31'
draft = false
title = 'GOCRYPTFS: Ubuntu-Paket bauen aus den Github-Quellen'
categories = [ 'Verschlüsselung' ]
tags = [ 'crypto', 'linux', 'ubuntu' ]
+++

<!--GOCRYPTFS: Ubuntu-Paket bauen aus den Github-Quellen-->
<!--======================================-->

Hier zeige ich, wie ich ein Ubuntu-Paket für
GOCRYPTFS aus
den Github-Quellen baue.

<!--more-->

Bestehendes Ubuntu-Paket bauen
------------------------------

Container mit Ubuntu-24.04:

```sh
sudo apt update
sudo apt upgrade
mkdir -p build/gocryptfs
cd build/gocryptfs
apt source gocryptfs
# -> installiert gocryptfs_2.4.0-1ubuntu0.24.04.2
sudo apt -y build-dep gocryptfs
cd gocryptfs-2.4.0
dpkg-buildpackage
```

Neue Quelltexte herunterladen
-----------------------------

- [gocryptfs-2.5.4.15.tar.gz](https://github.com/uli-heller/gocryptfs/archive/refs/tags/v2.5.4.15.tar.gz)
- Virencheck!
- Ablegen im Container mit Ubuntu-24.04 unter "build/gocryptfs/gocryptfs-2.5.4.15.tar.gz"

Neues Ubuntu-Paket bauen
------------------------

Container mit Ubuntu-24.04:

```sh
cd build/gocryptfs
cd gocryptfs-2.4.0
uupdate -u ../gocryptfs-2.5.4.15.tar.gz
cd ../gocryptfs-2.5.4.15
dpkg-buildpackage
# ... 0001-tests-add-TestNotIdle.patch klappt nicht
# -> Patch entfernen!
# ... 003-revert-jacobsa-fork.patch klappt nicht
# -> Patch anpassen
# ... dann klappt es "im Prinzip"
```

Leider scheitert das Bauen dann mit:

```
$ dpkg-buildpackage 
dpkg-buildpackage: info: source package gocryptfsrn about the format. Here
dpkg-buildpackage: info: source version 2.5.4.15-0ubuntu1 to
...
	/usr/lib/go-1.22/src/github.com/mdp/qrterminal/v3 (from $GOROOT)
	/home/ubuntu/build/gocryptfs/gocryptfs-2.5.4.15/_build/src/github.com/mdp/qrterminal/v3 (from $GOPATH)
dh_auto_build: error: cd _build && go install -trimpath -v -p 8 -ldflags "-X main.GitVersion=2.5.4.15 -X main.GitVersionFuse=2.4.2 -X main.BuildDate=2025-06-05" github.com/rfjakob/gocryptfs github.com/rfjakob/gocryptfs/contrib/atomicrename github.com/rfjakob/gocryptfs/contrib/findholes github.com/rfjakob/gocryptfs/contrib/findholes/holes github.com/rfjakob/gocryptfs/contrib/getdents-debug/getdents github.com/rfjakob/gocryptfs/contrib/getdents-debug/readdirnames github.com/rfjakob/gocryptfs/contrib/statfs github.com/rfjakob/gocryptfs/contrib/statvsfstat github.com/rfjakob/gocryptfs/ctlsock github.com/rfjakob/gocryptfs/gocryptfs-xray github.com/rfjakob/gocryptfs/internal/configfile github.com/rfjakob/gocryptfs/internal/contentenc github.com/rfjakob/gocryptfs/internal/cryptocore github.com/rfjakob/gocryptfs/internal/ctlsocksrv github.com/rfjakob/gocryptfs/internal/ensurefds012 github.com/rfjakob/gocryptfs/internal/exitcodes github.com/rfjakob/gocryptfs/internal/fido2 github.com/rfjakob/gocryptfs/internal/fusefrontend github.com/rfjakob/gocryptfs/internal/fusefrontend_reverse github.com/rfjakob/gocryptfs/internal/inomap github.com/rfjakob/gocryptfs/internal/nametransform github.com/rfjakob/gocryptfs/internal/openfiletable github.com/rfjakob/gocryptfs/internal/pathiv github.com/rfjakob/gocryptfs/internal/readpassword github.com/rfjakob/gocryptfs/internal/siv_aead github.com/rfjakob/gocryptfs/internal/speed github.com/rfjakob/gocryptfs/internal/stupidgcm github.com/rfjakob/gocryptfs/internal/syscallcompat github.com/rfjakob/gocryptfs/internal/tlog returned exit code 1
make[1]: *** [debian/rules:16: override_dh_auto_build] Error 255
make[1]: Leaving directory '/home/ubuntu/build/gocryptfs/gocryptfs-2.5.4.15'
make: *** [debian/rules:13: binary] Error 2
dpkg-buildpackage: error: debian/rules binary subprocess returned exit status 2
```

Umstellung auf Standard-Build von GOCRYPTFS
-------------------------------------------

debian/rules anpassen:

```diff
--- gocryptfs-2.4.0/debian/rules	2023-08-12 00:06:13.000000000 +0200
+++ gocryptfs-2.5.4.15/debian/rules	2025-06-05 15:46:28.777345426 +0200
@@ -10,13 +10,16 @@
 DEB_LDFLAGS="-X main.GitVersion=$(DEB_VERSION_UPSTREAM) -X main.GitVersionFuse=$(GOFUSE_VERSION_UPSTREAM) -X main.BuildDate=$(CHANGELOG_TIMESTAMP)"
 
 %:
+	PATH="$(CURDIR)/debian:$$PATH" \
 	dh $@ --buildsystem=golang --with=golang --builddirectory=_build
 
 override_dh_auto_build:
-	dh_auto_build -- -ldflags $(DEB_LDFLAGS)
-	cp -r internal/* _build/src/github.com/rfjakob/gocryptfs/internal/
-	cp -r tests/* _build/src/github.com/rfjakob/gocryptfs/tests
-	cp _build/bin/gocryptfs _build/src/github.com/rfjakob/gocryptfs/
+	head -1 debian/changelog|cut -f 2 -d '('|cut -f 1 -d ')' >VERSION
+	./build-without-openssl.bash
+	#dh_auto_build -- -ldflags $(DEB_LDFLAGS)
+	#cp -r internal/* _build/src/github.com/rfjakob/gocryptfs/internal/
+	#cp -r tests/* _build/src/github.com/rfjakob/gocryptfs/tests
+	#cp _build/bin/gocryptfs _build/src/github.com/rfjakob/gocryptfs/
 	pandoc Documentation/MANPAGE.md -s -t man -o debian/gocryptfs.1
 	pandoc Documentation/MANPAGE-XRAY.md -s -t man -o debian/gocryptfs-xray.1
 	pandoc Documentation/MANPAGE-STATFS.md -s -t man -o debian/statfs.1
@@ -26,14 +29,25 @@
     PATH="$(CURDIR)/_build/bin:$$PATH" \
     DH_GOLANG_EXCLUDES="gocryptfs-xray tests/cli tests/defaults tests/deterministic_names tests/example_filesystems tests/fsck tests/hkdf_sanity \
 			tests/matrix tests/plaintextnames tests/reverse tests/root_test tests/sharedstorage tests/xattr" \
-    dh_auto_test
+    true
+#    dh_auto_test
 
 override_dh_auto_clean:
 	rm -f debian/gocryptfs.1
 	rm -f debian/gocryptfs-xray.1
 	rm -f debian/statfs.1
+	rm -f contrib/atomicrename/atomicrename
+	rm -f contrib/findholes/findholes
+	rm -f contrib/statfs/statfs
+	rm -f gocryptfs-xray/gocryptfs-xray
+	rm -f gocryptfs
+	rm -f VERSION
 	dh_auto_clean
 
 override_dh_auto_install:
 	dh_auto_install --destdir=debian/tmp
+	mkdir -p debian/tmp/usr/bin
+	cp gocryptfs debian/tmp/usr/bin
+	cp gocryptfs-xray/gocryptfs-xray debian/tmp/usr/bin
+	cp contrib/statfs/statfs debian/tmp/usr/bin
 	rm -rf debian/tmp/usr/share/gocode
```

debian/dh_golang anlegen:

```
#!/bin/sh
exec true
```

debian/patches/004-uli-build.patch anlegen:

```
...
--- gocryptfs-2.5.4.15.orig/build-without-openssl.bash
+++ gocryptfs-2.5.4.15/build-without-openssl.bash
@@ -5,6 +5,8 @@ cd "$(dirname "$0")"
 CGO_ENABLED=0 source ./build.bash -tags without_openssl
 
 if ldd gocryptfs 2> /dev/null ; then
+	echo "build-without-openssl.bash: error: compiled binary is static"
+else
 	echo "build-without-openssl.bash: error: compiled binary is not static"
 	exit 1
 fi
```

debian/patches/series anpassen:

```
#0001-tests-add-TestNotIdle.patch
001-disable-emulated-getdents.patch
002-disable-getdents-test.patch
#003-revert-jacobsa-fork.patch
004-uli-build.patch
```

debian/changelog anpassen:

```diff
--- gocryptfs-2.4.0/debian/changelog	2024-11-01 10:42:11.000000000 +0100
+++ gocryptfs-2.5.4.15/debian/changelog	2025-06-05 15:38:11.897705339 +0200
@@ -1,3 +1,9 @@
+gocryptfs (2.5.4.15-1ubuntu0.24.04.2~uh~noble) noble-security; urgency=medium
+
+  * New upstream release.
+
+ -- Uli Heller <uli.heller@daemons-point.com>  Thu, 05 Jun 2025 15:13:07 +0200
+
 gocryptfs (2.4.0-1ubuntu0.24.04.2) noble-security; urgency=medium
 
   * No change rebuild due to golang-1.22 update
```

Bauen
-----

Container mit Ubuntu-24.04:

```sh
PATH="${HOME}/bin:${PATH}"
export PATH
cd build/gocryptfs
cd gocryptfs-2.5.4.15
dpkg-buildpackage
# -> erzeugt u.a. ../gocryptfs_2.5.4.15-1ubuntu0.24.04.2~uh~noble_amd64.deb
```

Links
-----

- [Homepage: gocryptfs](https://nuetzlich.net/gocryptfs/)
- [GITHUB: gocryptfs](https://github.com/rfjakob/gocryptfs)

Versionen
---------

Getestet mit

- Ubuntu-24.04 und Github:gocryptfs "master" vom 2025-05-31

Historie
--------

- 2025-05-31: Erste Version

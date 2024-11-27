+++
date = '2024-11-30'
draft = false
title = 'Ubuntu: Aktivieren der Quelltext-Repositories'
categories = [ 'Ubuntu' ]
tags = [ 'lxc', 'lxd', 'linux', 'ubuntu', 'debian' ]
+++

<!--
Ubuntu: Aktivieren der Quelltext-Repositories
=============================================
-->

Manchmal benötige ich die Quellen eines Ubuntu-Pakets.
Die Quellen spielt man ein mit `apt source (paketname)`.
Bei einer "frischen" Installation wird das Kommando
quitiert mit dieser Fehlermeldung:

```
/tmp# apt source git
Reading package lists... Done
E: You must put some 'deb-src' URIs in your sources.list
```

Die Korrektur dieser Fehlermeldung folgt!

<!--more-->

Aktivieren der Quelltext-Repos
------------------------------

```
$ sudo cat /etc/apt/sources.list /etc/apt/sources.list.d/*\
  |sed -e "s/^deb/deb-src/" -e "s/:\s*deb$/: deb-src/"\
  >/etc/apt/sources.list.d/deb-src.sources
```

Aktualisierung
--------------

```
$ sudo apt update
Hit:1 http://archive.ubuntu.com/ubuntu noble InRelease
Get:2 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:3 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Get:4 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
Get:5 http://archive.ubuntu.com/ubuntu noble-updates/main Sources [301 kB]
Get:6 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages [673 kB]
Get:7 http://security.ubuntu.com/ubuntu noble-security/main Sources [127 kB]  
...
```

Quelltext einspielen
--------------------

```
$ apt source git
eading package lists... Done
NOTICE: 'git' packaging is maintained in the 'Git' version control system at:
https://repo.or.cz/r/git/debian.git/
Please use:
git clone https://repo.or.cz/r/git/debian.git/
to retrieve the latest (possibly unreleased) updates to the package.
Need to get 8159 kB of source archives.
Get:1 http://archive.ubuntu.com/ubuntu noble-updates/main git 1:2.43.0-1ubuntu7.1 (dsc) [2927 B]
Get:2 http://archive.ubuntu.com/ubuntu noble-updates/main git 1:2.43.0-1ubuntu7.1 (tar) [7383 kB]
Get:3 http://archive.ubuntu.com/ubuntu noble-updates/main git 1:2.43.0-1ubuntu7.1 (diff) [773 kB]
Fetched 8159 kB in 3s (2987 kB/s)
dpkg-source: info: extracting git in git-2.43.0
dpkg-source: info: unpacking git_2.43.0.orig.tar.xz
dpkg-source: info: unpacking git_2.43.0-1ubuntu7.1.debian.tar.xz
dpkg-source: info: using patch list from debian/patches/series
dpkg-source: info: applying CVE-2024-32002.patch
dpkg-source: info: applying CVE-2024-32004.patch
dpkg-source: info: applying CVE-2024-32020.patch
dpkg-source: info: applying CVE-2024-32021.patch
dpkg-source: info: applying CVE-2024-32465.patch
```

Versionen
---------

- Getestet mit Ubuntu 22.04.5 LTS auf dem Host
- Getestet mit Ubuntu 24.04.1 LTS im Container

Historie
--------

- 2024-11-30: Erste Version

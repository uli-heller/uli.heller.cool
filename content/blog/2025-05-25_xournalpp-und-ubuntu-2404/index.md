+++
date = '2025-05-25'
draft = false
title = 'Ubuntu: XournalPP - Probleme beim Start'
categories = [ 'pdf' ]
tags = [ 'linux', 'ubuntu', 'debian' ]
+++

<!--
Ubuntu: XournalPP - Probleme beim Start
============================
-->

Für das Ausfüllen von PDF-Dokumenten verwende ich gerne
XournalPP und davon die AppImage-Variante. Bislang hat
das immer problemlos geklappt. Nach der Umstellung auf
Ubuntu-24.04 (noble) startet die Anwendung nicht mehr.

<!--more-->

Fehlermeldung beim Start
------------------------

Ich starte XournalPP mit diesem Kommando:

- `~/Software/xournalpp-1.2.7-x86_64.AppImage`

Leider klappt der Start nicht und wirft stattdessen die
nachfolgende Fehlermeldung:

```sh
$ ~/Software/xournalpp-1.2.7-x86_64.AppImage
/tmp/.mount_xournagPlJCb/AppRun.wrapped: error while loading shared libraries: libjack.so.0: cannot open shared object file: No such file or directory
```

Quercheck mit Version 1.2.0 liefert denselben Fehler!

Abhilfe
-------

Das Problem wird korrigiert mit diesen Kommandos:

```
sudo apt update
sudo apt upgrade
sudo apt install libjack0
```

Links
-----

- [Github - XournalPP](https://github.com/xournalpp/xournalpp)
- [Github - AppImage relies on external libjack.so.0: cannot open shared obj. file](https://github.com/xournalpp/xournalpp/issues/5409)

Versionen
---------

- Getestet mit Ubuntu 24.04.2 LTS

Historie
--------

- 2025-05.-25: Erste Version

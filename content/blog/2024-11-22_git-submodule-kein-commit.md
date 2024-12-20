+++
date = '2024-11-22'
draft = false
title = 'Git: Mecker über fehlenden Commit'
categories = [ 'Git' ]
tags = [ 'git' ]
+++

<!--
Git: Mecker über fehlenden Commit
=================================
-->

Wenn ich mit Git-Submodulen arbeite, dann
sehe ich gelegentlich Fehlermeldungen wie diese:

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ git commit -m "png-cheatsheet.md: Skalieren auf Breite und Höhe" .
Fehler: 'my-hugo-site/themes/mainroad.orig' hat keinen Commit ausgecheckt
Schwerwiegend: Aktualisierung der Dateien fehlgeschlagen

$ LANG=C git commit .
error: 'my-hugo-site/themes/mainroad.orig' does not have a commit checked out
fatal: updating files failed
```

Hier beschreibe ich, was zu tun ist, damit die Fehlermeldung
verschwindet!

<!--more-->

Fehlerbeschreibung
------------------

Wenn ich mich richtig erinnere, dann tritt der
Fehler beispielsweise bei folgendem Abauf aus:

- Ich habe einen Checkout und füge diesem ein Submodul
  hinzu

- Ich wechsle zu einem anderen Rechner

- Ich clone das Repo ohne spezielle Berücksichtigung des Submoduls

- Ich versuche eine Änderung im Repo abzuspeichern (`git commit ...`)

  - KO: `git commit -m XYZ .`
  - OK: `git commit -m XYZ content`
    Submodul liegt außerhalb von "content"

Hier die Fehler im Detail:

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ git commit -m "png-cheatsheet.md: Skalieren auf Breite und Höhe" .
Fehler: 'my-hugo-site/themes/mainroad.orig' hat keinen Commit ausgecheckt
Schwerwiegend: Aktualisierung der Dateien fehlgeschlagen

uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ git commit -m "png-cheatsheet.md: Skalieren auf Breite und Höhe" content
[main 9ada5c8] png-cheatsheet.md: Skalieren auf Breite und Höhe
 1 file changed, 11 insertions(+)
```

Abhilfe
-------

Den Fehler kann man recht einfach korrigieren mit:

```
git submodule init
git submodule update
```

Die Ausgaben im Detail sehen so aus:

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ git submodule init
Submodul 'my-hugo-site/themes/mainroad.orig' (https://github.com/vimux/mainroad.git) für Pfad 'themes/mainroad.orig' in die Konfiguration eingetragen.

uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ git submodule update
Klone nach '/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/mainroad.orig'...
Submodul-Pfad 'themes/mainroad.orig': '13e04b3694ea2d20a68cfbfaea42a8c565079809' ausgecheckt
```

Historie
--------

- 2024-12-20: Tippfehler korrigiert
- 2024-11-22: Erste Version

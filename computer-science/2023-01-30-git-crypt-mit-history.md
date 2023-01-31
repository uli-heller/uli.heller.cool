---
layout: post
title: "GIT: Verschlüsseln inklusive Altversionen"
date: 2023-01-31 00:00:00
comments: false
author: Uli Heller (privat)
categories: git
include_toc: false
published: true
---

<!--
GIT: Verschlüsseln inklusive Altversionen
=========================================
-->

Seit vielen Jahren verwende ich quasi ausschließlich
GIT zur Versionierung meiner Dateien. Wenn ich dafür
öffentliche Infrastruktur verwende wie GITHUB, dann
möchte ich manche Dateien dort nicht im Klartext für
jeden einsehbar sehen. Diese Dateien verschlüssele
ich dann mit GIT-CRYPT, das funktioniert recht einfach.

Problematisch wird es, wenn die Dateien bereits in
unverschlüsselter Form im Git-Repo vorliegen und
ich mich dann entschliesse, sie zu verschlüsseln.

<!-- more -->

TLDR
----

- Initialisierte GIT-CRYPT: `git crypt init`
- Verschlüssele den aktuellen Stand durch Anlegen einer geeigneten
  Version von ".gitattributes"
- Verschlüssele alle Altversionen mit:
    ```
    cp .gitattributes /tmp/gitattributes.uli
    git filter-branch --tree-filter "cp /tmp/gitattributes.uli .gitattributes" --tag-name-filter cat -- --all
    rm -f /tmp/gitattributes.uli
    git -c gc.reflogExpire=now -c gc.pruneExpire=now gc --aggressive --prune=now
    ```

Man kann auf ähnliche Art und Weise die Verschlüsselung auch
komplett entfernen:

```
git filter-branch --tree-filter "rm -f /.gitattributes" -- --all
```

Vorbereitungen
--------------

- Verzeichnis anlegen und reinwechseln: `mkdir git-crypt-test && cd git-crypt-test`
- Neues Git-Repo anlegen: `git init`
- Mini-Versions-Baum erzeugen:
    ```
    git commit --allow-empty -m "Erster Commit"
    date >eine-datei.txt
    date >ein-kennwort.KEY
    git add *
    git commit -m "Erste Dateien aufgenommen"
    date >noch-ein-kennwort.KEY
    git add noch-ein-kennwort.KEY
    date >>ein-kennwort.KEY
    git commit -m "Diverse Änderungen" .
    git log
    git tag Erste-Markierung-ohne-Beschreibung 7c68152334
    git tag -a -m "Beschreibung für zweite Markierung"  Zweite-Markierung-mit-Beschreibung b0b660c2a
    git checkout -b Verzweigung Zweite-Markierung-mit-Beschreibung
    date >zweig-kennwort.KEY
    date >zweig-datei.txt
    git checkout main
    ```

Den hierbei erzeugten Stand habe ich gesichert unter [data/git-crypt-test_vor-verschluesselung.tar.xz](data/git-crypt-test_vor-verschluesselung.tar.xz).

Verschlüsselung aktivieren
--------------------------

Die Aktivierung erfolgt grob so:

```
git crypt init
echo "*KEY filter=git-crypt diff=git-crypt" >.gitattributes
git add .gitattributes
echo "Super-geheimer KEY" >super-geheim.KEY
```

Den Status der Verschlüsselung prüft man dann mit: `git crypt status`
Er liefert diese Aufgabe:

```
not encrypted: .gitattributes
    encrypted: ein-kennwort.KEY *** WARNING: staged/committed version is NOT ENCRYPTED! ***
not encrypted: eine-datei.txt
    encrypted: noch-ein-kennwort.KEY *** WARNING: staged/committed version is NOT ENCRYPTED! ***
    encrypted: super-geheim.KEY

Warning: one or more files is marked for encryption via .gitattributes but
was staged and/or committed before the .gitattributes file was in effect.
Run 'git-crypt status' with the '-f' option to stage an encrypted version.
```

Also: "Eigentlich" sollte man die zwei bestehenden KEY-Dateien gesondert bearbeiten.
Wir "vergessen" das erstmal!

```
git commit -m "Verschlüsselung aktiviert" .
git status
# -> alles OK
git crypt status
# -> die zwei Dateien werden noch immer angemeckert
git crypt status -f
git commit -m "KEY-Dateien verschlüsselt" .
```

Nun sieht die Welt erstmal OK aus, alle KEY-Dateien sind verschlüsselt!

Den hierbei erzeugten Stand habe ich gesichert unter [data/git-crypt-test_nach-verschluesselung.tar.xz](data/git-crypt-test_nach-verschluesselung.tar.xz).

Verschlüsselung für alte Versionen sichten
------------------------------------------

Die Verschlüsselung alter Versionen kann man überprüfen mit
diesem Kommando: `FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --tree-filter "echo && git crypt status" -- --all`

Es liefert die folgende Ausgabe:

```
Rewrite 7c681523345accc045945fd2b22630c27cd322ee (1/6) (0 seconds passed, remaining 0 predicted)    
Rewrite b0b660c2a2acb91f498334db779457d5cfa0d0d2 (2/6) (0 seconds passed, remaining 0 predicted)    
not encrypted: ein-kennwort.KEY
not encrypted: eine-datei.txt
Rewrite 60f8e98448215b811871ff38854f5a2ea63bc771 (3/6) (0 seconds passed, remaining 0 predicted)    
not encrypted: ein-kennwort.KEY
not encrypted: eine-datei.txt
not encrypted: zweig-datei.txt
not encrypted: zweig-kennwort.KEY
Rewrite bb8208f1eb8914841928aa6d639d952ed64e6f95 (4/6) (0 seconds passed, remaining 0 predicted)    
not encrypted: ein-kennwort.KEY
not encrypted: eine-datei.txt
not encrypted: noch-ein-kennwort.KEY
Rewrite 6cfadbdfe569e92f71c6a713df86cff99247e89c (5/6) (0 seconds passed, remaining 0 predicted)    git-crypt: Warning: file not encrypted
git-crypt: Run 'git-crypt status' to make sure all files are properly encrypted.
git-crypt: If 'git-crypt status' reports no problems, then an older version of
git-crypt: this file may be unencrypted in the repository's history.  If this
git-crypt: file contains sensitive information, you can use 'git filter-branch'
git-crypt: to remove its old versions from the history.
git-crypt: Warning: file not encrypted
git-crypt: Run 'git-crypt status' to make sure all files are properly encrypted.
git-crypt: If 'git-crypt status' reports no problems, then an older version of
git-crypt: this file may be unencrypted in the repository's history.  If this
git-crypt: file contains sensitive information, you can use 'git filter-branch'
git-crypt: to remove its old versions from the history.

not encrypted: .gitattributes
    encrypted: ein-kennwort.KEY *** WARNING: staged/committed version is NOT ENCRYPTED! ***
not encrypted: eine-datei.txt
    encrypted: noch-ein-kennwort.KEY *** WARNING: staged/committed version is NOT ENCRYPTED! ***
    encrypted: super-geheim.KEY

Warning: one or more files is marked for encryption via .gitattributes but
was staged and/or committed before the .gitattributes file was in effect.
Run 'git-crypt status' with the '-f' option to stage an encrypted version.
```

Hier sieht man viele KEY-Dateien mit dem Zusatz "not encrypted".

Alle Versionen verschlüsseln
----------------------------

```
git filter-branch --tree-filter 'echo "*KEY filter=git-crypt diff=git-crypt" >.gitattributes'  --tag-name-filter cat -- --all
git -c gc.reflogExpire=now -c gc.pruneExpire=now gc --aggressive --prune=now
```

Nochmalige Sichtung
-------------------

```
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --tree-filter "echo && git crypt status" -- --all`
# liefert die nachfolgende Ausgabe:
Rewrite 8339223ffbe6eb50298329d30a2dc50d3685f5f1 (1/6) (0 seconds passed, remaining 0 predicted)
not encrypted: .gitattributes
Rewrite e27065622f342886a63eb38110a8eb12797145fc (2/6) (0 seconds passed, remaining 0 predicted)
not encrypted: .gitattributes
    encrypted: ein-kennwort.KEY
not encrypted: eine-datei.txt
Rewrite 0dcb8c19c04efaeeb1a096597308abd812a88edc (3/6) (0 seconds passed, remaining 0 predicted)
not encrypted: .gitattributes
    encrypted: ein-kennwort.KEY
not encrypted: eine-datei.txt
not encrypted: zweig-datei.txt
    encrypted: zweig-kennwort.KEY
Rewrite 11f119af388012e4aa738d30dda0222f7e2638ef (4/6) (0 seconds passed, remaining 0 predicted)
not encrypted: .gitattributes
    encrypted: ein-kennwort.KEY
not encrypted: eine-datei.txt
    encrypted: noch-ein-kennwort.KEY
Rewrite 5d9d00d862155ea8e9f93822487c83490a13e0f3 (5/6) (0 seconds passed, remaining 0 predicted)
not encrypted: .gitattributes
    encrypted: ein-kennwort.KEY
not encrypted: eine-datei.txt
    encrypted: noch-ein-kennwort.KEY
    encrypted: super-geheim.KEY
Rewrite 24d68f71f423c416a1280262e031aa72c230620a (6/6) (0 seconds passed, remaining 0 predicted)
not encrypted: .gitattributes
    encrypted: ein-kennwort.KEY
not encrypted: eine-datei.txt
    encrypted: noch-ein-kennwort.KEY
    encrypted: super-geheim.KEY

WARNING: Ref 'refs/heads/Verzweigung' is unchanged
WARNING: Ref 'refs/heads/main' is unchanged
WARNING: Ref 'refs/tags/Erste-Markierung-ohne-Beschreibung' is unchanged
WARNING: Ref 'refs/tags/Zweite-Markierung-mit-Beschreibung' is unchanged
```

Dieser finale Stand liegt ab unter [data/git-crypt-test_komplett-verschluesselung.tar.xz](data/git-crypt-test_komplett-verschluesselung.tar.xz).

Unklarheiten
------------

### Offene Unklarheiten

Keine offenen Unklarheiten!

### Geklärte Unklarheiten

#### Wie sieht es mit Branches aus?

Branches werden mit bearbeitet, keine Sonderaktionen notwendig!

#### Wie sieht es mit Tags aus?

Tags müssen manuell verschoben werden mit `git tag -f (tagname) (commit)`!

#### Wie kann ich halbwegs sicher sein, dass die Verschlüsselung geklappt hat?

Überprüfung mit:

```
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --tree-filter "echo && git crypt status" -- --all
```

Links
-----

* [git-scm.com: git-filter-branch - Rewrite branches](https://git-scm.com/docs/git-filter-branch)
* [git-filter-branch examples and notes](https://gist.github.com/kanzure/5558267)

Änderungen
----------

* 2023-01-30: Erste Version auf uli.heller.cool

+++
date = '2024-11-16'
draft = false
title = 'Git: Leere Verzeichnisse'
categories = [ 'Git', 'Hugo' ]
+++

<!--
Git: Leere Verzeichnisse
========================
-->

Manchmal würde man gerne leere Verzeichnisse in
Git speichern. Beispielsweise dann, wenn ich
neu eingerichtete und fast leere Hugo-Sites per
Git von einem Rechner zum anderen kopiert werden.
Das Erzeugen von neuen Inhalten mit `hugo new content blog/new-blog-post.md`
scheitert mit dem Fehler "Error: no existing content directory configured for this project".

Hier erkläre ich, wie man das Problem umgeht!

<!--more-->

Fehlerbeschreibung
------------------

Ablauf:

- Auf Rechner A eine Hugo-Site anlegen (`hugo new site ...`)
- In Git speichern (`git add...; git commit...; git push`)
- Auf Rechner B das Git-Repo clonen (`git clone...`)
- Auf Rechner B mit der Hugo-Site arbeiten (`hugo new content bog/new-blog-post.md`)

Der letzte Schritt
scheitert mit dem Fehler "Error: no existing content directory configured for this project".

Wenn man die Hugo-Site auf Rechner B sichtet und mit Rechner A vergleicht, so stellt man
fest, dass viele Verzeichnisse fehlen:

- Rechner A - `ls -1`
  - archetypes
  - assets
  - content
  - data
  - hugo.toml
  - i18n
  - layouts
  - static
  - themes
- Rechner B - `ls -1`
  - archetypes
  - hugo.toml

Alle fehlenden Verzeichnisse sind leer. Sie werden von Git nicht
gespeichert (=bekanntes Verhalten).

Abhilfe
-------

Damit das besser klappt, muß man auf Rechner A beim Speichern
in Git einen Zusatzschritt unternehmen:

- Hugo-Site anlegen - Verzeichnis "hugo-site"
- Zusätzlich - Dummy-Dateien anlegen: `find hugo-site -type d -empty|xargs -I{} touch {}/.gitkeep`
- In Git speichern
- usw.

Danach kann das Repo auf Rechner B geclont und dort damit gearbeitet werden.

Historie
--------

- 2024-11-16: Erste Version

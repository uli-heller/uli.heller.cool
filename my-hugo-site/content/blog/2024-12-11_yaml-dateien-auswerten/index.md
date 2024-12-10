+++
date = '2024-12-11'
draft = false
title = 'YAML-Dateien auswerten'
categories = [ 'YAML' ]
tags = [ 'yaml', 'yq', 'go' ]
+++

<!--
YAML-Dateien auswerten
======================
-->

Für eine Analyse für einen meiner Kunden muß ich YAML-Dateien auswerten.
Konkret geht es um die Gitlab-Konfigurationsdatei "gitlab-ci.yml"
und da drin um die verwendeten Gitlab-Runner.

<!--more-->

Quelltext einspielen
--------------------

```
git clone git@github.com:mikefarah/yq.git
```

Bauen
-----

```
cd yq
go build
# ... erzeugt "yq"
```

Test
----

```
./yq
# ... gibt jede Menge Text aus
```

Anzeige aller Gitlab-Runner
---------------------------

Die Gitlab-Runner sind hinterlegt in der Datei ".gitlab-ci.yml".
Hier gibt es den Eintrag "tags" und dieser enthält die Kennungen
der Gitlab-Runner. Hier die Abfrage:

```
yq '..|select(has"tags")|.tags' .gitlab-ci.yml
```

Ausgabe:

```
$ yq '..|select(has"tags")|.tags' .gitlab-ci.yml
- bach004-docker
- bach005-docker
```

Links
-----

- [YQ - Doku](https://mikefarah.gitbook.io/yq)
- [YQ - Quelltext](https://github.com/mikefarah/yq)

Historie
--------

- 2024-12-11: Erste Version

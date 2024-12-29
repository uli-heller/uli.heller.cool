+++
date = '2024-12-29'
draft = false
title = 'Fehlermeldung bei Git-Submodule nach Repo-Umstellungen'
categories = [ 'Git' ]
tags = [ 'git' ]
+++

<!--
Fehlermeldung bei Git-Submodule nach Repo-Umstellungen
======================================================
-->

Ich habe bei einem meiner Git-Repos viele Pfade angepasst
mit dem Werkzeug "git-filter-repo". Seit den Anpassungen
gibt es Fehlermeldung bzgl. eines Git-Submodules. Die Github-Action
zum Bauen funktioniert auch nicht mehr.

<!--more-->

Fehlermeldung in der Github-Action
----------------------------------

[Fehlermeldung in der Github-Action](https://github.com/uli-heller/uli.heller.cool/actions/runs/12519060308):

```
Annotations
  2 errors and 2 warnings

build
  No url found for submodule path 'themes/hugo-clarity.orig' in .gitmodules
build
  The process '/usr/bin/git' failed with exit code 128
build
  ubuntu-latest pipelines will use ubuntu-24.04 soon. For more details, see https://github.com/actions/runner-images/issues/10636
build
  The process '/usr/bin/git' failed with exit code 128
```

Fehlermeldung bei "git commit"
------------------------------

```
$ git commit .
Fehler: 'themes/hugo-clarity.orig' hat keinen Commit ausgecheckt
Schwerwiegend: Aktualisierung der Dateien fehlgeschlagen
```

Erster Abhilfeversuch
---------------------

```
$ git submodule update --init
Schwerwiegend: Keine URL für Submodul-Pfad 'themes/hugo-clarity.orig' in .gitmodules gefunden
```

Sichtung .gitmodules
--------------------

```
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool$ cat .gitmodules 
[submodule "my-hugo-site/themes/mainroad.orig"]
	path = my-hugo-site/themes/mainroad.orig
	url = https://github.com/vimux/mainroad.git
[submodule "my-hugo-site/themes/hugo-clarity.orig"]
	path = my-hugo-site/themes/hugo-clarity.orig
	url = https://github.com/chipzoller/hugo-clarity
```

Erkenntnis: Da stehen noch die falschen Pfade drin!
Hab mein Git-Repo umorganisiert mit `git-filter-repo`.

Anpassung
---------

```diff
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool$ git diff 
diff --git a/.gitmodules b/.gitmodules
index fa75b80..b4856a6 100644
--- a/.gitmodules
+++ b/.gitmodules
@@ -1,6 +1,6 @@
-[submodule "my-hugo-site/themes/mainroad.orig"]
-       path = my-hugo-site/themes/mainroad.orig
+[submodule "themes/mainroad.orig"]
+       path = themes/mainroad.orig
        url = https://github.com/vimux/mainroad.git
-[submodule "my-hugo-site/themes/hugo-clarity.orig"]
-       path = my-hugo-site/themes/hugo-clarity.orig
+[submodule "themes/hugo-clarity.orig"]
+       path = themes/hugo-clarity.orig
        url = https://github.com/chipzoller/hugo-clarity
```

Noch ein Abhilfeversuch
-----------------------

```
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool$ git submodule update --init
Submodul 'themes/hugo-clarity.orig' (https://github.com/chipzoller/hugo-clarity) für Pfad 'themes/hugo-clarity.orig' in die Konfiguration eingetragen.
Submodul 'themes/mainroad.orig' (https://github.com/vimux/mainroad.git) für Pfad 'themes/mainroad.orig' in die Konfiguration eingetragen.
Klone nach '/home/uli/git/github/uli-heller/uli.heller.cool/themes/hugo-clarity.orig'...
Klone nach '/home/uli/git/github/uli-heller/uli.heller.cool/themes/mainroad.orig'...
Submodul-Pfad 'themes/hugo-clarity.orig': '174a5e638704181c744934b75c327c665844ab04' ausgecheckt
Submodul-Pfad 'themes/mainroad.orig': '13e04b3694ea2d20a68cfbfaea42a8c565079809' ausgecheckt
```

Schlusstest
-----------

```
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool$ git commit .
Auf Branch main
Ihr Branch ist auf demselben Stand wie 'origin/main'.

Unversionierte Dateien:
  (benutzen Sie "git add <Datei>...", um die Änderungen zum Commit vorzumerken)
	content/2024-12-29_git-submodule-fehler/

nichts zum Commit vorgemerkt, aber es gibt unversionierte Dateien
(benutzen Sie "git add" zum Versionieren)
```

Das sieht schon wieder ganz gut aus! Uff!

Links
-----

- Keine

Versionen
---------

Getestet mit Ubuntu-20.04 und Git-2.47.1

Historie
--------

- 2024-12-29: Erste Version

+++
date = '2024-12-21'
draft = false
title = 'Git: Inhalt ohne "git clone"'
categories = [ 'Git' ]
tags = [ 'git', 'github', 'forgejo' ]
+++

<!--
Git: Inhalt ohne "git clone"
============================
-->

Git ermöglicht es, auf Teile eines Git-Repositories
zuzugreifen ohne das Repo zuvor Clonen zu müssen.
Dies verwende ich beispielsweise, um über alle meine
Kunden-Git-Projekte Auswertungen durchzuführen.

Leider klappt das Verfahren auf Github überhaupt nicht.
Eine Lösung hierfür folgt weiter hinten!

<!--more-->

Inhalt einer einzelnen Datei
----------------------------

Ich würde gerne auf den Inhalt der Datei "build.gradle"
in einem meiner Forgejo-Projekte zugreifen.

Was brauche ich alles?

- Projekt-URL: gitea@gitea.heller.cool:ich/mein-projekt.git
- Branchname: main
- Dateiname: /build.gradle

Abfragekommando und Ausgaben:

```
$ URL=gitea@gitea.heller.cool:ich/mein-projekt.git
$ BRANCH=main
$ FILE=build.gradle

$ git archive --remote="${URL}" --format=tar ${BRANCH}: "${FILE}"|tar -Oxf -
buildscript {
    repositories {
        mavenLocal()
...
```

Fehlermeldung bei falschem Dateinamen:

```
$ URL=gitea@gitea.heller.cool:ich/mein-projekt.git
$ BRANCH=main
$ FILE=uli-war-da-und-ist-jetzt-weg.txt

$ git archive --remote="${URL}" --format=tar ${BRANCH}: "${FILE}"|tar -Oxf -
fatal: sent error to the client: git upload-archive: archiver died with error
Forgejo: Failed to execute git command
remote: fatal: pathspec 'uli-war-da-und-ist-jetzt-weg.txt' did not match any files
remote: git upload-archive: archiver died with error
tar: Das sieht nicht wie ein „tar“-Archiv aus.
tar: Beende mit Fehlerstatus aufgrund vorheriger Fehler
```

Inhalt mehrerer gleichartig benannter Dateien
---------------------------------------------

```
$ URL=gitea@gitea.heller.cool:ich/mein-projekt.git
$ BRANCH=main
$ FILES="**build.gradle"

$ git archive --remote="${URL}" --format=tar ${BRANCH}: "${FILES}"|tar -Oxf -
# Alle build.gradle-Dateien werden angezeigt

$ git archive --remote="${URL}" --format=tar ${BRANCH}: "${FILES}" >mein-projekt-build-gradle.tar
# TAR mit allen build.gradle-Dateien wird abgelegt
```

Inhalt mehrerer Dateien
-----------------------

```
$ URL=gitea@gitea.heller.cool:ich/mein-projekt.git
$ BRANCH=main

$ git archive --remote="${URL}" --format=tar ${BRANCH}: "**build.gradle" "**.java" >mein-projekt-bgj.tar
# TAR mit allen build.gradle- und java-Dateien wird abgelegt
```

Fehlermeldung bei Github
------------------------

Mit einer SSH-Url:

```
$ URL=git@github.com:uli-heller/mein-projekt.git
$ BRANCH=main

$ git archive --remote="${URL}" --format=tar ${BRANCH}: "**.md" >mein-projekt-md.tar
Invalid command: git-upload-archive 'uli-heller/mein-projekt.git'
  You appear to be using ssh to clone a git:// URL.
  Make sure your core.gitProxy config option and the
  GIT_PROXY_COMMAND environment variable are NOT set.
Schwerwiegend: Die Gegenseite hat unerwartet abgebrochen.
tar: Das sieht nicht wie ein „tar“-Archiv aus.
tar: Beende mit Fehlerstatus aufgrund vorheriger Fehler
```

Mit einer HTTPS-URL:

```
$ URL=git@github.com:uli-heller/mein-projekt.git
$ BRANCH=main

$ git archive --remote="${URL}" --format=tar ${BRANCH}: "**.md" >mein-projekt-md.tar
Fehler: RPC fehlgeschlagen; HTTP 403 curl 22 The requested URL returned error: 403
Schwerwiegend: git archive: ACK/NAK erwartet, Flush-Paket bekommen
tar: Das sieht nicht wie ein „tar“-Archiv aus.
tar: Beende mit Fehlerstatus aufgrund vorheriger Fehler
```

Gemäß [StackOverflow - git export from github remote repository](https://stackoverflow.com/questions/9609835/git-export-from-github-remote-repository)
wird `git archive` von Github nicht unterstützt.

Eine Abhilfe, die ähnlich wie `git archive` funktioniert, ist dieses Skript:

```
#!/bin/sh
URL="$1"
BRANCH="$2"
shift
shift

mkdir /tmp/new-folder || exit 1
(
  {
    cd /tmp/new-folder
    git init -b main.
    git remote add origin "${URL}"
    git config core.sparseCheckout true
    git config remote.origin.tagopt --no-tags
    while [ $# -gt 0 ]; do
      echo "${1}" >>.git/info/sparse-checkout
      shift
    done
    git pull --depth=1 --no-tags origin "${BRANCH}"
    rm -rf .git
  } 1>&2
  tar -cf - .
)
rm -rf /tmp/new-folder
```

Am besten speichern unter "mein-git-archive.sh"
und dann aufrufen mit

```
./mein-git-archive.sh $URL $BRANCH datei1 datei2 >git.tar
```

Unschön: Das Skript führt zwar einen sparsamen Checkout durch
(es werden also nur die gewünschten Dateien ausgecheckt), der Clone
enthält aber alle Dateien! Es gibt zwar auch "partial clones",
die bringen für meinen Anwendungsfall aber nix!

Links
-----

- [StackOverflow - git export from github remote repository](https://stackoverflow.com/questions/9609835/git-export-from-github-remote-repository)

Historie
--------

- 2024-12-21: Erste Version

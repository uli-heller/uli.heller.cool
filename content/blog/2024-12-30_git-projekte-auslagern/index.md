---
date: 2024-12-30
draft: false
title: Git: Projekte auslagern
categories:
 - Git
tags:
 - git
---

<!--Git: Projekte auslagern-->
<!--=======================-->

Im Git-Projekt zu dieser Webseite habe
ich einige sehr kleine Java-Projekte
als Code-Beispiele gespeichert. Leider
zeigt sich, dass deren Verlinkung nicht gut funktioniert.

Nun möchte ich diese Projekte auslagern in eigene
Github-Projekte. Links darauf funktionieren sicher.

<!--more-->

Liste der Java-Projekte
-----------------------

- static/gradle-artifactory ... erledigt
- static/gradle-maven-publish
- static/gradle-bom
- static/gradle-bom-use
- static/springboot-hello-world
- static/my-gradle-project ... erledigt
- static/gradle-proxy

Neue Heimat
-----------

Ich mache es mit einfach und verwende dieses feste Schema:

- Schema: static/(projektname) -> uli-heller/java-example-(projektname)
- Beispiel: static/my-gradle-project -> uli-heller/java-example-my-gradle-project".

Grob-Ablauf für jedes Projekt
-----------------------------

- Github: Neues Repo anlegen
- Github-URL speichern
- Git-Projekt der Webseite kopieren
- Kopie aufbereiten
- Abspeichern im neuen Repo
- Aufräumen der Kopie
- Anpassen der Verweise
- Löschen des Java-Projektes

Ablauf für "my-gradle-project"
------------------------------

- Github: Neues Repo anlegen
  - Owner: uli-heller
  - Repository name: java-example-my-gradle-project
  - Public
- Github-URL speichern: git@github.com:uli-heller/java-example-my-gradle-project.git
- Git-Projekt der Webseite kopieren
  ```
  rm -rf /tmp/git-separation
  mkdir /tmp/git-separation
  cp -a .../uli.heller.cool/.  /tmp/git-separation/.
  ```
- Kopie aufbereiten
  ```
  (
    cd /tmp/git-separation
    rm -rf .git/filter-repo
    rm -rf .git/modules/*
    git checkout .
    git clean -fdx
    git status
    git filter-repo --force --path static/my-gradle-project/ --path-rename static/my-gradle-project/:
    git clean -fdx
    git status
  )
  ```
- Abspeichern im neuen Repo
  ```
  (
    cd /tmp/git-separation
    git remote add new git@github.com:uli-heller/java-example-my-gradle-project.git
    git push new main:main
  )
  ```
- Aufräumen der Kopie
  ```
  rm -rf /tmp/git-separation
  ```
- Anpassen der Verweise
  ```
  for f in $(find . -type f -name "*.md"|xargs grep -l my-gradle-project); do
    sed -i -e 's,\[\([^]]*\)\](/my-gradle-project),[github:java-example-\1](https://github.com/uli-heller/java-example-my-gradle-project),' "${f}"
  done
  git status
  git diff
  git commit -m "Java-Beispiel 'my-gradle-project' ausgelagert - Verweise" .
  ```
- Löschen des Java-Projektes
  ```
  git rm -r static/my-gradle-project
  git commit -m "Java-Beispiel 'my-gradle-project' ausgelagert - Löschen" static
  ```

Ablauf mit Skript
-----------------

- Github: Neues Repo anlegen
  - Owner: uli-heller
  - Repository name: java-example-gradle-artifactory
  - Public
- Github-URL speichern: git@github.com:uli-heller/java-example-gradle-artifactory.git

Skript: [auslagern.sh](auslagern.sh)

```
NAME=gradle-artifactory
GITHUB_URL="git@github.com:uli-heller/java-example-${NAME}.git"
ULI_HELLER_COOL_PATH=.../uli.heller.cool

rm -rf /tmp/git-separation
mkdir /tmp/git-separation
cp -a "${ULI_HELLER_COOL_PATH}/."  /tmp/git-separation/. || exit 1
(
    cd /tmp/git-separation || exit 1
    rm -rf .git/filter-repo
    rm -rf .git/modules/*
    git checkout .
    git clean -fdx
    git status
    git filter-repo --force --path "static/${NAME}/" --path-rename "static/${NAME}/:"
    git clean -fdx
    git status
#)
#(
#    cd /tmp/git-separation
    git remote add new "${GITHUB_URL}"
    git push new main:main
)
rm -rf /tmp/git-separation
(
  cd "${ULI_HELLER_COOL_PATH}" || exit 1

  for f in $(find . -type f -name "*.md"|xargs grep -l "${NAME}"); do
    sed -i -e "s,\[\([^]]*\)\](/${NAME}),[github:java-example-\1](${GITHUB_URL})," "${f}"
  done
  git status
  git diff
  git commit -m "Java-Beispiel '${NAME}' ausgelagert - Verweise" .
  git rm -r "static/${NAME}"
  git commit -m "Java-Beispiel '${NAME}' ausgelagert - Löschen" static
)
```

Historie
--------

- 2024-12-30: Erste Version
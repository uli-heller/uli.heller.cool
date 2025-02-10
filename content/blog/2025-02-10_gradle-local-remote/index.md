+++
date = '2025-02-10'
draft = false
title = 'Gradle: Lokales oder entferntes PackageRepository'
categories = [ 'Gradle' ]
tags = [ 'gradle' ]
+++

<!--
Gradle: Lokales oder entferntes PackageRepository
=================================================
-->

Bei Gradle-Projekten kann ich Maven-Package-Repositories
hinterlegen mit URLs wie "file://" - das sind dann lokal
vorhandene Repositories - oder "https://" - das sind entferne
Repositories. Leider verhalten sie sich leicht unterschiedlich!

<!--more-->

Vorbereitungen
--------------

- Beispielprojekt clonen: `git clone git@github.com:uli-heller/java-example-gradle-local-remote.git`
- Verzeichnis wechseln: `cd java-example-gradle-local-remote`

Test mit lokalem Repository
---------------------------

- Sicherstellen: Es ist eine "file://"-URL hinterlegt für das Maven-Package-Repository:
  ```sh
  $ grep maven-repository build.gradle|grep -v "^\s*//"
          url("file://${projectDir}/maven-repository")
  ```
- Maven-Package-Repository füllen:
  ```sh
  rm -rf maven-repository
  ./create-maven-repository.sh
  ```
- Projekt bauen: `./gradlew --refresh-dependencies build`
- Ergebnis untersuchen:
  - `unzip -v build/libs/java-example-gradle-local-remote-0.0.2.jar|grep hello`
  - hello-world-0.9.1-plain.jar
- Zusätzliche neue Version anlegen: `./create-version.sh hello-world 0.9.2`
- Projekt nochmal bauen ohne "--refresh-dependencies": `./gradlew build`
- Ergebnis untersuchen:
  - `unzip -v build/libs/java-example-gradle-local-remote-0.0.2.jar|grep hello`
  - hello-world-0.9.2-plain.jar
- Die zusätzlich erzeugte neue Version wird verwendet!

Test mit entferntem Repository
------------------------------

- Webserver starten: `jwebserver --port 8888 &`
- Ändern der URL für das Maven-Package-Repository:
  - Von: `url("file://${projectDir}/maven-repository")`
  - Nach: `url("http://localhost:8888/maven-repository")`
- Maven-Package-Repository füllen:
  ```sh
  rm -rf maven-repository
  ./create-maven-repository.sh
  ```
- Projekt bauen: `./gradlew --refresh-dependencies build`
- Ergebnis untersuchen:
  - `unzip -v build/libs/java-example-gradle-local-remote-0.0.2.jar|grep hello`
  - hello-world-0.9.1-plain.jar
- Zusätzliche neue Version anlegen: `./create-version.sh hello-world 0.9.2`
- Projekt nochmal bauen ohne "--refresh-dependencies": `./gradlew build`
- Ergebnis untersuchen:
  - `unzip -v build/libs/java-example-gradle-local-remote-0.0.2.jar|grep hello`
  - hello-world-0.9.1-plain.jar
- Es wird weiterhin die ursprünglichw Version verwendet!

Erkenntnis
----------

Bei lokalem Maven-Package-Repository
werden dynamische Abhängigkeiten bei jedem
Build-Lauf akualisiert. Bei entfernten werden
sie nur einmal pro Tag aktualisiert!

Versionen
---------

Getestet mit

- Gradle-8.11.1 und Java-21

Links
-----

- [Github:java-example-gradle-local-remote](https://github.com/uli-heller/java-example-gradle-local-remote)

Historie
--------

- 2025-02-10: Erste Version

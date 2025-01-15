+++
date = '2025-01-22'
draft = false
title = 'Gradle: Verwendung von useVersion'
categories = [ 'Gradle' ]
tags = [ 'gradle' ]
+++

<!--
Gradle: Verwendung von useVersion
=================================
-->

Ich möchte, dass alle Pakete der Gruppe
"cool.heller.uli" bei einem Build mit gleicher
Versionsnummer angezogen werden. Da ich nicht
weiß, welche Pakete künftig zur Gruppe gehören,
kann ich sie nicht einzeln auflisten und
Gradle-Constraints für die definieren

<!--more-->

Beispielprojekt und build.gradle
--------------------------------

[Github:java-example-gradle-useversion](https://github.com/uli-heller/java-example-gradle-useversion)

Ablauf ohne Dependency-Locking
------------------------------

```
cd java-example-gradle-useversion
./create-maven-repository.sh 0 2
./create-maven-repository.sh 1 2
./gradlew build                                     # --> BUILD SUCCESSFUL
unzip -v build/libs/java-*-SNAPSHOT.jar |grep hello # --> 1.2.0
unzip -v build/libs/java-*-SNAPSHOT.jar |grep bye   # --> 1.2.0
```

Ohne Dependency-Locking klappt das Bauen.
Nun noch mit aktualisiertem MavenRepository:

```
./create-maven-repository.sh 1 3
./gradlew build                                     # --> BUILD SUCCESSFUL
unzip -v build/libs/java-*-SNAPSHOT.jar |grep hello # --> 1.3.0
unzip -v build/libs/java-*-SNAPSHOT.jar |grep bye   # --> 1.3.0
```

Wie erwartet wird die aktualisierte Version 1.3.0
verwenden!

Ablauf mit Dependency-Locking
------------------------------


Versionen
---------

Getestet mit

- Gradle-8.11.1

Links
-----

- [Github:java-example-gradle-useversion](https://github.com/uli-heller/java-example-gradle-useversion)
- [GradleForums - Dependency Locking and useVersion](https://discuss.gradle.org/t/dependency-locking-and-useversion/50256)

Historie
--------

- 2025-01-22: Erste Version

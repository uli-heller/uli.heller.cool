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

```
cd java-example-gradle-useversion
./create-maven-repository.sh 0 2
./create-maven-repository.sh 1 2
./gradlew dependencies --write-locks
./gradlew build                                     # --> BUILD SUCCESSFUL
unzip -v build/libs/java-*-SNAPSHOT.jar |grep hello # --> 1.2.0
unzip -v build/libs/java-*-SNAPSHOT.jar |grep bye   # --> 1.2.0
```

Auch mit Dependency-Locking klappt das Bauen,
sofern nach dem Erzeugen der Lockfiles
keine Aktualisierung am Maven-Repository erfolgt.

Nun noch mit aktualisiertem MavenRepository:

```
./create-maven-repository.sh 1 3
./gradlew build                                     # --> BUILD FAILED
```

Meine Erwartung wäre, dass das Bauen klappt und die Versionen
1.2.0 verwendet werden. Leider klappt das Bauen nicht
und es erscheint diese Fehlermeldung:

```
java-example-gradle-useversion$ ./gradlew build
> Task :compileJava FAILED

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':compileJava'.
> Could not resolve all files for configuration ':compileClasspath'.
   > Did not resolve 'cool.heller.uli:bye-moon:1.2.0' which has been forced / substituted to a different version: '1.3.0'
   > Did not resolve 'cool.heller.uli:hello-world:1.2.0' which has been forced / substituted to a different version: '1.3.0'

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 576ms
1 actionable task: 1 executed
```

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

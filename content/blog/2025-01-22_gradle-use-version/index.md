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

Mit und ohne "useVersion"
-------------------------

Ich habe eine neue Abhängigkeit mit Namen "maybe-mars"
hinzugefügt. Diese verwendet auch die dynamische Version "1.+",
allerdings ohne "useVersion()".

Damit wie zuvor:

```
rm -rf maven-repository
./create-maven-repository.sh 0 2
./create-maven-repository.sh 1 2
./gradlew dependencies --write-locks             # --> BUILD SUCCESSFUL, *lockfile created
./create-maven-repository.sh 1 3
./gradlew build                                  # --> BUILD FAILED
```

In der Fehlermeldung taucht "maybe-mars" nicht auf:

```
java-example-gradle-useversion$ ./gradlew build
> Task :compileJava FAILED

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':compileJava'.
> Could not resolve all files for configuration ':compileClasspath'.
   > Did not resolve 'cool.heller.uli:hello-world:1.2.0' which has been forced / substituted to a different version: '1.3.0'
   > Did not resolve 'cool.heller.uli:bye-moon:1.2.0' which has been forced / substituted to a different version: '1.3.0'

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 1s
```

In den Dateien "*lockfile" sehen alle drei Abhängigkeiten ähnlich aus:

```
java-example-gradle-useversion$ grep heller *lockfile
gradle.lockfile:cool.heller.uli:bye-moon:1.2.0=compileClasspath,productionRuntimeClasspath,runtimeClasspath,testCompileClasspath,testRuntimeClasspath
gradle.lockfile:cool.heller.uli:hello-world:1.2.0=compileClasspath,productionRuntimeClasspath,runtimeClasspath,testCompileClasspath,testRuntimeClasspath
gradle.lockfile:cool.heller:maybe-mars:1.2.0=compileClasspath,productionRuntimeClasspath,runtimeClasspath,testCompileClasspath,testRuntimeClasspath
```

Also: Das Problem liegt an "useVersion()"!

Abstimmung im Gradle-Forum
--------------------------

Meine Nachfrage im [GradleForum - Dependency Locking and useVersion](https://discuss.gradle.org/t/dependency-locking-and-useversion/50256)
liefert als Erkenntnis, dass man "useVersion()" besser nicht verwendet!

Vielen Dank an Björn Kautler!

Nachtrag: POM und Module
------------------------

Bei meinem Kundenteam gibt es die Hypothese, dass `useVersion`
keine Auswirkung auf die Module-Datei beim Publishing hat.
Dort steht wohl immer diejenige Version drin, die in der Datei
"build.gradle" vorgegeben wird.

Ich habe das nachgetestet mit [Github:java-example-gradle-useversion](https://github.com/uli-heller/java-example-gradle-useversion), Entwicklerzweig "module-and-pom".

- Auschecken: `git checkout "module-and-pom"`
- Sichten: Was steht in "build.gradle"?
  - cool.heller.uli:hello-world:0.9.0
  - cool.heller.uli:bye-moon (leer, keine Version)
  - cool.heller:maybe-mars:${coolHellerUliVersion}
- Sichten: Was steht in "cool-heller-uli.gradle"?
  - coolHellerUliVersion='0.1.0'
- Maven-Repo erzeugen:
  - `./create-maven-repository.sh 0 2`
  - `./create-maven-repository.sh 1 2`
- Sichten: Welche Version wird verwendet?
  - `./gradlew dependencies|grep cool`
  - Erkenntnis: (Fast) Immer 0.1.0, bei "implementation" sind die
    Versionen aus "build.gradle" drin
- Veröffentlichen: `./gradlew publish`
- Sichten POM: `less build/local-repository/com/example/java-example-gradle-useversion/0.0.2/java-example-gradle-useversion-0.0.2.pom`
  - cool.heller.uli:hello-world:0.9.0
  - cool.heller.uli:bye-moon (leer, keine Version)
  - cool.heller:maybe-mars:0.1.0
- Sichten Module: `less build/local-repository/com/example/java-example-gradle-useversion/0.0.2/java-example-gradle-useversion-0.0.2.module`
  - cool.heller.uli:hello-world:0.9.0
  - cool.heller.uli:bye-moon (leer, keine Version)
  - cool.heller:maybe-mars:0.1.0

Also: Sowohl in der POM-Datei, als auch in der Modules-Datei
tauchen die mit "useVersion" überschriebenen Versionen nicht auf!

Versionen
---------

Getestet mit

- Gradle-8.11.1

Links
-----

- [Github:java-example-gradle-useversion](https://github.com/uli-heller/java-example-gradle-useversion)
- [GradleForum - Dependency Locking and useVersion](https://discuss.gradle.org/t/dependency-locking-and-useversion/50256)

Historie
--------

- 2025-01-22: Erste Version

+++
date = '2025-01-12'
draft = false
title = 'Gradle: Dependency-Locking und Probleme'
categories = [ 'Gradle' ]
tags = [ 'gradle' ]
+++

<!--
Gradle: Dependency-Locking und Probleme
=======================================
-->

Hier beschreibe ich, wie ich DependencyLocking
in meinen Gradle-Projekten aktiviere und
ein Problem, welches dabei manchmal auftritt.

<!--more-->

Beispielprojekt
---------------

Mein Beispielprojekt liegt hier: [github:java-example-gradle-dependency-locking](https://github.com/uli-heller/java-example-gradle-dependency-locking).

Dependency-Locking aktivieren
-----------------------------

```diff
--- build.gradle ---
index 4552994..aedb683 100644
@@ -9,6 +9,10 @@ group = 'com.example'
 version = '0.0.1-SNAPSHOT'
 sourceCompatibility = '17'
 
+dependencyLocking {
+    lockAllConfigurations()
+}
+
 repositories {
        mavenCentral()
 }
```

Versionen festschreiben
-----------------------

```
$ ./gradlew dependencies --write-locks
To honour the JVM settings for this build a single-use Daemon process will be forked. For more on this, please refer to https://docs.gradle.org/8.12/userguide/gradle_daemon.html#sec:disabling_the_daemon in the Gradle documentation.
Daemon will be stopped at the end of the build 

> Task :dependencies

------------------------------------------------------------
Root project 'java-example-gradle-dependency-locking'
------------------------------------------------------------
...
You can use '--warning-mode all' to show the individual deprecation warnings and determine if they come from your own scripts or plugins.

For more on this, please refer to https://docs.gradle.org/8.12/userguide/command_line_interface.html#sec:command_line_warnings in the Gradle documentation.

BUILD SUCCESSFUL in 5s
1 actionable task: 1 executed
```

Es wird die Datei "gradle.lockfile" erzeugt.
Typischerweise speichert man die im Git-Repo
und erhält damit reproduzierbare Programmversionen.

Es werden immer diejenigen Versionen verwendet,
die im "gradle.lockfile" drinstehen!

Bauen mit festgeschriebenen Versionen
-------------------------------------

Das Bauen funktioniert wie gewohnt:

```
$ ./gradlew build
Daemon will be stopped at the end of the build 
> Task :compileJava
> Task :processResources NO-SOURCE
> Task :classes
...
BUILD SUCCESSFUL in 9s
4 actionable tasks: 4 executed
```

Test mit verschiedenen Versionen
--------------------------------

Zunächst passe ich in "build.gradle" diese Zeile an:

```diff
--- a/build.gradle
+++ b/build.gradle
@@ -1,6 +1,6 @@
 plugins {
        id 'java'
-       id 'org.springframework.boot' version '3.4.1'
+       id 'org.springframework.boot' version "${springBootVersion}"
 }
```

Dann führe ich jeweils aus:

```
$ ./gradlew dependencies --write-locks -PspringBootVersion=3.4.1
$ mv gradle.lockfile gradle.lockfile-3.4.1
```

Hier die Ergebnisse:

Version | Datei
--------|-------
3.4.1   | [gradle.lockfile-3.4.1](https://github.com/uli-heller/-java-example-gradle-dependency-locking/blob/main/gradle.lockfile-3.4.1)
3.2.1   | [gradle.lockfile-3.2.1](https://github.com/uli-heller/-java-example-gradle-dependency-locking/blob/main/gradle.lockfile-3.2.1)
3.+     | [gradle.lockfile-3.+](https://github.com/uli-heller/-java-example-gradle-dependency-locking/blob/main/gradle.lockfile-3.%2B)

Es fällt auf, dass die Variante "3.+" identisch zur "3.4.1" ist.
Also gehe ich davon aus, dass

- ein Eintrag in der "build.gradle" mit "3.+" zum Zeitpunkt, als 3.2.1 aktiv war, die Datei
 [gradle.lockfile-3.2.1](https://github.com/uli-heller/-java-example-gradle-dependency-locking/blob/main/gradle.lockfile-3.2.1)
 erzeugt hätte
- ein weiterer Build-Versuch mit der Lockdatei von 3.2.1 zum Zeitpunkt mit aktiver 3.4.1-Version funktionieren sollte
  (zumindest verstehe ich den Sinn der Lockdatei so: Ich schreibe die Versionen fest und kann später noch damit bauen)

Also:

```
$ cp gradle.lockfile-3.2.1 gradle.lockfile
$ sed -i -e "s/3.4.1/3.+/" build.gradle
$ ./gradlew build
...
FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':compileJava'.
> Could not resolve all files for configuration ':compileClasspath'.
   > Did not resolve 'org.springframework:spring-beans:6.1.2' which has been forced / substituted to a different version: '6.2.1'
   > Did not resolve 'io.micrometer:micrometer-observation:1.12.1' which has been forced / substituted to a different version: '1.14.2'
   > Did not resolve 'org.springframework:spring-webmvc:6.1.2' which has been forced / substituted to a different version: '6.2.1'
   > Did not resolve 'org.springframework.boot:spring-boot:3.2.1' which has been forced / substituted to a different version: '3.4.1'
   > Did not resolve 'com.fasterxml.jackson.core:jackson-core:2.15.3' which has been forced / substituted to a different version: '2.18.2'
...
```

Klappt also leider überhaupt nicht. Da sind noch Forschungsarbeiten
notwendig!

Hier die Gradle-Doku: [Running a build with lock state present](https://docs.gradle.org/current/userguide/dependency_locking.html#sec:run-build-lock-state)

----
...
The complete validation is as follows:

- Existing entries in the lock state must be matched in the build

  - A version mismatch or missing resolved module causes a build failure

- Resolution result must not contain extra dependencies compared to the lock state
----

Also:

- Ich hatte ein völlig falsches Verständnis vom DepencendyLocking
- Ich dachte, die gelockten Versionen werden für den Build verwendet - das ist falsch
- Die gelockten Versionen werden mit den gefundenen Versionen verglichen und bei Abweichungen wird abgebrochen - das entspricht genau der Beobachtung

Test mit LockState.LENIENT
--------------------------

```diff
diff --git a/build.gradle b/build.gradle
index c40fb59..b689c75 100644
--- a/build.gradle
+++ b/build.gradle
@@ -10,6 +10,7 @@ version = '0.0.1-SNAPSHOT'
 sourceCompatibility = '17'
 
 dependencyLocking {
+    lockMode = LockMode.LENIENT
     lockAllConfigurations()
 }
```

Damit gibt es zwar keine Fehlermeldung mehr, jedoch
wird trotz 3.2.1-er-Lock die Version 3.4.1 eingebaut.

Versionen
---------

Getestet mit

- Gradle-8.12

Links
-----

- [github:java-example-gradle-dependency-locking](https://github.com/uli-heller/java-example-gradle-dependency-locking)
- [Gradle-Doku: Running a build with lock state present](https://docs.gradle.org/current/userguide/dependency_locking.html#sec:run-build-lock-state)
- [Gradle forum: Subproject downloads dependencies higher version than in lockfiles](https://discuss.gradle.org/t/subproject-downloads-dependencies-higher-version-than-in-lockfiles/38308)

Historie
--------

- 2025-01-12: Erste Version

+++
date = '2025-01-20'
draft = false
title = 'Gradle: Anstehende Kompatibilitätsänderungen bei Version 9.0'
categories = [ 'Gradle' ]
tags = [ 'gradle' ]
+++

<!--
Gradle: Anstehende Kompatibilitätsänderungen bei Version 9.0
============================================================
-->

Hier beschreibe ich meine Korrektur der Warnmeldung
"Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0."
Klar: Ich korrigiere nur die Warnungen, die bei mir auftreten.

<!--more-->

Beispielprojekt
---------------

Mein Beispielprojekt liegt hier: [github:java-example-gradle-plugin-use](https://github.com/uli-heller/java-example-gradle-plugin-use).
Das Beispielprojekt möchte ich "eigentlich" verwenden, um die Einbindung von Gradle-Plugins
zu beschreiben. In der Vorbereitung bin ich wieder über die Warnung gestolpert
und habe mich nun entschlossen, diese vorab zu korrigieren!

Warnungen beim Build
--------------------

```bash
java-example-gradle-plugin-use$ ./gradlew build
To honour the JVM settings for this build a single-use Daemon process will be forked. For more on this, please refer to https://docs.gradle.org/8.12/userguide/gradle_daemon.html#sec:disabling_the_daemon in the Gradle documentation.
Daemon will be stopped at the end of the build 
> Task :compileJava
> Task :processResources NO-SOURCE
> Task :classes
> Task :resolveMainClassName
> Task :bootJar
> Task :jar
> Task :assemble
> Task :compileTestJava NO-SOURCE
> Task :processTestResources NO-SOURCE
> Task :testClasses UP-TO-DATE
> Task :test NO-SOURCE
> Task :check UP-TO-DATE
> Task :build

[Incubating] Problems report is available at: file:///.../java-example-gradle-plugin-use/build/reports/problems/problems-report.html

Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0.

You can use '--warning-mode all' to show the individual deprecation warnings and determine if they come from your own scripts or plugins.

For more on this, please refer to https://docs.gradle.org/8.12/userguide/command_line_interface.html#sec:command_line_warnings in the Gradle documentation.

BUILD SUCCESSFUL in 7s
4 actionable tasks: 4 executed
```

Sichtung von "problems-report.html"
-----------------------------------

Ich öffne im Browser den Link zu "problems-report.html" - file:///.../java-example-gradle-plugin-use/build/reports/problems/problems-report.html:

```
build file '/home/uli/git/github/uli-heller/java-example-gradle-plugin-use/build.gradle'`

        - [warn]  The org.gradle.api.plugins.JavaPluginConvention type has been deprecated.`:10`
        This is scheduled to be removed in Gradle 9.0.
        The org.gradle.api.plugins.JavaPluginConvention type has been deprecated.
```

Mit "Google" lande ich hier: [StackOverflow - Project.getConvention() method has been deprecated](https://stackoverflow.com/questions/76777878/project-getconvention-method-has-been-deprecated)
und dort die Antwort von [Taoufik Laaroussi](https://stackoverflow.com/a/79346365/959232).

Korrekturversuch
----------------

```diff
diff --git a/build.gradle b/build.gradle
index 60222cc..0dcbfb6 100644
--- a/build.gradle
+++ b/build.gradle
@@ -8,7 +8,9 @@ apply plugin: 'io.spring.dependency-management'
 group = 'cool.heller.uli'
 version = '0.0.1-SNAPSHOT'
 
-sourceCompatibility = '17'
+java {
+  sourceCompatibility = '17'
+}
 
 repositories {
   mavenCentral()
```

Schlusstest
-----------

```bash
java-example-gradle-plugin-use$ ./gradlew build
To honour the JVM settings for this build a single-use Daemon process will be forked. For more on this, please refer to https://docs.gradle.org/8.12/userguide/gradle_daemon.html#sec:disabling_the_daemon in the Gradle documentation.
Daemon will be stopped at the end of the build 
> Task :compileJava UP-TO-DATE
> Task :processResources NO-SOURCE
> Task :classes UP-TO-DATE
> Task :resolveMainClassName UP-TO-DATE
> Task :bootJar UP-TO-DATE
> Task :jar UP-TO-DATE
> Task :assemble UP-TO-DATE
> Task :compileTestJava NO-SOURCE
> Task :processTestResources NO-SOURCE
> Task :testClasses UP-TO-DATE
> Task :test NO-SOURCE
> Task :check UP-TO-DATE
> Task :build UP-TO-DATE

BUILD SUCCESSFUL in 6s
4 actionable tasks: 4 up-to-date
```

Die Warnung ist weg, Problem gelöst!

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

- 2025-01-20: Erste Version

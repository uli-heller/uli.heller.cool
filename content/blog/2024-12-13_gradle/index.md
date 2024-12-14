+++
date = '2024-12-13'
draft = false
title = 'Gradle: Starten eines Java-Projektes'
categories = [ 'Gradle' ]
tags = [ 'gradle', 'java' ]
+++

<!--
Gradle: Starten eines Java-Projektes
====================================
-->

Hier zeige ich, wie ich mit einem Java-Projekt "loslege".
Klar: Man kann auch SpringInitializer oder ähnliches verwenden.
Ich versuche es ohne!

<!--more-->

Leeres Verzeichnis anlegen
--------------------------

```
mkdir my-gradle-project
cd my-gradle-projec
touch settings.gradle
gradle wrapper
```

Gradle Wrapper aktualisieren
----------------------------

```
./gradlew wrapper --gradle-version latest
./gradlew wrapper --gradle-version latest
```

Hinweis: Die doppelte Ausführung des gleichen Kommandos ist Absicht!
Die erste Ausführung ersetzt nur die Versionsnummer in einer Konfigurationsdatei,
die zweite lädt die neuen Komponenten herunter!

Java-Klasse
-----------

```
mkdir -p src/main/java
cat >src/main/java/Main.java <<EOF
class Main {
    public static void main(String[] args) {
        System.out.println("Hello, World!"); 
    }
}
EOF
```

Bauplan - build.gradle
----------------------

```
cat >build.gradle <<'EOF'
plugins {
  id("maven-publish")
  id("java")
}

group = 'cool.heller'
version = '1.0-SNAPSHOT'

publishing {
    repositories {
        // Local repository which we can first publish in it to check artifacts
        maven {
            name = "LocalTestRepo"
            url = uri("file://${buildDir}/local-repository")
        }
    }
    publications {
        mavenJava(MavenPublication) {
            from components.java
        }
    }
}
EOF
```

Bauen und veröffentlichen
-------------------------

```
./gradlew publish
# Erzeugt ein Artefakt unter "build/local-repository/cool/heller/my-gradle-project/1.0-SNAPSHOT"
```

Links
-----

- [Gradle - Maven Publish Plugin](https://docs.gradle.org/current/userguide/publishing_maven.html)
- [my-gradle-project](/my-gradle-project)

Historie
--------

- 2024-12-14: Hinweis auf Doppelausführung
- 2024-12-13: Erste Version

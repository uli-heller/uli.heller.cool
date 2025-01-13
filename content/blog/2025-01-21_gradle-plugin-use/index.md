+++
date = '2025-01-21'
draft = false
title = 'Gradle: Verwendung von Plugins'
categories = [ 'Gradle' ]
tags = [ 'gradle' ]
+++

<!--
Gradle: Verwendung von Plugins
==============================
-->

Hier beschreibe ich verschiedene Varianten der Einbindung
von Plugins in Gradle. Für die Beschreibung
verwende ich das Plugin ["Nebula Dependency Lock"](https://plugins.gradle.org/plugin/nebula.dependency-lock).
Mittlerweile weiß ich, dass ich dieses spezielle Plugin NICHT verwenden werde.
Es dient nur zur Illustration der Einbinde-Varianten!

<!--more-->

Standard-Einbindung
-------------------

[Locking Dependency Versions in Gradle](https://jkutner.github.io/2017/03/29/locking-gradle-dependencies.html)

build.gradle:

```
plugins {
  id "nebula.dependency-lock" version "2.2.4"
}
```

Dies ist der übliche Weg, ein Plugin einzubinden.
Es muß über "plugins.gradle.org" verfügbar sein.

Ich habe das Plugin in einem Artikel aus 2017 gefunden.
Dementsprechend ist die Versionsnummer veraltet!

Aktuelle Version
----------------

[plugins.gradle.org - nebula.dependency-lock](https://plugins.gradle.org/plugin/nebula.dependency-lock)

build.gradle:

```
plugins {
  id("nebula.dependency-lock") version "12.7.1"
}
```

Ich habe auf "plugins.gradle.org" nachgesehen
und dort die Version 12.7.1 gefunden.

Plugin Hosted On Github - Version 4.+
-------------------------------------

[https://github.com/nebula-plugins/gradle-dependency-lock-plugin - Usage - example](https://github.com/nebula-plugins/gradle-dependency-lock-plugin/wiki/Usage#example)

build.gradle:

```
buildscript {
    repositories {
        mavenLocal()
        jcenter()
    }

    dependencies {
        classpath 'com.netflix.nebula:gradle-dependency-lock-plugin:4.+'
    }
}
apply plugin: 'nebula.dependency-lock'

...
```

Suche auf Github liefert eine weitere Version.
Auf der Wiki-Seite dort findet sich obere Variante.

Plugin Hosted On Github - Latest Version 15.+
---------------------------------------------

[Github - gradle-dependency-lock-plugin](https://github.com/nebula-plugins/gradle-dependency-lock-plugin)

build.gradle:

```
buildscript {
    repositories {
        mavenLocal()
        jcenter()
    }

    dependencies {
        classpath 'com.netflix.nebula:gradle-dependency-lock-plugin:15.+'
    }
}
apply plugin: 'com.netflix.nebula.dependency-lock'
...
```

Im Github-Repo selbst finde ich Version v15.1.1.
Mi etwas Rumprobieren habe ich vorstehende
Variante entdeckt und damit die neueste Version vom Dezember 2024
verwendet.

Server-Kommunikation
--------------------

- 2.2.7
  - plugins.gradle.org
  - plugins-artifacts.gradle.org
- 12.7.1
  - repo.maven.apache.org
- 4.+
  - jcenter.bintray.com
  - repo1.maven.org
- 15.+
  - keine zusätzliche Server-Kommunikation

Versionen
---------

Getestet mit

- Gradle-8.12

Links
-----

- ["Nebula Dependency Lock"](https://plugins.gradle.org/plugin/nebula.dependency-lock)
- [plugins.gradle.org - nebula.dependency-lock](https://plugins.gradle.org/plugin/nebula.dependency-lock)
- [https://github.com/nebula-plugins/gradle-dependency-lock-plugin - Usage - example](https://github.com/nebula-plugins/gradle-dependency-lock-plugin/wiki/Usage#example)
- [Github - gradle-dependency-lock-plugin](https://github.com/nebula-plugins/gradle-dependency-lock-plugin)
- [github:java-example-gradle-plugin-use](https://github.com/uli-heller/java-example-gradle-plugin-use)

Historie
--------

- 2025-01-21: Erste Version

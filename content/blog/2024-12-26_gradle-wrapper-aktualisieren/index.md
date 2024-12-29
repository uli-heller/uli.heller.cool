+++
date = '2024-12-26'
draft = false
title = 'Gradle: Wrapper aktualisieren'
categories = [ 'Gradle' ]
tags = [ 'gradle' ]
+++

<!--
Gradle: Wrapper aktualisieren
=============================
-->

Alle paar Monate erscheint eine neue Version
von Gradle. Die muß man dann in seinen Java-Projekten
aktualisieren. Hier zeige ich den Ablauf!

<!--more-->

Beispielprojekt
---------------

Mein Beispielprojekt liegt hier: [github:java-example-my-gradle-project](https://github.com/uli-heller/java-example-my-gradle-project).

Aktualisieren
-------------

```
./gradlew --version
  # 8.11.1

./gradlew wrapper --gradle-version latest
  # ... aktualisiert gradle/wrapper/gradle-wrapper.properties
./gradlew wrapper --gradle-version latest
  # ... lädt die neue Version herunter
  #     und aktualisiert ggf. die Wrapper-Skripts, -Jars, ...

./gradlew --version
  # 8.12
```

Versionen
---------

Getestet mit

- Gradle-8.11.1
- Gradle-8.12

Links
-----

- [github:java-example-my-gradle-project](https://github.com/uli-heller/java-example-my-gradle-project)

Historie
--------

- 2024-12-26: Erste Version

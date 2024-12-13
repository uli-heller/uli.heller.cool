+++
date = '2024-12-15'
draft = false
title = 'Gradle: "Einfache" Konsolenausgabe'
categories = [ 'Gradle' ]
tags = [ 'gradle', 'java', 'publish' ]
+++

<!--
Gradle: "Einfache" Konsolenausgabe
==================================
-->

Ich hasse die optimierte Konsolenausgabe in neueren
Versionen von Gradle. Hier beschreibe ich, wie
ich zur älteren einfacheren Konsolenausgabe zurückkomme.

<!--more-->

Neue Konsolenausgabe
--------------------

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site/static/gradle-maven-publish$ ./gradlew publish

BUILD SUCCESSFUL in 531ms
5 actionable tasks: 5 executed
```

Was stört mich hieran? Ich kann nicht erkennen, was
alles erledigt wurde!

Alte einfache Konsolenausgabe
-----------------------------

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site/static/gradle-maven-publish$ ./gradlew -Dorg.gradle.console=plain publish
> Task :compileJava
> Task :processResources NO-SOURCE
> Task :classes
> Task :jar
> Task :generateMetadataFileForMavenJavaPublication
> Task :generatePomFileForMavenJavaPublication
> Task :publishMavenJavaPublicationToLocalTestRepoRepository
> Task :publish

BUILD SUCCESSFUL in 598ms
5 actionable tasks: 5 executed
```

Drei Varianten zur Aktivierung der alten Konsolenausgabe
--------------------------------------------------------

- Mittels Kommandozeilenoption "-Dorg.gradle.console=plain"
- Mittels Kommandozeilenoption "--console=plain"
- Mittels Erweiterung von gradle.properties:

  ```diff
  diff --git a/my-hugo-site/static/gradle-maven-publish/gradle.properties b/my-hugo-site/static/gradle-maven-publish/gradle.properties
  index 336465c..0136d21 100644
  --- a/my-hugo-site/static/gradle-maven-publish/gradle.properties
  +++ b/my-hugo-site/static/gradle-maven-publish/gradle.properties
  @@ -1 +1 @@
  +org.gradle.console=plain
  ```

Links
-----

- [Make –console=plain default](https://discuss.gradle.org/t/make-console-plain-default/23514)

Historie
--------

- 2024-12-15: Erste Version

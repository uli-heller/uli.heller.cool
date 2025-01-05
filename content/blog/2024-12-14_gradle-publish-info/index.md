+++
date = '2024-12-14'
draft = false
title = 'Gradle: Ausgabe des veröffentlichten Artefakts'
categories = [ 'Gradle' ]
tags = [ 'gradle', 'java', 'publish' ]
+++

<!--
Gradle: Ausgabe des veröffentlichten Artefakts
==============================================
-->

Bei einem meiner Kunden habe ich bislang immer das Artifactory-Plugin
verwendet um die Artefakte eines Java-Projektes zu veröffentlichen.
Da der Kunde seine Artifactory-Instanz abschaltet, ist ein Wechsel
zum Standard-Maven-Publish-Plugin fällig.

Leider gibt dieses Plugin die Namen der Artefakte nicht aus.
Die brauche ich aber!

<!--more-->

Beispiel-Ausgaben Artifactory-Plugin
------------------------------------

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site/static/gradle-artifactory$ ./gradlew artifactoryPublish
> Task :compileJava
> Task :processResources NO-SOURCE
> Task :classes
> Task :jar
> Task :generateMetadataFileForJavaPublication
> Task :generatePomFileForJavaPublication
> Task :artifactoryPublish
> Task :extractModuleInfo
[pool-1-thread-1] Deploying artifact: file:/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/static/gradle-artifactory/build/local-repository/artifactory/cool/heller/gradle-artifactory/1.0-SNAPSHOT/gradle-artifactory-1.0-SNAPSHOT.jar
...
```

Beispiel-Ausgaben Maven-Publish-Plugin
--------------------------------------

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site/static/gradle-maven-publish$ ./gradlew publish
> Task :compileJava UP-TO-DATE
> Task :processResources NO-SOURCE
> Task :classes UP-TO-DATE
> Task :jar UP-TO-DATE
> Task :generateMetadataFileForMavenJavaPublication
> Task :generatePomFileForMavenJavaPublication
> Task :publishMavenJavaPublicationToLocalTestRepoRepository
> Task :publish

BUILD SUCCESSFUL in 476ms
5 actionable tasks: 3 executed, 2 up-to-date
```

Erweiterung "build.gradle"
--------------------------

```diff
------------ my-hugo-site/static/gradle-maven-publish/build.gradle ------------
index e4a94ba..ab170a1 100644
@@ -6,6 +6,12 @@ plugins {
 group = 'cool.heller'
 version = '1.0-SNAPSHOT'
 
+tasks.withType(PublishToMavenRepository) {
+    doFirst {
+        println("Publishing ${publication.groupId}:${publication.artifactId}:${publication.version} to ${repository.url}")
+    }
+}
+
 publishing {
     repositories {
         // Local repository which we can first publish in it to check artifacts
```

Ausgaben mit Erweiterung
------------------------

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site/static/gradle-maven-publish$ ./gradlew publish
> Task :compileJava UP-TO-DATE
> Task :processResources NO-SOURCE
> Task :classes UP-TO-DATE
> Task :jar UP-TO-DATE
> Task :generateMetadataFileForMavenJavaPublication
> Task :generatePomFileForMavenJavaPublication

> Task :publishMavenJavaPublicationToLocalTestRepoRepository
Publishing cool.heller:gradle-maven-publish:1.0-SNAPSHOT to file:/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/static/gradle-maven-publish/build/local-repository/

> Task :publish

BUILD SUCCESSFUL in 510ms
5 actionable tasks: 3 executed, 2 up-to-date
```

Links
-----

- [Gradle - Maven Publish Plugin](https://docs.gradle.org/current/userguide/publishing_maven.html)
- [github:java-example-gradle-artifactory](https://github.com/uli-heller/java-example-gradle-artifactory.git)
- [StackOverflow - Get uri of published artifact using maven-publish gradle plugin](https://stackoverflow.com/questions/41745995/get-uri-of-published-artifact-using-maven-publish-gradle-plugin)

Historie
--------

- 2024-12-14: Erste Version

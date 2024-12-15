+++
date = '2024-12-17'
draft = false
title = 'Gradle: Artefakte untersuchen'
categories = [ 'Gradle' ]
tags = [ 'gradle', 'java', 'publish' ]
+++

<!--
Gradle: Artefakte untersuchen
=============================
-->

Sehr häufig dienen meine Java-Projekte dazu, irgendwelche
Artefakte zu publizieren. Manchmal enthalten die Artefakte
irgendwelchen Mist und ich muß sie untersuchen, analysieren
und korrigieren. Bislang habe ich die Artefakte wie üblich
publiziert (bspw. nach Artifactory oder Gitlab) und dann von dort
heruntergeladen und untersucht.

Es geht auch einfacher!

<!--more-->

Ausgangspunkt: Java-Projekt mit Veröffentlichung nach Gitlab
------------------------------------------------------------

build.gradle:

```
...
tasks.withType(PublishToMavenRepository) {
    doFirst {
        println("Publishing ${publication.groupId}:${publication.artifactId}:${publication.version} to ${repository.url}")
    }
}

publishing {
    publications {
        javaPlatform(MavenPublication) {
          from components.javaPlatform
        }
    }
    repositories {
      maven {
        name 'gitlab-registry'
	// Projektname:                        uli/my-test-project   <-- geht nicht (2024-12)
	// Projektname - urlencoded:           uli%2Fmy-test-project <-- geht nicht (2024-12)
	// Projekt-ID (aus der Settings-Page): 123 <-------------------- geht       (2024-12)
        url = uri("https://gitlab.heller.cool/api/v4/projects/123/packages/maven")
        credentials(HttpHeaderCredentials) {
                name = 'Job-Token'
                value = System.getenv("CI_JOB_TOKEN")
        }
        authentication {
                header(HttpHeaderAuthentication)
        }
      } // maven
    } // repositories
}
...
```

Anpassung: Veröffentlichung in lokales Verzeichnis
--------------------------------------------------

build.gradle:

```
...
tasks.withType(PublishToMavenRepository) {
    doFirst {
        println("Publishing ${publication.groupId}:${publication.artifactId}:${publication.version} to ${repository.url}")
    }
}

publishing {
    publications {
        javaPlatform(MavenPublication) {
          from components.javaPlatform
        }
    }
    repositories {
      maven {
        name 'local-registry'
        url = uri("file://${buildDir}/local-repository")
      }
      /*
      maven {
        name 'gitlab-registry'
	// Projektname:                        uli/my-test-project   <-- geht nicht (2024-12)
	// Projektname - urlencoded:           uli%2Fmy-test-project <-- geht nicht (2024-12)
	// Projekt-ID (aus der Settings-Page): 123 <-------------------- geht       (2024-12)
        url = uri("https://gitlab.heller.cool/api/v4/projects/123/packages/maven")
        credentials(HttpHeaderCredentials) {
                name = 'Job-Token'
                value = System.getenv("CI_JOB_TOKEN")
        }
        authentication {
                header(HttpHeaderAuthentication)
        }
      } // maven
      */
    } // repositories
}
...
```

Anpassungen:

```diff
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/my-hugo-site/content/blog/2024-12-17_gradle-artefakte-untersuchen$ diff -u build-fragment.gradle.orig build-fragment.gradle
--- build-fragment.gradle.orig	2024-12-14 17:47:22.888022820 +0100
+++ build-fragment.gradle	2024-12-14 18:04:37.589040215 +0100
@@ -13,6 +13,11 @@
     }
     repositories {
       maven {
+        name 'local-registry'
+        url = uri("file://${buildDir}/local-repository")
+      }
+      /*
+      maven {
         name 'gitlab-registry'
 	// Projektname:                        uli/my-test-project   <-- geht nicht (2024-12)
 	// Projektname - urlencoded:           uli%2Fmy-test-project <-- geht nicht (2024-12)
@@ -26,6 +31,7 @@
                 header(HttpHeaderAuthentication)
         }
       } // maven
+      */
     } // repositories
 }
 ...
```

Test
----

```
$ ./gradlew publish
To honour the JVM settings for this build a single-use Daemon process will be forked. For more on this, please refer to https://docs.gradle.org/8.11.1/userguide/gradle_daemon.html#sec:disabling_the_daemon in the Gradle documentation.
Daemon will be stopped at the end of the build 
> Task :compileJava
> Task :processResources NO-SOURCE
> Task :classes
> Task :jar
> Task :generateMetadataFileForJavaPublication
> Task :generatePomFileForJavaPublication

> Task :publishJavaPublicationToLocal-registryRepository
Publishing cool.heller:gradle-maven-publish:1.0-SNAPSHOT to file:/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/static/gradle-maven-publish/build/local-repository

> Task :publish

BUILD SUCCESSFUL in 4s
5 actionable tasks: 5 executed
```

Erzeugte Ordner und Dateien:

- build/local-repository/cool/heller/gradle-maven-publish/
  - maven-metadata.xml
  - maven-metadata.xml.md5
  - maven-metadata.xml.sha1
  - maven-metadata.xml.sha256
  - maven-metadata.xml.sha512
  - 1.0-SNAPSHOT
    - gradle-maven-publish-1.0-20241214.170633-1.jar
    - gradle-maven-publish-1.0-20241214.170633-1.jar.md5
    - gradle-maven-publish-1.0-20241214.170633-1.jar.sha1
    - gradle-maven-publish-1.0-20241214.170633-1.jar.sha256
    - gradle-maven-publish-1.0-20241214.170633-1.jar.sha512
    - gradle-maven-publish-1.0-20241214.170633-1.module
    - gradle-maven-publish-1.0-20241214.170633-1.module.md5
    - gradle-maven-publish-1.0-20241214.170633-1.module.sha1
    - gradle-maven-publish-1.0-20241214.170633-1.module.sha256
    - gradle-maven-publish-1.0-20241214.170633-1.module.sha512
    - gradle-maven-publish-1.0-20241214.170633-1.pom
    - gradle-maven-publish-1.0-20241214.170633-1.pom.md5
    - gradle-maven-publish-1.0-20241214.170633-1.pom.sha1
    - gradle-maven-publish-1.0-20241214.170633-1.pom.sha256
    - gradle-maven-publish-1.0-20241214.170633-1.pom.sha512
    - maven-metadata.xml
    - maven-metadata.xml.md5
    - maven-metadata.xml.sha1
    - maven-metadata.xml.sha256
    - maven-metadata.xml.sha512

Links
-----

- [Gradle - Maven Publish Plugin](https://docs.gradle.org/current/userguide/publishing_maven.html)

Historie
--------

- 2024-12-17: Erste Version

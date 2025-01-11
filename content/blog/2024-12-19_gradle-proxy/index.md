+++
date = '2024-12-19'
draft = false
title = 'Gradle: Verwendung eines Proxy mit Ausnahmen'
categories = [ 'Gradle' ]
tags = [ 'gradle', 'proxy' ]
+++

<!--
Gradle: Verwendung eines Proxy mit Ausnahmen
============================================
-->

Bei einem meiner Kunden muß ich für eine Gradle-Builds
einen Proxy verwenden, um auf die PackageRegistry
des Kunden zuzugreifen. Die wird für die Pakete des Kunden
verwendet mit einer Gruppe wie "org.meinkunde".

Für öffentlich verfügbare Pakete wie die von SpringBoot
darf ich den Proxy nicht verwenden. Er blockt die Zugriffe
darauf.

Hier beschreibe ich Konfiguration und Probleme.

<!--more-->

Beispielprojekt
---------------

Mein Beispielprojekt liegt hier: [github:java-example-gradle-proxy](https://github.com/uli-heller/java-example-gradle-proxy.git).

Zunächst: Proxy für alles
-------------------------

Mein Kunde hat grob die nachstehenden Einstellungen in
gradle.properties:

```
systemProp.http.proxyHost=http-proxy.meinkunde.org
systemProp.http.proxyPort=3128
systemProp.https.proxyHost=http-proxy.meinkunde.org
systemProp.https.proxyPort=3128
```

Zu Testzwecken ändere ich das in

```
systemProp.http.proxyHost=localhost
systemProp.http.proxyPort=1234
systemProp.https.proxyHost=localhost
systemProp.https.proxyPort=1234
```

Dann in Terminalfenster 1:

```
$ nc -k -l 1234
# Bleibt hängen
```

Und in Terminalfenster 2:

```
gradle-proxy$ ./gradlew -g h build
Downloading https://services.gradle.org/distributions/gradle-8.11.1-bin.zip

Exception in thread "main" java.io.IOException: Downloading from https://services.gradle.org/distributions/gradle-8.11.1-bin.zip failed: timeout (10000ms)
	at org.gradle.wrapper.Install.forceFetch(SourceFile:4)
	at org.gradle.wrapper.Install$1.call(SourceFile:8)
	at org.gradle.wrapper.GradleWrapperMain.main(SourceFile:67)
Caused by: java.net.SocketTimeoutException: Read timed out
	at java.base/sun.nio.ch.NioSocketImpl.timedRead(NioSocketImpl.java:278)
...
```

Es funktioniert also nicht. Blick auf Terminalfenster 1:

```
$ nc -k -l 1234
CONNECT services.gradle.org:443 HTTP/1.1
User-Agent: Java/21.0.1
Host: services.gradle.org
Accept: */*
Proxy-Connection: keep-alive
```

Erstes Ziel: Herunterladen von gradle.zip soll klappen
------------------------------------------------------

Also Ausnahme: services.gradle.org

gradle.properties:

```
systemProp.http.proxyHost=localhost
systemProp.http.proxyPort=1234
systemProp.https.proxyHost=localhost
systemProp.https.proxyPort=1234

systemProp.http.nonProxyHosts=services.gradle.org
systemProp.https.nonProxyHosts=services.gradle.org
```

Terminalfenster 2: Identisch wie zuvor

Terminalfenster 1:

```
$ nc -k -l 1234
CONNECT github.com:443 HTTP/1.1
User-Agent: Java/21.0.1
Host: github.com
Accept: */*
Proxy-Connection: keep-alive
```

Also: Noch eine Ausnahme in gradle.properties:

```
...
systemProp.http.nonProxyHosts=services.gradle.org|github.com
systemProp.https.nonProxyHosts=services.gradle.org|github.com
```

Ablauf wiederholt sich für

- objects.githubusercontent.com

Also gradle.properties:

```
...
systemProp.http.nonProxyHosts=services.gradle.org|github.com|objects.githubusercontent.com
systemProp.https.nonProxyHosts=services.gradle.org|github.com|objects.githubusercontent.com
```

Danach klappt das Herunterladen der Gradle.ZIP-Datei!

Zweites Ziel: Herunterladen der öffentlichen Artefakte soll klappen
-------------------------------------------------------------------

Ablauf wie zuvor mit den beiden Terminalfenstern.

Terminalfenster 2:

```
gradle-proxy$ ./gradlew -g h build
> Task :compileJava
> Task :compileJava FAILED

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':compileJava'.
> Could not resolve all files for configuration ':compileClasspath'.
   > Could not resolve org.springframework.boot:spring-boot-dependencies:[3.0,).
     Required by:
         root project :
      > Failed to list versions for org.springframework.boot:spring-boot-dependencies.
         > Unable to load Maven meta-data from https://repo.maven.apache.org/maven2/org/springframework/boot/spring-boot-dependencies/maven-metadata.xml.
            > Could not GET 'https://repo.maven.apache.org/maven2/org/springframework/boot/spring-boot-dependencies/maven-metadata.xml'.
               > Read timed out
> There are 6 more failures with identical causes.

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 1m 33s
1 actionable task: 1 executed
```

Terminalfenster 1:

```
$ nc -k -l 1234
CONNECT repo.maven.apache.org:443 HTTP/1.1
Host: repo.maven.apache.org
User-Agent: Gradle/8.11.1 (Linux;6.8.0-49-generic;amd64) (Oracle Corporation;21.0.1;21.0.1+12-29)
```

Erweitern von gradle.properties:

```
...
systemProp.http.nonProxyHosts=services.gradle.org|github.com|objects.githubusercontent.com|repo.maven.apache.org
systemProp.https.nonProxyHosts=services.gradle.org|github.com|objects.githubusercontent.com|repo.maven.apache.org
```

Damit Terminalfenster 2:

```
gradle-proxy$ ./gradlew -g h build
> Task :compileJava UP-TO-DATE
> Task :processResources NO-SOURCE
> Task :classes UP-TO-DATE
> Task :jar UP-TO-DATE
> Task :assemble UP-TO-DATE
> Task :compileTestJava NO-SOURCE
> Task :processTestResources NO-SOURCE
> Task :testClasses UP-TO-DATE
> Task :test NO-SOURCE
> Task :check UP-TO-DATE
> Task :build UP-TO-DATE

BUILD SUCCESSFUL in 26s
2 actionable tasks: 2 up-to-date
```

Probleme mit Plugins
--------------------

- build.gradle erweitern - "3.4.1-uli" ist eine Phantasie-Version

  ```diff
  diff --git a/my-hugo-site/static/gradle-proxy/build.gradle b/my-hugo-site/static/gradle-proxy/build.gradle
  index 18ea9d5..df317c4 100644
  --- a/my-hugo-site/static/gradle-proxy/build.gradle
  +++ b/my-hugo-site/static/gradle-proxy/build.gradle
  @@ -1,6 +1,7 @@
   plugins {
     id("maven-publish")
     id("java-library")
  +  id 'org.springframework.boot' version '3.4.1-uli'
   }
  
  group = 'cool.heller'
  ```

- Vorbereitung in Terminalfenster1: `nc -k -l 1234`

- Build starten in Terminalfenster2: `./gradlew build`

Damit Terminalfenster1:

```
uli@uliip5:~/.gradle$ nc -k -l 1234
CONNECT plugins.gradle.org:443 HTTP/1.1
Host: plugins.gradle.org
User-Agent: Gradle/8.11.1 (Linux;6.8.0-49-generic;amd64) (Oracle Corporation;21.0.1;21.0.1+12-29)
```

Also: "nonProxyHosts" erweitern um "plugins.gradle.org"!

Beobachtung: Ich muß die Erweiterung in $HOME/.gradle/gradle.properties vornehmen.
In "java-projekt/gradle.properties" scheint sie nicht zu greifen!

Nachtrag 2024-12-27 - Could not GET 'https://plugins-artifacts.gradle.org/...' ...
----------------------------------------------------------------------------------

Heute am 2024-12-27 habe ich mit dem Beispielprojekt [github:java-example-springboot-hello-world](https://github.com/uli-heller/java-example-springboot-hello-world.git) gearbeitet.
Dabei erschien diese Fehlermeldung:

```
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/my-hugo-site/static/springboot-hello-world$ ./gradlew --write-locks
To honour the JVM settings for this build a single-use Daemon process will be forked. For more on this, please refer to https://docs.gradle.org/8.11.1/userguide/gradle_daemon.html#sec:disabling_the_daemon in the Gradle documentation.
Daemon will be stopped at the end of the build

FAILURE: Build failed with an exception.

* What went wrong:
A problem occurred configuring root project 'springboot-hello-world'.Could not resolve all artifacts for configuration 'classpath'.   > Could not resolve org.springframework.boot:spring-boot-gradle-plugin:3.4.1.
     Required by:
         root project : > org.springframework.boot:org.springframework.boot.gradle.plugin:3.4.1
      > Could not resolve org.springframework.boot:spring-boot-gradle-plugin:3.4.1.
         > Could not get resource 'https://plugins.gradle.org/m2/org/springframework/boot/spring-boot-gradle-plugin/3.4.1/spring-boot-gradle-plugin-3.4.1.pom'.
            > Could not GET 'https://plugins-artifacts.gradle.org/org.springframework.boot/spring-boot-gradle-plugin/3.4.1/e7cb3adea6a8ea7c227f2db62a3a5e584191fd02d7ee255c54b25d8c5e7d9690/spring-boot-gradle-plugin-3.4.1.pom'.
               > http-proxy.porsche.org: Der Name oder der Dienst ist nicht bekannt

* Try:Run with --stacktrace option to get the stack trace.
Run with --info or --debug option to get more log output.
Run with --scan to get full insights.
Get more help at https://help.gradle.org.
BUILD FAILED in 4s
```

Korrigieren konnte ich das durch Erweitern der "gradle.properties" um
"plugins-artifacts.gradle.org". Leider kann ich den ursprünglichen Fehler
aktuell nicht mehr reproduzieren. Dementsprechend kann ich aktuell auch
nicht mir Einträgen wie "plugins*.gradle.org" experimentieren!

Finale Version von gradle.properties
------------------------------------

Die finale Version von gradle.properties
hat diesen Inhalt:

```
org.gradle.console=plain

systemProp.http.proxyHost=http-proxy.meinkunde.org
systemProp.http.proxyPort=3128
systemProp.https.proxyHost=http-proxy.meinkunde.org
systemProp.https.proxyPort=3128

#systemProp.http.proxyHost=localhost
#systemProp.http.proxyPort=1234
#systemProp.https.proxyHost=localhost
#systemProp.https.proxyPort=1234

systemProp.http.nonProxyHosts=plugins-artifacts.gradle.org|plugins.gradle.org|services.gradle.org|github.com|objects.githubusercontent.com|repo.maven.apache.org|repo1.maven.apache.org|jcenter.bintray.com
systemProp.https.nonProxyHosts=plugins-artifacts.gradle.org|plugins.gradle.org|services.gradle.org|github.com|objects.githubusercontent.com|repo.maven.apache.org|repo1.maven.apache.org|jcenter.bintray.com
```

Sie liegt typischerweise NICHT im Projektverzeichnis, sondern
unter dem Dateinamen "$HOME/.gradle/gradle.properties".

Versionen
---------

Getestet mit

- Gradle-8.11.1

Links
-----

- [github:java-example-Beispielprojekt gradle-proxy](https//github.com/uli-heller/java-example-gradle-proxy.git)

Historie
--------

- 2025-01-11: Weitere Ausnahmen bei nonProxyHosts: repo1.maven.apache.org und jcenter.bintray.com
- 2024-12-27: Weitere Tests - nonProxyHosts erweitern um plugins-artifacts.gradle.org
- 2024-12-22: Tests mit Gradle-Plugins - nonProxyHosts erweitern um plugins.gradle.org
- 2024-12-19: Erste Version

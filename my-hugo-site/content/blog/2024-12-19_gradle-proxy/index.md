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

Mein Beispielprojekt liegt hier: [gradle-proxy](/gradle-proxy).

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

systemProp.http.nonProxyHosts=services.gradle.org|github.com|objects.githubusercontent.com|repo.maven.apache.org
systemProp.https.nonProxyHosts=services.gradle.org|github.com|objects.githubusercontent.com|repo.maven.apache.org
```

Sie liegt typischerweise NICHT im Projektverzeichnis, sondern
unter dem Dateinamen "$HOME/.gradle/gradle.properties".

Versionen
---------

Getestet mit

- Gradle-8.11.1

Links
-----

- [Beispielprojekt gradle-proxy](/gradle-proxy)

Historie
--------

- 2024-12-19: Erste Version

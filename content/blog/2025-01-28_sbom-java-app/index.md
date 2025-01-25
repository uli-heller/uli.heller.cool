+++
date = '2025-01-28'
draft = false
title = 'Erstellung einer Software-Inventurliste (SBOM) für eine Java-App - JSON und CSV'
categories = [ 'Trivy' ]
tags = [ 'trivy', 'cdxgen', 'sicherheit', 'sbom', 'java' ]
+++

<!--
Erstellung einer Software-Inventurliste (SBOM) für eine Java-App - JSON und CSV
===============================================================================
-->

Hier beschreibe ich, wie ich eine
Software-Inventurliste (SBOM) für eine
Java-App mit Trivy und auch dem CycloneDX-Plugin erstelle.

Die SBOM wandle ich auch noch nach CSV, damit
ich sie leichter in einer Datenbank ablegen kann.

<!--more-->

SBOM für ein Java-Projekt
-------------------------

### Java-Projekt clonen

```
git clone https://github.com/uli-heller/java-example-sbom.git
cd java-example-sbom
```

### Maven-Repo erzeugen

```
cd java-example-sbom
rm -rf maven-repository
./create-maven-repository.sh
```

### SBOM mit CDXGEN-Plugin erzeugen

Damit die SBOM mit dem CDXGEN-Plugin erzeugt werden kann,
muß dieses in der Datei "build.gradle" eingebunden sein:

```
diff -u build.gradle.orig build.gradle
--- build.gradle.orig	2025-01-25 14:08:52.613830464 +0100
+++ build.gradle	2025-01-25 14:09:11.644940000 +0100
@@ -7,6 +7,7 @@
 plugins {
   id 'java'
   id 'maven-publish'
+  id 'org.cyclonedx.bom' version '+' // or '2.0.0'
   id 'org.springframework.boot' version '3.4.1'
 }
```

Die SBOM erzeugt man dann mit:

```
cd java-example-sbom
./gradlew cyclonedxBom
mv build/reports/application.cdx.json plugin-cdx-sbom.json
```

[plugin-cdx-sbom.json](plugin-cdx-sbom.json)

### SBOM mit TRIVY erzeugen

Damit die SBOM mit TRIVY erzeugt werden kann, muß
das DepencencyLocking aktiv sein. Außerdem müssen
die entsprechenden Lock-Dateien erzeugt werden.

build.gradle mit DependencyLocking:

```diff
diff --git a/build.gradle b/build.gradle
index f5551dd..04ffb52 100644
--- a/build.gradle
+++ b/build.gradle
@@ -1,3 +1,9 @@
+buildscript {
+    configurations.classpath {
+        resolutionStrategy.activateDependencyLocking()
+    }
+}
+
 plugins {
   id 'java'
   id 'maven-publish'
@@ -12,6 +18,10 @@ java {
   sourceCompatibility = '17'
 }
 
+dependencyLocking {
+    lockAllConfigurations()
+}
+
 repositories {
        mavenCentral()
```

Die SBOM erzeugt man dann mit:

```
cd java-example-sbom
./gradlew --write-locks dependencies
trivy filesystem gradle.lockfile --format spdx-json --output trivy-spdx-sbom.json
trivy filesystem gradle.lockfile --format cyclonedx --output trivy-cdx-sbom.json
```

[trivy-spdx-sbom.json](trivy-spdx-sbom.json)
[trivy-cdx-sbom.json](trivy-cdx-sbom.json)

Wandeln nach CSV
----------------

### trivy-spdx-sbom.json

```
jq -r '[ "name", "versionInfo" ] as $cols | .packages | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' <trivy-spdx-sbom.json >trivy-spdx-sbom.csv
```

[trivy-spdx-sbom.csv](trivy-spdx-sbom.csv)

### trivy-cdx-sbom.json

```
jq -r '[ "group", "name", "version" ] as $cols | .components | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' <trivy-cdx-sbom.json >trivy-cdx-sbom.csv
```

[trivy-cdx-sbom.csv](trivy-cdx-sbom.csv)

### plugin-cdx-sbom.json

```
jq -r '[ "group", "name", "version" ] as $cols | .components | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' <plugin-cdx-sbom.json >plugin-cdx-sbom.csv
```

[plugin-cdx-sbom.csv](plugin-cdx-sbom.csv)

### Vergleich

```
$ wc -l *.csv
  40 plugin-cdx-sbom.csv
  41 trivy-cdx-sbom.csv
  42 trivy-spdx-sbom.csv
 123 insgesamt
```

Die Anzahl der Komponenten scheint unterschiedlich zu sein!

Detailvergleich:

- plugin-cdx-sbom.csv -> trivy-cdx-sbom.csv: gradle.lockfile
- trivy-cdx-sbom.csv -> trivy-spdx-sbom.csv: gradle.lockfile taucht 2x auf

Allgemeine Erkenntnisse
-----------------------

### Plugin-Locking

Wenn beim DependencyLocking to GradlePlugins mit
einbezogen sind, dann wird die Datei "buildscript-gradle.lockfile"
angelegt und auch in die SBOM eingebunden. Damit erhält man dann
die Komponenten der Plugins in des SBOM. Das ist eher unerwünscht!

Abhilfe:

- Statt: `trivy filesystem . ...`
- Dies: `trivy filesystem gradle.lockfile ...`

Links
-----

- [Github - Trivy - Releases](https://github.com/aquasecurity/trivy/releases)
- [Github - java-example-sbom](https://github.com/uli-heller/java-example-sbom)

Versionen
---------

Getestet mit Ubuntu-22.04 und Trivy-v0.58.0 und dem Gradle-CycloneDX-Plugin-2.0.0.

Historie
--------

- 2025-01-28: Erste Version

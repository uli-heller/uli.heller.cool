+++
date = '2025-01-29'
draft = false
title = 'JQ: Feld aufsplitten beim Wandeln nach CSV'
categories = [ 'JQ' ]
tags = [ 'jq', 'csv' ]
toc  = false
+++

<!--
JQ: Feld aufsplitten beim Wandeln nach CSV
==========================================
-->

Bei der Wandlung der SBOM-JSON-Dokumente nach CSV
fällt auf, dass die JSON-Struktur beim SPDX-Format
leider keine Trennung von "group" und "name"
aufweist. Dies möchte ich bei der Wandlung
mit JQ "nachholen".

<!--more-->

Problembeschreibung
-------------------

Ausgangsdatei: [trivy-spdx-sbom.json](trivy-spdx-sbom.json)

Direkte Wandlung nach CSV:

```
jq -r '[ "name", "versionInfo" ] as $cols | .packages | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' <trivy-spdx-sbom.json >trivy-spdx-sbom-ko.csv
```

Das erzeugt eine [CSV-Datei wie diese - trivy-spdx-sbom-ko.csv](trivy-spdx-sbom-ko.csv):

```csv
"name","versionInfo"
"gradle.lockfile",
"ch.qos.logback:logback-classic","1.5.12"
"ch.qos.logback:logback-core","1.5.12"
"com.fasterxml.jackson.core:jackson-annotations","2.18.2"
...
```

Ich hätte gerne:

```csv
"group","name","version"
"","gradle.lockfile",""
"ch.qos.logback","logback-classic","1.5.12"
"ch.qos.logback","logback-core","1.5.12"
"com.fasterxml.jackson.core","jackson-annotations","2.18.2"
...
```

Also: Feld "name" aufsplitten bei ":"!

Eine erste Variante
-------------------

```
jq -r '["group", "name", "version"], (.packages[] | ([(.name|split(":")|.[]), .versionInfo])) | @csv'  <trivy-spdx-sbom.json >trivy-spdx-sbom-ok1.csv
```

Hier die gelieferte [CSV-Datei - trivy-spdx-sbom-ok1.json](trivy-spdx-sbom-ok1.csv):

```csv
"group","name","version"
"gradle.lockfile",
"ch.qos.logback","logback-classic","1.5.12"
"ch.qos.logback","logback-core","1.5.12"
"com.fasterxml.jackson.core","jackson-annotations","2.18.2"
...
```

Verbeibendes Problem
--------------------

Wenn "name" keinen Doppelpunkt enthält, so sieht die
erzeugte Datei so aus:

```csv
"group","name","version"
"myname-kein-doppelpunkt","1.0"
```

Bei zwei Doppelpunkten:

```csv
"group","name","version"
"eins","zwei","myname-zwei-doppelpunkte","1.0"
```

Hier eine Testausführung:

```
jq -r '["group", "name", "version"], (.packages[] | ([(.name|split(":")|.[]), .versionInfo])) | @csv' <doppelpunkt-probleme.json >doppelpunkt-probleme-ko.csv
```

... führt zu [doppelpunkt-probleme-ko.csv](doppelpunkt-probleme-ko.csv):

```csv
"group","name","version"
"ohne-doppelpunkt","1.5.12"
"mit","zwei","doppelpunkten","1.5.12"
"ganz","ganz","ganz","ganz","viele","doppelpunkte","2.18.2"
```

Lösungsversuch
--------------

Neuer Versuch:

```
jq -r '["group", "name", "version"], (
             .packages[]
             | (
                 [
                   (
                     .name|split(":") as $splitted|($splitted[-2], $splitted[-1])
                   ), .versionInfo
                 ]
               )
       ) | @csv' <doppelpunkt-probleme.json >doppelpunkt-probleme-ok.csv
```

Damit sieht die [CSV-Datei doppelpunkt-probleme-ok.csv] so aus:

```csv
"group","name","version"
,"ohne-doppelpunkt","1.5.12"
"zwei","doppelpunkten","1.5.12"
"viele","doppelpunkte","2.18.2"
```

Mit der SBOM-Datei:

```
jq -r '["group", "name", "version"], (
             .packages[]
             | (
                 [
                   (
                     .name|split(":") as $splitted|($splitted[-2], $splitted[-1])
                   ), .versionInfo
                 ]
               )
       ) | @csv' <trivy-spdx-sbom.json >trivy-spdx-sbom-ok2.csv
```

[CSV-Datei - trivy-spdx-sbom-ok2.csv](trivy-spdx-sbom-ok2.csv):

```csv
"group","name","version"
,"gradle.lockfile",
"ch.qos.logback","logback-classic","1.5.12"
"ch.qos.logback","logback-core","1.5.12"
"com.fasterxml.jackson.core","jackson-annotations","2.18.2"
...
```

Links
-----

- [Erstellung einer Software-Inventurliste (SBOM) für eine Java-App - JSON und CSV]({{- ref "/blog/2025-01-28_sbom-java-app" -}})

Historie
--------

- 2025-01-29: Erste Version

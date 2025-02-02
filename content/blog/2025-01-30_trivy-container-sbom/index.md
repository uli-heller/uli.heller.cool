+++
date = '2025-01-30'
draft = false
title = 'Container-SBOM nach CSV wandeln'
categories = [ 'Trivy' ]
tags = [ 'trivy', 'cdxgen', 'spdx', 'sicherheit', 'sbom', 'container' ]
+++

<!--
SBOM nach CSV wandeln
=====================
-->

Für Kundenprojekte verwende ich häufig Container-Images
als Ergebnis der CICD-Pipeline. Diese werden dann in einer
Cloud-Umgebung eingespielt.

Wir erstellen für die Container-Images SBOMs. Diese sind im
JSON-Format. Für Auswertungen möchte ich sie als CSV-Datei
bereitstellen und danach in eine Datenbank importieren.

<!--more-->

SPDX-Format
-----------

### Wandlung nach CSV

[spdx-2-csv.sh](spdx-2-csv.sh):

```sh
#!/bin/sh
jq -r '["type","group", "name", "version"], (
             .packages[]
             | (
                 [
                   .primaryPackagePurpose,
                   (
                     .name|split(":") as $splitted|($splitted[-2], $splitted[-1])
                   ), .versionInfo
                 ]
               )
       ) | @csv'
```

Damit wird aus der [SBOM im SPDX-JSON-Format]() diese [CSV-Datei trivy-spdx-jib-sbom.csv](trivy-spdx-jib-sbom.csv):

```csv
"type","group","name","version"
"CONTAINER",,"build/jib-image.tar",
"LIBRARY",,"adduser","3.137ubuntu1"
"LIBRARY",,"apt","2.7.14build2"
"LIBRARY",,"base-files","13ubuntu10.1"
...
"LIBRARY","ch.qos.logback","logback-classic","1.5.12"
"LIBRARY","ch.qos.logback","logback-core","1.5.12"
"LIBRARY","com.fasterxml.jackson.core","jackson-annotations","2.18.2"
"LIBRARY","com.fasterxml.jackson.core","jackson-core","2.18.2"
"LIBRARY","com.fasterxml.jackson.core","jackson-databind","2.18.2"
...
```

Schön wäre es, wenn man erkennen könnte, ob es
sich jeweils um ein Betriebssystem-Paket oder
um ein Java-Paket handelt. Falls eine Sicherheitslücke
entdeckt wird, muß man bei Betriebsystem-Paketen
das Basisimage aktualisieren. Bei Java-Paketen die
Anwendung.

Idee: "referenceLocator" könnte helfen!

```
      "externalRefs": [
        {
          "referenceCategory": "PACKAGE-MANAGER",
          "referenceType": "purl",
          "referenceLocator": "pkg:deb/ubuntu/adduser@3.137ubuntu1?arch=all\u0026distro=ubuntu-24.04"
        }
      ],
...
      "externalRefs": [
        {
          "referenceCategory": "PACKAGE-MANAGER",
          "referenceType": "purl",
          "referenceLocator": "pkg:maven/org.springframework.boot/spring-boot@3.4.1"
        }
      ],
```

Umsetzung mit JQ:

```diff
--- a/content/blog/2025-01-30_trivy-container-sbom/spdx-2-csv-2.sh
+++ b/content/blog/2025-01-30_trivy-container-sbom/spdx-2-csv-2.sh
@@ -1,9 +1,12 @@
 #!/bin/sh
-jq -r '["type","group", "name", "version"], (
+jq -r '["type","ref","group", "name", "version"], (
              .packages[]
              | (
                  [
                    .primaryPackagePurpose,
+                   (
+                     .externalRefs|..|.referenceLocator?|strings|split("/")[0]
+                   ),
                    (
                      .name|split(":") as $splitted|($splitted[-2], $splitted[-1])
                    ), .versionInfo
```

Damit erhält man dann die [CVS-Datei trivy-spdx-jib-sbom-2.csv](trivy-spdx-jib-sbom-2.csv):

```csv
type","ref","group","name","version"
"CONTAINER",,"build/jib-image.tar",
"LIBRARY","pkg:deb",,"adduser","3.137ubuntu1"
"LIBRARY","pkg:deb",,"apt","2.7.14build2"
"LIBRARY","pkg:deb",,"base-files","13ubuntu10.1"
...
"LIBRARY","pkg:deb",,"wget","1.21.4-1ubuntu4.1"
"LIBRARY","pkg:deb",,"zlib1g","1:1.3.dfsg-3.1ubuntu2.1"
"OPERATING-SYSTEM",,"ubuntu","24.04"
```

CycloneDX-Format
----------------

```
     "bom-ref": "pkg:deb/ubuntu/adduser@3.137ubuntu1?arch=all&distro=ubuntu-24.04",
      "type": "library",
      "supplier": {
        "name": "Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>"
      },
      "name": "adduser",
      "version": "3.137ubuntu1",
```

Also: "bom-ref" verwenden!

Dazu muß die ursprüngliche Wandlung leider komplett umgestellt werden!

[cdx-2-csv.sh](cdx-2-csv.sh)

```
#!/bin/sh
jq -r '[ "type", "group", "name", "version" ] as $cols | .components | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv'
```

[cdx-2-csv-2.sh](cdx-2-csv-2.sh)

```
#!/bin/sh
jq -r '["type","ref","group", "name", "version"], (
             .components[]
             | (
                 [
                   .type,
                   (."bom-ref"|split("/")[0]),
                   .group,
                   .name,
                   .version
                 ]
               )
       ) | @csv'
```

Damit erhält man dann die [CVS-Datei trivy-cdx-jib-sbom-2.csv](trivy-cdx-jib-sbom-2.csv):

```csv
."type","ref","group","name","version"
"operating-system","b085e671-e87c-4e93-977b-a6d88eae88ad",,"ubuntu","24.04"
"library","pkg:deb",,"adduser","3.137ubuntu1"
"library","pkg:deb",,"apt","2.7.14build2"
"library","pkg:deb",,"base-files","13ubuntu10.1"
...
"library","pkg:maven","org.springframework","spring-web","6.2.1"
"library","pkg:maven","org.springframework","spring-webmvc","6.2.1"
"library","pkg:maven","org.yaml","snakeyaml","2.3"
```

Links
-----

- [Erstellung einer Software-Inventurliste (SBOM) für eine Java-App - JSON und CSV]({{< ref "blog/2025-01-28_sbom-java-app" >}})

Änderungen
----------

- 2025-02-02: Link korrigiert
- 2025-01-30: Erste Version

SODX-Format
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
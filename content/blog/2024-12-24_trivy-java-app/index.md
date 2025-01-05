+++
date = '2024-12-24'
draft = false
title = 'Sicherheitsscan einer Java-Anwendung mit Trivy'
categories = [ 'Trivy' ]
tags = [ 'trivy', 'sicherheit', 'java' ]
toc = false
+++

<!--
Sicherheitsscan einer Java-Anwendung mit Trivy
==============================================
-->

Hier beschreibe ich, wie ich Java-Anwendungen
mit "Trivy" auf Sicherheitslücken untersuche.

<!--more-->

Ein Beispiel-Java-Projekt findet sich hier:  [github:java-example-springboot-hello-world](https://github.com/uli-heller/java-example-springboot-hello-world.git)

Wichtig ist insbesondere dieser Teil in "build.gradle":

```
buildscript {
    configurations.classpath {
        resolutionStrategy.activateDependencyLocking()
    }
}
```

Damit läuft die Prüfung dann wie folgt:

```
cd springboot-hello-world

./gradlew dependencies --write-locks
# ... erzeugt *gradle.lockfile

trivy fs .
```

Man erhält Ausgaben wie diese:

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site/static/gradle-bom$ trivy fs .
2024-12-22T10:18:53+01:00	INFO	[vulndb] Need to update DB
2024-12-22T10:18:53+01:00	INFO	[vulndb] Downloading vulnerability DB...
2024-12-22T10:18:53+01:00	INFO	[vulndb] Downloading artifact...	repo="mirror.gcr.io/aquasec/trivy-db:2"
57.93 MiB / 57.93 MiB [-----------------------------------------------------------------------------] 100.00% 2.51 MiB p/s 23s
2024-12-22T10:19:19+01:00	INFO	[vulndb] Artifact successfully downloaded	repo="mirror.gcr.io/aquasec/trivy-db:2"
2024-12-22T10:19:19+01:00	INFO	[vuln] Vulnerability scanning is enabled
2024-12-22T10:19:19+01:00	INFO	[secret] Secret scanning is enabled
2024-12-22T10:19:19+01:00	INFO	[secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2024-12-22T10:19:19+01:00	INFO	[secret] Please see also https://aquasecurity.github.io/trivy/v0.58/docs/scanner/secret#recommendation for faster secret detection
2024-12-22T10:19:32+01:00	INFO	Number of language-specific files	num=1
2024-12-22T10:19:32+01:00	INFO	[gradle] Detecting vulnerabilities...

buildscript-gradle.lockfile (gradle)

Total: 2 (UNKNOWN: 0, LOW: 0, MEDIUM: 1, HIGH: 1, CRITICAL: 0)

┌─────────────────────────────────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬─────────────────────────────────────────────────────────────┐
│               Library               │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                            Title                            │
├─────────────────────────────────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ org.apache.commons:commons-compress │ CVE-2024-25710 │ HIGH     │ fixed  │ 1.25.0            │ 1.26.0        │ commons-compress: Denial of service caused by an infinite   │
│                                     │                │          │        │                   │               │ loop for a corrupted...                                     │
│                                     │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-25710                  │
│                                     ├────────────────┼──────────┤        │                   │               ├─────────────────────────────────────────────────────────────┤
│                                     │ CVE-2024-26308 │ MEDIUM   │        │                   │               │ commons-compress: OutOfMemoryError unpacking broken Pack200 │
│                                     │                │          │        │                   │               │ file                                                        │
│                                     │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-26308                  │
└─────────────────────────────────────┴────────────────┴──────────┴────────┴───────────────────┴───────────────┴─────────────────────────────────────────────────────────────┘
```

Links
-----

- [Github - Trivy - Releases](https://github.com/aquasecurity/trivy/releases)
- [github:java-example-Beispielprojekt](https://github.com/uli-heller/java-example-springboot-hello-world.git)

Versionen
---------

Getestet mit Ubuntu-22.04 und Trivy-v0.58.0.

Historie
--------

- 2024-12-24: Erste Version

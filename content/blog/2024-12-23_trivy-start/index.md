+++
date = '2024-12-23'
draft = false
title = 'Sicherheitsscans mit Trivy'
categories = [ 'trivy' ]
tags = [ 'trivy', 'sicherheit' ]
+++

<!--
Sicherheitsscans mit Trivy
==========================
-->

Wenn ich Anwendungen erstelle oder mit
Containern arbeite, dass möchte ich gerne wissen,
ob mein Werk bekannte Sicherheitslücken aufweist.
Dazu nutze ich gerne den Scanner "Trivy".

<!--more-->

Trivy herunterladen, prüfen und installieren
--------------------------------------------

- Trivy herunterladen: [trivy_0.58.0_Linux-64bit.tar.gz](https://github.com/aquasecurity/trivy/releases/download/v0.58.0/trivy_0.58.0_Linux-64bit.tar.gz)
- Virenprüfung
- Signaturprüfung

  ```
  $ cosign verify-blob trivy_0.58.0_Linux-64bit.tar.gz\
    --certificate trivy_0.58.0_Linux-64bit.tar.gz.pem\
    --signature trivy_0.58.0_Linux-64bit.tar.gz.sig\
    --certificate-identity-regexp 'https://github\.com/aquasecurity/trivy/\.github/workflows/.+' \
    --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
  Verified OK
  ```

- Temporäres Verzeichnis anlegen und reinwechseln: `mkdir /tmp/trivy-extract && cd /tmp/trivy-extract`

- Auspacken: `gzip -cd $HOME/Downloads/trivy_0.58.0_Linux-64bit.tar.gz|tar -xf -`

- Installieren: Datei "trivy" irgendwo hinkopieren, wo sie im PATH liegt. Bspw. nach "$HOME/bin".

- Test: `trivy version` -> Version: 0.58.0

Test eines Java-Projektes
-------------------------

```
cd mein-java-projekt

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
- [Beispielprojekt](/springboot-hello-world)

Versionen
---------

Getestet mit Ubuntu-22.04 und Trivy-v0.58.0.

Historie
--------

- 2024-12-23: Erste Version

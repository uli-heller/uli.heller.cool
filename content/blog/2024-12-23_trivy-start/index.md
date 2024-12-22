+++
date = '2024-12-23'
draft = false
title = 'Sicherheitsscans mit Trivy'
categories = [ 'Trivy' ]
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

Hier beschreibe ich, wie ich ihn einspiele.

<!--more-->

Trivy herunterladen
-------------------

- Trivy herunterladen: [trivy_0.58.0_Linux-64bit.tar.gz](https://github.com/aquasecurity/trivy/releases/download/v0.58.0/trivy_0.58.0_Linux-64bit.tar.gz)
- Zusätzlich: .sig-Datei
- Zusätzlich: .pem-Datei

Trivy prüfen
------------

- Virenprüfung - bspw. mit Virustotal
- Signaturprüfung

  ```
  $ cosign verify-blob trivy_0.58.0_Linux-64bit.tar.gz\
    --certificate trivy_0.58.0_Linux-64bit.tar.gz.pem\
    --signature trivy_0.58.0_Linux-64bit.tar.gz.sig\
    --certificate-identity-regexp 'https://github\.com/aquasecurity/trivy/\.github/workflows/.+' \
    --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
  Verified OK
  ```

Trivy auspacken und installieren
--------------------------------

- Temporäres Verzeichnis anlegen und reinwechseln: `mkdir /tmp/trivy-extract && cd /tmp/trivy-extract`

- Auspacken: `gzip -cd $HOME/Downloads/trivy_0.58.0_Linux-64bit.tar.gz|tar -xf -`

- Installieren: Datei "trivy" irgendwo hinkopieren, wo sie im PATH liegt. Bspw. nach "$HOME/bin".
  Achtung: Wenn "root" die Prüfungen durchführen soll, dann **unbedingt** irgendwo ablegen, wo nur
  "root" Schreibzugriff hat! Also niemals sowas wie `sudo /home/uli/bin/trivy ...` ausführen!

- Test: `trivy version` -> Version: 0.58.0

- Temporäres Verzeichnis löschen: `rm -rf /tmp/trivy-extract`

Links
-----

- [Github - Trivy - Releases](https://github.com/aquasecurity/trivy/releases)

Versionen
---------

Getestet mit Ubuntu-22.04 und Trivy-v0.58.0.

Historie
--------

- 2024-12-23: Erste Version

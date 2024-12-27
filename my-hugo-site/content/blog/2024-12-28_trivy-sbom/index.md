+++
date = '2024-12-28'
draft = false
title = 'Erstellung einer Software-Inventurliste (SBOM) mit Trivy'
categories = [ 'Trivy' ]
tags = [ 'trivy', 'sicherheit', 'sbom' ]
+++

<!--
Erstellung einer Software-Inventurliste (SBOM) mit Trivy
========================================================
-->

Hier beschreibe ich, wie ich eine
Software-Inventurliste (SBOM) mit Trivy erstelle.

<!--more-->

SBOM für ein Java-Projekt
-------------------------

```
cd springboot-hello-world
./gradlew --write-locks
trivy fs --format spdx-json --output springboot-hello-world.sbom.json .
```

Die Software-Inventurliste (SBOM) sieht dann so aus: [javaapp-sbom.json](springboot-hello-world.sbom.json).

SBOM für einen LXC/LXD-Container
--------------------------------

```
sudo nsenter --target "$(cat /var/snap/lxd/common/lxd.pid)" --mount\
   /root/bin/trivy rootfs --format spdx-json --output build-2004.sbom.json "/var/snap/lxd/common/lxd/containers/build-2004/rootfs/"
```

Die Software-Inventurliste (SBOM) sieht dann so aus: [lxc-lxd-sbom.json](build-2004.sbom.json).

Links
-----

- [Github - Trivy - Releases](https://github.com/aquasecurity/trivy/releases)

Versionen
---------

Getestet mit Ubuntu-20.04 und Trivy-v0.52.0.

Historie
--------

- 2024-12-28: Erste Version

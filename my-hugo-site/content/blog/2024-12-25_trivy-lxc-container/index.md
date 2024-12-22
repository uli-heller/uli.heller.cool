+++
date = '2024-12-25'
draft = false
title = 'Sicherheitsscan eines LXC/LXD-Containers mit Trivy'
categories = [ 'Trivy' ]
tags = [ 'trivy', 'sicherheit', 'lxc', 'lxd' ]
+++

<!--
Sicherheitsscan eines LXC/LXD-Containers mit Trivy
==================================================
-->

Hier beschreibe ich, wie ich einen LXC/LXD-Container mit Trivy
auf Schwachstellen untersuche.

<!--more-->

Ich würde gerne einen laufenden LXC/LXD-Container mit Trivy scannen.
Klar: Ich könnte ihn exportieren und dann den Export scannen. Das erzeugt aber
sehr viel Zusatzaufwand und kostet viel Zeit!

Ich gehe so vor:

- Trivy für Nutzer "root" einrichten - /root/bin/trivy
- Prozess-ID vom LXD-Daemon ermitteln: `cat /var/snap/lxd/common/lxd.pid` -> 1957718
- LXC/LXD-Container ermitteln: `lxc ls --format csv --columns n`
  (gibt nur die Namen der Container aus)
- LXC/LXD-Container auswählen: build-2404
- Scan durchführen:

  ```
  $ sudo nsenter --target "$(cat /var/snap/lxd/common/lxd.pid)" --mount\
     /root/bin/trivy rootfs "/var/snap/lxd/common/lxd/containers/build-2404/rootfs/"
  2024-12-22T11:42:59+01:00	INFO	[vulndb] Need to update DB
  2024-12-22T11:42:59+01:00	INFO	[vulndb] Downloading vulnerability DB...
  2024-12-22T11:42:59+01:00	INFO	[vulndb] Downloading artifact...	repo="mirror.gcr.io/aquasec/trivy-db:2"
    57.93 MiB / 57.93 MiB [-----------------------------------------------------------------------------] 100.00% 4.47 MiB p/s 13s
  2024-12-22T11:43:14+01:00	INFO	[vulndb] Artifact successfully downloaded	repo="mirror.gcr.io/aquasec/trivy-db:2"
  2024-12-22T11:43:14+01:00	INFO	[vuln] Vulnerability scanning is enabled
  2024-12-22T11:43:14+01:00	INFO	[secret] Secret scanning is enabled
  2024-12-22T11:43:14+01:00	INFO	[secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
  2024-12-22T11:43:14+01:00	INFO	[secret] Please see also https://aquasecurity.github.io/trivy/v0.58/docs/scanner/secret#recommendation for faster secret detection
  ...
  2024-12-22T11:48:03+01:00	INFO	[javadb] Java DB is cached for 3 days. If you want to update the database more frequently, "trivy clean --java-db" command clears the DB cache.
  2024-12-22T11:48:03+01:00	WARN	Provide a higher timeout value, see https://aquasecurity.github.io/trivy/v0.58/docs/configuration
  2024-12-22T11:48:03+01:00	FATAL	Fatal error	rootfs scan error: scan error: scan failed: failed analysis: post analysis error: post analysis error: walk dir error: context deadline exceeded

  $ sudo nsenter --target "$(cat /var/snap/lxd/common/lxd.pid)" --mount\
     /root/bin/trivy rootfs "/var/snap/lxd/common/lxd/containers/build-2404/rootfs/"\
     --scanners vuln
  ...
  2024-12-22T11:50:56+01:00	INFO	Detected OS	family="ubuntu" version="24.04"
  2024-12-22T11:50:56+01:00	INFO	[ubuntu] Detecting vulnerabilities...	os_version="24.04" pkg_num=907
  2024-12-22T11:50:56+01:00	INFO	Number of language-specific files	num=0
  
  build-2404 (ubuntu 24.04)
  
  Total: 720 (UNKNOWN: 0, LOW: 87, MEDIUM: 631, HIGH: 2, CRITICAL: 0)
  
  ┌───────────────────────────┬──────────────────┬──────────┬──────────┬────────────────────────────┬───────────────────┬──────────────────────────────────────────────────────────────┐
  │          Library          │  Vulnerability   │ Severity │  Status  │     Installed Version      │   Fixed Version   │                            Title                             │
  ├───────────────────────────┼──────────────────┼──────────┼──────────┼────────────────────────────┼───────────────────┼──────────────────────────────────────────────────────────────┤
  │ binutils                  │ CVE-2017-13716   │ LOW      │ affected │ 2.42-4ubuntu2.3            │                   │ binutils: Memory leak with the C++ symbol demangler routine  │
  │                           │                  │          │          │                            │                   │ in libiberty                                                 │
  │                           │                  │          │          │                            │                   │ https://avd.aquasec.com/nvd/cve-2017-13716                   │
  │                           ├──────────────────┤          │          │                            ├───────────────────┼──────────────────────────────────────────────────────────────┤
  │                           │ CVE-2018-20657   │          │          │                            │                   │ libiberty: Memory leak in demangle_template function         │
  │                           │                  │          │          │                            │                   │ resulting in a denial of service...                          │
  │                           │                  │          │          │                            │                   │ https://avd.aquasec.com/nvd/cve-2018-20657                   │
  ├───────────────────────────┼──────────────────┤          │          │                            ├───────────────────┼──────────────────────────────────────────────────────────────┤
  │ binutils-common           │ CVE-2017-13716   │          │          │                            │                   │ binutils: Memory leak with the C++ symbol demangler routine  │
  │                           │                  │          │          │                            │                   │ in libiberty                                                 │
  │                           │                  │          │          │                            │                   │ https://avd.aquasec.com/nvd/cve-2017-13716                   │
  │                           ├──────────────────┤          │          │                            ├───────────────────┼──────────────────────────────────────────────────────────────┤
  │                           │ CVE-2018-20657   │          │          │                            │                   │ libiberty: Memory leak in demangle_template function         │
  │                           │                  │          │          │                            │                   │ resulting in a denial of service...                          │
  │                           │                  │          │          │                            │                   │ https://avd.aquasec.com/nvd/cve-2018-20657                   │
  ...
  ├───────────────────────────┼──────────────────┤          │          ├────────────────────────────┼───────────────────┼──────────────────────────────────────────────────────────────┤
  │ snapd                     │ CVE-2024-5138    │          │          │ 2.65.3+24.04               │                   │ The snapctl component within snapd allows a confined snap to │
  │                           │                  │          │          │                            │                   │ interact ...                                                 │
  │                           │                  │          │          │                            │                   │ https://avd.aquasec.com/nvd/cve-2024-5138                    │
  ├───────────────────────────┼──────────────────┼──────────┤          ├────────────────────────────┼───────────────────┼──────────────────────────────────────────────────────────────┤
  │ wget                      │ CVE-2021-31879   │ MEDIUM   │          │ 1.21.4-1ubuntu4.1          │                   │ wget: authorization header disclosure on redirect            │
  │                           │                  │          │          │                            │                   │ https://avd.aquasec.com/nvd/cve-2021-31879                   │
  └───────────────────────────┴──────────────────┴──────────┴──────────┴────────────────────────────┴───────────────────┴──────────────────────────────────────────────────────────────┘

  ```

Links
-----

- [Github - Trivy - Releases](https://github.com/aquasecurity/trivy/releases)

Versionen
---------

Getestet mit Ubuntu-22.04 und Trivy-v0.58.0.

Historie
--------

- 2024-12-25: Erste Version

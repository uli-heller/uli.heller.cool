+++
date = '2024-12-04'
draft = false
title = 'TRIVY: JSON nach CSV wandeln'
categories = [ 'TRIVY' ]
tags = [ 'trivy', 'jq', 'json', 'csv', 'sqlite' ]
+++

<!--
TRIVY: JSON nach CSV wandeln
=========================
-->

TRIVE ist ein Sicherheitsscanner. Die Berichte des Scanners
kann man in verschiedenen Formaten erzeugen, bspw.
auch im HTML-Format zur Einbindung in Webseiten.
Leider fehlen dann gewisse Informationen, bspw. der SCORE.

Hier beschreibe ich, wie ich den TRIVY-Report im JSON-Format
mit JQ in's CSV-Format wandele.

<!--more-->

Wandel-Skript
-------------

[trivy-check-json-2-csv.sh](trivy-check-json-2-csv.sh)

```
jq -r '["score","severity","cve","pkgname","title","description","installed_version","fixed_version","target","class","type"],
       ( .Results[]
         |.Target as $target
         |.Class as $class
         |.Type as $type
         |.Vulnerabilities
           |select(.!=null)
           | .[]
           | [ ([ .CVSS|..|.V3Score?|select(. != null) ]|first), .Severity, .VulnerabilityID, .PkgName, .Title, .Description, .InstalledVersion, .FixedVersion, $target, $class, $type ]
       )|@csv'
```

Test
----

```
./trivy-check-json-2-csv.sh <ubuntu-2404.trivy-check.json >ubuntu-2404.trivy-check.csv
```

[ubuntu-2404.trivy-check.csv](ubuntu-2404.trivy-check.csv):

```csv
"score","severity","cve","pkgname","title","description","installed_version","fixed_version","target","class","type"
7,"MEDIUM","CVE-2024-52533","gir1.2-glib-2.0","glib: buffer overflow in set_connect_msg()","gio/gsocks4aproxy.c in GNOME GLib before 2.82.1 has an off-by-one error and resultant buffer overflow because SOCKS4_CONN_MSG_LEN is not sufficient for a trailing '\0' character.","2.80.0-6ubuntu3.1","2.80.0-6ubuntu3.2","/tmp/7af54f429a9c161382d6fdcb516d07cf984f92ef74caa02fddb218babeddd81d.sbom.json (ubuntu 24.04)","os-pkgs","ubuntu"
7,"MEDIUM","CVE-2024-52533","libglib2.0-0t64","glib: buffer overflow in set_connect_msg()","gio/gsocks4aproxy.c in GNOME GLib before 2.82.1 has an off-by-one error and resultant buffer overflow because SOCKS4_CONN_MSG_LEN is not sufficient for a trailing '\0' character.","2.80.0-6ubuntu3.1","2.80.0-6ubuntu3.2","/tmp/7af54f429a9c161382d6fdcb516d07cf984f92ef74caa02fddb218babeddd81d.sbom.json (ubuntu 24.04)","os-pkgs","ubuntu"
7,"MEDIUM","CVE-2024-52533","libglib2.0-data","glib: buffer overflow in set_connect_msg()","gio/gsocks4aproxy.c in GNOME GLib before 2.82.1 has an off-by-one error and resultant buffer overflow because SOCKS4_CONN_MSG_LEN is not sufficient for a trailing '\0' character.","2.80.0-6ubuntu3.1","2.80.0-6ubuntu3.2","/tmp/7af54f429a9c161382d6fdcb516d07cf984f92ef74caa02fddb218babeddd81d.sbom.json (ubuntu 24.04)","os-pkgs","ubuntu"
...
```

Weitere Umwandlungen nach Markdown und nach HTML
------------------------------------------------

```
sqlite3 trivy.db ".mode csv" ".import ubuntu-2404.trivy-check.csv cve"
sqlite3 trivy.db ".mode markdown" "select * from cve;" >ubuntu-2404.trivy-check.md
sqlite3 trivy.db ".mode html" "select * from cve;" >ubuntu-2404.trivy-check.html~
echo "<html><body><table>"        >ubuntu-2404.trivy-check.html
cat ubuntu-2404.trivy-check.html~ >>ubuntu-2404.trivy-check.html
echo "</table></body></html>"     >>ubuntu-2404.trivy-check.html
rm -f ubuntu-2404.trivy-check.html~
rm -f trivy.db
```

Erzeugte Dateien:

- Markdown: [ubuntu-2404.trivy-check.md](ubuntu-2404.trivy-check.md.txt)
- HTML: [ubuntu-2404.trivy-check.html](ubuntu-2404.trivy-check.html.txt)

Historie
--------

- 2024-12-30: trivy-json -> trivy-check-json (zur Abgrenzung gegenüber trivy-sbom-json)
- 2024-12-04: Erste Version

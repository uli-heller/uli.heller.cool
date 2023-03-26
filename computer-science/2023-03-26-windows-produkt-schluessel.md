---
layout: post
title: "Windows-Produkt-Schlüssel aus BIOS auslesen"
date: 2023-03-26 00:00:00
comments: false
author: Uli Heller (privat)
categories: bionic jammy
include_toc: true
published: true
---

<!--
Windows-Produkt-Schlüssel aus BIOS auslesen
===========================================
-->

Manche meiner Rechner habe ich mit Windows gekauft
und mit Linux "überklatscht". Hier beschreibe ich,
wie ich den Windows-Produkt-Schlüssel unter Linux aus dem
BIOS auslesen kann.

Hinweis: Das klappt leider nicht bei allen Rechnern!
Lenovo funktioniert, Dell eher nicht.

<!-- more -->

Wenn ein Windows-Produkt-Schlüssel im BIOS hinterlegt ist, so
liegt er unter Linux in der Datei "/sys/firmware/acpi/tables/MSDM"
ab. Wenn es diese Datei nicht gibt, dann ist kein
Windows-Produkt-Schlüssel im BIOS vorhanden.

Mit nachfolgenden Befehlen kann der Schlüssel angezeigt werden:

```
MSDM=/sys/firmware/acpi/tables/MSDM
if [ -e "${MSDM}" ]; then
  sudo tail -c29 "${MSDM}"
else
  echo >&2 "Kein Windows-Produkt-Schlüssel im BIOS vorhanden"
fi
```

Eventuell mußt Du das Kennwort Deines Benutzers eingeben,
damit `sudo` durchläuft. Der "eigentliche" Schlüssel kann
durch reguläre Linux-Nutzer leider nicht ausgelesen
werden.

Mögliche Ausgaben:

- `Kein Windows-Produkt-Schlüssel im BIOS vorhanden` ... alles klar?
- `ZD763-JRVWZ-1KPHR-H6KVO-BF3PZ` ... der Windows-Produkt-Schlüssel

Klar: Das oben ist kein "richtiger" Schlüssel, ich habe
ihn ersetzt durch Zufallsausgaben!

Änderungen
----------

* 2023-03-26: Erste Version auf uli.heller.cool

---
layout: post
title: "PDF-Schreibschutz entfernen"
date: 2023-01-29 00:00:00
comments: false
author: Uli Heller (privat)
categories: exfat bionic jammy
include_toc: false
published: true
---

<!--
PDF-Schreibschutz entfernen
===========================
-->

Manchmal bekomme ich PDF-Dokumente zugeschickt,
die ich unterschreiben soll. Das mache ich meist mit
der PDF-Schreib-Anwendung von Samsung. Leider weigert
sich die Samsung-Anwendung manchmal das Beschreiben
eines Dokumentes zuzulassen. Es erscheint eine
Anzeige wie "Dieses PDF-Dokument ist schreibgeschützt"
und das war's. Nachfolgend beschreibe ich, wie
ich das Problem umgehe.

<!-- more -->

Zur Umgehung benötigt ich GHOSTSCRIPT. Ich wandle damit
das Quell-PDF in ein beschreibbares Ziel-PDF und zwar
mit diesem Befehl:

```
gs -q -dNOPAUSE -dBATCH \
  -sDEVICE=pdfwrite \
  -sOutputFile=ziel.pdf \
  -c .setpdfwrite \
  -f quell.pdf
```

Links
-----

* [superuser.com: Removing PDF usage restrictions (duplicate)](https://superuser.com/questions/367184/removing-pdf-usage-restrictions)

Änderungen
----------

* 2023-01-29: Erste Version auf uli.heller.cool

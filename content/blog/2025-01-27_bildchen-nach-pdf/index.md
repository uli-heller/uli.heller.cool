+++
date = '2025-01-27'
draft = false
title = 'Bildchen nach PDF wandeln'
categories = [ 'Bildchen' ]
tags = [ 'pdf', 'imagemagick' ]
toc = false
+++

<!--
Bildchen nach PDF wandeln
=========================
-->

Manchmal bekomme ich einen Scan eines Dokumentes als Bild
zugespielt und soll dies unterschreiben. Ich nutze dafür
"WriteToPDF" und dies funktioniert nur für PDFs, nicht
für JPGs oder PNGs. Also: Wandeln ist angesagt!

<!--more-->

Voraussetzung
-------------

- Ubuntu-22.04
- ImageMagick einspielen:
  ```
  sudo apt update
  sudo apt install imagemagick
  ```

Ablauf
------

```
# convert (document).png (document.pdf)
convert a.png a.pdf
```

... wandelt das Bildchen "a.png" nach "a.pdf".
Funktioniert analog auch mit "a.jpg".

Problem
-------

### Fehlermeldung

```
$ convert a.png a.pdf
convert-im6.q16: attempt to perform an operation not allowed by the security policy `PDF' @ error/constitute.c/IsCoderAuthorized/426.
```

### Korrektur

Anpassung von "/etc/ImageMagick-6/policy.xml":

```diff
--- /etc/ImageMagick-6/policy.xml.orig	2025-01-23 22:34:09.965329480 +0100
+++ /etc/ImageMagick-6/policy.xml	2025-01-23 22:34:34.931335854 +0100
@@ -94,6 +94,6 @@
   <policy domain="coder" rights="none" pattern="PS2" />
   <policy domain="coder" rights="none" pattern="PS3" />
   <policy domain="coder" rights="none" pattern="EPS" />
-  <policy domain="coder" rights="none" pattern="PDF" />
+  <!-- <policy domain="coder" rights="none" pattern="PDF" />-->
   <policy domain="coder" rights="none" pattern="XPS" />
 </policymap>
```

Versionen
---------

- Ubuntu-22.04
- ImageMagick-8:6.9.11.60+dfsg-1.3ubuntu0.22.04.5

Links
-----

- [StackOverflow - ImageMagick security policy 'PDF' blocking conversion](https://stackoverflow.com/questions/52998331/imagemagick-security-policy-pdf-blocking-conversion)

Historie
--------

- 2025-01-27: Erste Version

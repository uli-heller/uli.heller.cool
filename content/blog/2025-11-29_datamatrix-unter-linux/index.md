+++
date = '2025-11-29'
draft = false
title = '2D-DataMatrix-Codes einlesen unter Linux'
categories = [ 'Sonstiges' ]
tags = [ 'linux', 'ubuntu' ]
+++

<!--
2D-DataMatrix-Codes einlesen unter Linux
============================
-->

Für einen meiner Kunde habe ich gelegentlich mit
einer Art QR-Code zu tun. Die Art sieht "anders"
aus als übliche QR-Codes. Eine Google-Suche
zeigt, dass es sich um einen "2D-DataMatrix-Code".

Standardprogramme wie `zbarimg` können damit leider
nicht umgehen. Mit etwas Suchen habe ich ein anderes
Programm gefunden, welches dafür geeignet ist.

<!-- more -->

Beispiel eines 2D-DataMatrix-Codes
----------------------------------

![Beispiel eines 2D-DataMatrix-Codes](matrix-code.png)

Ein Versuch mit ZBARIMG
-----------------------

```
$ zbarimg matrix-code.png 
scanned 0 barcode symbols from 1 images in 0 seconds

WARNING: barcode data was not detected in some image(s)
Things to check:
  - is the barcode type supported? Currently supported symbologies are:
	. EAN/UPC (EAN-13, EAN-8, EAN-2, EAN-5, UPC-A, UPC-E, ISBN-10, ISBN-13)
	. DataBar, DataBar Expanded
	. Code 128
	. Code 93
	. Code 39
	. Codabar
	. Interleaved 2 of 5
	. QR code
	. SQ code
  - is the barcode large enough in the image?
  - is the barcode mostly in focus?
  - is there sufficient contrast/illumination?
  - If the symbol is split in several barcodes, are they combined in one image?
  - Did you enable the barcode type?
    some EAN/UPC codes are disabled by default. To enable all, use:
    $ zbarimg -S*.enable <files>
    Please also notice that some variants take precedence over others.
    Due to that, if you want, for example, ISBN-10, you should do:
    $ zbarimg -Sisbn10.enable <files>
```

Google ist Dein Freund
----------------------

Eine Google-Suche nach "2D-Data-Matrix-Code scan linux"
liefert u.a. einen Link auf [scanbot.io - ata Matrix Code Scanner](https://scanbot.io/barcode-scanner-sdk/data-matrix/) und dort wiederum gibt
es einen Link nach [ask Ubuntu - Software to read a QR code?](https://askubuntu.com/questions/22871/software-to-read-a-qr-code).

dmtx-utils
----------

### Installieren

```
$ sudo apt install dmtx-utils
```

### Bild nach Text

```
$ dmtxread matrix-code.png
1
2
...
```

### Text nach Bild

```
$ seq 1 10 | dmtxwrite -o matrix-code.png
```

... erzeugt die Datei "matrix-code.png](matrix-code.png)

Hinweis: Mit der Standard-Version des Tools von Ubuntu-24.04
gibt es einen Abbruch mit einem Fehler!

Probleme
--------

### Erledigt - Absturz beim Erzeugen eines Bildes

Fehler:

```
$ echo -n 123456 | dmtxwrite -o message.png
*** buffer overflow detected ***: terminated
Abgebrochen
```

Korrektur:

```diff
--- dmtx-utils-0.7.6/dmtxwrite/dmtxwrite.c 2025-05-26 13:20:58.000000000 +0900
+++ dmtx-utils/dmtxwrite/dmtxwrite.c 2025-05-26 13:18:18.823289015 +0900
@@ -340,7 +340,7 @@

    /* Read input contents into buffer */
    for(bytesReadTotal = 0;; bytesReadTotal += bytesRead) {
- bytesRead = read(fd, codeBuffer + bytesReadTotal, DMTXWRITE_BUFFER_SIZE);
+ bytesRead = read(fd, codeBuffer + bytesReadTotal, DMTXWRITE_BUFFER_SIZE - bytesReadTotal);
       if(bytesRead == 0)
          break;
```

Versionen
---------

- Getestet unter Ubuntu-2404

Links
-----

- [Ubuntu - dmtx-utils package - Aborted (core dumped) on 24.04 Ubuntu version](https://bugs.launchpad.net/ubuntu/+source/dmtx-utils/+bug/2087948)
- [scanbot.io - ata Matrix Code Scanner](https://scanbot.io/barcode-scanner-sdk/data-matrix/)
- [ask Ubuntu - Software to read a QR code?](https://askubuntu.com/questions/22871/software-to-read-a-qr-code)

Historie
--------

- 2025-11-29: Erste Version

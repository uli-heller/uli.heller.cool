+++
date = '2025-05-29'
draft = false
title = 'Ubuntu: Alternativer Browser Epiphany'
categories = [ 'browser' ]
tags = [ 'linux', 'ubuntu', 'debian' ]
+++

<!--
Ubuntu: Alternativer Browser Epiphany
============================
-->

Manchmal möchte ich einen alternativen Browser
nutzen um das Erscheinungsbild von Webseiten zu überprüfen.
Unter Ubuntu bietet sich hierzu der Browser "Epiphany" an.

<!--more-->

Grundinstallation
-----------------

```sh
sudo apt update
sudo apt upgrade
sudo apt install epiphany-browser
```

Kurztest
--------

```sh
epiphany-browser https://heise.de
```

Sichten der Webseite klappt wunderbar!

![Heise OK](heise-ok.jpg)

Videos
------

```sh
epiphany-browser https://ard.de
```

Sobald man ein Video anwählt erscheint eine Anzeige wie
diese:

![Video KO](video-ko.jpg)

Auf der Konsole sieht man diverse Fehlermeldung. Diese
erscheinen auch nach der Korrekturmaßnahme noch, sind also
wohl irrelevant!

Korrektur mittels Anleitung [GStreamer - Installing on Linux](https://gstreamer.freedesktop.org/documentation/installing/on-linux.html?gi-language=c):

```
sudo apt install gstreamer1.0-plugins-bad
```

Danach klappt es!

![Video OK](video-ok.jpg)

Links
-----

- [GStreamer - Installing on Linux](https://gstreamer.freedesktop.org/documentation/installing/on-linux.html?gi-language=c)

Versionen
---------

- Getestet mit Ubuntu 24.04.2 LTS

Historie
--------

- 2025-05-29: Erste Version

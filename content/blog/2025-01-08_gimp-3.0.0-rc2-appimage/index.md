+++
date = '2024-12-31'
draft = false
title = 'GIMP: Appimage von Version 3.0.0-RC2 installieren'
categories = [ 'Bildchen' ]
tags = [ 'gimp' ]
+++

<!--GIMP: Appimage von Version 3.0.0-RC2 installieren-->
<!--=================================================-->

Die neuen Versionen von GIMP werden auch
als AppImage veröffentlicht. Hier beschreibe
ich, wie man sie herunterladet und einspielt.

<!--more-->

Herunterladen
-------------

- [Download-Seite von GIMP](gimp.org/downloads/)
- Development snapshots (ganz unten) - [development downloads page](https://www.gimp.org/downloads/devel/)
- Detailbeschreibung: Automatic AppImage development builds
- Gitlab-Server: [scheduled pipelines listing](https://gitlab.gnome.org/GNOME/gimp/-/pipeline_schedules)
- Zeile: AppImage - "Bestanden"- Anwählen
  - distribution - dist-appimage-weekly
  - Durchsuchen (rechts)
  - build
  - linux
  - appimage
  - _Output
  - x86_64.AppImage wählen und speichern
- [GIMP-3.0.0-RC2+git-x86_64.AppImage](https://gitlab.gnome.org/GNOME/gimp/-/jobs/4598011/artifacts/file/build/linux/appimage/_Output/GIMP-3.0.0-RC2+git-x86_64.AppImage)

Viruscheck
----------

- Hochladen nach https://virustotal.com
- Alles grün!

Einspielen
----------

- Ablegen irgendwo im PATH
- `chmod +x .../GIMP-3.0.0-RC2+git-x86_64.AppImage`

Links
-----

- [GIMP](https://www.gimp.org)

Historie
--------

- 2024-12-31: Erste Version

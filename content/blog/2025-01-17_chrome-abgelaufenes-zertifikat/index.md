+++
date = '2025-01-17'
draft = false
title = 'Chrome: Webseite mit abgelaufenem Zertifikat anzeigen'
categories = [ 'Chrome' ]
tags = [ 'chrome', 'zertifikat' ]
toc = true
+++

<!--
Chrome: Webseite mit abgelaufenem Zertifikat anzeigen
=====================================================
-->

Ich bin über diesen Artikel gestolpert: [https://www.idontplaydarts.com](https://www.idontplaydarts.com/2016/04/detecting-curl-pipe-bash-server-side/).
Leider ist das Zertifikat abgelaufen. So kann ich den Artikel in Chrome nicht ansehen.
Früher konnte man man "Zertifikatsfehler ignorieren" anklicken, das geht seit
einiger Zeit leider nicht mehr!

<!--more-->

Anzeige mittels archive.org
---------------------------

- Im Browser öffnen: [https://archive.org](https://archive.org)
- Search: www.idontplaydarts.com
- Search archived web sites: Ja
- Go
- "Letztes" Datum auswählen

Damit wird die Seite angezeigt!

Direkte Anzeige in Chrome
-------------------------

- Alle Chrome-Prozesse stoppen
- Neuen Chrome-Prozess starten via Kommandozeile: `google-chrome-stable --ignore-certificate-errors`
- Diverse Warnungen ignorieren
- Nun klappts: [https://www.idontplaydarts.com](https://www.idontplaydarts.com/2016/04/detecting-curl-pipe-bash-server-side/) - Zertifikat abgelaufen
- Getestet mit Google-Chrome Version Version 131.0.6778.204 (Offizieller Build) (64-Bit)

Links
-----

- [archive.org - Wayback-Machine](https://archive.org)
- [https://www.idontplaydarts.com](https://www.idontplaydarts.com/2016/04/detecting-curl-pipe-bash-server-side/) - Zertifikat abgelaufen

Historie
--------

- 2025-01-17: Erste Version

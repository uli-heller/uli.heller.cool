+++
date = '2025-05-13'
draft = false
title = 'Ubuntu: Installation von VLC'
categories = [ 'multimedia' ]
tags = [ 'linux', 'ubuntu', 'debian' ]
+++

<!--
Ubuntu: Installation von VLC
============================
-->

Für die Betrachtung von Videos nutze ich unter Ubuntu
gerne VLC. Leider gibt es bei Ubuntu-24.04 (noble) ein
paar Probleme!

<!--more-->

VLC-Start ohne Installation
---------------------------

Wenn man direkt nach dem Aufsetzen einer Standard-Installation
von Ubuntu-24.04 versucht VLC zu starten, dann erhält man diese
Ausgaben:

```sh
$ vlc
Der Befehl 'vlc' wurde nicht gefunden, kann aber installiert werden mit:
sudo snap install vlc      # version 3.0.20-1-g2617de71b6, or
sudo apt  install vlc-bin  # version 3.0.20-1build1
Informationen zu neuen Versionen sind mit 'snap info vlc' zu finden.
```

Als SNAP-Hasser kommt für mich nur die obere Variante nicht in Betracht!

VLC installieren gemäß Hinweisen
--------------------------------

Leider klappt die APT-Variante überhaupt nicht:

```sh
$ sudo apt install vlc-bin
Paketlisten werden gelesen… Fertig
Abhängigkeitsbaum wird aufgebaut… Fertig
Statusinformationen werden eingelesen… Fertig
...
Entpacken von vlc-bin (3.0.20-3build6) ...
vlc-bin (3.0.20-3build6) wird eingerichtet ...
Trigger für man-db (2.12.0-4build2) werden verarbeitet ...

$ vlc mein-film.mp4
VLC media player 3.0.20 Vetinari (revision 3.0.20-0-g6f0d0ab126b)

$
```

Beim Versuch einen Film abzuspielen wird nur die Versionsnummer
ausgegeben und es erscheint wieder ein Kommandozeilen-Prompt!

VLC "richtig" installieren
--------------------------

So klappt es:

```sh
$ sudo apt install vlc
...

$ vlc mein-film.mp4
VLC media player 3.0.20 Vetinari (revision 3.0.20-0-g6f0d0ab126b)
  # Film wird abgespielt
```

Der Hinweis stammt aus [dieser Reddit-Diskussion](https://www.reddit.com/r/Ubuntu/comments/1cjx0qp/vlc_is_not_working_in_244_lts/).

Links
-----

- [Reddit-Diskussion](https://www.reddit.com/r/Ubuntu/comments/1cjx0qp/vlc_is_not_working_in_244_lts/).

Versionen
---------

- Getestet mit Ubuntu 24.04.2 LTS

Historie
--------

- 2025-05-13: Erste Version

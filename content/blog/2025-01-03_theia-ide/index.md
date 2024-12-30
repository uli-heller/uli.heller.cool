+++
date = '2025-01-03'
draft = false
title = 'Erste Schritte mit Theia-IDE' 
categories = [ 'Theia' ]
tags = [ 'theia', 'java' ]
+++

<!--Erste Schritte mit Theia-IDE-->
<!--============================-->

Traditionell habe ich für meine Tätigkeit
als Java-Entwickler über viele Jahre hinweg
Eclipse verwendet. In letzter Zeit habe
ich wenig Java-Code erstellt und so den
Anschluß etwas verloren.

Meine Team-Mitarbeiter verwenden überwiegend
IntelliJ Idea. Das gefällt mir auch recht gut.

Dennoch möchte ich Theia-IDE mal ausprobieren.
Soll ja so eine Art "neue Generation" von Eclipse
sein. Mal sehen...

<!--more-->

Herunterladen und Einspielen
----------------------------

- [Theia IDE - Downloads](http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/theia/)
- Suchen: Wo liegt die neuste Version?
  - ide-preview
  - ide
  - latest
- Herunterladen von [TheiaIDE.AppImage](http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/theia/ide/1.57.100/linux/TheiaIDE.AppImage)
- Virustest, falls KO abbrechen!
- Ablegen in PATH und `chmod +x .../TheiaIDE.AppImage`

Kurztest
--------

Java-Projekt clonen: `git clone git@github.com:uli-heller/java-example-my-gradle-project.git`

TheiaIDE starten: `.../TheiaIDE.AppImage java-example-my-gradle-project`

Nach dem Start erscheint das Willkommen-Fenster.
Es enthält allgemeine Informationen und ist relativ uninteressant.
Am besten:

- Show welcome page on startup: Nein
- Welcome: Schliessen
- Dateien: Aktivieren

![Theia Willkommen](images/02-welcome-mit-anweisungen.png?width=800pt)

Danach kann man das Mini-Java-Projekt sichten:

- Dateien: Aktivieren (vermutlich bereits erfolgt)
- Java Projects: Hochschieben
- src/main/java: Aufklappen
- Main: Aktivieren

![Theia Main](images/05-java-main-mit-anweisungen.png?width=800pt)

Zuletzt noch Test, ob "Run" funktioniert:

![Theia Run](07-run-mit-anweisungen.png?width=800pt)

Erkenntnis
----------

Die Installation von TheiaIDE ist sehr einfach,
der erste Eindruck ist vielversprechend!

Notizen
-------

### Theia-Daten löschen

```
rm -rf "$HOME/.config/Theia IDE"
```

Links
-----

- [Eclipse IDE](https://eclipseide.org/)
- [IntelliJ Idea](https://www.jetbrains.com/de-de/idea/)
- [Theia IDE](https://theia-ide.org/)
- [Theia IDE - Downloads](http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/theia/)

Versionen
---------

Alle Tests durchgeführt unter Ubuntu-20.04
mit TheiaIDE.AppImage-1.57.100.

Historie
--------

- 2025-01-03: Erste Version

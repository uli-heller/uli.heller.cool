+++
date = '2024-11-25'
draft = false
title = 'Lizenzen'
categories = [ 'Hugo' ]
tags = [ 'hugo', 'lizenz' ]
+++

<!--
Lizenzen
========
-->

Momentan ist mir persönlich noch nicht 100%ig klar,
unter welcher Lizenz ich meine Artikel hier veröffentlichen
möchte. Stand November 2024 habe ich noch keine Lizenz
festgelegt. Das wird sich wahrscheinlich in den
nächsten Wochen oder Monaten ändern. In diesem Post
halte ich meine Gedanken dazu fest!

<!--more-->

Grundsätzliche Überlegungen
---------------------------

Ich höre immer wieder, dass ich eine Lizenz festlegen
muß um nicht in einer Grauzone zu landen.
Für mich ist klar, dass ich

- die Wiederverwendung grundsätzlich zulassen möchte
- bei Wiederverwendung in den Quellen genannt werden möchte
- nicht haftbar sein möchte wenn jemand die Posts
  "nachspielt" und dabei Schaden anrichtet
- gleiches für Aufgreifen der Posts und schadhafte Anwendung

Ob jemand mit der Verwendung Geld verdient oder nicht
ist mir persönlich erstmal egal!

Künstliche Intelligenz
----------------------

Etwas problematisch finde ich die Nutzung meiner Texte für's
Anlernen von KI-Modellen oder ähnlichem sowie den daran anschliessenden
Folgenutzungen. KI-Modelle erzeugen aus den angelernten Daten
für den Nutzer der Modelle neue Daten. Diese basieren auf den
für's Anlernen genutzten Quellen, also im Zweifel auf meinen
Texten. Der Nutzer kann dies aber nicht erkennen. Also kann
er auch den von mir gewünschten Quellverweis nicht erstellen.

Zur Vermeidung von "Unstimmigkeiten" möchte ich
die Verwendung für's Anlernen von KI-Modellen
ausschliessen! Mir geht es bei dem Ausschluss nicht um den
konkreten Ablauf des Anlernens oder um Begrifflichkeiten.

Was möchte ich zulassen?

- Verwendung in "Suchmaschinen". "Suchmaschinen" sind für mich
  in diesem Zusammenhang Einrichtungen, die meine Texte und/oder Bilder
  auswerten und ihren menschliche Nutzern präsentieren mit Hinweisen
  und Verweisen auf die Quellen

- Stand 2024 gibt es mehrere dieser "Suchmaschinen". Man gibt
  als menschlicher Nutzer Schlagworte ein und bekommt Auszüge aus Webseiten
  angezeigt samt Verweis auf die Webseite. Der menschliche Nutzer
  bewertet die erlangte Information und nutzt sie entsprechend den
  dahinterliegenden Lizenen. Diese Art der Nutzung
  finde ich absolut in Ordnung!

Was möchte ich nicht zulassen?

- Verwendung in "Wissenswolken". "Wissenswolken" sind für mich
  in diesem Zusammenhang Einrichtungen, die meine Texte und/oder Bilder
  auswerten, optional mit anderen Inhalten vermischen und
  ihren Nutzern präsentieren ohne sinnvollen Hinweisen
  auf die Quellen

- Stand 2024 gibt es mehrere dieser "Wissenswolken". Die aktuell
  bekannteste "Wissenswolke" ist wohl ChatGPT. Als Nutzer der "Wissenswolke"
  präsentiere ich eine Fragestellung und erhalte als Ergebnis eine
  Vermischung aus den Eingangsdaten der "Wissenswolke". Der Nutzer
  kann am Ergebnis die Quellen nicht mehr erkennen. Er kann also die
  dahinterliegenden Lizenzen auch nicht einhalten. Diese Art der Nutzung
  möchte ich ausschliessen!

Im Artikel
[The future is now: Künstliche Intelligenz und das Urheberrecht](https://www.haufe.de/recht/weitere-rechtsgebiete/kuenstliche-intelligenz-und-das-urheberrecht_216_588912.html)
wird darauf hingewiesen, dass Einschränkungen der oben genannten Art
nur zulässig sind, wenn sie in maschinenlesbarer Form bereitgestellt werden.
Die maschinenlesbare Form findet sich hier: [robots.json](/robots.json).

Für Techniker:

```json
{
  "search": true,
  "ai":     false
}
```

"search" und "ai" entsprechen dabei den vorgenannten Bereichen "Suchmaschine"
und "Wissenswolke". 'true' bedeutet, dass die entsprechende Nutzung zugelassen ist,
'false' schliesst die Nutzung aus!

Entscheidungshilfen
-------------------

Ein Ausgangspunkt für die Lizenz scheint mir [Creative Commons](https://creativecommons.org) zu sein.
Dort gibt es einen ["Lizenz-Wähler"](https://chooser-beta.creativecommons.org/). Wenn ich den
durchspiele, dann wird die Lizenz [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
gewählt. Hier die Lizenzbedingungen in einfach verständlicher Form:
[NAMENSNENNUNG-SHARE ALIKE 4.0 INTERNATIONAL](https://creativecommons.org/licenses/by-sa/4.0/deed.de).

CreativeCommons-Lizenz-Auswähler
--------------------------------

- License Expertise
  - Do you know which license you need? -> No
- Attribution
  - Do you want attribution for your work? -> Yes
- Commercial Use
  - Do you want to allow others to use your work commercially? -> Yes
- Derivative Works
  - Do you want to allow others to remix, adapt, or build upon your work? -> Yes
- Sharing Requirements
  - Do you want to allow others to share adaptations of your work under any terms? -> No
- Confirm that CC licensing is appropriate
  - I own or have authority to license the work -> Yes
  - I have read and understand the terms of the license -> Yes
  - I understand that CC licensing is not revocable -> Yes
- Attribution Details
  - Title: Ulis Welt ... da läuft was!
  - Creator: Uli Heller
  - Link to Work: https://uli.heller.cool
  - Link to Profile: https://uli.heller.cool/about
  - Year Of Creation: 2024

Ergebnis:

- Text: "Ulis Welt ... da läuft was! © 2024 by Uli Heller is licensed under CC BY-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/"
- HTML: <p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://uli.heller.cool">Ulis Welt ... da läuft was!</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://uli.heller.cool/about">Uli Heller</a> is licensed under <a href="https://creativecommons.org/licenses/by-sa/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-SA 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/sa.svg?ref=chooser-v1" alt=""></a></p>
- Markdown: [Ulis Welt ... da läuft was!](https://uli.heller.cool) (c) 2024 by [Uli Heller](https://uli.heller.cool/about) is licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) ![logo](images/logo.svg?width=20em)![by](images/by.svg?width=20em)![sa](images/sa.svg?width=20em)

Noch zu erledigen
-----------------

Jetzt muß ich die ausgewählte Lizenz noch in
die Fußzeile einbauen!

Links
-----
 [Creative Commons](https://creativecommons.org/licenses/by-nc-nd/4.0/)
 https://creativecommons.org/licenses/by-sa/4.0/deed.de
 https://creativecommons.org/licenses/by-sa/3.0/de/deed.de
 ["Lizenz-Wähler"](https://chooser-beta.creativecommons.org/) 
- [Codeberg](https://codeberg.org)
- [Github](https://github.com)
- [Gitlab](https://gitlab.com)
- [Software Freedom Conservancy - Give Up Github!](https://sfconservancy.org/GiveUpGitHub/)
- [The future is now: Künstliche Intelligenz und das Urheberrecht](https://www.haufe.de/recht/weitere-rechtsgebiete/kuenstliche-intelligenz-und-das-urheberrecht_216_588912.html)

Historie
--------

- 2024-11-25: Erste Version

---
date: 2024-11-21
draft: true
title: Störende Details bei Hugo
categories:
 - Hugo
---

<!--Störende Details bei Hugo-->
<!--=========================-->

Ich verwende Hugo mit dem Theme "mainroad".
Einige Dinge stören mich. Diese sammle
ich hier, idealerweise mit Lösungen.

<!--more-->

Offen
-----

- 2024-11-21_01 - Persönliches Styling. Die Aufmachung muß ein wenig personalisiert
  werden, damit ich mich "wiederfinde".

- 2024-11-21_02 - Breite: Wenn ich das Browser-Fenster sehr breit ziehe, dann
  erscheint rechts und links ein zunehmend breiter Rahmen.
  Entspricht aktuell dem Zeitgeist, mich stört es. Ich würde lieber
  mehr Text sehen!

- 2024-11-21_03 - Kopf- und Fußzeilen bleiben nicht sichtbar. Wenn ich durch
  eine längere Seite blättere, dann verschwinden Kopf- und Fußzeilen.
  Ich würde mir wünschen, dass diese (zumindest auf meinem Arbeitsplatzrechner)
  dauernd sichtbar sind!

- 2024-11-21_04 - Klären: Was hat es mit den "Categories" und "Tags" auf
  sich?

- 2024-11-21_06 - Reihenfolge in Menü und im Recent-Widget unklar

Erledigt
--------

- 2024-11-21_05 - Klären: Wie passe ich das Menü an? Was erscheint dort? Was
  nicht?

  Das geht via "Front Matter" in einem Betrag:

  ```
  menu:
    main:
      name: FAQ
  #
  # oder
  #
  title: Getting started
  menu: main
  ```

  Geht auch via "_index.md" in einem Verzeichnis!

Historie
--------

- 2024-11-21: Erste Version
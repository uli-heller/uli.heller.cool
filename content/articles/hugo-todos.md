---
date: 2024-11-21
draft: false
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

- 2024-11-21_03 - Kopf- und Fußzeilen bleiben nicht sichtbar. Wenn ich durch
  eine längere Seite blättere, dann verschwinden Kopf- und Fußzeilen.
  Ich würde mir wünschen, dass diese (zumindest auf meinem Arbeitsplatzrechner)
  dauernd sichtbar sind!

- 2024-11-21_04 - Klären: Was hat es mit den "Categories" und "Tags" auf
  sich?

- 2024-11-22_01 - Bilder in den Übersichtseiten nicht sichtbar.
  Beispiel: "Hugo: Breitenlimitierung aufheben"

  - [Relative linking in Hugo](https://nick.groenen.me/notes/relative-linking-in-hugo/)
    - https://github.com/zoni/obsidian-export/issues/8#issuecomment-774521792
  - [Hugo - relative paths in page bundles](https://stackoverflow.com/questions/53464336/hugo-relative-paths-in-page-bundles)
  - [Image processing](https://gohugo.io/content-management/image-processing/)
    - Legt nahe, dass die URL keinen Pfad enthalten darf
    - Klappt leider nicht!

  Hier gibt es ein paar Testseiten:

  - [Übersicht](/tests) - Bilder fehlen
  - [Detailseite](/tests/2024-11-22_01-relative-links-to-images) - Bilder sind sichtbar

Erledigt
--------

- 2024-11-21_02 - Breite: Wenn ich das Browser-Fenster sehr breit ziehe, dann
  erscheint rechts und links ein zunehmend breiter Rahmen.
  Entspricht aktuell dem Zeitgeist, mich stört es. Ich würde lieber
  mehr Text sehen!

- 2024-11-21_06 - Reihenfolge in Menü und im Recent-Widget unklar

  - Menü-Reihenfolge: weight
  - Recent-Reihenfolge: Neueste zuerst

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

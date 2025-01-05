---
date: 2024-11-21
draft: false
title: Störende Details bei Hugo
categories:
 - Hugo
tags:
 - hugo
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

  - Stand 2024-11-23 gibt es diese "Categories": Git, Hugo, Markdown
  - Stand 2024-11-23 gibt es diese "Tags": Github
  - Sollte "Tags" eine Obermenge von "Categories" sein?

- 2024-11-30_01 - Fußzeile erweitern um Lizenz

  - ./themes/mainroad/layouts/partials/footer_links.html
    - Wertet Site.Menus.footer aus
    - .URL und .Name definieren Links
  - ./themes/mainroad/layouts/partials/footer.html
    - Wertet Site.Params.copyright aus
    - Und Site.Title

- 2024-11-30_02 - LICENSE.txt

- 2024-11-30_04 - Fußzeile erweitern um "Edit in Github"

  - https://discourse.gohugo.io/t/hugo-v0-112-0-new-template-functions/44512

- 2024-12-02_01 - Inhaltsverzeichnis ein- und ausblendbar

- 2024-12-03_01 - Sichten von [HugoBlox](https://docs.hugoblox.com/)

- 2024-12-03_02 - Sichten von [ThomasVölkl](https://thomas-voelkl.de/hugo-website-erstellen/)

  - Erstellt mit Hugo und "mainroad" (zunächst)
  - Nutzt Hugo und "clarity" (aktuell)

- 2024-12-04_01 - Clarity

  - [Change From Beautifulhugo to Clarity Theme](https://blog.euc-rt.me/post/change-from-beautifulhugo-to-clarity-theme)
  - [Adding a floating TOC to the Hugo-Clarity theme](https://www.nodinrogers.com/post/2023-04-06-add-floating-toc-in-hugo-clarity-theme)
  - [Organizing page resources](https://github.com/chipzoller/hugo-clarity#organizing-page-resources)

- 2024-12-11_01 - [Michael Welford](https://its.mw/)

  - [Custom code blocks in Hugo](https://its.mw/posts/custom-code-blocks-hugo/) - mit "Unterschriften" und "Copy"

- 2024-12-11_02 - [Hugo Survival Guide](https://gist.github.com/janert/4e22671044ffb06ee970b04709dd7d81)

  - Beschreibt viele Hugo-Konzepte

- 2024-12-11_03 - [DecapCMS](https://github.com/decaporg/decap-cms)

  - CMS für Hugo (und andere StaticSiteGenerators)

- 2024-12-11_04 - [Tag-Cloud für Hugo](https://blog.cubieserver.de/2020/adding-a-tag-cloud-to-my-hugo-blog)

- 2024-12-11_05 - [Diagramme in Hugo](https://gohugo.io/content-management/diagrams)

- 2024-12-19_01 - Fehlermeldungen beim Test mit `hugo -D -E -F server`

  ```
  WARN  Raw HTML omitted while rendering "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/content/blog/2024-12-03_jq-nach-csv/index.md"; see https://gohugo.io/getting-started/configuration-markup/#rendererunsafe
  You can suppress this warning by adding the following to your site configuration:
  ignoreLogs = ['warning-goldmark-raw-html']
  ```

- 2024-12-21_01 - [Kommentare mit Utterances](https://www.softwarecraftsperson.com/posts/2024-02-04-blog-comments-using-utterances/)

- 2024-12-21_02 - [Theme PaperMod](https://www.softwarecraftsperson.com/posts/2024-11-09-responsive-menu/)

- 2024-12-29_01 - Clarity: Logo+Motto oben links

- 2024-12-29_02 - Clarity: Home

- 2024-12-29_03 - Clarity: Suchen

- 2024-12-29_04 - Clarity: Bildbreite

- 2024-12-29_05 - Clarity: Textbreite

- 2024-12-29_06 - Clarity: Menübreite

- 2024-12-29_08 - Clarity: Inhaltsverzeichnis - [Adding a floating TOC to the Hugo-Clarity theme | No D in Rogers](https://www.nodinrogers.com/post/2023-04-06-add-floating-toc-in-hugo-clarity-theme/)

- 2024-12-29_09 - Clarity: Copyright + Lizenz

Erledigt
--------

- 2024-12-29_07 - Clarity: Aktiven Eintrag im Menü markieren

  - Siehe [Hugo-Clarity: Diverse Kleinprobleme]({{< ref "/blog/2025-01-05_hugo-clarity-probleme" >}})

- 2024-12-11_01 - [More Hugo Tipps](https://its.mw/posts/more-hugo-tips-tricks/), robots.txt

- 2024-11-30_03 - Lizenzseite

- 2024-12-01_01 - Inhaltsverzeichnis

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

- 2025-01-05: Aktualisierung einiger TODOs beim Theme "Clarity"
- 2024-12-29: Viele TODOs beim Theme "Clarity"
- 2024-12-21: [Kommentare mit Utterances](https://www.softwarecraftsperson.com/posts/2024-02-04-blog-comments-using-utterances/)
    und [Theme PaperMod](https://www.softwarecraftsperson.com/posts/2024-11-09-responsive-menu/)
- 2024-12-19: Fehlermeldungen beim Test mit `hugo -D -E -F server`
- 2024-12-15: TODO bzgl. robots.txt erledigt
- 2024-12-11: Viele neue TODOs und Links
- 2024-12-06: Clarity und PageBundles
- 2024-12-03: Clarity
- 2024-11-30: Mehr TODOs bzgl. Fusszeile und Lizenz
- 2024-11-21: Erste Version

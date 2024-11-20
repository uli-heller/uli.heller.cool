Spielereien mit  Hugo und DPSG
==============================

Vorbereitungen
--------------

- Hugo muß verfügbar sein
- "quickstart" muß verfügbar sein
- Theme DPSG muß aktiviert sein
- config.toml -> hugo.toml aus DPSG muß aktiv sein

Ein paar Veröffentlichungen
---------------------------

### Ein erster Artikel

- Verzeichnis anlegen: quickstart/content/blog
- Datei anlegen:  quickstart/content/blog/2024-11-20_erster-blog-eintrag.md
- Anpassen aller Referenzen auf "placeholder": `find . -type f|xargs -n1 sed -i -e "s/placeholder.jpg/placeholder.png/g"`

Was "sieht" an?

- Dateiname: Erscheint in der URL in der Adresszeile
- Daten aus dem Dateikopf
  - title
    - Überschrift
    - Letzte Beiträge
  - date

### Noch ein Artikel

- Kopieren: quickstart/content/blog/2024-11-20_erster-blog-eintrag.md -> quickstart/content/blog/2024-11-19_nullter-blog-eintrag.md
- Inhaltlich anpassen
- "menu:" auskommentieren

### Notizen

Hier erscheinen Posts, die in einem Unterordner des content/ Ordners abgelegt werden (z.B. in content/post). Standardmäßig werden nur Posts der Gruppe mit den meisten Einträgen angezeigt.

```
[Params]
 ...
 mainSections = ["post", "blog", "news"] # Specify section pages to show on home page and the "Recent articles" widget
```

Umstellung auf "Deutsch"
------------------------

Anpassen der Farben
-------------------

Anpassen des Bildes oben
------------------------

Verhalten beim Ziehen in die Breite optimieren
----------------------------------------------

Kopf- und Fusszeilen eingeblendet lassen
----------------------------------------

Links
-----

- [Hugo - Getting started - Quick start](https://gohugo.io/getting-started/quick-start/)
- [Hugo - Installation](https://gohugo.io/installation/linux/)
  - [Hugo - Downloads](https://github.com/gohugoio/hugo/releases/latest)
- Themes
  - [Ananke](https://themes.gohugo.io/themes/gohugo-theme-ananke/)
  - [DSGO](https://themes.gohugo.io/themes/hugo-dpsg/)
  
Historie
--------

- 2024-11-03 - Erste Version

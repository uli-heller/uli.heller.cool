+++
date = '2024-11-23'
draft = false
title = 'Hugo: Bilder bei Page Bundles'
categories = [ 'Hugo' ]
tags = [ 'hugo' ]
+++

<!--
Hugo: Bilder bei Page Bundles
=============================
-->

Ich verwende auf meiner Hugo-Seite gerne [Page Bundles](https://gohugo.io/content-management/page-bundles/).
Die erlauben mir, alle Teile eines Dokuments in einem Ordner abzulegen.
Damit weiß ich dann, was zusammengehört und kann so veraltete
Dokumente problemlos löschen.

Leider stellt sich heraus, dass es Probleme mit Bildern gibt.
Wenn eine Seite auf dem Page Bundle auf ein Bild innerhalb des Bundles
verweist, dann funktioniert das Einblenden des Bildes in
der Detailansicht problemlos. In der Dokumenten-Übersicht
wird das Bild aber nicht dargestellt. Das sieht dann so wie hier aus:

![Nicht angezeigtes Testbild](testbild-gibt-es-nicht.png)

Damit das Bild in der Dokumenten-Übersicht angezeigt wird, muß es auf jeden
Fall oberhalb von "\<\!--more--\>" stehen! Obiges Bild ist bewusst "kaputt".
Es wird **immer** als kaputt angezeigt!

<!--more-->

Abhilfe
-------

Aus meiner Sicht wird das Problem an einfachsten
korrigiert durch [Image render hooks - Default](https://gohugo.io/render-hooks/images/#default).
Bei mir sieht das so aus:

```diff
diff --git a/my-hugo-site/hugo.toml b/my-hugo-site/hugo.toml
index 5ba0696..84b7c7d 100644
--- a/my-hugo-site/hugo.toml
+++ b/my-hugo-site/hugo.toml
@@ -37,3 +37,9 @@ googleAnalytics = "" # Enable Google Analytics by entering your tracking id
 [Params.widgets]
   recent_num = 10 # Set the number of articles in the "Recent articles" widget
   tags_counter = false # Enable counter for each tag in "Tags" widget (disabled by default)
+
+[markup]
+  [markup.goldmark]
+    [markup.goldmark.renderHooks]
+      [markup.goldmark.renderHooks.image]
+        enableDefault = true
```

Danach werden die Bilder auch in der Übersicht korrekt angezeigt!

Links
-----

- [Page Bundles](https://gohugo.io/content-management/page-bundles/)
- [Image render hooks - Default](https://gohugo.io/render-hooks/images/#default)

Historie
--------

- 2024-11-23: Erste Version

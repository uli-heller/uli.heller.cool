+++
date = '2024-11-27'
draft = false
title = 'Hugo: Ränder entfernen'
categories = [ 'Hugo' ]
tags = [ 'hugo', 'mainroad' ]
+++

<!--
Hugo: Ränder entfernen
======================
-->

Bei meiner Webseite stören mich die Ränder oben und an den Seiten.
Sind zwar nur ein paar Pixel, dennoch sollen sie weg:

![rand](images/hugo-rand_roh.png?width=500)

<!--more-->

"Halbe" Korrektur
-----------------

```diff
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site/content/blog/2024-11-27_hugo-mainroad-rand$ git diff 'kein-rand~1..kein-rand'
diff --git a/my-hugo-site/themes/mainroad/assets/css/style.css b/my-hugo-site/themes/mainroad/assets/css/style.css
index a64bc86..b2f024d 100644
--- a/my-hugo-site/themes/mainroad/assets/css/style.css
+++ b/my-hugo-site/themes/mainroad/assets/css/style.css
@@ -67,8 +67,8 @@ body {
 }
 
 .container--outer {
-       margin: 25px auto;
-       box-shadow: 0 0 10px rgba(50, 50, 50, .17);
+       /*margin: 25px auto;*/
+       /*box-shadow: 0 0 10px rgba(50, 50, 50, .17);*/
 }
 
 .wrapper {
```

Danach sieht es so aus:

![rand](images/hugo-rand-rechts-links.png?width=500)

Der obere Rand ist weg, rechts und links gibt es aber noch einen Rand!

Weitergehende Analyse
---------------------

Wenn ich die Menüzeile bei verschiedenen Breiten des Browserfensters
beobachte, dann stelle ich fest:

- Breite kleiner 900px: Kein Rand links und rechts
- Breite größer 900px: Rand links und rechts

Also:

- Theme "mainroad" durchsuchen nach 900px
- Gefunden in themes/mainroad/assets/css/style.css
- Ändern auf 9000px
- Sichten -> klappt nun, Menü ist immer ohne Rand

```diff
diff --git themes/mainroad/assets/css/style.css themes/mainroad/assets/css/style.css
index 72d9df7..c0f66e4 100644
--- themes/mainroad/assets/css/style.css
+++ themes/mainroad/assets/css/style.css
@@ -1197,7 +1197,7 @@ textarea {
         }
 }
 
-@media screen and (max-width: 900px) {
+@media screen and (max-width: 9000px) {
         .container--outer {
                 width: 100%;
                 margin: 0 auto;
```

Versionen
---------

Getestet mit

- hugo v0.136.5-46cc...
- Theme: mainroad, main, commit:13e04b3694ea2d20a68cfbfaea42a8c565079809

Historie
--------

- 2024-12-01: Leider nur halbe Korrektur und weitergehende Analyse
- 2024-11-27: Erste Version

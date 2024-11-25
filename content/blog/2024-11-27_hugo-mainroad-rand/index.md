+++
date = '2024-11-27'
draft = true
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

Korrektur
---------

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

Versionen
---------

Getestet mit

- hugo v0.136.5-46cc...
- Theme: mainroad, main, commit:13e04b3694ea2d20a68cfbfaea42a8c565079809

Historie
--------

- 2024-11-27: Erste Version

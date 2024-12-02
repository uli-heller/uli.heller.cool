+++
date = '2024-12-02'
draft = false
title = 'Hugo: Inhaltsverzeichnis'
categories = [ 'Hugo' ]
tags = [ 'hugo', 'mainroad' ]
+++

<!--
Hugo: Inhaltsverzeichnis
========================
-->

Wie aktiviert man global in allen Artikeln
das Inhaltsverzeichnis? Wie deaktiviert man
es für einzelne Artikel?

<!--more-->

Globale Aktivierung des Inhaltsverzeichnisses
---------------------------------------------

Die globale Aktivierung erfolgt durch Anpassung
der Datei "hugo.toml". Eigentlich sollte es mittels
`tableOfContents=true` funktionieren. Da klappt
bei mir zumindest mit dem Theme "mainroad" nicht.
Über `Params.toc=true` geht's!

```diff
diff --git hugo.toml hugo.toml
index 7103dfb..5ffecf8 100644
--- hugo.toml
+++ hugo.toml
@@ -7,6 +7,7 @@ theme = "mainroad"
 disqusShortname = "" # Enable comments by entering your Disqus shortname
 googleAnalytics = "" # Enable Google Analytics by entering your tracking id
 enableGitInfo   = true
+#tableOfContents = true #  2024-12-01_01: Parameter funktioniert zumindest mit 'mainroad' nicht, siehe unten!
 
@@ -20,6 +21,7 @@ enableGitInfo   = true
 [Params]
   readmore = true # Show "Read more" button in list if true - Weiterlesen...
   authorbox = true
   pager = true
+  toc = true #  2024-12-01_01: Parameter funktioniert mit 'mainroad'
   post_meta = ["date", "categories"] # Order of post meta information
   mainSections = [ "articles", "blog" ]
```

Deaktivierung für einzelne Artikel
----------------------------------

Für einen einzelnen Artikel kann man
das Inhaltserzeichnis deaktivieren mittels
"FrontPage". Das ist der Parameterblock am
Beginn des Artikels.

```diff
diff --git content/blog/2024-12-05_lxc-mit-netzwerk/index.md content/blog/2024-12-05_lxc-mit-netzwerk/index.md
index e27231c..db524d2 100644
--- content/blog/2024-12-05_lxc-mit-netzwerk/index.md
+++ content/blog/2024-12-05_lxc-mit-netzwerk/index.md
@@ -4,6 +4,7 @@ draft = false
 title = 'LXC/LXD: Grundeinrichtung mit Netzwerk'
 categories = [ 'LXC/LXD' ]
 tags = [ 'lxc', 'lxd', 'linux', 'ubuntu', 'debian' ]
+toc = false
 +++
 
 <!--
```

Links
-----

- [Hugo: How to Add a Table of Contents (TOC) to Your Post?](https://juliecodestack.github.io/2023/04/21/hugo-toc/)
- [Mainroad - README.md](https://github.com/Vimux/Mainroad/blob/master/README.md)

Versionen
---------

Getestet mit

- hugo v0.136.5-46cc...
- Theme: mainroad, main, commit:13e04b3694ea2d20a68cfbfaea42a8c565079809

Historie
--------

- 2024-12-02: Erste Version

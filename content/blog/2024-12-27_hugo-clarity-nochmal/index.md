+++
date = '2024-12-27'
draft = false
title = 'Hugo: Nochmal umstellen auf das Theme Clarity'
categories = [ 'Hugo' ]
tags = [ 'hugo', 'clarity' ]
+++

<!--
Hugo: Nochmal umstellen auf das Theme Clarity
=============================================
-->

Der Versuch der Umstellung auf das Theme "Clarity" ist vor ein
paar Tagen gescheitert. Details stehen hier:
[Hugo: Kurztest vom Theme Clarity]({{< ref "blog/2024-12-12_hugo-clarity-kurztest" >}}).
Danach habe ich weitere Tests durchgeführt. Diese waren relativ
erfolgreich. Details: [Hugo: Neustart mit dem Theme Clarity]({{< ref "blog/2024-12-22_hugo-clarity-start" >}}).

Nun versuche ich erneut, meine Webseite umzustellen
auf das Theme Clarity.

<!--more-->

Git-Zweig anlegen
-----------------

```
git fetch --all
git pull --rebase
git checkout -b clarity
```

Theme Clarity installieren
--------------------------

Das Theme "Clarity" ist bereits im
Rahmen von [Hugo: Kurztest vom Theme Clarity]({{< ref "blog/2024-12-12_hugo-clarity-kurztest" >}})
eingespielt worden.

Theme Clarity aktivieren
------------------------

```
git rm hugo.toml
cp -a themes/hugo-clarity/exampleSite/config .
```

Theme Clarity anpassen
----------------------

### PageBundles aktivieren - Links auf Bilder

```diff
diff --git a/my-hugo-site/config/_default/params.toml b/my-hugo-site/config/_default/params.toml
index 4fc2c74..3a3c661 100644
--- a/my-hugo-site/config/_default/params.toml
+++ b/my-hugo-site/config/_default/params.toml
@@ -27,7 +27,7 @@ numberOfTagsShown = 14 # Applies for all other default & custom taxonomies. e.g
 # Switch to `true` if you'd like to group assets with the post itself (as a "leaf bundle").
 # This can be overridden at the page level; what is set below acts as the default if no page variable is set.
 # Details on page bundles: https://gohugo.io/content-management/page-bundles/#leaf-bundles
-usePageBundles = false
+usePageBundles = true
 
 # Path variables
 #
```

### Standardsprache: Deutsch

```diff
diff --git a/my-hugo-site/config/_default/hugo.toml b/my-hugo-site/config/_default/hugo.toml
index 387c99f..bc51023 100644
--- a/my-hugo-site/config/_default/hugo.toml
+++ b/my-hugo-site/config/_default/hugo.toml
@@ -8,7 +8,7 @@ copyright = "Copyright © 2008–2018, Steve Francia and the Hugo Authors; all r
 theme = "hugo-clarity"
 disqusShortname = ""
 
-DefaultContentLanguage = "en"
+DefaultContentLanguage = "de"
 # [languages]
 # config/_default/languages.toml
```

### Sprachen: Deutsch und Englisch

```diff
diff --git a/my-hugo-site/config/_default/languages.toml b/my-hugo-site/config/_default/languages.toml
index 71ebefb..483b44e 100644
--- a/my-hugo-site/config/_default/languages.toml
+++ b/my-hugo-site/config/_default/languages.toml
@@ -1,11 +1,10 @@
+[de]
+  title = "Uli Heller ... da läuft was"
+  LanguageName = "Deutsch"
+  weight = 1
 [en]
-  title = "Clarity"
+  title = "Uli Heller ... there's something going on"
   LanguageName = "English"
-  weight = 1
-
-[pt]
-  title = "Claridade" # just for the sake of showing this is possible
-  LanguageName = "Português"
   weight = 2
 
   # tip: assign the default language the lowest Weight
```

### Menü rechts - Social links

- config/_default/menus/menu.en.toml
- config/_default/menus/menu.de.toml
- config/_default/menus/menu.pt.toml ... löschen

### TODOs

- Logo+Motto oben links
- Home
- Archives
- Links
  - LinkedIn
  - Twitter
- About
- Sprachen
- Rechts: Github
- Twitter
- LinkedIn
- RSS: OK
- JaneDoe
- Fusszeile

Test
----

```
hugo -D -E -F server
```

Browser: [http://localhost:1313](http://localhost:1313) öffnen

Links
-----

- [Github - Hugo-Clarity](https://github.com/chipzoller/hugo-clarity)
- [Getting Up And Running](https://github.com/chipzoller/hugo-clarity?tab=readme-ov-file#getting-up-and-running)
- [Clarity - Organizing page resources](https://github.com/chipzoller/hugo-clarity#organizing-page-resources)
- [Hugo: Kurztest vom Theme Clarity]({{< ref "blog/2024-12-12_hugo-clarity-kurztest" >}})
- [Hugo: Neustart mit dem Theme Clarity]({{< ref "blog/2024-12-22_hugo-clarity-start" >}})

Historie
--------

- 2024-12-27: Erste Version

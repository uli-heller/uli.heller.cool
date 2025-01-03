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

### Autor

```diff
diff --git a/my-hugo-site/config/_default/params.toml b/my-hugo-site/config/_default/params.toml
index 3a3c661..4e02aee 100644
--- a/my-hugo-site/config/_default/params.toml
+++ b/my-hugo-site/config/_default/params.toml
@@ -2,9 +2,9 @@
 enableSearch = true
 
 # socials
-twitter = "@janedoe"
+#twitter = "@janedoe"
 largeTwitterCard = false # set to true if you want to show a large twitter card image. The default is a small twitter card image
-introDescription = "Technologist, perpetual student, teacher, continual incremental improvement."
+introDescription = "Software-Entwicklung, Gutachten, Systemsicherheit, Datenschutz und Ausdauersport"
 # introURL = "about/" # set the url for the 'read more' button below the introDescription, or set to false to not show the button
 # description = "A theme based on VMware's Clarity Design System for publishing technical blogs with Hugo." # Set your site's meta tag (SEO) description here. Alternatively set this description in your home page content file e.g. content/_index.md. Whatever is set in the latter will take precedence.
 # keywords = ["design", "clarity", "hugo theme"] # Set your site's meta tag (SEO) keywords here. Alternatively set these in your home page content file e.g. content/_index.md. Whatever is set in the latter will take precedence.
@@ -150,7 +150,7 @@ blogDir = "post"
 
 # website author
 [author]
-name = "Jane Doe"
+name = "Uli Heller"
 # photo = "images/jane-doe.png" #include this if you would like to show the author photo on the sidebar
 
 [plausible_analytics]
```

### Logo

Konvertierung: `convert stuttgart.svg -transparent white -scale 40x stuttgart.png`

```diff
diff --git a/my-hugo-site/config/_default/params.toml b/my-hugo-site/config/_default/params.toml
index 4e02aee..83dd678 100644
--- a/my-hugo-site/config/_default/params.toml
+++ b/my-hugo-site/config/_default/params.toml
@@ -52,7 +52,7 @@ fontsDir = "fonts/" # without a leading forward slash
 fallBackOgImage = "images/thumbnail.png"
 
 # Logo image
-logo = "logos/logo.png"
+logo = "images/stuttgart.png"
 
 # center logo on navbar
 centerLogo = false # Set to "true" for centering or "false" for left aligned.
```

### Url korrigiert

Unklar: Was genau sind die Auswirkungen? Anscheinend braucht man's für die "share icons"...

```diff
diff --git a/my-hugo-site/config/_default/hugo.toml b/my-hugo-site/config/_default/hugo.toml
index bc51023..740e866 100644
--- a/my-hugo-site/config/_default/hugo.toml
+++ b/my-hugo-site/config/_default/hugo.toml
@@ -1,8 +1,8 @@
 # set `baseurl` to your root domain
 # if you set it to "/" share icons won't work properly on production
-baseurl = "https://example.com/"  # Include trailing slash
+baseurl = "https://uli.heller.cool/"  # Include trailing slash
 # title = "Clarity"  # Edit directly from config/_default/languages.toml # alternatively, uncomment this and remove `title` entry from the aforemention file.
```

### Fußzeile

Bislang erschien "Copyright" ud "all rights reserved" mehrfach in der Fußzeile.

```diff
diff --git a/my-hugo-site/config/_default/hugo.toml b/my-hugo-site/config/_default/hugo.toml
index b01eefe..740e866 100644
--- a/my-hugo-site/config/_default/hugo.toml
+++ b/my-hugo-site/config/_default/hugo.toml
@@ -2,7 +2,7 @@
 # if you set it to "/" share icons won't work properly on production
 baseurl = "https://uli.heller.cool/"  # Include trailing slash
 # title = "Clarity"  # Edit directly from config/_default/languages.toml # alternatively, uncomment this and remove `title` entry from the aforemention file.
-copyright = "Copyright © 2008–2018, Steve Francia and the Hugo Authors; all rights reserved."
+copyright = "Uli Heller"
 # canonifyurls = true
 
 theme = "hugo-clarity"
```

### Blog-Verzeichnis

```diff
diff --git a/my-hugo-site/config/_default/params.toml b/my-hugo-site/config/_default/params.toml
index 83dd678..2797713 100644
--- a/my-hugo-site/config/_default/params.toml
+++ b/my-hugo-site/config/_default/params.toml
@@ -67,7 +67,7 @@ codeLineNumbers = false
 enableMathNotation = false
 
 # directory(s) where your articles are located
-mainSections = ["post"] # see config details here https://gohugo.io/functions/where/#mainsections
+mainSections = ["blog"] # see config details here https://gohugo.io/functions/where/#mainsections
 
 # Label Non inline images on an article body
 figurePositionShow = false # toggle on or off globally
@@ -103,7 +103,7 @@ languageMenuName = "🌐"
 # comments = false
 
 # Activate meta ld+json for blog
-blogDir = "post"
+blogDir = "blog"
 
 # Enable or disable Utterances (https://github.com/utterance/utterances) Github Issue-Based Commenting
```

### Viele Menüs ausblenden

```diff
diff --git a/my-hugo-site/config/_default/menus/menu.de.toml b/my-hugo-site/config/_default/menus/menu.de.toml
index 9d6bc81..be39dd3 100644
--- a/my-hugo-site/config/_default/menus/menu.de.toml
+++ b/my-hugo-site/config/_default/menus/menu.de.toml
@@ -1,31 +1,31 @@
-[[main]]
-  name = "Home"
-  url = ""
-  weight = -110
+#[[main]]
+#  name = "Home"
+#  url = ""
+#  weight = -110
 
-[[main]]
-  name = "Archives"
-  url = "post/rich-content/"
-  weight = -109
+#[[main]]
+#  name = "Archives"
+#  url = "post/rich-content/"
+#  weight = -109
 
 # Submenus are done this way: parent -> identifier
-[[main]]
-  name = "Links"
-  identifier = "Links"
-  weight = -108
-[[main]]
-  parent = "Links"
-  name = "LinkedIn"
-  url = "https://www.linkedin.com/"
-[[main]]
-  parent = "Links"
-  name = "Twitter"
-  url = "https://twitter.com/"
-
-[[main]]
-  name = "About"
-  url = "about/"
-  weight = -107
+#[[main]]
+#  name = "Links"
+#  identifier = "Links"
+#  weight = -108
+#[[main]]
+#  parent = "Links"
+#  name = "LinkedIn"
+#  url = "https://www.linkedin.com/"
+#[[main]]
+#  parent = "Links"
+#  name = "Twitter"
+#  url = "https://twitter.com/"
+#
+#[[main]]
+#  name = "About"
+#  url = "about/"
+#  weight = -107
 
 # social menu links
 
diff --git a/my-hugo-site/config/_default/menus/menu.en.toml b/my-hugo-site/config/_default/menus/menu.en.toml
index 9d6bc81..3b60b33 100644
--- a/my-hugo-site/config/_default/menus/menu.en.toml
+++ b/my-hugo-site/config/_default/menus/menu.en.toml
@@ -1,31 +1,31 @@
-[[main]]
-  name = "Home"
-  url = ""
-  weight = -110
-
-[[main]]
-  name = "Archives"
-  url = "post/rich-content/"
-  weight = -109
+#[[main]]
+#  name = "Home"
+#  url = ""
+#  weight = -110
+#
+#[[main]]
+#  name = "Archives"
+#  url = "post/rich-content/"
+#  weight = -109
 
 # Submenus are done this way: parent -> identifier
-[[main]]
-  name = "Links"
-  identifier = "Links"
-  weight = -108
-[[main]]
-  parent = "Links"
-  name = "LinkedIn"
-  url = "https://www.linkedin.com/"
-[[main]]
-  parent = "Links"
-  name = "Twitter"
-  url = "https://twitter.com/"
-
-[[main]]
-  name = "About"
-  url = "about/"
-  weight = -107
+#[[main]]
+#  name = "Links"
+#  identifier = "Links"
+#  weight = -108
+#[[main]]
+#  parent = "Links"
+#  name = "LinkedIn"
+#  url = "https://www.linkedin.com/"
+#[[main]]
+#  parent = "Links"
+#  name = "Twitter"
+#  url = "https://twitter.com/"
+#
+#[[main]]
+#  name = "About"
+#  url = "about/"
+#  weight = -107
 
 # social menu links
```

### Hinweis auf Github

```diff
diff --git a/my-hugo-site/config/_default/params.toml b/my-hugo-site/config/_default/params.toml
index f6e5907..c474eaa 100644
--- a/my-hugo-site/config/_default/params.toml
+++ b/my-hugo-site/config/_default/params.toml
@@ -89,9 +89,9 @@ enforceLightMode = false
 # customize footer icon. see issue https://github.com/chipzoller/hugo-clarity/issues/77
 footerLogo = "images/stuttgart.svg"
 
-# Customize Sidebar Disclaimer Text
-# sidebardisclaimer = true
-# disclaimerText = "The opinions expressed on this site are my own personal opinions and do not represent my employer’s view in any way."
+# Customize Sidebar Disclaimer Text - es geht nur Text, kein Markdown oder HTML
+sidebardisclaimer = true
+disclaimerText = "Diese Webseite wird bereitgestellt auf und durch Github"
 
 # Text for the languages menu.
```

### Sprachmenü deaktivieren

Bislang sieht die Seite auf Englisch sehr leer aus. Also
deaktiviere ich das Sprachmenü und konzentriere mich auf Deutsch:

```diff
----------------- my-hugo-site/config/_default/languages.toml -----------------
index f9c6b7e..f27af7a 100644
@@ -2,9 +2,9 @@
   title = "Ulis Welt ... da läuft was"
   LanguageName = "Deutsch"
   weight = 1
-[en]
-  title = "Uli's world ... there's something going on"
-  LanguageName = "English"
-  weight = 2
+#[en]
+#  title = "Uli's world ... there's something going on"
+#  LanguageName = "English"
+#  weight = 2
 
   # tip: assign the default language the lowest Weight
\ No newline at end of file

------------------- my-hugo-site/config/_default/params.toml -------------------
index c474eaa..b4c77f1 100644
@@ -94,7 +94,7 @@ sidebardisclaimer = true
 disclaimerText = "Diese Webseite wird bereitgestellt auf und durch Github"
 
 # Text for the languages menu.
-languageMenuName = "������"
+#languageMenuName = "������"
 
 # Title separator, default to |.
 # titleSeparator = "|"
```

### TODOs

#### Offen

- Logo+Motto oben links
- Home
- Suchen
- Bildbreite
- Textbreite
- Menübreite
- Menü: Aktiven Eintrag markieren
- Inhaltsverzeichnis
- Copyright + Lizenz

#### Erledigt

- Logo+Motto oben links
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
- JaneDoe (rechts)
- Neueste Artikel (rechts)
- Fusszeile

Test
----

```
hugo -D -E -F server
```

Browser: [http://localhost:1313](http://localhost:1313) öffnen

Mainroad vs. Clarity
--------------------

### Mainroad

![Eingangsseite - oben](images/mainroad/home-top.png)

![Eingangsseite - unten](images/mainroad/home-bottom.png)

![Blog](images/mainroad/blog.png)

![Über mich](images/mainroad/about.png)

![Inhaltsverzeichnis](images/mainroad/toc.png)

![Codeblock](images/mainroad/codeblock.png)

### Clarity

![Eingangsseite - oben](images/clarity/home-top.png)

![Eingangsseite - unten](images/clarity/home-bottom.png)

![Blog](images/clarity/blog.png)

![Über mich](images/clarity/about.png)


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

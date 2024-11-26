+++
date = '2024-11-28'
draft = true
title = 'Hugo: Letzte Änderung anzeigen'
categories = [ 'Hugo' ]
tags = [ 'hugo', 'mainroad' ]
+++

<!--
Hugo: Letzte Änderung anzeigen
==============================
-->

Manchmal passe ich Artikel und BlogPosts auf meiner Webseite
nachträglich an. Ich bemühe mich, innerhalb Dokumente die Änderungshistorie
zu dokumentieren (was wurde wann geändert?). Hier zeige ich,
wie man nachträgliche Änderungen auch in den Übersichten erkennen kann.

<!--more-->

Aktivierung "Zuletzt geändert"
------------------------------

```diff
diff --git a/my-hugo-site/hugo.toml b/my-hugo-site/hugo.toml
index 84b7c7d..7103dfb 100644
--- a/my-hugo-site/hugo.toml
+++ b/my-hugo-site/hugo.toml
@@ -6,6 +6,7 @@ pagination.pageSize = "10" # Number of posts per page
 theme = "mainroad"
 disqusShortname = "" # Enable comments by entering your Disqus shortname
 googleAnalytics = "" # Enable Google Analytics by entering your tracking id
+enableGitInfo   = true
 
 [Params.author]
   name = "John Doe"
```

Mit voriger Änderung wird der Zeitpunkt der letzten Änderung
via GIT ermittelt. Die Darstellung in den Übersichten
sieht dann so aus:

![Zuletzt geändert](images/zuletzt-geaendert.png?width=300)

"Zuletzt geändert" vor Datum der Erstveröffentlichung
-----------------------------------------------------

Manchmal bereite ich Artikel frühzeitig zur Veröffentlichung vor.
Beispielsweise habe ich nachfolgenden Artikel erstellt am 25.11.
zur Veröffentlichung am 27.11.:

![Vor Veröffentlichung](images/vor-veroeffentlichung.png?width=300)

Idealerweise wird "zuletzt geändert" nur angezeigt, wenn die Änderung
nach der Erstveröffentlichung erfolgt! Erreicht wird dies beim Theme
"mainroad" mit dieser Änderung:

```diff
diff --git a/my-hugo-site/themes/mainroad/layouts/partials/post_meta/date.html b/my-hugo-site/themes/mainroad/layouts/partials/post_meta/date.html
index 33055a5..f9bdd8d 100644
--- a/my-hugo-site/themes/mainroad/layouts/partials/post_meta/date.html
+++ b/my-hugo-site/themes/mainroad/layouts/partials/post_meta/date.html
@@ -4,7 +4,7 @@
        <time class="meta__text" datetime="{{ .Date.Format "2006-01-02T15:04:05Z07:00" }}">
                {{- .Date | dateFormat (.Site.Params.dateformat | default "January 02, 2006") -}}
        </time>
-       {{- if ne .Date .Lastmod }}
+       {{- if lt .Date .Lastmod }}
        <time class="meta__text" datetime="{{ .Lastmod.Format "2006-01-02T15:04:05Z07:00" }}">(
                {{- T "meta_lastmod" }}: {{ .Lastmod | dateFormat (.Site.Params.dateformat | default "January 02, 2006") -}}
        )</time>
```

"Zuletzt geändert" am Datum der Erstveröffentlichung
----------------------------------------------------

Wenn ich einen Artikel veröffentliche und dann am selben
Tag noch Änderungen vornehme, dann erscheint manchmal
die Anzeige "November 23, 2024 (Zuletzt geändert: November 23, 2024)",
also zweimal dasselbe Datum:

![gleiches-datum](images/gleiches-datum.png?width=300)

Das Problem kann man sicherlich irgendwie über Anpassungen am Mainroad-Theme
lösen. Mein pragmatischer Ansatz besteht im richtigen Setzen des Veröffentlichungsdatums:

```diff
diff --git a/my-hugo-site/content/blog/2024-11-23_github-oder-codeberg/index.md b/my-hugo-site/content/blog/2024-11-23_github-oder-codeberg/index.md
index e5ddcc1..0ed0230 100644
--- a/my-hugo-site/content/blog/2024-11-23_github-oder-codeberg/index.md
+++ b/my-hugo-site/content/blog/2024-11-23_github-oder-codeberg/index.md
@@ -1,5 +1,5 @@
 +++
-date = '2024-11-23'
+date = '2024-11-23T22:00:00'
 draft = false
 title = 'Github oder Codeberg oder ???'
 categories = [ 'Github' ]
```

Versionen
---------

Getestet mit

- hugo v0.136.5-46cc...
- Theme: mainroad, main, commit:13e04b3694ea2d20a68cfbfaea42a8c565079809

Historie
--------

- 2024-11-28: Erste Version

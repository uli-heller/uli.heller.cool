+++
date = '2024-11-20T19:08:37+01:00'
draft = true
title = '2024 11 20_start Mit Hugo'
+++

Mein Start mit Hugo
===================

Motivation
----------

Bislang habe ich Octopress benutzt, um meine Artikel und Hinweise
zu veröffentlichen. Octopress war mal "der heiße Scheiß", ist
mittlerweile aber ziemlich veraltet.

Viele Leute sind umgestiegen auf Jekyll. Das ist für mich nicht
super motivierend, weil

- Jekyll auch nicht super gut weiterentwickelt wird
- Jekyll eine Ruby-Installation voraussetzt und da kenne ich mich nicht aus

Hugo scheint sehr einfach zu sein, wird sehr aktiv weiterentwickelt
und von vielen Leuten genutzt. Warum nicht?

Ablauf
------

1. Hugo installieren, Test: `hugo version` -> hugo v0.136.5-46cc...

2. Grundinitialisierung: `hugo new site my-hugo-site`

3. Wechseln in's Hugo-Verzeichnis: `cd my-hugo-site`

4. Theme "mainroad" einspielen: `git clone https://github.com/vimux/mainroad.git themes/mainroad`
    - `rm -rf themes/mainroad/.git`

5. Test mit neuem Theme:

   ```
   echo "theme = 'mainroad'" >>hugo.toml
   hugo serve
   ```

   [Browser: http://localhost:1313](http://localhost:1313) -> sieht sehr
   schlicht aus!
   
6. Test mit dem Beispiel:

   ```
   cp -a themes/mainroad/exampleSite/* .
   mv config.toml hugo.toml
   hugo serve
   # Fehlermeldung -> kleinere Korrekturen
   ```

   [Browser: http://localhost:1313](http://localhost:1313) -> sieht etwas
   besser aus!

7. Ersten Artikel anlegen: `hugo new content blog/2024-11-20_start-mit-hugo.md`
   Danach: Artikel erweitern!

8. Alles in GIT abspeichern - leere Verzeichnisse erfordern besondere Aufmerksamkeit!

   - `find . -type d -empty|xargs -I{} touch {}/.gitkeep`
   - `git add .`
   - `git commit -m "Hugo - neu - mainroad" .`
   - `git push`

Notizen
-------

### Grundinitialisierung

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool$ hugo new site my-hugo-site
Congratulations! Your new Hugo site was created in /home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site.

Just a few more steps...

1. Change the current directory to /home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site.
2. Create or install a theme:
   - Create a new theme with the command "hugo new theme <THEMENAME>"
   - Or, install a theme from https://themes.gohugo.io/
3. Edit hugo.toml, setting the "theme" property to the theme name.
4. Create new content with the command "hugo new content <SECTIONNAME>/<FILENAME>.<FORMAT>".
5. Start the embedded web server with the command "hugo server --buildDrafts".

See documentation at https://gohugo.io/.
```

### Theme "mainroad" einspielen

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ git clone https://github.com/vimux/mainroad.git themes/mainroad
Klone nach 'themes/mainroad'...
remote: Enumerating objects: 2489, done.
remote: Counting objects: 100% (194/194), done.
remote: Compressing objects: 100% (118/118), done.
remote: Total 2489 (delta 96), reused 143 (delta 64), pack-reused 2295 (from 1)
Empfange Objekte: 100% (2489/2489), 1.61 MiB | 2.44 MiB/s, fertig.
Löse Unterschiede auf: 100% (1454/1454), fertig.

uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ rm -rf themes/mainroad/.git

uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ git add themes/mainroad/

uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ git commit -m "Theme 'mainroad'" .
[main 070f948] Theme 'mainroad'
 104 files changed, 14059 insertions(+)
 create mode 100644 my-hugo-site/themes/mainroad/.browserslistrc
...
```

### Test mit dem Beispiel

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ hugo serve
WARN  deprecated: site config key paginate was deprecated in Hugo v0.128.0 and will be removed in a future release. Use pagination.pagerSize instead.
Watching for changes in /home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/{archetypes,assets,content,data,i18n,layouts,static,themes}
Watching for config changes in /home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/hugo.toml
Start building sites … 
hugo v0.136.5-46cccb021bc6425455f4eec093f5cc4a32f1d12c+extended linux/amd64 BuildDate=2024-10-24T12:26:27Z VendorInfo=gohugoio

ERROR deprecated: .Site.Author was deprecated in Hugo v0.124.0 and will be removed in Hugo 0.137.0. Implement taxonomy 'author' or use .Site.Params.Author instead.
Built in 41 ms
Error: error building site: logged 1 error(s)
```

Korrektur:

```diff

diff -u themes/mainroad/exampleSite/config.toml hugo.toml 
--- themes/mainroad/exampleSite/config.toml	2024-11-21 00:08:05.289738324 +0100
+++ hugo.toml	2024-11-21 00:21:07.265500676 +0100
@@ -1,12 +1,12 @@
 baseurl = "/"
 title = "Mainroad"
 languageCode = "en-us"
-paginate = "10" # Number of posts per page
+pagination.pageSize = "10" # Number of posts per page
 theme = "mainroad"
 disqusShortname = "" # Enable comments by entering your Disqus shortname
 googleAnalytics = "" # Enable Google Analytics by entering your tracking id
 
-[Author]
+[Params.author]
   name = "John Doe"
   bio = "John Doe's true identity is unknown. Maybe he is a successful blogger or writer. Nobody knows it."
   avatar = "img/avatar.png"
```

### Ersten Artikel anlegen

```
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ hugo new content blog/2024-11-20_start-mit-hugo.md 
Content "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/content/blog/2024-11-20_start-mit-hugo.md" created
```

### Alles in GIT abspeichern

```
uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ find . -type d -empty|xargs -I{} touch {}/.gitkeep

uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ git add .

uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ git commit -m "Hugo - neu - mainroad" .
[hugo-mainroad e89c5c4] Hugo - neu - mainroad
 9 files changed, 8 insertions(+)
 create mode 100644 my-hugo-site/archetypes/default.md
 create mode 100644 my-hugo-site/assets/.gitkeep
 create mode 100644 my-hugo-site/content/.gitkeep
...

uli@ulicsl:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ git push
Objekte aufzählen: 151, fertig.
Zähle Objekte: 100% (151/151), fertig.
Delta-Kompression verwendet bis zu 16 Threads.
Komprimiere Objekte: 100% (118/118), fertig.
Schreibe Objekte: 100% (150/150), 235.24 KiB | 2.24 MiB/s, fertig.
...
```

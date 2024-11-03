Erste Experimente mit Hugo
==========================

Installation
------------

Ich richte mich grob nach
[Hugo - Installation](https://gohugo.io/installation/linux/).
Mein Ziel ist die Installation der ExtendedEdition.

Vorabtests:

- Git: `git --version` -> git version 2.47.0
- Go: `go version` -> go version go1.23.2 linux/amd64
- Dart Sass: Lasse ich weg!

Hugo herunterladen:

- [Hugo - Downloads](https://github.com/gohugoio/hugo/releases/latest)
- [Hugo - 0.136.5](https://github.com/gohugoio/hugo/releases/download/v0.136.5/hugo_extended_0.136.5_linux-amd64.tar.gz)
- Danach: Virencheck etc - sieht alles gut aus!
- Auspacken, PATH erweitern, Test: `hugo version` -> hugo v0.136.5-46cc...

Erste Tests
-----------

```
uli@ulicsl:~/git/uli.heller.cool/hugo$ hugo version
hugo v0.136.5-46cccb021bc6425455f4eec093f5cc4a32f1d12c+extended linux/amd64 BuildDate=2024-10-24T12:26:27Z VendorInfo=gohugoio

uli@ulicsl:~/git/uli.heller.cool/hugo$ hugo new site quickstart
Congratulations! Your new Hugo site was created in /home/uli/git/uli.heller.cool/hugo/quickstart.
...

uli@ulicsl:~/git/uli.heller.cool/hugo/quickstart$ git clone https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke
Klone nach 'themes/ananke'...
remote: Enumerating objects: 3688, done.
remote: Counting objects: 100% (1443/1443), done.
...

uli@ulicsl:~/git/uli.heller.cool/hugo/quickstart$ echo "theme = 'ananke'" >> hugo.toml

uli@ulicsl:~/git/uli.heller.cool/hugo/quickstart$ hugo server
Watching for changes in /home/uli/git/uli.heller.cool/hugo/quickstart/{archetypes,assets,content,data,i18n,layouts,static,themes}
Watching for config changes in /home/uli/git/uli.heller.cool/hugo/quickstart/hugo.toml, /home/uli/git/uli.heller.cool/hugo/quickstart/themes/ananke/config/_default
...
Running in Fast Render Mode. For full rebuilds on change: hugo server --disableFastRender
Web Server is available at http://localhost:1313/ (bind address 127.0.0.1) 
Press Ctrl+C to stop
```

Wenn ich danach den [angegebenen Link](http://localhost:1313/)
im Browser öffne, dann erscheint ein Grundgerüst einer Webseite.

Zusatzhinweise:

- Ohne "Theme" erscheint nur eine Fehlermeldung
- In der Anleitung [Hugo - Getting started - Quick start](https://gohugo.io/getting-started/quick-start/) wird das "Theme" als Git-Submodule eingespielt. Ich mach das per `git clone`!

### Notizen

#### Ausgaben von "git new site"

```
uli@ulicsl:~/git/uli.heller.cool/hugo$ hugo new site quickstart
Congratulations! Your new Hugo site was created in /home/uli/git/uli.heller.cool/hugo/quickstart.

Just a few more steps...

1. Change the current directory to /home/uli/git/uli.heller.cool/hugo/quickstart.
2. Create or install a theme:
   - Create a new theme with the command "hugo new theme <THEMENAME>"
   - Or, install a theme from https://themes.gohugo.io/
3. Edit hugo.toml, setting the "theme" property to the theme name.
4. Create new content with the command "hugo new content <SECTIONNAME>/<FILENAME>.<FORMAT>".
5. Start the embedded web server with the command "hugo server --buildDrafts".

See documentation at https://gohugo.io/.
```

Links
-----

- [Hugo - Getting started - Quick start](https://gohugo.io/getting-started/quick-start/)
- [Hugo - Installation](https://gohugo.io/installation/linux/)
  - [Hugo - Downloads](https://github.com/gohugoio/hugo/releases/latest)
  
Historie
--------

- 2024-11-03 - Erste Version
